
import 'package:flutter/material.dart';

void main() => runApp(const BookVerseApp());

const primary = Color(0xFF3155C8);
const navy = Color(0xFF172554);
const bg = Color(0xFFF7F8FC);
const muted = Color(0xFF6B7280);

class BookVerseApp extends StatelessWidget {
  const BookVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookVerse',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: navy,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Color(0xFF8B93A7), fontSize: 13),
          prefixIconColor: navy,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide(color: primary, width: 1.2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

class Book {
  final String title, size, date, category;
  final int page, total;
  final Color color;
  const Book(this.title, this.size, this.date, this.category,
      this.page, this.total, this.color);
  double get progress => page / total;
}

const demoBooks = [
  Book('Data Structures and Algorithms', '12 MB', 'Aug 25, 2026',
      'Documents', 45, 320, Color(0xFF536DFE)),
  Book('Operating System Concepts', '8 MB', 'Aug 20, 2026',
      'Lectures', 120, 540, Color(0xFFFF7043)),
  Book('Database System', '8.4 MB', 'Aug 20, 2026',
      'Books', 20, 410, Color(0xFF42A5F5)),
  Book('Software Engineering', '10.2 MB', 'Aug 18, 2026',
      'Documents', 65, 380, Color(0xFFAB47BC)),
  Book('Machine Learning Notes', '6.1 MB', 'Aug 15, 2026',
      'Lectures', 87, 260, Color(0xFFEF5350)),
  Book('Mathematics for CSE', '14 MB', 'Aug 10, 2026',
      'Books', 30, 490, Color(0xFF26A69A)),
  Book('Digital Logic Design', '5.8 MB', 'Aug 5, 2026',
      'Documents', 15, 280, Color(0xFFFFA726)),
];

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9FBFF), Color(0xFFEAF0FF)],
            ),
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Icon(Icons.menu_book_rounded, size: 105, color: primary),
              const SizedBox(height: 18),
              const Text('BookVerse',
                  style: TextStyle(fontSize: 37, fontWeight: FontWeight.w800, color: navy)),
              const SizedBox(height: 5),
              const Text('Read  •  Learn  •  Explore',
                  style: TextStyle(color: primary, fontSize: 16, fontWeight: FontWeight.w500)),
              const Spacer(),
              const Text('Your PDFs,\nA Better Reading Experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, height: 1.45, color: navy)),
              const SizedBox(height: 34),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const MainShell())),
                    child: const Text('Get Started',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: muted),
                  children: [
                    TextSpan(text: 'Already have an account?  '),
                    TextSpan(text: 'Sign In',
                        style: TextStyle(color: navy, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [HomePage(), LibraryPage(), SearchPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelect: (i) => setState(() => index = i)),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        elevation: 8,
        height: 68,
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        indicatorColor: const Color(0xFFE8EDFF),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.library_books_outlined), selectedIcon: Icon(Icons.library_books), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const SearchBox({super.key, this.hint = 'Search for your files...', this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    decoration: InputDecoration(hintText: hint, prefixIcon: const Icon(Icons.search, size: 21)),
  );
}

class PdfIcon extends StatelessWidget {
  final Book book;
  const PdfIcon({super.key, required this.book});

  @override
  Widget build(BuildContext context) => Container(
    width: 45, height: 52,
    decoration: BoxDecoration(color: book.color, borderRadius: BorderRadius.circular(8)),
    child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
  );
}

class ProgressBookCard extends StatelessWidget {
  final Book book;
  const ProgressBookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(15),
    onTap: () => Navigator.push(context,
      MaterialPageRoute(builder: (_) => ReaderPage(book: book))),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(children: [
        PdfIcon(book: book),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${book.title}.pdf', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, color: navy, fontSize: 13)),
          const SizedBox(height: 6),
          Row(children: [
            Text('Page ${book.page} / ${book.total}', style: const TextStyle(fontSize: 11, color: muted)),
            const Spacer(),
            Text('${(book.progress * 100).round()}%', style: const TextStyle(fontSize: 11, color: muted)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: book.progress, minHeight: 4)),
        ])),
      ]),
    ),
  );
}

