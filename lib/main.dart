import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'providers/translator_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/translator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── INITIALIZE FIREBASE ─────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => TranslatorProvider(),
      child: const HibaloApp(),
    ),
  );
}

class HibaloApp extends StatelessWidget {
  const HibaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hibalo',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7c3aed),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      home: const AuthWrapper(),
    );
  }
}

// ── AUTH WRAPPER ───────────────────────────────────────
// AUTOMATICALLY CHECKS IF USER IS LOGGED IN

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // ── LOADING ─────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6D28D9), Color(0xFF7c3aed)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        }

        // ── USER LOGGED IN ─────────────────────
        if (snapshot.hasData) {
          return const TranslatorScreen();
        }

        // ── USER NOT LOGGED IN ─────────────────
        return AuthScreen(onAuthSuccess: () {});
      },
    );
  }
}
