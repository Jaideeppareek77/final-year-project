import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../models/appointment_model.dart';
import '../../../services/appointment_service.dart';
import '../../../services/doctor_service.dart';
import '../../../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _service = AppointmentService();
  final _doctorService = DoctorService();
  final _statuses = ['pending', 'confirmed', 'completed', 'cancelled'];
  final Map<String, List<AppointmentModel>> _cache = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() { if (!_tabCtrl.indexIsChanging) _loadTab(_tabCtrl.index); });
    _loadTab(0);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTab(int index) async {
    final status = _statuses[index];
    setState(() => _loading = true);
    try {
      final data = await _service.getAppointments(status: status);
      if (!mounted) return;
      setState(() {
        _cache[status] = (data['appointments'] as List).map((a) => AppointmentModel.fromJson(a as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showRatingDialog(AppointmentModel appt) async {
    double selected = 0;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Rate Doctor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How was your experience with Dr. ${appt.doctorName}?', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => setS(() => selected = star.toDouble()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        selected >= star ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: selected == 0 ? null : () async {
                Navigator.pop(ctx);
                try {
                  await _doctorService.rateDoctor(appt.doctorId, selected);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rating submitted!'), backgroundColor: AppColors.success),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit rating'), backgroundColor: AppColors.error),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelAppointment(String id, String status) async {
    try {
      await _service.updateAppointment(id, status: 'cancelled', cancelReason: 'Patient cancelled');
      _loadTab(_tabCtrl.index);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'Confirmed'), Tab(text: 'Completed'), Tab(text: 'Cancelled')],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: List.generate(4, (i) {
          final status = _statuses[i];
          return RefreshIndicator(
            onRefresh: () => _loadTab(i),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildList(_cache[status] ?? [], status),
          );
        }),
      ),
    );
  }

  Widget _buildList(List<AppointmentModel> appts, String status) {
    if (appts.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.calendar_today_outlined, size: 56, color: AppColors.border),
        const SizedBox(height: 16),
        Text('No $status appointments', style: const TextStyle(color: AppColors.textSecondary)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appts.length,
      itemBuilder: (_, i) => AppointmentCard(
        appointment: appts[i],
        isDoctor: false,
        onCancel: status == 'pending' ? () => _cancelAppointment(appts[i].id, status) : null,
        onRate: status == 'completed' ? () => _showRatingDialog(appts[i]) : null,
      ),
    );
  }
}