class LibraryTile extends StatelessWidget {
  final Book book;
  const LibraryTile({super.key, required this.book});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.push(context,
      MaterialPageRoute(builder: (_) => ReaderPage(book: book))),
    child: Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
      child: Row(children: [
        PdfIcon(book: book),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${book.title}.pdf', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: navy)),
          const SizedBox(height: 5),
          Text('${book.size}  •  ${book.date}', style: const TextStyle(fontSize: 10.5, color: muted)),
        ])),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, size: 20)),
      ]),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      children: [
        Row(children: [
          Builder(builder: (context) => IconButton(
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: navy))),
          const Expanded(child: Center(child: Text('BookVerse',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: navy)))),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: navy)),
        ]),
        const SizedBox(height: 15),
        const SearchBox(hint: 'Search for PDFs, books, subjects...'),
        const SizedBox(height: 18),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 1.58,
          children: const [
            StatCard('Recent', '12 files', Icons.access_time_rounded, Color(0xFFE7ECFF), primary),
            StatCard('Favorites', '8 files', Icons.favorite_rounded, Color(0xFFFFE7E9), Color(0xFFFF5C67)),
            StatCard('Notes', '5 notes', Icons.sticky_note_2_rounded, Color(0xFFFFF0D8), Color(0xFFFF9E27)),
            StatCard('Folders', '6 folders', Icons.folder_rounded, Color(0xFFDFF2FF), Color(0xFF26A8E0)),
          ],
        ),
        const SizedBox(height: 25),
        Row(children: [
          const Expanded(child: Text('Continue Reading',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: navy))),
          TextButton(onPressed: () {}, child: const Text('See All')),
        ]),
        const SizedBox(height: 8),
        ...demoBooks.take(2).map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 9), child: ProgressBookCard(book: b))),
      ],
    ),
  );
}

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color background, iconColor;
  const StatCard(this.title, this.value, this.icon, this.background, this.iconColor, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(15)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: iconColor, size: 24),
      const Spacer(),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: navy)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 10.5, color: muted)),
    ]),
  );
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});
  @override State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String filter = 'All', query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = demoBooks.where((b) {
      return b.title.toLowerCase().contains(query.toLowerCase()) &&
          (filter == 'All' || b.category == filter);
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 90),
        children: [
          Row(children: [
            const Expanded(child: Text('My Library',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: navy))),
            IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: navy)),
          ]),
          const SizedBox(height: 15),
          SearchBox(onChanged: (v) => setState(() => query = v)),
          const SizedBox(height: 14),
          SizedBox(height: 36, child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'Documents', 'Lectures', 'Books'].map((f) {
              final selected = filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 7),
                child: ChoiceChip(
                  label: Text(f, style: TextStyle(fontSize: 11, color: selected ? Colors.white : navy)),
                  selected: selected, onSelected: (_) => setState(() => filter = f),
                  selectedColor: primary, backgroundColor: Colors.white, side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              );
            }).toList(),
          )),
          const SizedBox(height: 10),
          ...filtered.map((b) => LibraryTile(book: b)),
        ],
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final results = demoBooks.where((b) =>
      b.title.toLowerCase().contains(query.toLowerCase())).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
        children: [
          const Text('Search',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: navy)),
          const SizedBox(height: 18),
          SearchBox(hint: 'Search books, PDFs, notes...',
            onChanged: (v) => setState(() => query = v)),
          const SizedBox(height: 15),
          Wrap(spacing: 7, children: ['All', 'Files', 'Notes', 'Bookmarks'].map(
            (x) => Chip(label: Text(x, style: const TextStyle(fontSize: 11)),
              backgroundColor: x == 'All' ? const Color(0xFFE7ECFF) : Colors.white,
              side: BorderSide.none)).toList()),
          const SizedBox(height: 12),
          ...results.map((b) => LibraryTile(book: b)),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Profile',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: navy)),
        const SizedBox(height: 22),
        Center(child: Column(children: [
          const CircleAvatar(radius: 42, backgroundColor: Color(0xFFE7ECFF),
            child: Icon(Icons.person, size: 48, color: primary)),
          const SizedBox(height: 10),
          const Text('BookVerse User',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: navy)),
          const SizedBox(height: 3),
          const Text('student@bookverse.com', style: TextStyle(color: muted, fontSize: 12)),
        ])),
        const SizedBox(height: 25),
        ProfileRow(Icons.bookmark_outline, 'Bookmarks & Notes',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksPage()))),
        ProfileRow(Icons.download_outlined, 'Downloads', () {}),
        ProfileRow(Icons.settings_outlined, 'Settings',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
        ProfileRow(Icons.info_outline, 'About BookVerse', () {}),
      ],
    ),
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
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
    child: ListTile(onTap: onTap, leading: Icon(icon, color: primary),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20)),
  );
}

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Page 12', 'Introduction to Data Structures', 'Aug 10, 2026'),
      ('Page 45', 'Stack operations', 'Aug 12, 2026'),
      ('Page 120', 'Queue example', 'Aug 15, 2026'),
      ('Page 200', 'Important formula', 'Aug 20, 2026'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks & Notes',
        style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: items.map((x) => ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 7),
          leading: const Icon(Icons.bookmark, color: primary),
          title: Text(x.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: navy)),
          subtitle: Text('${x.$2}\n${x.$3}', style: const TextStyle(fontSize: 11)),
          trailing: const Icon(Icons.more_vert, size: 19),
        )).toList(),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool animation = true, notes = true, pageNumber = true, progress = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings',
      style: TextStyle(fontWeight: FontWeight.w800))),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      children: [
        const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w700, color: navy)),
        SettingsLine(Icons.brightness_6_outlined, 'Theme', 'System'),
        SettingsLine(Icons.menu_book_outlined, 'Reading Mode', 'Default'),
        SettingsLine(Icons.zoom_in, 'Default Zoom', '100%'),
        SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.animation),
          title: const Text('Page Turn Animation'), value: animation,
          onChanged: (v) => setState(() => animation = v)),
        const SizedBox(height: 18),
        const Text('General', style: TextStyle(fontWeight: FontWeight.w700, color: navy)),
        SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.save_outlined),
          title: const Text('Auto Save Notes'), value: notes,
          onChanged: (v) => setState(() => notes = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.numbers),
          title: const Text('Show Page Number'), value: pageNumber,
          onChanged: (v) => setState(() => pageNumber = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.bar_chart),
          title: const Text('Show Reading Progress'), value: progress,
          onChanged: (v) => setState(() => progress = v)),
      ],
    ),
  );
}

