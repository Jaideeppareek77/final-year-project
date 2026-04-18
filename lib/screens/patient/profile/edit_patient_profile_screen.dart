import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../constants/api_constants.dart';
import '../../../services/api_client.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class EditPatientProfileScreen extends StatefulWidget {
  const EditPatientProfileScreen({super.key});

  @override
  State<EditPatientProfileScreen> createState() => _EditPatientProfileScreenState();
}

class _EditPatientProfileScreenState extends State<EditPatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dio = ApiClient.instance.dio;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();

  String? _bloodGroup;
  DateTime? _birthDate;
  bool _loading = true;
  bool _saving = false;

  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

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
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _allergiesCtrl.dispose();
    _conditionsCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        _dio.get(ApiConstants.usersMe),
        _dio.get(ApiConstants.patientsMe),
      ]);
      if (!mounted) return;
      final user = results[0].data as Map<String, dynamic>;
      final pat = results[1].data as Map<String, dynamic>? ?? {};

      final birthDateStr = user['birthDate'] as String?;
      final allergies = (pat['allergies'] as List<dynamic>?)?.cast<String>() ?? [];
      final conditions = (pat['chronicConditions'] as List<dynamic>?)?.cast<String>() ?? [];

      setState(() {
        _nameCtrl.text = user['name'] as String? ?? '';
        _phoneCtrl.text = user['phone'] as String? ?? '';
        _addressCtrl.text = user['address'] as String? ?? '';
        _heightCtrl.text = (pat['height'] as num?)?.toString() ?? '';
        _weightCtrl.text = (pat['weight'] as num?)?.toString() ?? '';
        _allergiesCtrl.text = allergies.join(', ');
        _conditionsCtrl.text = conditions.join(', ');
        _emergencyNameCtrl.text = pat['emergencyContactName'] as String? ?? '';
        _emergencyPhoneCtrl.text = pat['emergencyContactPhone'] as String? ?? '';
        final bg = pat['bloodGroup'] as String?;
        _bloodGroup = _bloodGroups.contains(bg) ? bg : null;
        if (birthDateStr != null) _birthDate = DateTime.tryParse(birthDateStr);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final allergies = _allergiesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final conditions = _conditionsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      await Future.wait([
        _dio.put(ApiConstants.usersMe, data: {
          'name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          if (_birthDate != null) 'birthDate': _birthDate!.toIso8601String(),
        }),
        _dio.put(ApiConstants.patientsMe, data: {
          if (_bloodGroup != null) 'bloodGroup': _bloodGroup,
          if (_heightCtrl.text.isNotEmpty) 'height': double.tryParse(_heightCtrl.text) ?? 0,
          if (_weightCtrl.text.isNotEmpty) 'weight': double.tryParse(_weightCtrl.text) ?? 0,
          'allergies': allergies,
          'chronicConditions': conditions,
          'emergencyContactName': _emergencyNameCtrl.text.trim(),
          'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
        }),
      ]);

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

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1995),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
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
                    hint: 'Your address',
                    label: 'Address',
                    controller: _addressCtrl,
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _birthDateField(),
                  const SizedBox(height: 24),
                  _sectionTitle('Medical Info'),
                  const SizedBox(height: 12),
                  _bloodGroupDropdown(),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: AppTextField(
                        hint: '170',
                        label: 'Height (cm)',
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.height, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        hint: '65',
                        label: 'Weight (kg)',
                        controller: _weightCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.monitor_weight_outlined, size: 20),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: 'Penicillin, Dust...',
                    label: 'Allergies (comma separated)',
                    controller: _allergiesCtrl,
                    prefixIcon: const Icon(Icons.warning_amber_outlined, size: 20),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: 'Diabetes, Hypertension...',
                    label: 'Chronic Conditions (comma separated)',
                    controller: _conditionsCtrl,
                    prefixIcon: const Icon(Icons.medical_information_outlined, size: 20),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Emergency Contact'),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: 'Contact person name',
                    label: 'Name',
                    controller: _emergencyNameCtrl,
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    hint: '+91 9876543210',
                    label: 'Phone',
                    controller: _emergencyPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 32),
                  AppButton(label: 'Save Changes', onPressed: _save, isLoading: _saving),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) =>
      Text(title, style: Theme.of(context).textTheme.displaySmall);

  Widget _birthDateField() {
    return GestureDetector(
      onTap: _pickBirthDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          const Icon(Icons.cake_outlined, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Date of Birth', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(
              _birthDate == null
                  ? 'Select date'
                  : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
              style: TextStyle(
                color: _birthDate == null ? AppColors.textSecondary : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _bloodGroupDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Blood Group', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _bloodGroup,
          hint: const Text('Select blood group'),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.bloodtype_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          ),
          items: _bloodGroups.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
          onChanged: (v) => setState(() => _bloodGroup = v),
        ),
      ],
    );
  }
}
