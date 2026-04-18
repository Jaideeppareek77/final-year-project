import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/patient/patient_shell.dart';
import 'screens/doctor/doctor_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MedicoApp());
}

class MedicoApp extends StatelessWidget {
  const MedicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fliser',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppEntry(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/patient': (_) => const PatientShell(),
        '/doctor': (_) => const DoctorShell(),
        '/splash': (_) => const SplashScreen(),
      },
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final loggedIn = await _authService.isLoggedIn();
    if (!mounted) return;

    if (!loggedIn) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    final role = await _authService.getRole();
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(role == 'doctor' ? '/doctor' : '/patient');
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
