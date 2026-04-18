import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../constants/api_constants.dart';
import '../../../models/vital_model.dart';
import '../../../services/api_client.dart';
import '../../../services/vital_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _vitalService = VitalService();
  final _dio = ApiClient.instance.dio;
  VitalModel? _latestVitals;
  List<dynamic> _records = [];
  bool _loadingVitals = true;
  bool _loadingRecords = true;

  static const _categoryColors = {
    'lab_report': Color(0xFF3B82F6),
    'imaging': Color(0xFF8B5CF6),
    'prescription': Color(0xFF10B981),
    'vaccination': Color(0xFFF59E0B),
    'allergy': Color(0xFFEF4444),
    'surgery': Color(0xFFEC4899),
    'other': Color(0xFF6B7280),
  };

  static const _categoryIcons = {
    'lab_report': Icons.science_outlined,
    'imaging': Icons.image_outlined,
    'prescription': Icons.medication_outlined,
    'vaccination': Icons.vaccines_outlined,
    'allergy': Icons.warning_amber_outlined,
    'surgery': Icons.medical_services_outlined,
    'other': Icons.folder_outlined,
  };

  @override
  void initState() {
    super.initState();
    _loadVitals();
    _loadRecords();
  }

  Future<void> _loadVitals() async {
    try {
      final data = await _vitalService.getLatestVitals();
      if (!mounted) return;
      setState(() {
        _latestVitals = data != null ? VitalModel.fromJson(data) : null;
        _loadingVitals = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingVitals = false);
    }
  }

  Future<void> _loadRecords() async {
    try {
      final resp = await _dio.get(ApiConstants.healthRecords);
      if (!mounted) return;
      setState(() {
        _records = (resp.data['records'] as List? ?? []);
        _loadingRecords = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingRecords = false);
    }
  }

  Future<void> _deleteRecord(String id) async {
    try {
      await _dio.delete('${ApiConstants.healthRecords}/$id');
      if (!mounted) return;
      setState(() => _records.removeWhere((r) => r['_id'] == id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted'), backgroundColor: AppColors.success),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete record'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Health')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogVitalsSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Vitals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        onRefresh: () async { await _loadVitals(); await _loadRecords(); },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            _buildVitalsCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Health Records', style: Theme.of(context).textTheme.displaySmall),
                TextButton.icon(
                  onPressed: _showAddRecordSheet,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecordsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsCard() {
    if (_loadingVitals) return const Center(child: CircularProgressIndicator());
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, Color(0xFF009688)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Latest Vitals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        if (_latestVitals != null) ...[
          const SizedBox(height: 4),
          Text(
            'Recorded: ${_formatDate(_latestVitals!.recordedAt)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        if (_latestVitals == null)
          const Center(child: Text('No vitals recorded yet', style: TextStyle(color: Colors.white70)))
        else
          Wrap(spacing: 12, runSpacing: 12, children: [
            if (_latestVitals!.bloodPressureSystolic != null)
              _vitalChip('BP', '${_latestVitals!.bloodPressureSystolic!.toInt()}/${_latestVitals!.bloodPressureDiastolic?.toInt()} mmHg', Icons.favorite_outline),
            if (_latestVitals!.heartRate != null)
              _vitalChip('HR', '${_latestVitals!.heartRate!.toInt()} bpm', Icons.monitor_heart_outlined),
            if (_latestVitals!.oxygenSaturation != null)
              _vitalChip('SpO2', '${_latestVitals!.oxygenSaturation!.toInt()}%', Icons.air),
            if (_latestVitals!.bloodSugar != null)
              _vitalChip('Sugar', '${_latestVitals!.bloodSugar!.toInt()} mg/dL', Icons.water_drop_outlined),
            if (_latestVitals!.weight != null)
              _vitalChip('Weight', '${_latestVitals!.weight} kg', Icons.monitor_weight_outlined),
          ]),
      ]),
    );
  }

  Widget _vitalChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _buildRecordsList() {
    if (_loadingRecords) return const Center(child: CircularProgressIndicator());
    if (_records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Column(children: [
          Icon(Icons.folder_open_outlined, size: 48, color: AppColors.border),
          SizedBox(height: 12),
          Text('No health records yet', style: TextStyle(color: AppColors.textSecondary)),
          SizedBox(height: 4),
          Text('Tap "Add" to upload records', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ])),
      );
    }
    return Column(
      children: _records.map((r) => _buildRecordCard(r as Map<String, dynamic>)).toList(),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final category = record['category'] as String? ?? 'other';
    final color = _categoryColors[category] ?? const Color(0xFF6B7280);
    final icon = _categoryIcons[category] ?? Icons.folder_outlined;
    final date = record['date'] != null ? DateTime.tryParse(record['date'] as String) : null;
    final id = record['_id'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(record['title'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(50)),
              child: Text(_formatCategory(category), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
            ),
            if (date != null) ...[
              const SizedBox(width: 8),
              Text(_formatDate(date), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ]),
          if ((record['description'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(record['description'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ])),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: () => _confirmDelete(id, record['title'] as String? ?? ''),
        ),
      ]),
    );
  }

  void _confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Delete "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(context); _deleteRecord(id); }, child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }

  void _showLogVitalsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LogVitalsSheet(onSaved: _loadVitals),
    );
  }

  void _showAddRecordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddRecordSheet(onSaved: _loadRecords),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _formatCategory(String c) => c.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');
}

// ─── Log Vitals Sheet ────────────────────────────────────────────────────────

class _LogVitalsSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _LogVitalsSheet({required this.onSaved});
  @override
  State<_LogVitalsSheet> createState() => _LogVitalsSheetState();
}

class _LogVitalsSheetState extends State<_LogVitalsSheet> {
  final _bpSysCtrl = TextEditingController();
  final _bpDiaCtrl = TextEditingController();
  final _hrCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  final _sugarCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _service = VitalService();
  bool _saving = false;

  @override
  void dispose() {
    _bpSysCtrl.dispose(); _bpDiaCtrl.dispose(); _hrCtrl.dispose();
    _spo2Ctrl.dispose(); _sugarCtrl.dispose(); _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.logVitals(
        bpSystolic: _bpSysCtrl.text.isNotEmpty ? double.parse(_bpSysCtrl.text) : null,
        bpDiastolic: _bpDiaCtrl.text.isNotEmpty ? double.parse(_bpDiaCtrl.text) : null,
        heartRate: _hrCtrl.text.isNotEmpty ? double.parse(_hrCtrl.text) : null,
        oxygenSaturation: _spo2Ctrl.text.isNotEmpty ? double.parse(_spo2Ctrl.text) : null,
        bloodSugar: _sugarCtrl.text.isNotEmpty ? double.parse(_sugarCtrl.text) : null,
        weight: _weightCtrl.text.isNotEmpty ? double.parse(_weightCtrl.text) : null,
      );
      if (!mounted) return;
      widget.onSaved();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Log Vitals', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: AppTextField(hint: 'Systolic', label: 'BP Systolic', controller: _bpSysCtrl, keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: AppTextField(hint: 'Diastolic', label: 'BP Diastolic', controller: _bpDiaCtrl, keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: AppTextField(hint: 'bpm', label: 'Heart Rate', controller: _hrCtrl, keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: AppTextField(hint: '%', label: 'SpO2', controller: _spo2Ctrl, keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: AppTextField(hint: 'mg/dL', label: 'Blood Sugar', controller: _sugarCtrl, keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: AppTextField(hint: 'kg', label: 'Weight', controller: _weightCtrl, keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 20),
        AppButton(label: 'Save Vitals', onPressed: _save, isLoading: _saving),
      ]),
    );
  }
}

