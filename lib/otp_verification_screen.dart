import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

String _flow = 'forgot';


@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final args = ModalRoute.of(context)?.settings.arguments;

if (args is String) {
  email = args;
  password = null;
  _flow = 'forgot';
} else if (args is Map<String, dynamic>) {
  email = args['email'] as String?;
  password = args['password'] as String?;
  
  // ✅ FLOW VALIDATION
  final flowArg = args['flow'] as String?;
  if (flowArg == 'signup' || flowArg == 'forgot') {
    _flow = flowArg!;
  } else {
    _flow = 'forgot';
  }
}

}



Future<void> _verifyOtp() async {
  // ✅ CHANGE #1: EARLY VALIDATION (BEFORE loading state)
  final otp = _otpController.text.trim();
  if (otp.isEmpty) {
    setState(() => _errorMsg = "Please enter OTP.");
    return;
  }

  final String? currentEmail = email?.trim().toLowerCase();
  if (currentEmail == null || currentEmail.isEmpty) {
    setState(() => _errorMsg = "Email missing for OTP verification.");
    return;
  }

  // ✅ CHANGE #2: PASSWORD CHECK FOR SIGNUP (CRITICAL FIX)
  if (_flow == 'signup' && (password == null || password!.isEmpty)) {
    setState(() => _errorMsg = "Password missing for signup. Please restart.");
    return;
  }

  // ✅ NOW set loading state
  setState(() {
    _errorMsg = "";
    _isVerifying = true;
  });

  try {
    final client = Supabase.instance.client;
    final res = await client.functions.invoke(
      'verify_otp',
      body: {'email': currentEmail, 'otp': otp},
    );

    // ✅ CHANGE #3: SAFE STATUS CHECK
    final status = res.status ?? 500;
    if (status != 200) {
      setState(() {
        _errorMsg = "Request failed with status $status";
        _isVerifying = false;
      });
      return;
    }

    // ✅ CHANGE #4: SAFE RESPONSE PARSING
    final Map<String, dynamic> body;
    try {
      if (res.data is String) {
        body = jsonDecode(res.data as String) as Map<String, dynamic>;
      } else if (res.data is Map) {
        body = (res.data as Map).cast<String, dynamic>();
      } else {
        throw Exception('Unexpected response type: ${res.data.runtimeType}');
      }
    } catch (e) {
      setState(() {
        _errorMsg = "Failed to parse server response: $e";
        _isVerifying = false;
      });
      return;
    }

    if (body['valid'] != true) {
      setState(() {
        _errorMsg = body['reason']?.toString() ?? "Invalid or expired OTP.";
        _isVerifying = false;
      });
      return;
    }

    // ✅ OTP verified - Check flow type
    if (!mounted) return;

    if (_flow == 'forgot') {
      Navigator.of(context).pushReplacementNamed(
        '/password_reset',
        arguments: {'email': currentEmail},
      );
    } else if (_flow == 'signup') {
      // ✅ CHANGE #5: CALL NEW SAFE SIGNUP METHOD
      await _completeSignup(currentEmail!, password!);
    }
  } catch (e) {
    setState(() {
      _errorMsg = "OTP verification error: $e";
      _isVerifying = false;
    });
  } finally {
    if (mounted) {
      setState(() {
        _isVerifying = false;
      });
    }
  }
}



Future<void> _completeSignup(String email, String password) async {
  try {
    final client = Supabase.instance.client;
    
    if (password.length < 6) {
      setState(() {
        _errorMsg = "Password must be at least 6 characters.";
        _isVerifying = false;
      });
      return;
    }

    final authResponse = await client.auth.signUp(
      email: email,
      password: password,  // ✅ SAFE
    );

    if (authResponse.user != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    }
  } on AuthException catch (authError) {
    setState(() {
      _errorMsg = 'Signup error: ${authError.message}';
      _isVerifying = false;
    });
  } catch (e) {
    setState(() {
      _errorMsg = "Signup failed: $e";
      _isVerifying = false;
    });
  }
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