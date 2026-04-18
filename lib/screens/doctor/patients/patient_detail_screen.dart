import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../services/api_client.dart';
import '../../chat/chat_room_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientDetailScreen({super.key, required this.patientId, required this.patientName});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final _dio = ApiClient.instance.dio;
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final resp = await _dio.get('/api/patients/${widget.patientId}');
      if (!mounted) return;
      setState(() { _data = resp.data as Map<String, dynamic>; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('Failed to load patient'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final d = _data!;
    final pat = d['patientProfile'] as Map<String, dynamic>? ?? {};
    final vitals = (d['recentVitals'] as List<dynamic>?) ?? [];
    final prescriptions = (d['recentPrescriptions'] as List<dynamic>?) ?? [];
    final allergies = (pat['allergies'] as List<dynamic>?)?.cast<String>() ?? [];
    final conditions = (pat['chronicConditions'] as List<dynamic>?)?.cast<String>() ?? [];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ChatRoomScreen(otherUserId: widget.patientId, otherUserName: widget.patientName),
              )),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryDark]),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 48),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white24,
                  child: Text(
                    widget.patientName.isNotEmpty ? widget.patientName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(d['name'] as String? ?? widget.patientName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(d['email'] as String? ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Health summary
              Row(children: [
                Expanded(child: _statCard('Blood Group', pat['bloodGroup'] as String? ?? '—', Icons.bloodtype_outlined, const Color(0xFFEF4444))),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Height', pat['height'] != null ? '${(pat['height'] as num).toInt()} cm' : '—', Icons.height, AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Weight', pat['weight'] != null ? '${(pat['weight'] as num).toInt()} kg' : '—', Icons.monitor_weight_outlined, AppColors.secondary)),
              ]),
              const SizedBox(height: 16),

              // Contact
              if ((d['phone'] as String?) != null) ...[
                _infoCard(Icons.phone_outlined, 'Phone', d['phone'] as String),
                const SizedBox(height: 16),
              ],

              // Allergies & conditions
              if (allergies.isNotEmpty || conditions.isNotEmpty) ...[
                _tagsCard(allergies, conditions),
                const SizedBox(height: 16),
              ],

              // Emergency contact
              if ((pat['emergencyContactName'] as String?)?.isNotEmpty == true) ...[
                _sectionHeader('Emergency Contact'),
                const SizedBox(height: 8),
                _infoCard(Icons.emergency_outlined, pat['emergencyContactName'] as String, pat['emergencyContactPhone'] as String? ?? ''),
                const SizedBox(height: 16),
              ],

              // Recent vitals
              _sectionHeader('Recent Vitals'),
              const SizedBox(height: 8),
              vitals.isEmpty
                  ? _emptyCard('No vitals recorded')
                  : Column(children: vitals.take(3).map((v) => _vitalCard(v as Map<String, dynamic>)).toList()),
              const SizedBox(height: 16),

              // Recent prescriptions
              _sectionHeader('Recent Prescriptions'),
              const SizedBox(height: 8),
              prescriptions.isEmpty
                  ? _emptyCard('No prescriptions')
                  : Column(children: prescriptions.take(3).map((p) => _prescriptionCard(p as Map<String, dynamic>)).toList()),
            ]),
          ),
        ),
      ],
    );
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

  Widget _infoCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ]),
      ]),
    );
  }

  Widget _tagsCard(List<String> allergies, List<String> conditions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (allergies.isNotEmpty) ...[
          const Text('Allergies', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: allergies.map((a) => _tag(a, const Color(0xFFEF4444))).toList()),
          if (conditions.isNotEmpty) const SizedBox(height: 12),
        ],
        if (conditions.isNotEmpty) ...[
          const Text('Chronic Conditions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: conditions.map((c) => _tag(c, AppColors.warning)).toList()),
        ],
      ]),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _sectionHeader(String title) =>
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary));

  Widget _emptyCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(msg, style: const TextStyle(color: AppColors.textSecondary))),
    );
  }

  Widget _vitalCard(Map<String, dynamic> v) {
    final date = v['recordedAt'] != null ? DateTime.tryParse(v['recordedAt'] as String) : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        const Icon(Icons.monitor_heart_outlined, color: AppColors.secondary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Wrap(spacing: 12, children: [
          if (v['bloodPressureSystolic'] != null) _vitalItem('BP', '${v['bloodPressureSystolic']}/${v['bloodPressureDiastolic']}'),
          if (v['heartRate'] != null) _vitalItem('HR', '${v['heartRate']} bpm'),
          if (v['oxygenSaturation'] != null) _vitalItem('SpO2', '${v['oxygenSaturation']}%'),
          if (v['bloodSugar'] != null) _vitalItem('Sugar', '${v['bloodSugar']} mg/dL'),
        ])),
        if (date != null) Text('${date.day}/${date.month}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ]),
    );
  }

  Widget _vitalItem(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    ]);
  }

  Widget _prescriptionCard(Map<String, dynamic> p) {
    final date = p['createdAt'] != null ? DateTime.tryParse(p['createdAt'] as String) : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        const Icon(Icons.medication_outlined, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p['diagnosis'] as String? ?? 'Prescription', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          if ((p['notes'] as String?)?.isNotEmpty == true)
            Text(p['notes'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        if (date != null) Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ]),
    );
  }
}
