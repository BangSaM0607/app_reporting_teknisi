import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/layar_login.dart';
import 'screens/auth/layar_daftar.dart';
import 'screens/dashboard/layar_dashboard_teknisi.dart';
import 'screens/report/layar_buat_report.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://odwonvruijzjixyejuqg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kd29udnJ1aWp6aml4eWVqdXFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5MjY2MjgsImV4cCI6MjA3NjUwMjYyOH0.vf89rmz0ilJ8IGd9GjqKbNwEV9yp5t4Qhb2VXtNjJdo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Pelaporan Teknisi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LayarLogin(),
        '/dashboard-teknisi': (context) => const LayarDashboardTeknisi(),
        '/register': (context) => const LayarDaftar(),
        '/buat-report': (context) => const LayarBuatReport(),
      },
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}
