import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/book.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/book_view_model.dart';
import 'reader_page.dart';
import '../widgets/book_widgets.dart';

class LibraryPage extends StatefulWidget {
  final BookViewModel viewModel;

  const LibraryPage({super.key, required this.viewModel});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _isImportingPdf = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isImportingPdf ? null : () => _showAddOptions(context),
        icon: _isImportingPdf
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: Text(_isImportingPdf ? 'Importing PDF' : 'Add to library'),
      ),
      body: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) {
          final filtered = widget.viewModel.filteredBooks;
          final categories = {
            'All',
            ...widget.viewModel.books.map((book) => book.category),
          }.toList();

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 90),
              children: [
                Text(
                  'My Library',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 15),
                SearchBox(
                  initialValue: widget.viewModel.searchQuery,
                  onChanged: widget.viewModel.setSearchQuery,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: categories.map((filter) {
                      final selected =
                          widget.viewModel.selectedCategory == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          selected: selected,
                          onSelected: (_) =>
                              widget.viewModel.setCategory(filter),
                          selectedColor: primary,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surface,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                if (widget.viewModel.dataError != null)
                  Text(
                    widget.viewModel.dataError!,
                    style: const TextStyle(color: Colors.red),
                  )
                else if (widget.viewModel.isLoadingBooks)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (widget.viewModel.books.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        'No books yet. Add the first book to Firestore.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted),
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        'No books match your search.',
                        style: TextStyle(color: muted),
                      ),
                    ),
                  )
                else
                  ...filtered.map(
                    (book) => LibraryTile(
                      book: book,
                      isFavorite: widget.viewModel.favoriteIds.contains(
                        book.id,
                      ),
                      onFavorite: () => _toggleFavorite(context, book),
                      onRemove: () =>
                          _confirmAndRemoveBook(context, widget.viewModel, book),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderPage(
                            book: book,
                            viewModel: widget.viewModel,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddOptions(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Import a PDF from this device'),
              subtitle: const Text('Keep a private copy in your library'),
              onTap: () => Navigator.pop(context, 'local'),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Add a book or PDF link'),
              subtitle: const Text('Add details and an optional online PDF'),
              onTap: () => Navigator.pop(context, 'online'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (action == 'local') {
      await _importPdf();
    } else if (action == 'online') {
      await _showAddBookDialog(context);
    }
  }

  Future<void> _importPdf() async {
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: 'Choose a PDF',
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (file == null) return;
      if (!mounted) return;
      setState(() => _isImportingPdf = true);
      try {
        final metadata = await _showLocalPdfDetails(file.name);
        if (!mounted || metadata == null) return;
        await widget.viewModel.importLocalPdf(
          file,
          title: metadata['title'],
          author: metadata['author'],
          category: metadata['category'],
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${file.name} added to your library.')),
        );
      } finally {
        if (mounted) setState(() => _isImportingPdf = false);
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not import PDF: $error')));
      }
    }
  }

  Future<Map<String, String>?> _showLocalPdfDetails(String fileName) async {
    final title = TextEditingController(
      text: fileName.replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), ''),
    );
    final author = TextEditingController();
    final category = TextEditingController(text: 'Local PDFs');
    try {
      return await showDialog<Map<String, String>>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('PDF details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Title (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: author,
                  decoration: const InputDecoration(
                    labelText: 'Author (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: category,
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    hintText: 'Local PDFs',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, {
                'title': title.text.trim(),
                'author': author.text.trim(),
                'category': category.text.trim(),
              }),
              child: const Text('Import PDF'),
            ),
          ],
        ),
      );
    } finally {
      title.dispose();
      author.dispose();
      category.dispose();
    }
  }

  Future<void> _showAddBookDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final title = TextEditingController();
    final author = TextEditingController();
    final category = TextEditingController(text: 'Educational');
    final description = TextEditingController();
    final content = TextEditingController();
    final pdfUrl = TextEditingController();
    final totalPages = TextEditingController();

    try {
      final result = await showDialog<Book>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add a book'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _bookField(title, 'Book title'),
                    _bookField(author, 'Author'),
                    _bookField(category, 'Category'),
                    _bookField(description, 'Description', maxLines: 3),
                    _bookField(
                      content,
                      'Reading text (optional)',
                      maxLines: 5,
                      required: false,
                    ),
                    _bookField(
                      pdfUrl,
                      'PDF download URL (optional)',
                      required: false,
                    ),
                    _bookField(
                      totalPages,
                      'Total pages (optional)',
                      keyboardType: TextInputType.number,
                      required: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(
                  dialogContext,
                  Book(
                    id: '',
                    title: title.text.trim(),
                    author: author.text.trim(),
                    size: '',
                    date: DateTime.now().toIso8601String().split('T').first,
                    category: category.text.trim(),
                    description: description.text.trim(),
                    content: content.text.trim(),
                    pdfUrl: pdfUrl.text.trim(),
                    page: 0,
                    total: int.tryParse(totalPages.text.trim()) ?? 0,
                    color: const Color(0xFF536DFE),
                  ),
                );
              },
              child: const Text('Save book'),
            ),
          ],
        ),
      );

      if (result == null) return;
      try {
        await widget.viewModel.addBook(result);
      } on FirebaseException catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Could not save book.')),
          );
        }
      }
    } finally {
      title.dispose();
      author.dispose();
      category.dispose();
      description.dispose();
      content.dispose();
      pdfUrl.dispose();
      totalPages.dispose();
    }
  }

  Widget _bookField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool required = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Required';
          }
          if (label.startsWith('Total pages') &&
              value != null &&
              value.trim().isNotEmpty &&
              int.tryParse(value.trim()) == null) {
            return 'Enter a whole number';
          }
          if (label == 'PDF download URL (optional)' &&
              value != null &&
              value.trim().isNotEmpty &&
              (!{
                    'http',
                    'https',
                  }.contains(Uri.tryParse(value.trim())?.scheme) ||
                  Uri.tryParse(value.trim())?.host.isEmpty != false)) {
            return 'Enter a valid URL';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, Book book) async {
    try {
      await widget.viewModel.toggleFavorite(book);
    } on FirebaseException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Could not update favorite.'),
          ),
        );
      }
    }
  }
}

