import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app_theme.dart';
import '../../../models/doctor_model.dart';
import '../../../services/appointment_service.dart';
import '../../../services/doctor_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class BookingScreen extends StatefulWidget {
  final DoctorModel doctor;

  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _appointmentService = AppointmentService();
  final _doctorService = DoctorService();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  List<String> _availableSlots = [];
  bool _loading = false;
  bool _loadingSlots = false;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSlots() async {
    setState(() { _loadingSlots = true; _selectedSlot = null; });
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final data = await _doctorService.getSlots(widget.doctor.id, dateStr);
      if (!mounted) return;
      setState(() { _availableSlots = (data['availableSlots'] as List).cast<String>(); _loadingSlots = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  Future<void> _book() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a time slot')));
      return;
    }

    setState(() => _loading = true);
    try {
      final parts = _selectedSlot!.split(':');
      final dateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, int.parse(parts[0]), int.parse(parts[1]));

      await _appointmentService.createAppointment(
        doctorId: widget.doctor.id,
        date: dateTime.toIso8601String(),
        phone: _phoneCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
            const SizedBox(height: 16),
            const Text('Appointment Booked!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Your appointment with ${widget.doctor.name} on ${DateFormat('MMM dd, yyyy').format(_selectedDate)} at $_selectedSlot has been booked.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          ]),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['error'] as String? ?? 'Booking failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildDoctorCard(),
            const SizedBox(height: 24),
            _buildDatePicker(),
            const SizedBox(height: 24),
            Text('Available Slots', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 12),
            _buildSlotGrid(),
            const SizedBox(height: 24),
            AppTextField(
              hint: 'Your phone number',
              label: 'Phone Number',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              validator: (v) => v != null && v.length >= 10 ? null : 'Enter valid phone',
            ),
            const SizedBox(height: 16),
            AppTextField(
              hint: 'Describe your symptoms or reason for visit...',
              label: 'Description (Optional)',
              controller: _descCtrl,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.notes_outlined, size: 20),
            ),
            const SizedBox(height: 32),
            AppButton(label: 'Book Appointment', onPressed: _book, isLoading: _loading),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white.withOpacity(0.2),
          backgroundImage: widget.doctor.profilePhoto != null ? NetworkImage(widget.doctor.profilePhoto!) : null,
          child: widget.doctor.profilePhoto == null ? const Icon(Icons.person, color: Colors.white) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.doctor.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(_capitalize(widget.doctor.specialization), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
          ]),
        ),
        Text('₹${widget.doctor.consultationFee.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ]),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final date = DateTime.now().add(Duration(days: i + 1));
              final selected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);
              return GestureDetector(
                onTap: () { setState(() => _selectedDate = date); _loadSlots(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(DateFormat('EEE').format(date), style: TextStyle(fontSize: 11, color: selected ? Colors.white70 : AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd').format(date), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: selected ? Colors.white : AppColors.textPrimary)),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSlotGrid() {
    if (_loadingSlots) return const Center(child: CircularProgressIndicator());
    if (_availableSlots.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('No slots available for this date', style: TextStyle(color: AppColors.textSecondary)),
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableSlots.map((slot) {
        final selected = slot == _selectedSlot;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            ),
            child: Text(slot, style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        );
      }).toList(),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
