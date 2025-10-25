// lib/screens/dashboard/layar_dashboard_teknisi.dart

import 'package:flutter/material.dart';

class LayarDashboardTeknisi extends StatelessWidget {
  const LayarDashboardTeknisi({super.key});

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
    // Placeholder untuk nama pengguna yang akan diambil dari Supabase
    final String namaPengguna = 'Nama Teknisi';

    return AppBar(
      title: const Text('Dashboard Teknisi'),
      centerTitle: false,
      actions: [
        // Tombol Logout
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            // Logic Logout menggunakan Supabase SDK
          },
        ),
      ],
    );
  }

  // Konten Utama Dashboard
  Widget _buildBody(BuildContext context) {
    // Placeholder untuk nama pengguna yang sudah login
    final String namaPengguna = 'Budi Santoso';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Bagian Sapaan
          Text(
            'Selamat Datang, $namaPengguna!',
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
        // Navigasi ke halaman Form Input Laporan Baru
        Navigator.pushNamed(context, '/input-laporan');
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
