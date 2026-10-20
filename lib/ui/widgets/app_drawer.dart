import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../viewmodels/book_view_model.dart';
import '../screens/profile_page.dart';

class AppDrawer extends StatelessWidget {
  final BookViewModel viewModel;
  final ValueChanged<int> onSelect;

  const AppDrawer({super.key, required this.viewModel, required this.onSelect});

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: Theme.of(context).colorScheme.surface,
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 15, 18),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: primary, size: 32),
                const SizedBox(width: 9),
                Text(
                  'BookVerse',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          DrawerItem(Icons.home_outlined, 'Home', true, () => onSelect(0)),
          DrawerItem(
            Icons.folder_outlined,
            'My Library',
            false,
            () => onSelect(1),
          ),
          DrawerItem(Icons.favorite_border, 'Favorites', false, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritesPage(viewModel: viewModel),
              ),
            );
          }),
          DrawerItem(Icons.note_outlined, 'Notes', false, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookmarksPage(viewModel: viewModel),
              ),
            );
          }),
          DrawerItem(Icons.access_time, 'Recent', false, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReadingHistoryPage(viewModel: viewModel),
              ),
            );
          }),
          DrawerItem(Icons.download_outlined, 'Downloads', false, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LocalPdfLibraryPage(viewModel: viewModel),
              ),
            );
          }),
          const Spacer(),
          DrawerItem(Icons.settings_outlined, 'Settings', false, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsPage(viewModel: viewModel),
              ),
            );
          }),
          DrawerItem(Icons.info_outline, 'About', false, () {
            showAboutDialog(
              context: context,
              applicationName: 'BookVerse',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(
                Icons.menu_book_rounded,
                color: primary,
              ),
              children: const [
                Text(
                  'A personal library for your study materials, with PDF '
                  'reading, bookmarks, notes, and reading progress.',
                ),
              ],
            );
          }),
          const SizedBox(height: 15),
        ],
      ),
    ),
  );
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final VoidCallback onTap;

  const DrawerItem(this.icon, this.title, this.active, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      color: active ? const Color(0xFFE8EDFF) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    child: ListTile(
      onTap: onTap,
      dense: true,
      leading: Icon(
        icon,
        color: active ? primary : Theme.of(context).colorScheme.onSurface,
        size: 21,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: active ? primary : Theme.of(context).colorScheme.onSurface,
          fontSize: 13,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    ),
  );
}
