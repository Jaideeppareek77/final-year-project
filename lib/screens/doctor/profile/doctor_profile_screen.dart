import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../constants/api_constants.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
import '../../common/help_support_screen.dart';
import 'edit_profile_screen.dart';
import 'availability_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _authService = AuthService();
  final _dio = ApiClient.instance.dio;

  String _name = '';
  String _specialization = '';
  double _rating = 0;
  int _yearsExp = 0;
  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final resp = await _dio.get(ApiConstants.usersMe);
      final data = resp.data as Map<String, dynamic>;
      final doc = data['doctorProfile'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _name = data['name'] as String? ?? '';
        _email = data['email'] as String? ?? '';
        _phone = data['phone'] as String? ?? '';
        _specialization = doc['specialization'] as String? ?? 'General';
        _rating = (doc['rating'] as num?)?.toDouble() ?? 0.0;
        _yearsExp = (doc['yearsExperience'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
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
                    _name.isEmpty ? '—' : 'Dr. $_name',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _specialization.isEmpty ? 'Doctor' : _capitalize(_specialization),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                    const SizedBox(width: 4),
                    Text(_rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    const Icon(Icons.work_outline, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text('$_yearsExp yrs exp', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                ]),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_email.isNotEmpty || _phone.isNotEmpty) ...[
                  _infoCard(),
                  const SizedBox(height: 16),
                ],
                _sectionCard([
                  _menuItem(Icons.person_outline, 'Edit Profile', onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    _load();
                  }),
                  _divider(),
                  _menuItem(Icons.schedule_outlined, 'Manage Availability', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AvailabilityScreen()));
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
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          if (_email.isNotEmpty)
            _infoRow(Icons.email_outlined, _email),
          if (_email.isNotEmpty && _phone.isNotEmpty)
            const Divider(height: 16, color: AppColors.border),
          if (_phone.isNotEmpty)
            _infoRow(Icons.phone_outlined, _phone),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14))),
    ]);
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

  Widget _divider() => const Divider(height: 1, indent: 56, color: AppColors.border);
}
