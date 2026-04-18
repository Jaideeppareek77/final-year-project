class ApiConstants {
  // Change this to your Vercel deployment URL after deploy
  // 10.0.2.2 = Mac localhost from Android emulator. Change to https://medico-api.vercel.app for production.
  static const String baseUrl = 'https://medico-api.vercel.app';

  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String refreshToken = '/api/auth/refresh';

  static const String usersMe = '/api/users/me';
  static const String doctors = '/api/doctors';
  static const String doctorSlots = '/api/doctors/{id}/slots';
  static const String doctorAvailability = '/api/doctors/{id}/availability';

  static const String appointments = '/api/appointments';
  static const String messages = '/api/messages';
  static const String conversations = '/api/messages/conversations';

  static const String patientsMe = '/api/patients/me';
  static const String prescriptions = '/api/prescriptions';
  static const String vitals = '/api/vitals';
  static const String vitalsLatest = '/api/vitals/latest';
  static const String healthRecords = '/api/health-records';
  static const String dashboard = '/api/dashboard';
  static const String filesUpload = '/api/files/upload';
}
