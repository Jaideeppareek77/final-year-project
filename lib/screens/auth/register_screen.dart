import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _authService = AuthService();
  String _role = 'patient';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await _authService.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _role,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(user['role'] == 'doctor' ? '/doctor' : '/patient', (r) => false);
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['error'] as String? ?? 'Registration failed.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back_ios, size: 20),
                ),
                const SizedBox(height: 24),
                Text('Create Account', style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 4),
                Text('Join Medico today', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 28),
                AppTextField(
                  hint: 'Your full name',
                  label: 'Full Name',
                  controller: _nameCtrl,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  validator: (v) => v != null && v.length >= 2 ? null : 'Enter your name',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hint: 'your@email.com',
                  label: 'Email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hint: 'Min 6 characters',
                  label: 'Password',
                  controller: _passwordCtrl,
                  obscure: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hint: 'Repeat password',
                  label: 'Confirm Password',
                  controller: _confirmCtrl,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (v) => v == _passwordCtrl.text ? null : 'Passwords do not match',
                ),
                const SizedBox(height: 24),
                Text('I am a...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _RoleCard(label: 'Patient', icon: Icons.person_outline, selected: _role == 'patient', onTap: () => setState(() => _role = 'patient'))),
                  const SizedBox(width: 12),
                  Expanded(child: _RoleCard(label: 'Doctor', icon: Icons.medical_services_outlined, selected: _role == 'doctor', onTap: () => setState(() => _role = 'doctor'))),
                ]),
                const SizedBox(height: 32),
                AppButton(label: 'Create Account', onPressed: _register, isLoading: _loading),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        children: [TextSpan(text: 'Sign In', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
