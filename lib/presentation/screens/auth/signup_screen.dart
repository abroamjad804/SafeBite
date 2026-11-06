import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/common/auth_shell.dart';
import '../../widgets/common/fx.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      _nameController.text.trim(),
      int.tryParse(_ageController.text) ?? 0,
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthShell(
      title: 'Create Account',
      subtitle: 'Start your healthy journey',
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your full name' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Age', prefixIcon: Icon(Icons.cake_outlined)),
                  validator: (v) {
                    final age = int.tryParse(v ?? '');
                    return age == null || age < 1 || age > 120 ? 'Enter a valid age' : null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) =>
                      v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    final value = v ?? '';
                    if (value.length < 8 || value.length > 12) return 'Use 8–12 characters';
                    if (!RegExp(r'[A-Z]').hasMatch(value) ||
                        !RegExp(r'[a-z]').hasMatch(value) ||
                        !RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Include uppercase, lowercase and a number';
                    }
                    return null;
                  },
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 14),
                  ErrorBox(auth.error!),
                ],
                const SizedBox(height: 22),
                GradientButton(
                  label: 'Sign Up',
                  icon: Icons.arrow_forward_rounded,
                  loading: auth.isLoading,
                  onPressed: _signUp,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: () async {
              await context.read<AuthProvider>().continueAsGuest();
              if (context.mounted) context.go('/home');
            },
            icon: const Icon(Icons.person_outline),
            label: const Text('Continue as Guest'),
          ),
          const SizedBox(height: 22),
          AuthFooter(
            prompt: 'Already have an account?',
            action: 'Log In',
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
