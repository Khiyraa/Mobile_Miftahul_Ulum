import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart'; // Ensure your API functions are imported
import 'login_screen.dart'; // Redirect to login screen after successful reset

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

  String? validateToken(String? value) {
    if (value == null || value.isEmpty) {
      return 'Token tidak boleh kosong';
    }
    if (value.length != 6) {
      return 'Token harus 6 digit';
    }
    return null;
  }

  // Function to verify the token and reset password
  Future<void> verifyToken() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Call API to verify token and reset password
      final response = await verifyResetPasswordAPI(
        widget.email,
        tokenController.text.trim(),
        widget.newPassword,
      );

      if (response['success'] == true) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text('Berhasil!'),
              ],
            ),
            content: Text(
              'Password Anda telah berhasil direset. Silakan login dengan password baru Anda.',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
                child: Text('Login Sekarang'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Token tidak valid'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Function to resend the token if user doesn't receive it
  Future<void> resendToken() async {
    setState(() => _isLoading = true);

    try {
      final response = await sendResetLinkAPI(widget.email);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Token baru telah dikirim ke email Anda'),
            backgroundColor: Colors.green,
          ),
        );
        tokenController.clear(); // Clear the token field when resending
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal mengirim ulang token'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verifikasi Token'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 32),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 50,
                    color: Colors.teal,
                  ),
                ),
              ),

              // Deskripsi
              Text(
                'Verifikasi Email',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 24),
                    SizedBox(height: 8),
                    Text(
                      'Kami telah mengirim kode verifikasi ke:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Token Input
              TextFormField(
                controller: tokenController,
                decoration: InputDecoration(
                  labelText: "Kode Verifikasi",
                  hintText: "Masukkan kode dari email",
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
                validator: validateToken,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),

              SizedBox(height: 24),

              // Instruksi
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '📱 Cara mendapatkan kode:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Buka aplikasi email Anda\n'
                      '2. Cari email dari "sanmoreee"\n'
                      '3. Salin kode verifikasi yang tertera\n'
                      '4. Masukkan kode di kolom di atas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Tombol Verifikasi
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : verifyToken,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Verifikasi Token',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),

              SizedBox(height: 16),

              // Tombol Kirim Ulang
              TextButton(
                onPressed: _isLoading ? null : resendToken,
                child: Text(
                  'Tidak menerima kode? Kirim ulang',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Footer Info
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.orange, size: 24),
                    SizedBox(height: 8),
                    Text(
                      'Kode verifikasi berlaku selama 5 menit',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pastikan untuk segera memasukkan kode sebelum kedaluwarsa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}