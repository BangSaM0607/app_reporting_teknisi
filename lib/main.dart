import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/layar_login.dart'; // Import Halaman Login
import 'screens/dashboard/layar_dashboard_teknisi.dart'; // Import Halaman Dashboard

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
        primarySwatch:
            Colors.blue, // Sesuaikan dengan warna branding PT. SMARTNET
      ),

      // 1. Definisikan Route Awal
      // Aplikasi akan selalu memulai dari sini, biasanya layar splash atau login.
      initialRoute: '/login',

      // 2. Daftarkan Semua Named Routes
      routes: {
        // Halaman Otentikasi
        '/login': (context) => const LayarLogin(),

        // Halaman Dashboard Utama
        // Setelah login sukses, user diarahkan ke sini.
        '/dashboard-teknisi': (context) => const LayarDashboardTeknisi(),

        // Halaman Pendaftaran (jika diperlukan)
        '/register': (context) => const LayarDaftar(),

        // --- Tambahan untuk Fitur Lain ---
        // '/input-laporan': (context) => const LayarInputLaporan(), // Contoh Route untuk Form Laporan
        // '/detail-laporan': (context) => const LayarDetailLaporan(),
      },
    );
  }
}
