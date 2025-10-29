import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
  }

Future<void> checkLoggedIn() async {
  final session = Supabase.instance.client.auth.currentSession;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.of(context).pushReplacementNamed('/login');
  });
}


Future<void> handleAuth() async {
  setState(() { _isLoading = true; _errorMsg = null; });

  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  try {
    final auth = Supabase.instance.client.auth;
    if (_isSignUp) {
      final res = await auth.signUp(email: email, password: password);
      if (res.user != null) {
        // Insert into users table
        try {
          await Supabase.instance.client.from('users').insert({
            'id': res.user!.id,
            'email': email,
            'full_name': '',
            'phone': '',
            'avatar_url': '',
          });
        } catch (e) {
          print('Insert error: $e');
          // Even if insert fails, still proceed to home
        }
        Navigator.of(context).pushReplacementNamed('/exam_selection');
      }
    } else {
      final res = await auth.signInWithPassword(email: email, password: password);
      if (res.user != null) {
        Navigator.of(context).pushReplacementNamed('/exam_selection');
      }
    }
  } catch (e) {
    setState(() { _errorMsg = e.toString(); });
  }
  setState(() { _isLoading = false; });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edu-Connect', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_isSignUp ? 'Sign Up' : 'Login',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE57C23))),
            const SizedBox(height: 16),
            Text(
              _isSignUp 
                ? 'Create a new account to start your journey.'
                : 'Sign in to continue your journey.',
              style: TextStyle(fontSize: 16, color: Colors.white54),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.email, color: Colors.white54),
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.lock, color: Colors.white54),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            if (_errorMsg != null)
              Text(_errorMsg!, style: TextStyle(color: Colors.red, fontSize: 14)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : handleAuth,
                icon: Icon(_isSignUp ? Icons.person_add : Icons.login, color: Colors.white),
                label: Text(_isSignUp ? 'Sign Up' : 'Login', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE57C23),
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => setState(() { _isSignUp = !_isSignUp; }),
              child: Text(_isSignUp
                  ? 'Already have an account? Login'
                  : 'Don\'t have an account? Sign Up',
                  style: TextStyle(color: Colors.white54)),
            ),
            Spacer(),
            Text('By continuing, you agree to our Terms & Privacy Policy.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
