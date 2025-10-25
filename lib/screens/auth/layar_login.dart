import 'package:flutter/material.dart';

class LayarLogin extends StatefulWidget {
  const LayarLogin({super.key});

  @override
  State<LayarLogin> createState() => _LayarLoginState();
}

class _LayarLoginState extends State<LayarLogin> {
  // Controller untuk mengambil input dari user
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi yang akan memanggil Supabase SDK untuk otentikasi
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // -----------------------------------------------------
      // HAPUS KOMENTAR INI SETELAH ANDA MENGHUBUNGKAN SUPABASE
      // -----------------------------------------------------

      /*
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Setelah berhasil login, Anda perlu:
      // 1. Cek Role pengguna (teknisi/supervisor) dari tabel 'profiles'.
      // 2. Arahkan ke Dashboard yang sesuai.

      if (response.user != null) {
        // Contoh Navigasi setelah login (Akan diganti dengan Cek Role)
        Navigator.pushReplacementNamed(context, '/dashboard-teknisi');
      }
      */

      // Placeholder: Simulasikan loading dan navigasi untuk UI testing
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/dashboard-teknisi');
    } catch (e) {
      // Tampilkan error jika login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Gagal. Pastikan email dan password benar.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Aplikasi Pelaporan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 1. Logo Perusahaan / Aplikasi
              const Icon(
                Icons.handyman,
                size: 80,
                color: Colors.blue, // Ganti dengan warna branding PT. SMARTNET
              ),
              const SizedBox(height: 16),
              Text(
                'Masuk Teknisi',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 40),

              // 2. Field Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Field Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 32),

              // 4. Tombol Login
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('MASUK', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
