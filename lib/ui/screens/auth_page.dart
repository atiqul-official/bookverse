import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/app_theme.dart';
import '../../viewmodels/book_view_model.dart';

class AuthPage extends StatefulWidget {
  final BookViewModel viewModel;

  const AuthPage({super.key, required this.viewModel});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showLogin = true;
  bool isSubmitting = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _authErrorMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Email or password is incorrect.',
      'email-already-in-use' => 'An account already exists for this email.',
      'weak-password' => 'Choose a password with at least 6 characters.',
      'network-request-failed' =>
        'Network error. Check your internet connection.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (showLogin) {
      if (email.isEmpty || password.isEmpty) {
        _showMessage('Please enter email and password.');
        return;
      }
    } else {
      final name = nameController.text.trim();
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _showMessage('Please fill in all fields to create an account.');
        return;
      }
      if (password.length < 6) {
        _showMessage('Choose a password with at least 6 characters.');
        return;
      }
    }

    setState(() => isSubmitting = true);
    try {
      if (showLogin) {
        await widget.viewModel.login(email, password);
      } else {
        await widget.viewModel.register(
          name: nameController.text.trim(),
          email: email,
          password: password,
        );
      }
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } on FirebaseAuthException catch (error) {
      _showMessage(_authErrorMessage(error));
    } on FirebaseException catch (error) {
      _showMessage(error.message ?? 'Could not save account data.');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email address first.');
      return;
    }
    try {
      await widget.viewModel.resetPassword(email);
      if (mounted) _showMessage('Password reset email sent.');
    } on FirebaseAuthException catch (error) {
      if (mounted) _showMessage(_authErrorMessage(error));
    } on FirebaseException catch (error) {
      if (mounted) _showMessage('Could not send reset email: $error');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = showLogin ? 'Sign In' : 'Create Account';
    final subtitle = showLogin
        ? 'Access your study library and PDF notes'
        : 'Create your BookVerse account';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: navy, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showLogin ? 'Welcome back' : 'Join BookVerse',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(color: muted, fontSize: 14),
              ),
              const SizedBox(height: 30),
              if (!showLogin) ...[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              if (showLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isSubmitting ? null : _resetPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          showLogin ? 'Sign In' : 'Create Account',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => showLogin = !showLogin),
                  child: Text(
                    showLogin
                        ? 'Create a new account'
                        : 'Already have an account? Sign In',
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
