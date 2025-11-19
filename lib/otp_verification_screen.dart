import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  String? email;
  String? password; // For sign up flow, optional
  bool _isVerifying = false;
  String? _errorMsg;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String) {
      email = args;
      password = null;
    } else if (args is Map<String, dynamic>) {
      email = args['email'];
      password = args['password'];
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _errorMsg = "Please enter OTP.");
      return;
    }
    setState(() {
      _errorMsg = null;
      _isVerifying = true;
    });

    // Call your edge function to validate OTP
    final response = await Supabase.instance.client.functions.invoke(
      'verify_otp',
      body: {'email': email, 'otp': otp},
    );

    final data = response.data;
    if (response.status == 200 && data['valid'] == true) {
      // If sign up, complete registration after OTP verified
      if (password != null && password!.isNotEmpty) {
        final signUpRes = await Supabase.instance.client.auth.signUp(
          email: email!,
          password: password!,
        );
        if (signUpRes.user != null) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
          return;
        } else {
          setState(() => _errorMsg = 'Account creation failed. Try again.');
        }
      } else {
        // For forgot password or login flow, just navigate home
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
        return;
      }
    } else {
      setState(() => _errorMsg = "Invalid or expired OTP!");
    }
    setState(() => _isVerifying = false);
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Enter the OTP sent to ${email ?? '--'}",
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "OTP",
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                style: const TextStyle(letterSpacing: 5, color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 18),
              if (_errorMsg != null)
                Text(_errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE57C23),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Text("Verify OTP", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: _isVerifying
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: const Text("Back", style: TextStyle(fontSize: 16, color: Color(0xFFE57C23))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
