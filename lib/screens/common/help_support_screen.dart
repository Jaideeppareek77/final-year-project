import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedIndex;

  static const _faqs = [
    {
      'q': 'How do I book an appointment?',
      'a': 'Go to the Doctors tab, search for a doctor, open their profile, and tap "Book Appointment". Select a date and available time slot, then confirm.',
    },
    {
      'q': 'How do I cancel an appointment?',
      'a': 'Go to the Appointments tab, find the appointment you want to cancel, tap on it and select "Cancel". Cancellation is only allowed for pending or confirmed appointments.',
    },
    {
      'q': 'How do I chat with a doctor?',
      'a': 'Open any doctor\'s profile and tap the chat icon in the top-right corner. You can also access conversations from the Chat tab.',
    },
    {
      'q': 'How do I log my vitals?',
      'a': 'Go to the Health tab and tap "Log Vitals". Enter your blood pressure, heart rate, SpO2, blood sugar, or weight and save.',
    },
    {
      'q': 'How do I add a health record?',
      'a': 'In the Health tab, scroll to "Health Records" and tap the "Add" button. Enter the title, category, description and date of the record.',
    },
    {
      'q': 'How do I update my profile?',
      'a': 'Go to the Profile tab and tap "Edit Profile". You can update your personal info, medical details, and emergency contact.',
    },
    {
      'q': 'How does a doctor set availability?',
      'a': 'Doctors can go to Profile → Manage Availability, enable days of the week, set start/end times, and choose appointment slot duration.',
    },
    {
      'q': 'How do I update my consultation fee?',
      'a': 'Doctors can go to Profile → Edit Profile and update the Consultation Fee field under Professional Info.',
    },
    {
      'q': 'Why am I not seeing any doctors?',
      'a': 'Make sure the backend server is running and you are connected to the internet. Doctors appear only after they have registered and set up their profile.',
    },
    {
      'q': 'How do I logout?',
      'a': 'Go to the Profile tab and scroll to the bottom. Tap "Logout" to sign out of your account.',
    },
  ];

  static const _supportEmail = 'support@medicoapp.com';
  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildContactCard(),
          const SizedBox(height: 24),
          Text('Frequently Asked Questions', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 12),
          _buildFAQList(),
          const SizedBox(height: 24),
          _buildAppInfoCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.support_agent_rounded, color: Colors.white, size: 36),
        const SizedBox(height: 12),
        const Text(
          'Need Help?',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Our support team is here for you. Reach out and we\'ll get back to you as soon as possible.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _copyEmail(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white38),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: const [
              Icon(Icons.email_outlined, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(_supportEmail, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
              SizedBox(width: 8),
              Icon(Icons.copy_outlined, color: Colors.white70, size: 14),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildFAQList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: List.generate(_faqs.length, (i) {
            final isLast = i == _faqs.length - 1;
            final isExpanded = _expandedIndex == i;
            return Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _expandedIndex = isExpanded ? null : i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: isExpanded ? AppColors.primary : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isExpanded ? Colors.white : AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _faqs[i]['q']!,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: isExpanded ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ]),
                  ),
                ),
                if (isExpanded)
                  Container(
                    width: double.infinity,
                    color: AppColors.primaryLight.withAlpha(80),
                    padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
                    child: Text(
                      _faqs[i]['a']!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
                    ),
                  ),
                if (!isLast) const Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        _infoRow(Icons.info_outline, 'App Version', _appVersion),
        const Divider(height: 20, color: AppColors.border),
        _infoRow(Icons.privacy_tip_outlined, 'Privacy Policy', 'medicoapp.com/privacy'),
        const Divider(height: 20, color: AppColors.border),
        _infoRow(Icons.description_outlined, 'Terms of Service', 'medicoapp.com/terms'),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      const Spacer(),
      Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    ]);
  }

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _supportEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email copied to clipboard'), backgroundColor: AppColors.success),
    );
  }
}
