import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app_theme.dart';
import '../../../models/doctor_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/doctor_service.dart';
import '../../../widgets/doctor_card.dart';
import '../doctors/doctor_profile_screen.dart';
import '../doctors/doctor_list_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final _doctorService = DoctorService();
  final _authService = AuthService();
  List<DoctorModel> _topDoctors = [];
  String _userName = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _authService.getUserName(),
        _doctorService.getDoctors(sortBy: 'rating', limit: 5),
      ]);
      if (!mounted) return;
      setState(() {
        _userName = (results[0] as String?) ?? '';
        final data = results[1] as Map<String, dynamic>;
        _topDoctors = (data['doctors'] as List).map((d) => DoctorModel.fromJson(d as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildSpecialistChips(),
                  const SizedBox(height: 28),
                  _buildSectionHeader('Top Doctors', onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorListScreen()))),
                  const SizedBox(height: 12),
                  _loading ? _buildShimmer() : _buildDoctorList(),
                  const SizedBox(height: 28),
                  _buildHealthTip(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      floating: true,
      snap: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryDark]),
          ),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              const SizedBox(height: 4),
              Text(_userName.isEmpty ? 'Welcome!' : 'Hi, $_userName 👋',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorListScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          const Icon(Icons.search, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text('Search doctors, specialists...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildSpecialistChips() {
    final specs = [
      {'label': 'General', 'icon': Icons.medical_services_outlined},
      {'label': 'Cardiology', 'icon': Icons.favorite_outline},
      {'label': 'Dermatology', 'icon': Icons.face_outlined},
      {'label': 'Pediatrics', 'icon': Icons.child_care_outlined},
      {'label': 'Neurology', 'icon': Icons.psychology_outlined},
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: specs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final spec = specs[i];
          return ActionChip(
            avatar: Icon(spec['icon'] as IconData, size: 16, color: AppColors.primary),
            label: Text(spec['label'] as String),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorListScreen(initialSpecialization: (spec['label'] as String).toLowerCase()))),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.displaySmall),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('See All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
      ],
    );
  }

  Widget _buildDoctorList() {
    if (_topDoctors.isEmpty) return const Center(child: Text('No doctors found'));
    return Column(
      children: _topDoctors.map((d) => DoctorCard(doctor: d, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctorId: d.id)));
      })).toList(),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(children: List.generate(3, (_) => Container(height: 90, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))))),
    );
  }

  Widget _buildHealthTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF00BFA5), Color(0xFF009688)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Health Tip', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              const Text('Drink at least 8 glasses of water daily to stay hydrated and boost your immune system.', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(50)),
                child: const Text('Learn More', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.water_drop_rounded, size: 60, color: Colors.white70),
      ]),
    );
  }
}