Future<void> _confirmAndRemoveBook(
  BuildContext context,
  BookViewModel viewModel,
  Book book,
) async {
  final isLocal = book.isLocalPdf;
  final remove = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isLocal ? 'Remove PDF?' : 'Delete book?'),
      content: Text(
        isLocal
            ? '"${book.title}" will be removed from this device.'
            : '"${book.title}" will be permanently deleted from your library.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(isLocal ? 'Remove' : 'Delete'),
        ),
      ],
    ),
  );
  if (remove != true || !context.mounted) return;

  try {
    await viewModel.removeBook(book);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLocal ? 'PDF removed from this device.' : 'Book deleted.'),
        ),
      );
    }
  } on FirebaseException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Could not delete this book.'),
        ),
      );
    }
  } on Exception catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove this book: $error')),
      );
    }
  }
}

class SearchPage extends StatefulWidget {
  final BookViewModel viewModel;

  const SearchPage({super.key, required this.viewModel});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final query = widget.viewModel.searchQuery.trim().toLowerCase();
        final matchingBooks = widget.viewModel.books.where((book) {
          if (query.isEmpty) return true;
          return book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query) ||
              book.category.toLowerCase().contains(query) ||
              book.description.toLowerCase().contains(query);
        }).toList();
        final matchingNotes = widget.viewModel.notes.where((note) {
          if (query.isEmpty) return true;
          return (note['title'] as String? ?? '').toLowerCase().contains(
                query,
              ) ||
              (note['content'] as String? ?? '').toLowerCase().contains(query);
        }).toList();
        final books = switch (_filter) {
          'Bookmarks' =>
            matchingBooks
                .where(
                  (book) => widget.viewModel.bookmarkedIds.contains(book.id),
                )
                .toList(),
          'Notes' => <Book>[],
          _ => matchingBooks,
        };

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            children: [
              Text(
                'Search',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 18),
              SearchBox(
                hint: 'Search books, PDFs, notes...',
                initialValue: widget.viewModel.searchQuery,
                onChanged: (v) => widget.viewModel.setSearchQuery(v),
                onSubmitted: (v) => widget.viewModel.setSearchQuery(v),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 7,
                children: ['All', 'Files', 'Notes', 'Bookmarks']
                    .map(
                      (x) => ChoiceChip(
                        label: Text(x, style: const TextStyle(fontSize: 11)),
                        selected: _filter == x,
                        onSelected: (_) => setState(() => _filter = x),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              if (widget.viewModel.dataError != null)
                Text(
                  widget.viewModel.dataError!,
                  style: const TextStyle(color: Colors.red),
                )
              else if (_filter == 'Notes' && matchingNotes.isEmpty)
                const Text(
                  'No matching notes found.',
                  style: TextStyle(color: muted),
                )
              else if (_filter == 'Notes')
                ...matchingNotes.map(
                  (note) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.sticky_note_2_outlined),
                      title: Text(note['title'] as String? ?? 'Book note'),
                      subtitle: Text(note['content'] as String? ?? ''),
                      onTap: () {
                        final bookId = note['bookId'] as String?;
                        final matching = widget.viewModel.books.where(
                          (book) => book.id == bookId,
                        );
                        if (matching.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReaderPage(
                                book: matching.first,
                                viewModel: widget.viewModel,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                )
              else if (books.isEmpty)
                Text(
                  _filter == 'Bookmarks'
                      ? 'No matching bookmarks found.'
                      : 'No matching books found in the library.',
                  style: const TextStyle(color: muted),
                )
              else
                ...books.map(
                  (book) => LibraryTile(
                    book: book,
                    isFavorite: widget.viewModel.favoriteIds.contains(book.id),
                    onFavorite: () => _toggleFavorite(context, book),
                    onRemove: () =>
                        _confirmAndRemoveBook(context, widget.viewModel, book),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReaderPage(book: book, viewModel: widget.viewModel),
                      ),
                    ),
                  ),
                ),
              if (_filter == 'All' && matchingNotes.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text(
                  'Notes',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                ...matchingNotes.map(
                  (note) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.sticky_note_2_outlined),
                      title: Text(note['title'] as String? ?? 'Book note'),
                      subtitle: Text(note['content'] as String? ?? ''),
                      onTap: () {
                        final bookId = note['bookId'] as String?;
                        final matching = widget.viewModel.books.where(
                          (book) => book.id == bookId,
                        );
                        if (matching.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReaderPage(
                                book: matching.first,
                                viewModel: widget.viewModel,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite(BuildContext context, Book book) async {
    try {
      await widget.viewModel.toggleFavorite(book);
    } on FirebaseException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Could not update favorite.'),
          ),
        );
      }
    }
  }
}
