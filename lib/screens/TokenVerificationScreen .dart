import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class TokenVerificationScreen extends StatefulWidget {
  final String email;
  final String newPassword;

  const TokenVerificationScreen({
    super.key,
    required this.email,
    required this.newPassword,
  });

  @override
  State<TokenVerificationScreen> createState() => _TokenVerificationScreenState();
}

class _TokenVerificationScreenState extends State<TokenVerificationScreen> {
  final TextEditingController tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> verifyToken() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await verifyResetPasswordAPI(
        widget.email,
        tokenController.text.trim(),
        widget.newPassword,
      );

      if (response['success'] == true) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Icon(Icons.check_circle, color: Colors.teal, size: 60),
            content: const Text('Password berhasil direset. Silakan login kembali.', textAlign: TextAlign.center),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
                child: const Text('LOGIN'),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Token tidak valid'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: Text('Verifikasi Token', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: const Icon(Icons.mark_email_read_rounded, size: 80, color: Colors.white24),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Kami telah mengirimkan 6 digit kode verifikasi ke:',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                    Text(
                      widget.email,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: tokenController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: GoogleFonts.poppins(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        counterText: "",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        hintText: "000000",
                        hintStyle: TextStyle(color: Colors.grey[300]),
                      ),
                      validator: (v) => v!.length != 6 ? "Masukkan 6 digit kode" : null,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _isLoading ? null : verifyToken,
                        child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('VERIFIKASI', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
