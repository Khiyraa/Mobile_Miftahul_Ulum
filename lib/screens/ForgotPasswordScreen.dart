import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'TokenVerificationScreen .dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await sendResetLinkAPI(emailController.text);
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TokenVerificationScreen(
              email: emailController.text,
              newPassword: newPasswordController.text,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal mengirim email'), backgroundColor: Colors.red),
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
        title: Text('Lupa Password', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
              child: const Icon(Icons.lock_reset_rounded, size: 80, color: Colors.white24),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Masukkan email terdaftar dan buat password baru Anda.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(emailController, 'Email', Icons.email_outlined, false),
                    const SizedBox(height: 20),
                    _buildTextField(newPasswordController, 'Password Baru', Icons.lock_outline, true, isNew: true),
                    const SizedBox(height: 20),
                    _buildTextField(confirmPasswordController, 'Konfirmasi Password', Icons.lock_outline, true, isConfirm: true),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _isLoading ? null : sendResetLink,
                        child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('KIRIM KODE', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isPassword, {bool isNew = false, bool isConfirm = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && (isNew ? _obscureNewPassword : _obscureConfirmPassword),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        suffixIcon: isPassword ? IconButton(
          icon: Icon((isNew ? _obscureNewPassword : _obscureConfirmPassword) ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() {
            if (isNew) _obscureNewPassword = !_obscureNewPassword;
            else _obscureConfirmPassword = !_obscureConfirmPassword;
          }),
        ) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Wajib diisi';
        if (isConfirm && v != newPasswordController.text) return 'Password tidak cocok';
        return null;
      },
    );
  }
}
