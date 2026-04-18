import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isDoctor;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;
  final VoidCallback? onRate;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.isDoctor,
    this.onConfirm,
    this.onCancel,
    this.onComplete,
    this.onRate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(appointment.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  isDoctor ? appointment.patientName : appointment.doctorName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(50)),
                child: Text(
                  _capitalize(appointment.status),
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(DateFormat('MMM dd, yyyy · hh:mm a').format(appointment.date), style: Theme.of(context).textTheme.bodySmall),
            ]),
            if (appointment.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(appointment.description, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            if (_showActions()) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  bool _showActions() {
    if (!isDoctor && appointment.status == 'pending' && onCancel != null) return true;
    if (!isDoctor && appointment.status == 'completed' && onRate != null) return true;
    if (isDoctor && appointment.status == 'pending') return true;
    if (isDoctor && appointment.status == 'confirmed') return true;
    return false;
  }

  Widget _buildActions(BuildContext context) {
    if (!isDoctor && appointment.status == 'pending') {
      return AppointmentActionButton(label: 'Cancel', color: AppColors.error, onPressed: onCancel);
    }
    if (!isDoctor && appointment.status == 'completed') {
      return AppointmentActionButton(label: 'Rate Doctor', color: const Color(0xFFF59E0B), onPressed: onRate);
    }
    if (isDoctor && appointment.status == 'pending') {
      return Row(children: [
        Expanded(child: AppointmentActionButton(label: 'Confirm', color: AppColors.success, onPressed: onConfirm)),
        const SizedBox(width: 8),
        Expanded(child: AppointmentActionButton(label: 'Cancel', color: AppColors.error, onPressed: onCancel)),
      ]);
    }
    if (isDoctor && appointment.status == 'confirmed') {
      return Row(children: [
        Expanded(child: AppointmentActionButton(label: 'Complete', color: AppColors.primary, onPressed: onComplete)),
        const SizedBox(width: 8),
        Expanded(child: AppointmentActionButton(label: 'Cancel', color: AppColors.error, onPressed: onCancel)),
      ]);
    }
    return const SizedBox.shrink();
  }

  Color _statusColor(String status) => switch (status) {
    'pending' => AppColors.warning,
    'confirmed' => AppColors.primary,
    'completed' => AppColors.success,
    _ => AppColors.error,
  };

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class AppointmentActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const AppointmentActionButton({super.key, required this.label, required this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
