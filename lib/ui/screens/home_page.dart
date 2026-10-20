import 'package:flutter/material.dart';
import '../../data/app_data.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/book_view_model.dart';
import 'reader_page.dart';
import '../widgets/book_widgets.dart';

class HomePage extends StatelessWidget {
  final BookViewModel viewModel;
  final VoidCallback? onSeeAll;
  final VoidCallback? onSearch;

  const HomePage({
    super.key,
    required this.viewModel,
    this.onSeeAll,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'BookVerse',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Notifications'),
                    content: Text(
                      viewModel.dataError ??
                          "You're all caught up. Reading reminders will appear here.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
                icon: Icon(
                  Icons.notifications_none,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SearchBox(
            hint: 'Search for PDFs, books, subjects...',
            initialValue: viewModel.searchQuery,
            onChanged: (v) => viewModel.setSearchQuery(v),
            onSubmitted: (v) {
              viewModel.setSearchQuery(v);
              onSearch?.call();
            },
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.58,
            children: readingStats.map((stat) {
              final value = switch (stat.label) {
                'Recent' => '${viewModel.readingHistory.length} books',
                'Favorites' => '${viewModel.favoriteIds.length} saved',
                'Notes' => '${viewModel.notes.length} notes',
                'Library' => '${viewModel.books.length} books',
                _ => stat.value,
              };
              return StatCard(
                stat.label,
                value,
                stat.icon,
                stat.color,
                stat.iconColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Continue Reading',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (viewModel.dataError != null)
            Text(
              viewModel.dataError!,
              style: const TextStyle(color: Colors.red),
            ),
          if (viewModel.isLoadingBooks)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.recentBooks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'Open a book from your library and it will appear here.',
                style: TextStyle(color: muted),
              ),
            )
          else
            ...viewModel.recentBooks.take(3).map(
              (book) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: ProgressBookCard(
                  book: book,
                  currentPage: viewModel.readingPage(book),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReaderPage(
                        book: book,
                        viewModel: viewModel,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}


class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color background, iconColor;

  const StatCard(
    this.title,
    this.value,
    this.icon,
    this.background,
    this.iconColor, {
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const Spacer(),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 10.5, color: muted)),
      ],
    ),
  );
}
