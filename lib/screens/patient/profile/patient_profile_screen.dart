import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../constants/api_constants.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
import '../../common/help_support_screen.dart';
import 'edit_patient_profile_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _authService = AuthService();
  final _dio = ApiClient.instance.dio;

  String _name = '';
  String _email = '';
  String _phone = '';
  String? _bloodGroup;
  double? _height;
  double? _weight;
  int? _age;
  List<String> _allergies = [];
  List<String> _conditions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _dio.get(ApiConstants.usersMe),
        _dio.get(ApiConstants.patientsMe),
      ]);
      if (!mounted) return;
      final user = results[0].data as Map<String, dynamic>;
      final pat = results[1].data as Map<String, dynamic>? ?? {};

      final birthDateStr = user['birthDate'] as String?;
      int? age;
      if (birthDateStr != null) {
        final birth = DateTime.tryParse(birthDateStr);
        if (birth != null) {
          final now = DateTime.now();
          age = now.year - birth.year - (now.month < birth.month || (now.month == birth.month && now.day < birth.day) ? 1 : 0);
        }
      }

      setState(() {
        _name = user['name'] as String? ?? '';
        _email = user['email'] as String? ?? '';
        _phone = user['phone'] as String? ?? '';
        _bloodGroup = pat['bloodGroup'] as String?;
        _height = (pat['height'] as num?)?.toDouble();
        _weight = (pat['weight'] as num?)?.toDouble();
        _age = age;
        _allergies = (pat['allergies'] as List<dynamic>?)?.cast<String>() ?? [];
        _conditions = (pat['chronicConditions'] as List<dynamic>?)?.cast<String>() ?? [];
      });
    } catch (_) {}
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.primary,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const SizedBox(height: 48),
                    const CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _name.isEmpty ? '—' : _name,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email.isEmpty ? 'Patient' : _email,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ]),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _healthSummaryCards(),
                  const SizedBox(height: 20),
                  if (_allergies.isNotEmpty || _conditions.isNotEmpty) ...[
                    _medicalTagsCard(),
                    const SizedBox(height: 16),
                  ],
                  if (_phone.isNotEmpty) ...[
                    _contactCard(),
                    const SizedBox(height: 16),
                  ],
                  _sectionCard([
                    _menuItem(Icons.person_outline, 'Edit Profile', onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditPatientProfileScreen()));
                      _load();
                    }),
                  ]),
                  const SizedBox(height: 16),
                  _sectionCard([
                    _menuItem(Icons.help_outline, 'Help & Support', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                  }),
                  ]),
                  const SizedBox(height: 16),
                  _sectionCard([
                    _menuItem(Icons.logout, 'Logout', color: AppColors.error, onTap: _logout),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _healthSummaryCards() {
    return Row(children: [
      Expanded(child: _statCard('Blood Group', _bloodGroup ?? '—', Icons.bloodtype_outlined, const Color(0xFFEF4444))),
      const SizedBox(width: 12),
      Expanded(child: _statCard('Height', _height != null ? '${_height!.toInt()} cm' : '—', Icons.height, AppColors.primary)),
      const SizedBox(width: 12),
      Expanded(child: _statCard('Weight', _weight != null ? '${_weight!.toInt()} kg' : '—', Icons.monitor_weight_outlined, AppColors.secondary)),
      if (_age != null) ...[
        const SizedBox(width: 12),
        Expanded(child: _statCard('Age', '$_age yrs', Icons.cake_outlined, const Color(0xFFF59E0B))),
      ],
    ]);
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _medicalTagsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_allergies.isNotEmpty) ...[
          const Text('Allergies', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: _allergies.map((a) => _tag(a, const Color(0xFFEF4444))).toList()),
          const SizedBox(height: 12),
        ],
        if (_conditions.isNotEmpty) ...[
          const Text('Chronic Conditions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: _conditions.map((c) => _tag(c, AppColors.warning)).toList()),
        ],
      ]),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        const Icon(Icons.phone_outlined, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(_phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      ]),
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _menuItem(IconData icon, String label, {Color? color, VoidCallback? onTap}) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w500)),
      trailing: color == null
          ? const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary)
          : null,
      onTap: onTap,
    );
  }
}
