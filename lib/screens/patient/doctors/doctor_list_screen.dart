import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app_theme.dart';
import '../../../models/doctor_model.dart';
import '../../../services/doctor_service.dart';
import '../../../widgets/doctor_card.dart';
import 'doctor_profile_screen.dart';

class DoctorListScreen extends StatefulWidget {
  final String? initialSpecialization;

  const DoctorListScreen({super.key, this.initialSpecialization});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final _service = DoctorService();
  final _searchCtrl = TextEditingController();
  List<DoctorModel> _doctors = [];
  bool _loading = true;
  String? _selectedSpec;

  final _specializations = ['All', 'General', 'Cardiology', 'Dermatology', 'Pediatrics', 'Neurology', 'Orthopedics', 'Gynecology'];

  @override
  void initState() {
    super.initState();
    _selectedSpec = widget.initialSpecialization;
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getDoctors(
        search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
        specialization: (_selectedSpec == null || _selectedSpec == 'All') ? null : _selectedSpec!.toLowerCase(),
      );
      if (!mounted) return;
      setState(() {
        _doctors = (data['doctors'] as List).map((d) => DoctorModel.fromJson(d as Map<String, dynamic>)).toList();
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
        title: const Text('Find Doctors'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _loadDoctors(),
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () { _searchCtrl.clear(); _loadDoctors(); })
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSpecFilter(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDoctors,
              child: _loading ? _buildShimmer() : _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecFilter() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _specializations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = _specializations[i];
          final selected = s == (_selectedSpec ?? 'All');
          return GestureDetector(
            onTap: () { setState(() => _selectedSpec = s == 'All' ? null : s); _loadDoctors(); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: selected ? AppColors.primary : AppColors.border),
              ),
              child: Text(s, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    if (_doctors.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off, size: 64, color: AppColors.border),
        SizedBox(height: 16),
        Text('No doctors found', style: TextStyle(color: AppColors.textSecondary)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _doctors.length,
      itemBuilder: (_, i) => DoctorCard(
        doctor: _doctors[i],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctorId: _doctors[i].id))),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, __) => Container(height: 90, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}
