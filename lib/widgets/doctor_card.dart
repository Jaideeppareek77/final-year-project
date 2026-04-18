import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback? onTap;
  final bool horizontal;

  const DoctorCard({super.key, required this.doctor, this.onTap, this.horizontal = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: horizontal ? 200 : double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: horizontal ? _buildHorizontalLayout(context) : _buildVerticalLayout(context),
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Row(
      children: [
        _avatar(60),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctor.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(_capitalize(doctor.specialization), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                const SizedBox(width: 4),
                Text(doctor.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${doctor.openHour} - ${doctor.closeHour}', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(50)),
          child: Text('₹${doctor.consultationFee.toInt()}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(56),
        const SizedBox(height: 10),
        Text(doctor.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(_capitalize(doctor.specialization), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
          const SizedBox(width: 4),
          Text(doctor.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ]),
      ],
    );
  }

  Widget _avatar(double radius) {
    return CircleAvatar(
      radius: radius / 2,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: doctor.profilePhoto != null ? NetworkImage(doctor.profilePhoto!) : null,
      child: doctor.profilePhoto == null ? const Icon(Icons.person, color: AppColors.primary) : null,
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