class SettingsLine extends StatelessWidget {
  final IconData icon;
  final String title, value;
  const SettingsLine(this.icon, this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero, leading: Icon(icon), title: Text(title),
    trailing: Text(value, style: const TextStyle(color: muted)));
}

class AppDrawer extends StatelessWidget {
  final ValueChanged<int> onSelect;
  const AppDrawer({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: Colors.white,
    child: SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 15, 18),
          child: Row(children: [
            const Icon(Icons.menu_book_rounded, color: primary, size: 32),
            const SizedBox(width: 9),
            const Text('BookVerse',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: navy)),
            const Spacer(),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
        ),
        DrawerItem(Icons.home_outlined, 'Home', true, () { Navigator.pop(context); onSelect(0); }),
        DrawerItem(Icons.folder_outlined, 'My Library', false, () { Navigator.pop(context); onSelect(1); }),
        DrawerItem(Icons.favorite_border, 'Favorites', false, () {}),
        DrawerItem(Icons.note_outlined, 'Notes', false, () {}),
        DrawerItem(Icons.access_time, 'Recent', false, () {}),
        DrawerItem(Icons.download_outlined, 'Downloads', false, () {}),
        DrawerItem(Icons.delete_outline, 'Trash', false, () {}),
        const Spacer(),
        DrawerItem(Icons.settings_outlined, 'Settings', false, () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
        }),
        DrawerItem(Icons.info_outline, 'About', false, () {}),
        const SizedBox(height: 15),
      ]),
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
      borderRadius: BorderRadius.circular(10)),
    child: ListTile(
      onTap: onTap, dense: true,
      leading: Icon(icon, color: active ? primary : navy, size: 21),
      title: Text(title, style: TextStyle(color: active ? primary : navy,
        fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w400))),
  );
}

class ReaderPage extends StatefulWidget {
  final Book book;
  const ReaderPage({super.key, required this.book});
  @override State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool dark = false;
  bool bookmarked = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: dark ? const Color(0xFF17191E) : const Color(0xFFEEF0F5),
    appBar: AppBar(
      backgroundColor: dark ? const Color(0xFF17191E) : const Color(0xFF20242C),
      foregroundColor: Colors.white,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${widget.book.title}.pdf', maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.white)),
        Text('${widget.book.page} / ${widget.book.total}',
          style: const TextStyle(fontSize: 9, color: Colors.white70)),
      ]),
      actions: const [Icon(Icons.more_vert)],
    ),
    body: Column(children: [
      Expanded(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          padding: const EdgeInsets.fromLTRB(25, 28, 25, 25),
          color: dark ? const Color(0xFF282B31) : const Color(0xFFFFFEFB),
          child: SingleChildScrollView(
            child: Text('''Chapter 3

Stacks and Queues

A stack is a linear data structure that follows the LIFO
(Last In First Out) principle.

In a stack, elements are inserted and deleted from the top
only.

                    Push       Pop
                      ↓         ↓
                    ┌─────┐
                    │  30 │
                    ├─────┤
                    │  20 │
                    ├─────┤
                    │  10 │
                    └─────┘
                       ↑
                      Top

Figure 3.1: Stack Operations

A queue is a linear data structure that follows the FIFO
(First In First Out) principle.

Elements are inserted at the rear and deleted from the
front.

Important Concepts

• Push
• Pop
• Enqueue
• Dequeue
• Stack Overflow
• Queue Underflow
''',
              style: TextStyle(fontSize: 16, height: 1.65,
                color: dark ? Colors.white : const Color(0xFF202124)),
            ),
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: dark ? const Color(0xFF20242C) : Colors.white,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          ReaderAction(Icons.list, 'Contents', () {}),
          ReaderAction(bookmarked ? Icons.bookmark : Icons.bookmark_border, 'Bookmark',
            () => setState(() => bookmarked = !bookmarked)),
          ReaderAction(Icons.edit_note, 'Note', () => _noteDialog(context)),
          ReaderAction(Icons.search, 'Search', () {}),
          ReaderAction(Icons.settings, 'Settings', () => setState(() => dark = !dark)),
        ]),
      ),
    ]),
  );

  void _noteDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Add Note'),
      content: const TextField(maxLines: 4,
        decoration: InputDecoration(hintText: 'Write your note...')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
      ],
    ));
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
      child: Column(children: [
        Icon(icon, size: 20),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 9)),
      ]),
    ),
  );
}
