import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'auth_page.dart';
import '../../viewmodels/book_view_model.dart';

class WelcomePage extends StatelessWidget {
  final BookViewModel viewModel;

  const WelcomePage({super.key, required this.viewModel});

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
              const Text(
                'BookVerse',
                style: TextStyle(
                  fontSize: 37,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Read  •  Learn  •  Explore',
                style: TextStyle(
                  color: primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Text(
                'Your PDFs,\nA Better Reading Experience',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, height: 1.45, color: navy),
              ),
              const SizedBox(height: 34),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AuthPage(viewModel: viewModel),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuthPage(viewModel: viewModel),
                  ),
                ),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: muted),
                    children: [
                      TextSpan(text: 'Already have an account?  '),
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
