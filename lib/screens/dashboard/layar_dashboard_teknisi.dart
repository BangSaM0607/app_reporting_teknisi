import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LayarDashboardTeknisi extends StatefulWidget {
  const LayarDashboardTeknisi({super.key});

  @override
  State<LayarDashboardTeknisi> createState() => _LayarDashboardTeknisiState();
}

class _LayarDashboardTeknisiState extends State<LayarDashboardTeknisi> {
  String _namaLengkap = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    String nama = '';

    if (user != null) {
      // Coba ambil nama lengkap dari tabel profiles (jika ada)
      try {
        final Map<String, dynamic>? res = await Supabase.instance.client
            .from('profiles')
            .select('nama_lengkap')
            .eq('id', user.id)
            .maybeSingle();

        if (res != null && res['nama_lengkap'] != null) {
          nama = (res['nama_lengkap'] as String).trim();
        }
      } catch (_) {
        // Kalau gagal, kita fallback ke email username
      }

      if (nama.isEmpty && user.email != null) {
        // Gunakan bagian sebelum '@' dari email sebagai username
        nama = user.email!.split('@').first;
      }
    }

    if (!mounted) return;
    setState(() {
      _namaLengkap = nama.isNotEmpty ? nama : 'Teknisi';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur dasar (App Bar, Body, dll.)
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      // Tombol Aksi Cepat: Buat Laporan Baru
      floatingActionButton: _buildFAB(context),
    );
  }

  // Header Aplikasi
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Dashboard Teknisi'),
      centerTitle: false,
      actions: [
        // Tombol Logout
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (!context.mounted) return;
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  // Konten Utama Dashboard
  Widget _buildBody(BuildContext context) {
    final String namaLengkap = _namaLengkap;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Bagian Sapaan
          Text(
            'Selamat Datang, $namaLengkap!',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 2. Judul Ringkasan
          Text(
            'Ringkasan Laporan Saya',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          _buildKartuRingkasanGrid(context), // Grid 3 Kartu

          const SizedBox(height: 30),

          // 3. Judul Daftar Laporan Terbaru
          Text(
            'Laporan Terbaru',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),

          // Daftar laporan (Akan menggunakan FutureBuilder/StreamBuilder)
          const Text('Daftar 5 laporan terakhir akan dimuat di sini...'),
          // ... (Tambahkan ListView.builder untuk menampilkan data laporan)
        ],
      ),
    );
  }

  // Grid Tiga Kartu Status
  Widget _buildKartuRingkasanGrid(BuildContext context) {
    // KartuStatus adalah widget kustom yang perlu dibuat terpisah
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: const [
        // Placeholder data, nanti akan diganti dengan data real dari Supabase
        KartuStatus(judul: 'Tertunda', jumlah: 5, warna: Colors.orange),
        KartuStatus(judul: 'Diproses', jumlah: 2, warna: Colors.blue),
        KartuStatus(judul: 'Selesai', jumlah: 18, warna: Colors.green),
      ],
    );
  }

  // Tombol Aksi Cepat (FAB)
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // Navigate to LayarBuatReport screen
        Navigator.pushNamed(context, '/buat-report').then((value) {
          // Refresh dashboard data when returning from create report screen
          setState(() {
            _loadUserName(); // Refresh user data
            // Add any other refresh functions here
          });
        });
      },
      icon: const Icon(Icons.add),
      label: const Text('BUAT LAPORAN BARU'),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}

// Widget Kustom untuk Kartu Status (dibuat terpisah)
class KartuStatus extends StatelessWidget {
  final String judul;
  final int jumlah;
  final Color warna;

  const KartuStatus({
    required this.judul,
    required this.jumlah,
    required this.warna,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: warna.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              judul,
              style: TextStyle(color: warna, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text('$jumlah', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
