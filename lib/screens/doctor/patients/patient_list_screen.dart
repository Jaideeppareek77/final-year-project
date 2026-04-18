import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../services/api_client.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _dio = ApiClient.instance.dio;
  final _searchCtrl = TextEditingController();
  List<dynamic> _patients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final resp = await _dio.get('/api/patients', queryParameters: {
        if (_searchCtrl.text.isNotEmpty) 'search': _searchCtrl.text,
        'limit': 50,
      });
      if (!mounted) return;
      setState(() {
        _patients = (resp.data['patients'] as List? ?? []);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () { _searchCtrl.clear(); _load(); })
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _patients.isEmpty
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.people_outline, size: 64, color: AppColors.border),
                    SizedBox(height: 16),
                    Text('No patients yet', style: TextStyle(color: AppColors.textSecondary)),
                    SizedBox(height: 4),
                    Text('Patients appear after their first appointment', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ]))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _patients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _buildCard(_patients[i] as Map<String, dynamic>),
                  ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> p) {
    final pat = p['patientProfile'] as Map<String, dynamic>? ?? {};
    final name = p['name'] as String? ?? '';
    final email = p['email'] as String? ?? '';
    final phone = p['phone'] as String? ?? '';
    final bloodGroup = pat['bloodGroup'] as String?;
    final id = p['_id'] as String;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => PatientDetailScreen(patientId: id, patientName: name),
      )),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 2),
            if (phone.isNotEmpty)
              Text(phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))
            else if (email.isNotEmpty)
              Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ])),
          if (bloodGroup != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withAlpha(20),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFFEF4444).withAlpha(77)),
              ),
              child: Text(bloodGroup, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}
