import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app_theme.dart';
import '../../../models/appointment_model.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/stat_card.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final _authService = AuthService();
  final _dio = ApiClient.instance.dio;
  Map<String, dynamic>? _stats;
  String _name = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final name = await _authService.getUserName();
      final resp = await _dio.get('/api/dashboard');
      if (!mounted) return;
      final body = resp.data as Map<String, dynamic>;
      final stats = body['stats'] as Map<String, dynamic>? ?? {};
      final schedule = body['todaySchedule'] as List<dynamic>? ?? [];
      setState(() {
        _name = name ?? '';
        _stats = {
          'appointmentsToday': stats['todayAppointments'],
          'appointmentsPending': stats['pendingApprovals'],
          'totalPatients': stats['totalPatients'],
          'averageRating': stats['avgRating'],
          'upcomingAppointments': schedule,
        };
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _loading ? _shimmerGrid() : _buildStatsGrid(),
                  const SizedBox(height: 24),
                  Text("Today's Schedule", style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 12),
                  _loading ? _shimmerList() : _buildSchedule(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 120,
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
              Text('Welcome back,', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              const SizedBox(height: 4),
              Text('Dr. $_name', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox.shrink();
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        StatCard(label: "Today's Appointments", value: '${_stats!['appointmentsToday'] ?? 0}', icon: Icons.calendar_today_rounded, color: AppColors.primary),
        StatCard(label: 'Pending', value: '${_stats!['appointmentsPending'] ?? 0}', icon: Icons.pending_actions_rounded, color: AppColors.warning),
        StatCard(label: 'Total Patients', value: '${_stats!['totalPatients'] ?? 0}', icon: Icons.people_rounded, color: AppColors.secondary),
        StatCard(label: 'Avg Rating', value: '${(_stats!['averageRating'] as num?)?.toStringAsFixed(1) ?? '-'}', icon: Icons.star_rounded, color: const Color(0xFFF59E0B)),
      ],
    );
  }

  Widget _buildSchedule() {
    final upcoming = (_stats?['upcomingAppointments'] as List<dynamic>?) ?? [];
    if (upcoming.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('No appointments scheduled today', style: TextStyle(color: AppColors.textSecondary)),
      ));
    }
    return Column(
      children: upcoming.map((a) {
        final appt = AppointmentModel.fromJson(a as Map<String, dynamic>);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            Container(width: 4, height: 48, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(appt.patientName, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(DateFormat('hh:mm a').format(appt.date), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              if (appt.description.isNotEmpty)
                Text(appt.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: appt.status == 'confirmed' ? AppColors.primaryLight : AppColors.warning.withOpacity(0.12),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                appt.status[0].toUpperCase() + appt.status.substring(1),
                style: TextStyle(color: appt.status == 'confirmed' ? AppColors.primary : AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        );
      }).toList(),
    );
  }

  Widget _shimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.3,
        children: List.generate(4, (_) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
      ),
    );
  }

  Widget _shimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(children: List.generate(3, (_) => Container(height: 80, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))))),
    );
  }
}
