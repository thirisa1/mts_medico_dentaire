import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mts_medico_dentaire/views/visiteur/about_page.dart';
import 'firebase_options.dart';

// Pages
import 'views/visiteur/cgv_page.dart';
import 'views/visiteur/contact.dart';
import 'views/visiteur/forgot_password_screen.dart';
import 'views/visiteur/home_page.dart';
import 'views/visiteur/login.dart';
import 'views/visiteur/sinscrire.dart';
// import 'views/auth/login_screen.dart';      // décommente quand tu crées le fichier
// import 'views/visitor/boutique_screen.dart'; // décommente quand tu crées le fichier
// import 'views/visitor/about_screen.dart';
// import 'views/visitor/contact_screen.dart';
// import 'views/visitor/cgu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ── Page de démarrage ──────────────────────────────────
      initialRoute: '/',

      // ── Toutes les routes ──────────────────────────────────
      routes: {
        '/': (_) => const HomePage(),
        '/about': (_) => const AboutScreen(),
        '/cgu': (_) => const CgvCguScreen(initialTab: 0),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/contact': (_) => const ContactScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
      },
    );
  }
}
