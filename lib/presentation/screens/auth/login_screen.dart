import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/common/auth_shell.dart';
import '../../widgets/common/fx.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _remember = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      context.go('/home');
    }
  }

  void _soon(String what) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$what is coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthShell(
      title: 'Welcome Back!',
      subtitle: 'Log in to continue your journey',
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter a valid email' : null,
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
                    if (!RegExp(r'[A-Z]').hasMatch(value) || !RegExp(r'[a-z]').hasMatch(value) || !RegExp(r'[0-9]').hasMatch(value)) return 'Include uppercase, lowercase and a number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _remember,
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        onChanged: (v) => setState(() => _remember = v ?? true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Remember me',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _soon('Password reset'),
                      child: const Text('Forgot password?',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark)),
                    ),
                  ],
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 14),
                  ErrorBox(auth.error!),
                ],
                const SizedBox(height: 22),
                GradientButton(
                  label: 'Log In',
                  icon: Icons.arrow_forward_rounded,
                  loading: auth.isLoading,
                  onPressed: _login,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const OrDivider(),
          const SizedBox(height: 18),
          GoogleButton(onPressed: () => _soon('Google sign-in')),
          const SizedBox(height: 22),
          TextButton.icon(
            onPressed: () async {
              await context.read<AuthProvider>().continueAsGuest();
              if (context.mounted) context.go('/home');
            },
            icon: const Icon(Icons.person_outline),
            label: const Text('Continue as Guest'),
          ),
          AuthFooter(
            prompt: "Don't have an account?",
            action: 'Sign Up',
            onTap: () => context.push('/signup'),
          ),
        ],
      ),
    );
  }
}
