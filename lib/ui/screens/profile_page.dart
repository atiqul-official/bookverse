import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/book.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/book_view_model.dart';
import 'reader_page.dart';

class ProfilePage extends StatelessWidget {
  final BookViewModel viewModel;

  const ProfilePage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xFFE7ECFF),
                  child: Icon(Icons.person, size: 48, color: primary),
                ),
                const SizedBox(height: 10),
                Text(
                  viewModel.userName?.isNotEmpty == true
                      ? viewModel.userName!
                      : 'BookVerse User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  viewModel.userEmail ?? '',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProfileMetric(
                  'Notes',
                  '${viewModel.notes.length}',
                  Icons.sticky_note_2_outlined,
                ),
                _ProfileMetric(
                  'Favorites',
                  '${viewModel.favoriteBooks.length}',
                  Icons.favorite_outline,
                ),
                _ProfileMetric(
                  'Books',
                  '${viewModel.books.length}',
                  Icons.menu_book_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ProfileRow(
            Icons.bookmark_outline,
            'Bookmarks & Notes',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookmarksPage(viewModel: viewModel),
              ),
            ),
          ),
          ProfileRow(
            Icons.download_outlined,
            'Downloads',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LocalPdfLibraryPage(viewModel: viewModel),
              ),
            ),
          ),
          ProfileRow(Icons.logout, 'Sign Out', () async {
            try {
              await viewModel.logout();
            } on FirebaseAuthException catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not sign out: $error')),
                );
              }
            }
          }),
          ProfileRow(
            Icons.settings_outlined,
            'Settings',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsPage(viewModel: viewModel),
              ),
            ),
          ),
          ProfileRow(
            Icons.info_outline,
            'About BookVerse',
            () => _showAbout(context),
          ),
        ],
      ),
    ),
  );
}

void _showAbout(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: 'BookVerse',
    applicationVersion: '1.0.0',
    applicationIcon: const Icon(Icons.menu_book_rounded, color: primary),
    children: const [
      Text(
        'A personal library for your study materials, with PDF reading, '
        'bookmarks, notes, and reading progress.',
      ),
    ],
  );
}

class _ProfileMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileMetric(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: primary, size: 22),
      const SizedBox(height: 8),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: muted, fontSize: 10)),
    ],
  );
}

class ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileRow(this.icon, this.title, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(13),
    ),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: primary),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
    ),
  );
}

class BookmarksPage extends StatelessWidget {
  final BookViewModel viewModel;

  const BookmarksPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) {
      final bookmarks = viewModel.bookmarkedBooks;
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Bookmarks & Notes',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Bookmarks',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (bookmarks.isEmpty)
              const ListTile(title: Text('No bookmarks yet'))
            else
              ...bookmarks.map(
                (book) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 7),
                  leading: const Icon(Icons.bookmark, color: primary),
                  title: Text(
                    book.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text('${book.author}\n${book.date}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReaderPage(book: book, viewModel: viewModel),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'Notes',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (viewModel.notes.isEmpty)
              const ListTile(title: Text('No saved notes yet'))
            else
              ...viewModel.notes.map(
                (note) => ListTile(
                  leading: const Icon(Icons.sticky_note_2_outlined),
                  title: Text(note['title'] as String? ?? 'Book note'),
                  subtitle: Text(note['content'] as String? ?? ''),
                  onTap: () {
                    final bookId = note['bookId'] as String?;
                    final matching = viewModel.books.where(
                      (book) => book.id == bookId,
                    );
                    if (matching.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderPage(
                            book: matching.first,
                            viewModel: viewModel,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}

class FavoritesPage extends StatelessWidget {
  final BookViewModel viewModel;

  const FavoritesPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Favorite Books')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: viewModel.favoriteBooks.isEmpty
            ? const [ListTile(title: Text('No favorite books yet'))]
            : viewModel.favoriteBooks
                  .map(
                    (book) => ListTile(
                      leading: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                      ),
                      title: Text(book.title),
                      subtitle: Text(book.author),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ReaderPage(book: book, viewModel: viewModel),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () => _toggleFavorite(context, book),
                      ),
                    ),
                  )
                  .toList(),
      ),
    ),
  );

  Future<void> _toggleFavorite(BuildContext context, Book book) async {
    try {
      await viewModel.toggleFavorite(book);
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

class ReadingHistoryPage extends StatelessWidget {
  final BookViewModel viewModel;

  const ReadingHistoryPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Reading History')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: viewModel.recentBooks.isEmpty
            ? const [ListTile(title: Text('Your reading history is empty'))]
            : viewModel.recentBooks
                  .map(
                    (book) => ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(book.title),
                      subtitle: Text(
                        'Page ${viewModel.readingPage(book)} of ${book.total}',
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ReaderPage(book: book, viewModel: viewModel),
                        ),
                      ),
                    ),
                  )
                  .toList(),
      ),
    ),
  );
}

