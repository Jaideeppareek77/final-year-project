import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../models/appointment_model.dart';
import '../../../services/appointment_service.dart';
import '../../../widgets/appointment_card.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _service = AppointmentService();
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

  Future<void> _updateStatus(String id, String status, {String? notes, String? cancelReason}) async {
    try {
      await _service.updateAppointment(id, status: status, notes: notes, cancelReason: cancelReason);
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
        title: const Text('Appointments'),
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
        isDoctor: true,
        onConfirm: status == 'pending' ? () => _updateStatus(appts[i].id, 'confirmed') : null,
        onCancel: (status == 'pending' || status == 'confirmed') ? () => _updateStatus(appts[i].id, 'cancelled', cancelReason: 'Doctor cancelled') : null,
        onComplete: status == 'confirmed' ? () => _updateStatus(appts[i].id, 'completed') : null,
      ),
    );
  }
}
