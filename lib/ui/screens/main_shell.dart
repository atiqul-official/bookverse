import 'package:flutter/material.dart';
import '../../viewmodels/book_view_model.dart';
import 'home_page.dart';
import 'library_page.dart';
import 'profile_page.dart';
import '../widgets/app_drawer.dart';

class MainShell extends StatefulWidget {
  final BookViewModel viewModel;

  const MainShell({super.key, required this.viewModel});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        viewModel: widget.viewModel,
        onSeeAll: () => setState(() => index = 1),
        onSearch: () => setState(() => index = 2),
      ),
      LibraryPage(viewModel: widget.viewModel),
      SearchPage(viewModel: widget.viewModel),
      ProfilePage(viewModel: widget.viewModel),
    ];

    return Scaffold(
      drawer: AppDrawer(
        viewModel: widget.viewModel,
        onSelect: (i) {
          setState(() => index = i);
          Navigator.pop(context);
        },
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        height: 68,
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        indicatorColor: const Color(0xFFE8EDFF),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
