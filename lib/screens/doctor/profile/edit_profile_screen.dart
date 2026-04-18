import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../services/doctor_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _doctorService = DoctorService();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _specificationCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _langCtrl = TextEditingController();

  String _specialization = 'general';
  bool _loading = true;
  bool _saving = false;
  String? _userId;

  final _specializations = [
    'general', 'cardiology', 'dermatology', 'pediatrics',
    'neurology', 'orthopedics', 'gynecology', 'psychiatry', 'oncology',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    _specificationCtrl.dispose();
    _feeCtrl.dispose();
    _expCtrl.dispose();
    _langCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userId = await _authService.getUserId();
    if (userId == null || !mounted) return;
    _userId = userId;
    try {
      final data = await _doctorService.getDoctorById(userId);
      if (!mounted) return;
      final doc = data['doctorProfile'] as Map<String, dynamic>? ?? {};
      final langs = (doc['languages'] as List<dynamic>?)?.cast<String>() ?? [];
      setState(() {
        _nameCtrl.text = data['name'] as String? ?? '';
        _phoneCtrl.text = data['phone'] as String? ?? '';
        _addressCtrl.text = data['address'] as String? ?? '';
        _bioCtrl.text = data['bio'] as String? ?? '';
        _specificationCtrl.text = doc['specification'] as String? ?? '';
        _feeCtrl.text = (doc['consultationFee'] as num?)?.toInt().toString() ?? '500';
        _expCtrl.text = (doc['yearsExperience'] as num?)?.toInt().toString() ?? '0';
        _langCtrl.text = langs.join(', ');
        final spec = doc['specialization'] as String? ?? 'general';
        _specialization = _specializations.contains(spec) ? spec : 'general';
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _userId == null) return;
    setState(() => _saving = true);
    try {
      final langs = _langCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      await _doctorService.updateDoctorProfile(_userId!, {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'specialization': _specialization,
        'specification': _specificationCtrl.text.trim(),
        'consultationFee': int.tryParse(_feeCtrl.text) ?? 500,
        'yearsExperience': int.tryParse(_expCtrl.text) ?? 0,
        'languages': langs,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['error'] as String? ?? 'Failed to update profile';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _sectionTitle('Personal Info'),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: 'Your full name',
                    label: 'Name',
                    controller: _nameCtrl,
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    validator: (v) => v != null && v.length >= 2 ? null : 'Enter your name',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: '+91 9876543210',
                    label: 'Phone',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: 'Clinic / Hospital address',
                    label: 'Address',
                    controller: _addressCtrl,
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: 'Brief bio about yourself',
                    label: 'Bio',
                    controller: _bioCtrl,
                    maxLines: 3,
                    prefixIcon: const Icon(Icons.info_outline, size: 20),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Professional Info'),
                  const SizedBox(height: 12),
                  _buildSpecDropdown(),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: 'Detailed expertise, services offered...',
                    label: 'About / Specification',
                    controller: _specificationCtrl,
                    maxLines: 3,
                    prefixIcon: const Icon(Icons.medical_services_outlined, size: 20),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: AppTextField(
                        hint: '500',
                        label: 'Consultation Fee (₹)',
                        controller: _feeCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                        validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        hint: '5',
                        label: 'Years Experience',
                        controller: _expCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.work_outline, size: 20),
                        validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: 'English, Hindi, Gujarati',
                    label: 'Languages (comma separated)',
                    controller: _langCtrl,
                    prefixIcon: const Icon(Icons.language, size: 20),
                  ),
                  const SizedBox(height: 32),
                  AppButton(label: 'Save Changes', onPressed: _save, isLoading: _saving),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.displaySmall);
  }

  Widget _buildSpecDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specialization',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _specialization,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.medical_services_outlined, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          items: _specializations
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s[0].toUpperCase() + s.substring(1)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _specialization = v ?? 'general'),
        ),
      ],
    );
  }
}
