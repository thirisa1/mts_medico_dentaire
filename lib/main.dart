import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mts_medico_dentaire/views/admin/home_page.dart';
import 'package:mts_medico_dentaire/views/visiteur/about_page.dart';
import 'firebase_options.dart';
import 'style/constants/app_routes.dart';
import 'views/client/acheteur_home_screen.dart';
import 'views/visiteur/boutique_screen.dart';
import 'views/client/cart_screen.dart';
import 'views/visiteur/cgv_page.dart';
import 'views/visiteur/contact.dart';
import 'views/visiteur/forgot_password_screen.dart';
import 'views/visiteur/home_page.dart';
import 'views/visiteur/login.dart';
import 'views/visiteur/product_detail_screen.dart';
import 'views/visiteur/sinscrire.dart';
import 'views/client/validerCommandpage.dart';

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

      initialRoute: '/',

      routes: {
        '/': (_) => const HomePage(),
        '/about': (_) => const AboutScreen(),
        '/cgu': (_) => const CgvCguScreen(initialTab: 0),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/contact': (_) => const ContactScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/boutique': (_) => const BoutiqueScreen(),

        // ── Rôles ──────────────────────────────────────────
        AppRoutes.productDetail: (_) => const ProductDetailScreen(),
        AppRoutes.cart: (_) => const CartScreen(),
        // AppRoutes.checkout:
        //     (_) => const Scaffold(
        //       body: Center(child: Text('Checkout — bientôt disponible')),
        //     ),
        AppRoutes.checkout: (_) => const CheckoutScreen(), // à créer plus tard
        '/admin/dashboard': (_) => const HomePageAdmin(),
        '/acheteur': (ctx) {
          final args =
              ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>? ??
              {'role': 'autre'};
          return AcheteurHomeScreen(role: args['role'] as String);
        },
      },
    );
  }
}
