import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const MeetNoteAIApp());
}

class MeetNoteAIApp extends StatelessWidget {
  const MeetNoteAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeetNote AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // Indigo
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF10B981), // Emerald
          error: const Color(0xFFE11D48), // Rose
          surface: const Color(0xFFF8FAFC), // Nền sáng
        ),
        fontFamily: 'Roboto', // Sử dụng font chữ mặc định của Flutter (có thể thay đổi)
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}
