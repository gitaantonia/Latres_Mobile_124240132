import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  bool _isLoading = true;
  bool _isKesanExpanded = false;

  final String _kesanText =
      'Kesan: Praktikum mobile sangat menyenangkan dan banyak insight baruu! Rasanya seperti minum es teh manis di siang hari yang panas, menyegarkan dan bikin semangat belajar meningkat. Es teh buatan kak alvin & kak umar lebih manis daripada es teh pak bagus. terima kasih yes kakak kakak.';

  final String _pesanText =
      'Pesan: Singkat saja, ijinkan saya dapat nilai A+ untuk praktikum mobile ini. Terima kasih banyak atas bimbingannya selama praktikum 🙏';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final username = await AuthService.getUsername();
    if (mounted) {
      setState(() {
        _username = username;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF232323),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah kamu yakin ingin logout dari akun $_username?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar Abu-abu Sesuai Mockup
                    Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A4A4A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 72,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Username dari SharedPreferences
                    Text(
                      _username.isNotEmpty ? _username : 'Pengguna',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Kesan (Panjang, 40 karakter saat ditutup, expandable)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isKesanExpanded = !_isKesanExpanded;
                        });
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: _isKesanExpanded
                                  ? _kesanText
                                  : (_kesanText.length > 40
                                        ? '${_kesanText.substring(0, 40)}...'
                                        : _kesanText),
                            ),
                            TextSpan(
                              text: _isKesanExpanded
                                  ? ' (tutup)'
                                  : ' tampilkan selengkapnya',
                              style: const TextStyle(
                                color: Color(0xFFE50914),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pesan
                    Text(
                      _pesanText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Tombol Logout Merah Solid Rounded
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
