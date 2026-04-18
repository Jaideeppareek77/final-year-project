import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await _authService.login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(user['role'] == 'doctor' ? '/doctor' : '/patient', (r) => false);
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final msg = (data is Map ? data['error'] as String? : null) ?? 'Login failed. Check your connection.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome Back', style: Theme.of(context).textTheme.displayLarge),
                      const SizedBox(height: 4),
                      Text('Sign in to your account', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 32),
                      AppTextField(
                        hint: 'Enter your email',
                        label: 'Email',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        hint: 'Enter your password',
                        label: 'Password',
                        controller: _passwordCtrl,
                        obscure: true,
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        textInputAction: TextInputAction.done,
                        validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                      ),
                      const SizedBox(height: 32),
                      AppButton(label: 'Sign In', onPressed: _login, isLoading: _loading),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/register'),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                              children: [TextSpan(text: 'Register', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset('assets/icon/appicon.png', width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          const Text('Fliser', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Fliser Health Care', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
        ],
      ),
    );
  }
}
