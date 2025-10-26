import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io'; // Untuk menggunakan File() saat menampilkan gambar

class LayarBuatReport extends StatefulWidget {
  const LayarBuatReport({super.key});

  @override
  State<LayarBuatReport> createState() => _LayarBuatReportState();
}

class _LayarBuatReportState extends State<LayarBuatReport> {
  // 1. Controller Formulir
  final _kunciForm = GlobalKey<FormState>();
  final _judulKontroler = TextEditingController();
  final _deskripsiKontroler = TextEditingController();
  final _lokasiKontroler = TextEditingController(); // Untuk tampilan lokasi GPS

  // 2. State untuk Data Laporan
  List<XFile> _fotoBukti = []; // Menyimpan file foto lokal yang dipilih
  String? _koordinatGPS; // Menyimpan koordinat Latitude,Longitude
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
    final XFile? gambar = await pemilihFoto.pickImage(source: sumber);

    if (gambar != null && _fotoBukti.length < 5) {
      // Batasi maksimal 5 foto
      setState(() {
        _fotoBukti.add(gambar);
      });
    }
  }

  // Fungsi: Mengambil Lokasi GPS Saat Ini
  Future<void> _ambilLokasiSaatIni() async {
    setState(() => _sedangMemuat = true);
    try {
      // Cek izin lokasi
      LocationPermission izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi diperlukan untuk melanjutkan'),
          ),
        );
        izin = await Geolocator.requestPermission();
      }
      if (izin == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak permanen. Mohon aktifkan di pengaturan',
            ),
          ),
        );
        return;
      }

      Position posisi = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _koordinatGPS = "${posisi.latitude}, ${posisi.longitude}";
        _lokasiKontroler.text =
            'Lokasi GPS Terambil: ${posisi.latitude.toStringAsFixed(4)}, ${posisi.longitude.toStringAsFixed(4)}';
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil lokasi: $e')));
    } finally {
      setState(() => _sedangMemuat = false);
    }
  }

  // --- FUNGSI SUBMIT LAPORAN UTAMA ---

  Future<void> _kirimLaporan() async {
    if (!_kunciForm.currentState!.validate() || _sedangMemuat) return;

    setState(() => _sedangMemuat = true);
    final idPengguna = _klienSupabase.auth.currentUser!.id;
    List<String> daftarUrlFoto = [];

    try {
      // 1. Upload Foto ke Supabase Storage (Bukti Laporan)
      for (var file in _fotoBukti) {
        final namaFile =
            '${idPengguna}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

        await _klienSupabase.storage
            .from('bukti_laporan')
            .upload(namaFile, File(file.path));

        // Mendapatkan URL publik/download untuk disimpan di Database
        final urlPublik = _klienSupabase.storage
            .from('bukti_laporan')
            .getPublicUrl(namaFile);
        daftarUrlFoto.add(urlPublik);
      }

      // 2. Insert Data Laporan ke Tabel 'laporan'
      await _klienSupabase.from('laporan').insert({
        'teknisi_id': idPengguna,
        'judul_pekerjaan': _judulKontroler.text.trim(),
        'deskripsi_pekerjaan': _deskripsiKontroler.text.trim(),
        'lokasi': _lokasiKontroler.text.trim(),
        'foto_bukti': daftarUrlFoto, // Array of URLs
        'status_laporan': 'Pending',
        'waktu_mulai': DateTime.now().toIso8601String(),
      });

      // 3. Sukses dan Navigasi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil disimpan! Status: Pending.'),
        ),
      );
      Navigator.pop(context); // Kembali ke dashboard
    } on StorageException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload foto: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan laporan: $e')));
    } finally {
      setState(() => _sedangMemuat = false);
    }
  }

  // --- WIDGET BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Laporan Baru')),
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
                  labelText: 'Judul Pekerjaan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (nilai) {
                  if (nilai == null || nilai.isEmpty) {
                    return 'Judul pekerjaan harus diisi';
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
                validator: (nilai) {
                  if (nilai == null || nilai.isEmpty) {
                    return 'Deskripsi pekerjaan harus diisi';
                  }
                  return null;
                },
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
          'Lokasi Pekerjaan:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _lokasiKontroler,
                decoration: const InputDecoration(
                  labelText: 'GPS / Deskripsi Lokasi',
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // Hanya untuk menampilkan hasil GPS
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
                (foto) => Stack(
                  children: [
                    Image.file(
                      File(foto.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _fotoBukti.remove(foto); // Hapus foto dari list
                          });
                        },
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
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto dengan Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _ambilFoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _ambilFoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
