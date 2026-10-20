import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/book.dart';
import '../../viewmodels/book_view_model.dart';
import '../widgets/pdf_document_view.dart';

class ReaderPage extends StatefulWidget {
  final Book book;
  final BookViewModel? viewModel;

  const ReaderPage({super.key, required this.book, this.viewModel});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late int currentPage;
  int? pdfPageCount;
  final noteController = TextEditingController();
  final pdfViewKey = GlobalKey<PdfDocumentViewState>();
  Timer? _progressSaveTimer;
  Timer? _noteSaveTimer;

  @override
  void initState() {
    super.initState();
    currentPage =
        widget.viewModel?.readingPage(widget.book) ?? widget.book.page;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistProgress(currentPage);
    });
  }

  @override
  void dispose() {
    _progressSaveTimer?.cancel();
    _noteSaveTimer?.cancel();
    noteController.dispose();
    super.dispose();
  }

  void _scheduleNoteSave(String value) {
    _noteSaveTimer?.cancel();
    if (widget.viewModel?.autoSaveNotes != true || value.trim().isEmpty) {
      return;
    }
    _noteSaveTimer = Timer(const Duration(milliseconds: 800), () async {
      try {
        await widget.viewModel?.saveNote(widget.book, value.trim());
      } on FirebaseException catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message ?? 'Could not save this note.'),
            ),
          );
        }
      }
    });
  }

  void _onPdfPageChanged(int pageNumber) {
    setState(() {
      currentPage = pageNumber - 1;
      pdfPageCount = pdfViewKey.currentState?.pageCount;
    });
    _progressSaveTimer?.cancel();
    _progressSaveTimer = Timer(
      const Duration(milliseconds: 700),
      () => _persistProgress(currentPage),
    );
  }

  void _onPdfDocumentReady(int pageCount) {
    if (mounted) setState(() => pdfPageCount = pageCount);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFEEF0F5),
    appBar: AppBar(
      backgroundColor: const Color(0xFF20242C),
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.book.title}.pdf',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          if (widget.book.hasPdf &&
              (widget.viewModel?.showPageNumber ?? true))
            Text(
              '${currentPage + 1} / ${pdfPageCount ?? widget.book.total}',
              style: const TextStyle(fontSize: 9, color: Colors.white70),
            ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Open PDF link',
          onPressed: widget.book.pdfUrl.isEmpty ? null : _openPdf,
          icon: const Icon(Icons.open_in_new),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: widget.book.hasPdf
              ? PdfDocumentView(
                  key: pdfViewKey,
                  book: widget.book,
                  initialPage: currentPage + 1,
                  onPageChanged: _onPdfPageChanged,
                  onDocumentReady: _onPdfDocumentReady,
                  bouncyScrolling: widget.viewModel?.pageTurnAnimation ?? true,
                )
              : Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  padding: const EdgeInsets.fromLTRB(25, 28, 25, 25),
                  color: const Color(0xFFFFFEFB),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.book.content.isNotEmpty
                          ? widget.book.content
                          : widget.book.description,
                      style: TextStyle(
                        fontSize: widget.viewModel?.fontSize.toDouble() ?? 16,
                        height: 1.65,
                        color: Color(0xFF202124),
                      ),
                    ),
                  ),
                ),
        ),
        if (widget.book.hasPdf &&
            (widget.viewModel?.showReadingProgress ?? true) &&
            (pdfPageCount ?? widget.book.total) > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: [
                if (widget.viewModel?.showPageNumber ?? true)
                  Text('Page ${currentPage + 1}'),
                Expanded(
                  child: Slider(
                    min: 1,
                    max: (pdfPageCount ?? widget.book.total).toDouble(),
                    value: (currentPage + 1)
                        .clamp(1, pdfPageCount ?? widget.book.total)
                        .toDouble(),
                    onChanged: (value) {
                      final page = value.round();
                      if (pdfViewKey.currentState?.isReady == true) {
                        pdfViewKey.currentState?.goToPage(page);
                      } else {
                        setState(() => currentPage = page - 1);
                      }
                    },
                    onChangeEnd: (value) => _persistProgress(value.round() - 1),
                  ),
                ),
                if (widget.viewModel?.showPageNumber ?? true)
                  Text('${pdfPageCount ?? widget.book.total}'),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ReaderAction(Icons.list, 'Contents', () {
                if (pdfViewKey.currentState != null) {
                  pdfViewKey.currentState!.showContents(context);
                } else {
                  _showTextContents();
                }
              }),
              ReaderAction(
                widget.viewModel?.bookmarkedIds.contains(widget.book.id) == true
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                'Bookmark',
                () async {
                  if (widget.viewModel == null) return;
                  try {
                    await widget.viewModel!.toggleBookmark(widget.book);
                    if (mounted) setState(() {});
                  } on FirebaseException catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not update bookmark: $error'),
                        ),
                      );
                    }
                  }
                },
              ),
              ReaderAction(Icons.edit_note, 'Note', () => _noteDialog(context)),
              ReaderAction(Icons.search, 'Search', () {
                if (pdfViewKey.currentState != null) {
                  pdfViewKey.currentState!.showSearch(context);
                } else {
                  _searchText();
                }
              }),
              if (widget.book.pdfUrl.isNotEmpty && !widget.book.isLocalPdf)
                ReaderAction(Icons.open_in_new, 'PDF link', _openPdf),
            ],
          ),
        ),
      ],
    ),
  );

  void _showTextContents() {
    final headings = widget.book.content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.length > 2 && line.length < 80)
        .take(30)
        .toList();
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            const ListTile(
              title: Text(
                'Contents',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (headings.isEmpty)
              const ListTile(title: Text('No contents are available.'))
            else
              ...headings.map((heading) => ListTile(title: Text(heading))),
          ],
        ),
      ),
    );
  }

  Future<void> _searchText() async {
    final controller = TextEditingController();
    final query = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find in book'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search text'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Find'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (query == null || query.isEmpty || !mounted) return;
    final text = widget.book.content.isNotEmpty
        ? widget.book.content
        : widget.book.description;
    final count = RegExp(
      RegExp.escape(query),
      caseSensitive: false,
    ).allMatches(text).length;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$count matches in this book.')));
  }

  void _noteDialog(BuildContext context) {
    noteController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          onChanged: _scheduleNoteSave,
          decoration: InputDecoration(hintText: 'Write your note...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final content = noteController.text.trim();
              if (content.isEmpty || widget.viewModel == null) return;
              try {
                await widget.viewModel!.saveNote(widget.book, content);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } on FirebaseException catch (error) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        error.message ?? 'Could not save this note.',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPdf() async {
    final uri = Uri.tryParse(widget.book.pdfUrl);
    if (uri == null ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty) {
      _showPdfLinkError('This book does not have a valid web PDF link.');
      return;
    }
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        _showPdfLinkError('Could not open the PDF link.');
      }
    } on Exception catch (error) {
      _showPdfLinkError('Could not open the PDF link: $error');
    }
  }

  void _showPdfLinkError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _persistProgress(int page) async {
    if (widget.viewModel == null) return;
    try {
      await widget.viewModel!.addReadingHistory(widget.book, page);
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Could not save reading progress.'),
          ),
        );
      }
    }
  }
}

class ReaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ReaderAction(this.icon, this.label, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 9)),
        ],
      ),
    ),
  );
}