class LocalPdfLibraryPage extends StatelessWidget {
  final BookViewModel viewModel;

  const LocalPdfLibraryPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) {
      final books = viewModel.books.where((book) => book.isLocalPdf).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Local PDFs')),
        body: books.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Text(
                    'PDFs imported from this device will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf, color: primary),
                      title: Text(book.title),
                      subtitle: Text('${book.size} • Stored on this device'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ReaderPage(book: book, viewModel: viewModel),
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: 'Remove local PDF',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeLocalPdf(context, book),
                      ),
                    ),
                  );
                },
              ),
      );
    },
  );

  Future<void> _removeLocalPdf(BuildContext context, Book book) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove PDF?'),
        content: Text(
          '"${book.title}" will be removed from this device. '
          'This does not affect your online books.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (remove != true) return;
    try {
      await viewModel.removeLocalBook(book);
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not remove this PDF: $error')),
        );
      }
    }
  }
}

class SettingsPage extends StatelessWidget {
  final BookViewModel viewModel;

  const SettingsPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SettingsLine(
            Icons.brightness_6_outlined,
            'Theme',
            viewModel.darkMode ? 'Dark' : 'Light',
          ),
          SettingsLine(
            Icons.menu_book_outlined,
            'PDF scrolling',
            viewModel.pageTurnAnimation ? 'Bouncy' : 'Clamped',
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.text_fields),
            title: const Text('Reader font size'),
            subtitle: Slider(
              min: 12,
              max: 28,
              divisions: 8,
              label: '${viewModel.fontSize} px',
              value: viewModel.fontSize.toDouble().clamp(12, 28),
              onChanged: (value) => viewModel.setFontSize(value.round()),
              onChangeEnd: (_) => _saveSetting(context, viewModel.saveFontSize),
            ),
            trailing: Text('${viewModel.fontSize}'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            value: viewModel.darkMode,
            onChanged: (v) =>
                _saveSetting(context, () => viewModel.updateDarkMode(v)),
          ),
          const SizedBox(height: 18),
          Text(
            'General',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.save_outlined),
            title: const Text('Auto Save Notes'),
            value: viewModel.autoSaveNotes,
            onChanged: (v) => _saveSetting(
              context,
              () => viewModel.updateSetting('autoSaveNotes', v),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.numbers),
            title: const Text('Show Page Number'),
            value: viewModel.showPageNumber,
            onChanged: (v) => _saveSetting(
              context,
              () => viewModel.updateSetting('showPageNumber', v),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.bar_chart),
            title: const Text('Show Reading Progress'),
            value: viewModel.showReadingProgress,
            onChanged: (v) => _saveSetting(
              context,
              () => viewModel.updateSetting('showReadingProgress', v),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.timer_outlined),
            title: const Text('Daily Reading Goal'),
            value: viewModel.dailyGoalEnabled,
            onChanged: (v) => _saveSetting(
              context,
              () => viewModel.updateSetting('dailyGoal', v),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Daily goal'),
            subtitle: Text('${viewModel.dailyGoalMinutes} minutes'),
            onTap: () => _editDailyGoal(context),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.auto_awesome_motion_outlined),
            title: const Text('Bouncy PDF scrolling'),
            value: viewModel.pageTurnAnimation,
            onChanged: (v) => _saveSetting(
              context,
              () => viewModel.updateSetting('pageTurnAnimation', v),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _editDailyGoal(BuildContext context) async {
    var minutes = viewModel.dailyGoalMinutes;
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Daily reading goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$minutes minutes'),
              Slider(
                min: 5,
                max: 180,
                divisions: 35,
                value: minutes.clamp(5, 180).toDouble(),
                onChanged: (value) => setState(() => minutes = value.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, minutes),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (selected != null) {
      await _saveSetting(
        context,
        () => viewModel.updateDailyGoalMinutes(selected),
      );
    }
  }

  Future<void> _saveSetting(
    BuildContext context,
    Future<void> Function() save,
  ) async {
    try {
      await save();
    } on FirebaseException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Could not save this setting.'),
          ),
        );
      }
    }
  }
}

class SettingsLine extends StatelessWidget {
  final IconData icon;
  final String title, value;

  const SettingsLine(this.icon, this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(title),
    trailing: Text(value, style: const TextStyle(color: muted)),
  );
}
