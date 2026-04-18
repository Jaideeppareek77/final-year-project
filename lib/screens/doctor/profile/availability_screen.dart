import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../services/doctor_service.dart';
import '../../../widgets/app_button.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final _authService = AuthService();
  final _doctorService = DoctorService();
  bool _loading = true;
  bool _saving = false;
  String? _userId;

  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<bool> _enabled = List.filled(7, false);
  final List<TimeOfDay> _start = List.generate(7, (_) => const TimeOfDay(hour: 9, minute: 0));
  final List<TimeOfDay> _end = List.generate(7, (_) => const TimeOfDay(hour: 21, minute: 0));
  final List<int> _slotDuration = List.filled(7, 30);

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final userId = await _authService.getUserId();
    if (userId == null || !mounted) return;
    _userId = userId;
    try {
      final data = await _doctorService.getDoctorById(userId);
      if (!mounted) return;
      final doc = data['doctorProfile'] as Map<String, dynamic>? ?? {};
      final avail = (doc['availability'] as List<dynamic>?) ?? [];
      for (final a in avail) {
        final day = a['dayOfWeek'] as int? ?? -1;
        if (day < 0 || day > 6) continue;
        _enabled[day] = true;
        _start[day] = _parseTime(a['startTime'] as String? ?? '09:00');
        _end[day] = _parseTime(a['endTime'] as String? ?? '21:00');
        _slotDuration[day] = a['slotDurationMinutes'] as int? ?? 30;
      }
      setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(int day, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start[day] : _end[day],
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _start[day] = picked;
      } else {
        _end[day] = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_userId == null) return;
    setState(() => _saving = true);
    try {
      final availability = <Map<String, dynamic>>[];
      for (int i = 0; i < 7; i++) {
        if (!_enabled[i]) continue;
        availability.add({
          'dayOfWeek': i,
          'startTime': _formatTime(_start[i]),
          'endTime': _formatTime(_end[i]),
          'slotDurationMinutes': _slotDuration[i],
        });
      }
      await _doctorService.updateAvailability(_userId!, availability);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Availability updated successfully'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update availability'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Availability')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemCount: 7,
                    itemBuilder: (_, i) => _buildDayCard(i),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  child: AppButton(label: 'Save Availability', onPressed: _save, isLoading: _saving),
                ),
              ],
            ),
    );
  }

  Widget _buildDayCard(int day) {
    final isOn = _enabled[day];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOn ? AppColors.primary : AppColors.border, width: isOn ? 1.5 : 1),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isOn ? AppColors.primaryLight : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _days[day],
                  style: TextStyle(
                    color: isOn ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: Text(_days[day], style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              isOn
                  ? '${_start[day].format(context)} – ${_end[day].format(context)}'
                  : 'Not available',
              style: TextStyle(
                color: isOn ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: Switch(
              value: isOn,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primaryLight,
              onChanged: (v) => setState(() => _enabled[day] = v),
            ),
          ),
          if (isOn) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: _timeTile('Start Time', _start[day], () => _pickTime(day, true))),
                    const SizedBox(width: 12),
                    Expanded(child: _timeTile('End Time', _end[day], () => _pickTime(day, false))),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Slot Duration:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: <int>[15, 30, 45, 60]
                        .map<Widget>((d) => _slotChip(day, d))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeTile(String label, TimeOfDay time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.access_time, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              time.format(context),
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _slotChip(int day, int minutes) {
    final selected = _slotDuration[day] == minutes;
    return GestureDetector(
      onTap: () => setState(() => _slotDuration[day] = minutes),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          '${minutes}m',
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