// ─── Add Health Record Sheet ─────────────────────────────────────────────────

class _AddRecordSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddRecordSheet({required this.onSaved});
  @override
  State<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<_AddRecordSheet> {
  final _dio = ApiClient.instance.dio;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'other';
  DateTime _date = DateTime.now();
  bool _saving = false;

  static const _categories = [
    'lab_report', 'imaging', 'prescription', 'vaccination', 'allergy', 'surgery', 'other',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    setState(() => _saving = true);
    try {
      await _dio.post(ApiConstants.healthRecords, data: {
        'title': _titleCtrl.text.trim(),
        'category': _category,
        'description': _descCtrl.text.trim(),
        'date': _date.toIso8601String(),
      });
      if (!mounted) return;
      widget.onSaved();
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add record'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String _formatCategory(String c) => c.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Add Health Record', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 20),
        AppTextField(hint: 'e.g. Blood Test Report', label: 'Title', controller: _titleCtrl,
          prefixIcon: const Icon(Icons.title, size: 20)),
        const SizedBox(height: 12),
        Text('Category', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          ),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(_formatCategory(c)))).toList(),
          onChanged: (v) => setState(() => _category = v ?? 'other'),
        ),
        const SizedBox(height: 12),
        AppTextField(hint: 'Optional notes...', label: 'Description', controller: _descCtrl, maxLines: 2,
          prefixIcon: const Icon(Icons.notes, size: 20)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text('${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(color: AppColors.textPrimary)),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        AppButton(label: 'Save Record', onPressed: _save, isLoading: _saving),
      ]),
    );
  }
}
