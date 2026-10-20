import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../screens/reader_page.dart';
import '../../theme/app_theme.dart';

class SearchBox extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String initialValue;

  const SearchBox({
    super.key,
    this.hint = 'Search for your files...',
    this.onChanged,
    this.onSubmitted,
    this.initialValue = '',
  });

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant SearchBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.value = TextEditingValue(
        text: widget.initialValue,
        selection: TextSelection.collapsed(
          offset: widget.initialValue.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    onChanged: widget.onChanged,
    onSubmitted: widget.onSubmitted,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: widget.hint,
      prefixIcon: const Icon(Icons.search, size: 21),
    ),
  );
}

class PdfIcon extends StatelessWidget {
  final Book book;

  const PdfIcon({super.key, required this.book});

  @override
  Widget build(BuildContext context) => Container(
    width: 45,
    height: 52,
    decoration: BoxDecoration(
      color: book.color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
  );
}

class ProgressBookCard extends StatelessWidget {
  final Book book;
  final int? currentPage;
  final VoidCallback? onTap;

  const ProgressBookCard({
    super.key,
    required this.book,
    this.currentPage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final page = currentPage ?? book.page;
    final displayPage = page + 1;
    final progress = book.total == 0
        ? null
        : (displayPage / book.total).clamp(0.0, 1.0);

    return InkWell(
    borderRadius: BorderRadius.circular(15),
    onTap:
        onTap ??
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReaderPage(book: book)),
        ),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          PdfIcon(book: book),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${book.title}.pdf',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      book.total > 0
                          ? 'Page $displayPage / ${book.total}'
                          : 'Page $displayPage',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (progress != null) ...[
                      const Spacer(),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                if (progress != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class LibraryTile extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final bool? isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onRemove;

  const LibraryTile({
    super.key,
    required this.book,
    this.onTap,
    this.isFavorite,
    this.onFavorite,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap:
        onTap ??
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReaderPage(book: book)),
        ),
    child: Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          PdfIcon(book: book),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${book.title}.pdf',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${book.size}  •  ${book.date}',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onFavorite != null)
            IconButton(
              tooltip: isFavorite == true ? 'Remove favorite' : 'Add favorite',
              onPressed: onFavorite,
              icon: Icon(
                isFavorite == true ? Icons.favorite : Icons.favorite_border,
                color: isFavorite == true ? Colors.redAccent : muted,
                size: 20,
              ),
            ),
          if (onRemove != null)
            IconButton(
              tooltip: book.isLocalPdf ? 'Remove PDF' : 'Delete book',
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete_outline,
                color: muted,
                size: 20,
              ),
            ),
        ],
      ),
    ),
  );
}
