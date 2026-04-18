import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app_theme.dart';
import '../../../models/doctor_model.dart';
import '../../../services/doctor_service.dart';
import '../appointments/booking_screen.dart';
import '../../chat/chat_room_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final String doctorId;

  const DoctorProfileScreen({super.key, required this.doctorId});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _service = DoctorService();
  DoctorModel? _doctor;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _service.getDoctorById(widget.doctorId);
      if (!mounted) return;
      setState(() { _doctor = DoctorModel.fromJson(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading ? const Center(child: CircularProgressIndicator()) : _buildContent(),
      floatingActionButton: _doctor == null ? null : FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(doctor: _doctor!))),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.calendar_today, color: Colors.white),
        label: const Text('Book Appointment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent() {
    final doc = _doctor!;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(otherUserId: doc.id, otherUserName: doc.name))),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryDark]),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: doc.profilePhoto != null ? NetworkImage(doc.profilePhoto!) : null,
                    child: doc.profilePhoto == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(doc.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_capitalize(doc.specialization), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 4),
                    Text(doc.rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    const Icon(Icons.work_outline, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text('${doc.yearsExperience} yrs exp', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _infoRow([
                _infoChip(Icons.schedule, '${doc.openHour} - ${doc.closeHour}'),
                _infoChip(Icons.currency_rupee, '${doc.consultationFee.toInt()} /visit'),
              ]),
              const SizedBox(height: 20),
              if (doc.specification != null && doc.specification!.isNotEmpty) ...[
                _sectionTitle('About'),
                const SizedBox(height: 8),
                Text(doc.specification!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.6)),
                const SizedBox(height: 20),
              ],
              if (doc.address != null) ...[
                _sectionTitle('Location'),
                const SizedBox(height: 8),
                _iconRow(Icons.location_on_outlined, doc.address!),
                const SizedBox(height: 20),
              ],
              if (doc.phone != null) ...[
                _sectionTitle('Contact'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('tel:${doc.phone}')),
                  child: _iconRow(Icons.phone_outlined, doc.phone!, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
              ],
              if (doc.languages.isNotEmpty) ...[
                _sectionTitle('Languages'),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: doc.languages.map((l) => Chip(label: Text(l))).toList()),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: Theme.of(context).textTheme.displaySmall);

  Widget _infoRow(List<Widget> chips) => Wrap(spacing: 12, runSpacing: 8, children: chips);

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(50)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _iconRow(IconData icon, String text, {Color? color}) {
    return Row(children: [
      Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color ?? AppColors.textSecondary))),
    ]);
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
