
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saas_new/password_reset_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import 'splash_screen.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';
import 'exam_selection_screen.dart';
import 'home_screen.dart';
import 'subscription_screen.dart';
import 'pyq_chapter_list_screen.dart';
import 'ai_chat_screen.dart';
import 'question_screen.dart';
import 'models_mock_test.dart'; // Adjust if needed

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pgvymttdvdlkcroqxsgn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBndnltdHRkdmRsa2Nyb3F4c2duIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzOTEwMzMsImV4cCI6MjA3NDk2NzAzM30.lAaQEs2Mk6BGjIcP8zLkqkFxUDIKyDIT-9kTK5kPnq8',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _authSubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

void _setupAuthListener() {
  _authSubscription =
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    debugPrint('🔐 [MyApp] Auth Event: $event');

    if (event == AuthChangeEvent.passwordRecovery) {
      debugPrint(
          '✅ [MyApp] Password recovery detected - navigating to OTP screen');
      _navigatorKey.currentState?.pushNamed(
        '/otp_verification',
        arguments: data.session?.user.email,
      );
    }

    // ❌ Ye block ABHI ke liye hata do / comment:
    // if (event == AuthChangeEvent.signedOut) {
    //   debugPrint('👤 [MyApp] User signed out - navigating to login');
    //   _navigatorKey.currentState?.pushNamedAndRemoveUntil(
    //     '/login',
    //     (route) => false,
    //   );
    // }
  });
}


  @override
  Widget build(BuildContext context) {
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0E21),
      primaryColor: const Color(0xFFE57C23),
      cardColor: const Color(0xFF1D1E33),
      textTheme: GoogleFonts.poppinsTextTheme(
        Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE57C23),
        secondary: Color(0xFF9C27B0),
        surface: Color(0xFF1D1E33),
        onSurface: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE57C23),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: const Color(0xFFE57C23).withOpacity(0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1D1E33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE57C23),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFE57C23),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0E21),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return MaterialApp(
      title: 'Prepixo',
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/exam_selection': (context) => const ExamSelectionScreen(),
        '/home': (context) => const HomeScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
        '/pyq_mains': (context) => const PyqChapterListScreen(),
            '/password_reset': (context) => const PasswordResetScreen(),

    '/otp_verification': (context) => const OtpVerificationScreen(),


        '/ai_chat': (context) {
          final question = ModalRoute.of(context)!.settings.arguments as PyqQuestion;
          return AiChatScreen(question: question);
        }
      },
      onGenerateRoute: (settings) {
        debugPrint('🔗 [Route] Generated route: ${settings.name}');
if (settings.name == '/otp_verification') {
  return MaterialPageRoute(
    builder: (context) => const OtpVerificationScreen(), // ← NO email param!
    settings: settings, // ← so the arguments are passed
  );
}
        // Add similar dynamic routing for other screens needing arguments
        return null;
      },
      onUnknownRoute: (settings) {
        debugPrint('⚠️ [Route] Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: const Color(0xFF0A0E21),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFE57C23),
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Route Not Found',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${settings.name}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
