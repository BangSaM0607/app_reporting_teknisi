import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class LayarKirimLaporan extends StatefulWidget {
  const LayarKirimLaporan({super.key});

  @override
  State<LayarKirimLaporan> createState() => _LayarKirimLaporanState();
}

class _LayarKirimLaporanState extends State<LayarKirimLaporan> {
  // 1. Controller Formulir
  final _kunciForm = GlobalKey<FormState>();
  final _judulKontroler = TextEditingController();
  final _deskripsiKontroler = TextEditingController();
  final _lokasiKontroler = TextEditingController();

  // 2. State untuk Data Laporan
  List<XFile> _fotoBukti = [];
  bool _sedangMemuat = false;

  final _klienSupabase = Supabase.instance.client;

  @override
  void dispose() {
    _judulKontroler.dispose();
    _deskripsiKontroler.dispose();
    _lokasiKontroler.dispose();
    super.dispose();
  }

  // --- FUNGSI PENGAMBILAN MEDIA & LOKASI ---

  // Fungsi: Mengambil Foto dari Kamera/Galeri
  Future<void> _ambilFoto(ImageSource sumber) async {
    final ImagePicker pemilihFoto = ImagePicker();
    // Batas kompresi bisa ditambahkan di sini jika diperlukan (imageQuality: 50)
    final XFile? gambar = await pemilihFoto.pickImage(source: sumber);

    if (gambar != null && _fotoBukti.length < 5) {
      setState(() {
        _fotoBukti.add(gambar);
      });
    }
  }

  // Fungsi: Mengambil Lokasi GPS Saat Ini
  Future<void> _ambilLokasiSaatIni() async {
    setState(() => _sedangMemuat = true);
    try {
      // Cek izin lokasi dan meminta izin jika diperlukan
      LocationPermission izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied ||
          izin == LocationPermission.deniedForever) {
        izin = await Geolocator.requestPermission();
        if (izin != LocationPermission.whileInUse &&
            izin != LocationPermission.always)
          return;
      }

      Position posisi = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        // Tampilkan koordinat ke kontroler untuk visualisasi
        _lokasiKontroler.text =
            'Lokasi GPS Terambil: ${posisi.latitude.toStringAsFixed(6)}, ${posisi.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil lokasi: ${e.toString()}')),
      );
    } finally {
      setState(() => _sedangMemuat = false);
    }
  }

  // --- FUNGSI SUBMIT LAPORAN UTAMA ---

  Future<void> _kirimLaporan() async {
    // Validasi form dan cek status loading
    if (!_kunciForm.currentState!.validate() || _sedangMemuat) return;

    setState(() => _sedangMemuat = true);
    final idPengguna = _klienSupabase.auth.currentUser!.id;
    List<String> daftarUrlFoto = [];

    try {
      // 1. Upload Foto ke Supabase Storage
      for (var file in _fotoBukti) {
        final namaFile =
            'laporan/${idPengguna}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

        await _klienSupabase.storage
            .from('bukti_laporan')
            .upload(namaFile, File(file.path));

        // Mendapatkan URL publik/download
        final urlPublik = _klienSupabase.storage
            .from('bukti_laporan')
            .getPublicUrl(namaFile);
        daftarUrlFoto.add(urlPublik);
      }

      // 2. Insert Data Laporan ke Tabel 'laporan'
      await _klienSupabase.from('laporan').insert({
        'teknisi_id': idPengguna,
        'tanggal_laporan': DateTime.now().toIso8601String().substring(
          0,
          10,
        ), // Format YYYY-MM-DD
        'judul_pekerjaan': _judulKontroler.text.trim(),
        'deskripsi_pekerjaan': _deskripsiKontroler.text.trim(),
        'lokasi': _lokasiKontroler.text
            .trim(), // Berisi data GPS yang divisualisasikan
        'foto_bukti': daftarUrlFoto, // Array of URLs
        'status_laporan': 'Pending', // Default
        'waktu_mulai': DateTime.now().toIso8601String(),
      });

      // 3. Sukses dan Navigasi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim! Status: Pending.'),
        ),
      );
      Navigator.pop(context); // Kembali ke dashboard
    } on StorageException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload foto: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan laporan: ${e.toString()}')),
      );
    } finally {
      setState(() => _sedangMemuat = false);
    }
  }

  // --- WIDGET BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kirim Laporan Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _kunciForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Input Judul Pekerjaan
              TextFormField(
                controller: _judulKontroler,
                decoration: const InputDecoration(
                  labelText: 'Judul Pekerjaan (Wajib)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (nilai) {
                  if (nilai == null || nilai.isEmpty) {
                    return 'Judul pekerjaan harus diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Input Deskripsi Pekerjaan
              TextFormField(
                controller: _deskripsiKontroler,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Detail Pekerjaan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // 3. Tombol dan Input Lokasi GPS
              _bangunBagianLokasi(),
              const SizedBox(height: 16),

              // 4. Bagian Foto Bukti
              _bangunBagianFoto(context),
              const SizedBox(height: 32),

              // 5. Tombol Kirim Laporan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _sedangMemuat ? null : _kirimLaporan,
                  icon: _sedangMemuat
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(_sedangMemuat ? 'Mengirim...' : 'KIRIM LAPORAN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Pembantu untuk Bagian Lokasi
  Widget _bangunBagianLokasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi Pekerjaan (GPS):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _lokasiKontroler,
                decoration: const InputDecoration(
                  labelText: 'Koordinat GPS',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _sedangMemuat ? null : _ambilLokasiSaatIni,
              child: const Icon(Icons.gps_fixed),
            ),
          ],
        ),
      ],
    );
  }

  // Widget Pembantu untuk Bagian Foto
  Widget _bangunBagianFoto(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Bukti (Maks. 5 Foto):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Grid Foto yang sudah dipilih
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _fotoBukti
              .map(
                (file) => Stack(
                  children: [
                    Image.file(
                      File(file.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _fotoBukti.remove(file); // Hapus foto dari list
                          });
                        },
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 16),

        // Tombol Tambah Foto
        OutlinedButton.icon(
          onPressed: _fotoBukti.length >= 5
              ? null
              : () => _tampilkanPilihanSumberFoto(context),
          icon: const Icon(Icons.camera_alt),
          label: Text(
            _fotoBukti.isEmpty
                ? 'TAMBAH FOTO BUKTI'
                : 'TAMBAH LAGI (${_fotoBukti.length}/5)',
          ),
        ),
      ],
    );
  }

  // Bottom Sheet untuk Pilihan Kamera/Galeri
  void _tampilkanPilihanSumberFoto(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri Foto'),
                onTap: () {
                  _ambilFoto(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  _ambilFoto(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
