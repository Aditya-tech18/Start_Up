// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <<< NEW IMPORT >>>
import 'splash_screen.dart';
import 'login_screen.dart';
import 'exam_selection_screen.dart';
import 'home_screen.dart';
import 'subscription_screen.dart';
import 'pyq_chapter_list_screen.dart'; 
import 'ai_chat_screen.dart'; 
import 'question_screen.dart';

// --- 🛑 ASYNCHRONOUS MAIN FUNCTION WITH SUPABASE INITIALIZATION 🛑 ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // 🛑 REPLACE THESE PLACEHOLDERS 🛑
    url: 'https://pgvymttdvdlkcroqxsgn.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBndnltdHRkdmRsa2Nyb3F4c2duIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzOTEwMzMsImV4cCI6MjA3NDk2NzAzM30.lAaQEs2Mk6BGjIcP8zLkqkFxUDIKyDIT-9kTK5kPnq8',
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define your dark theme with orange and purple accents
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: const Color(0xFFE57C23), // Orange
      cardColor: const Color(0xFF1E1E1E), // Black for card background
      textTheme: GoogleFonts.poppinsTextTheme(
        Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE57C23), // Orange
        secondary: Color(0xFF9C27B0), // Purple
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE57C23),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE57C23)),
        ),
      ),
    );

    return MaterialApp(
      title: 'Edu-Connect',
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/exam_selection': (context) => const ExamSelectionScreen(),
        '/home': (context) => const HomeScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
        '/pyq_mains': (context) => const PyqChapterListScreen(), // Correct Route Name
        '/ai_chat': (context) {
        // Extract the question object passed as an argument
          final question = ModalRoute.of(context)!.settings.arguments as PyqQuestion;
          return AiChatScreen(question: question);
        }
      },
    );
  }
}