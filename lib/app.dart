import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'ui/screens/main_shell.dart';
import 'ui/screens/welcome_page.dart';
import 'viewmodels/book_view_model.dart';

class BookVerseApp extends StatefulWidget {
  const BookVerseApp({super.key});

  @override
  State<BookVerseApp> createState() => _BookVerseAppState();
}

class _BookVerseAppState extends State<BookVerseApp> {
  final BookViewModel viewModel = BookViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.initialize();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final isDark = viewModel.darkMode;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BookVerse',
          theme: ThemeData(
            useMaterial3: true,
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: isDark ? const Color(0xFF111827) : bg,
            fontFamily: 'Arial',
            colorScheme: ColorScheme.fromSeed(
              seedColor: primary,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: isDark ? const Color(0xFF111827) : bg,
              foregroundColor: isDark ? Colors.white : navy,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              hintStyle: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF8B93A7),
                fontSize: 13,
              ),
              prefixIconColor: isDark ? Colors.white70 : navy,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(color: primary, width: 1.2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          home: _AuthGate(viewModel: viewModel),
        );
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  final BookViewModel viewModel;

  const _AuthGate({required this.viewModel});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) {
      if (!viewModel.isInitialized) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return viewModel.isLoggedIn
          ? MainShell(viewModel: viewModel)
          : WelcomePage(viewModel: viewModel);
    },
  );
}
