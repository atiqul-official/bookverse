import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../models/book.dart';

class PdfDocumentView extends StatefulWidget {
  const PdfDocumentView({
    super.key,
    required this.book,
    required this.initialPage,
    required this.onPageChanged,
    required this.onDocumentReady,
    required this.bouncyScrolling,
  });

  final Book book;
  final int initialPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onDocumentReady;
  final bool bouncyScrolling;

  @override
  State<PdfDocumentView> createState() => PdfDocumentViewState();
}

class PdfDocumentViewState extends State<PdfDocumentView> {
  final PdfViewerController _controller = PdfViewerController();
  PdfTextSearcher? _searcher;
  VoidCallback? _removeSearchListener;
  int? pageCount;

  bool get isReady => _searcher != null;

  void goToPage(int page) => _controller.setCurrentPageNumber(page);

  @override
  void dispose() {
    _removeSearchListener?.call();
    _searcher?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localPath = widget.book.localPdfPath;
    final localBytes = widget.book.localPdfBytes;
    final uri = Uri.tryParse(widget.book.pdfUrl);
    final isRemotePdf =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;

    if (localPath == null && localBytes == null && !isRemotePdf) {
      return const Center(child: Text('This book does not have a PDF file.'));
    }

    final params = PdfViewerParams(
      backgroundColor: const Color(0xFFEEF0F5),
      onViewerReady: (document, controller) {
        if (!mounted) return;
        if (_searcher != null) return;
        setState(() {
          pageCount = document.pages.length;
          _searcher = PdfTextSearcher(controller);
          _removeSearchListener = _searcher!.addListener(() {
            if (mounted) setState(() {});
          });
        });
        widget.onDocumentReady(document.pages.length);
      },
      onPageChanged: (pageNumber) {
        if (pageNumber != null) widget.onPageChanged(pageNumber);
      },
      scrollPhysics: widget.bouncyScrolling
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
      pagePaintCallbacks: _searcher == null
          ? const []
          : [_searcher!.pageTextMatchPaintCallback],
      errorBannerBuilder: (context, error, stackTrace, documentRef) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not open this PDF.\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );

    if (localPath != null) {
      return PdfViewer.file(
        localPath,
        controller: _controller,
        initialPageNumber: widget.initialPage,
        params: params,
      );
    }
    if (localBytes != null) {
      return PdfViewer.data(
        localBytes,
        sourceName: widget.book.id,
        controller: _controller,
        initialPageNumber: widget.initialPage,
        params: params,
      );
    }
    return PdfViewer.uri(
      uri!,
      controller: _controller,
      initialPageNumber: widget.initialPage,
      params: params,
    );
  }

  Future<void> showContents(BuildContext context) async {
    if (!_controller.isReady) {
      _showMessage(context, 'The PDF is still loading.');
      return;
    }
    List<PdfOutlineNode>? items;
    try {
      items = await _controller.useDocument((document) {
        return document.loadOutline();
      });
    } on Exception catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Could not load the table of contents: $error');
      }
      return;
    }
    if (!context.mounted) return;
    final outlineItems = items;
    if (outlineItems == null || outlineItems.isEmpty) {
      _showMessage(context, 'This PDF has no table of contents.');
      return;
    }

    final entries = <PdfOutlineNode>[];
    void addEntries(List<PdfOutlineNode> nodes) {
      for (final node in nodes) {
        entries.add(node);
        addEntries(node.children);
      }
    }

    addEntries(outlineItems);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            const ListTile(
              title: Text(
                'Table of contents',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ...entries.map(
              (entry) => ListTile(
                title: Text(entry.title),
                contentPadding: EdgeInsets.only(
                  left: (20 + 16 * _depthOf(entry, outlineItems)).toDouble(),
                  right: 20,
                ),
                onTap: entry.dest == null
                    ? null
                    : () {
                        _controller.setCurrentPageNumber(
                          entry.dest!.pageNumber,
                        );
                        Navigator.pop(context);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _depthOf(PdfOutlineNode target, List<PdfOutlineNode> roots) {
    int? findDepth(List<PdfOutlineNode> nodes, int depth) {
      for (final node in nodes) {
        if (identical(node, target)) return depth;
        final childDepth = findDepth(node.children, depth + 1);
        if (childDepth != null) return childDepth;
      }
      return null;
    }

    return findDepth(roots, 0) ?? 0;
  }

  Future<void> showSearch(BuildContext context) async {
    final searcher = _searcher;
    if (searcher == null) {
      _showMessage(context, 'The PDF is still loading.');
      return;
    }
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AnimatedBuilder(
        animation: searcher,
        builder: (context, _) => AlertDialog(
          title: const Text('Find in PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  searcher.startTextSearch(
                    value,
                    searchImmediately: true,
                  );
                },
                decoration: const InputDecoration(
                  hintText: 'Search this document',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                searcher.isSearching
                    ? 'Searching…'
                    : '${searcher.matches.length} matches',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => searcher.goToPrevMatch(),
              child: const Text('Previous'),
            ),
            TextButton(
              onPressed: () => searcher.goToNextMatch(),
              child: const Text('Next'),
            ),
            FilledButton(
              onPressed: () {
                searcher.startTextSearch(
                  controller.text,
                  searchImmediately: true,
                );
              },
              child: const Text('Find'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
