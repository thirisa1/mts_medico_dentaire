import 'package:flutter/material.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_dimens.dart';
import '../../style/constants/app_routes.dart';
import '../../utils/app_validators.dart';
import '../../services/auth_service.dart';

/// Page de connexion — MTS Médico Dentaire
/// Branché sur Firebase Auth via AuthService
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;

  bool get _isMobile =>
      MediaQuery.of(context).size.width < AppDimens.mobileBreak;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final user = await AuthService.instance.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      switch (user.role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          break;

        case 'professionnel':
          if (!user.verified) {
            _showPendingDialog();
          } else {
            Navigator.pushReplacementNamed(
              context,
              '/acheteur',
              arguments: {'role': 'professionnel'},
            );
          }
          break;

        case 'autre':
        default:
          Navigator.pushReplacementNamed(
            context,
            '/acheteur',
            arguments: {'role': 'autre'},
          );
          break;
      }
    } catch (e) {
      setState(() => _errorMessage = AuthService.translateError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Dialog : compte pro en attente de validation admin
  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(32),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_empty_outlined,
                    color: Color(0xFFF59E0B),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Compte en attente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Votre justificatif professionnel est en cours de vérification. Vous serez notifié par email dès validation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      AuthService.instance.logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Compris',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Row(
        children: [
          if (!_isMobile) _buildLeftPanel(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: _isMobile ? 24 : 56,
                  vertical: 40,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 40),
                      _buildFormHeader(),
                      const SizedBox(height: 32),
                      _buildForm(),
                      const SizedBox(height: 12),
                      _buildForgotPassword(),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _buildErrorBanner(),
                      ],
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                      const SizedBox(height: 28),
                      _buildRegisterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // PANNEAU GAUCHE
  // ──────────────────────────────────────────────────────────────

  Widget _buildLeftPanel() {
    return Container(
      width: 480,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bannerGradTop, AppColors.primaryDeep],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: _decor(200, Colors.white.withOpacity(0.04)),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: _decor(250, Colors.white.withOpacity(0.04)),
          ),
          Positioned(
            top: 200,
            left: -50,
            child: _decor(120, AppColors.primary.withOpacity(0.15)),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPanelLogo(),
                const Spacer(),
                const Text(
                  'Votre espace\nprofessionnel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Accédez à votre compte pour gérer vos commandes, suivre vos livraisons et profiter de tarifs exclusifs.',
                  style: TextStyle(
                    color: AppColors.bannerDesc,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 40),
                ...[
                  'Commandes en ligne simplifiées',
                  'Suivi de livraison en temps réel',
                  'Tarifs professionnels exclusifs',
                  'Support prioritaire 7j/7',
                ].map(
                  (text) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  '© 2025 MTS Médico-Dentaire',
                  style: TextStyle(color: AppColors.textFooter, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelLogo() {
    return Row(
      children: [
        Image.asset(
          'images/logo1.png',
          height: 44,
          width: 44,
          fit: BoxFit.contain,
          errorBuilder:
              (_, __, ___) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MTS Médico Dentaire',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'COMPTOIR DENTAIRE',
              style: TextStyle(
                color: AppColors.bannerWelcome,
                fontSize: 9,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _decor(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  // ──────────────────────────────────────────────────────────────
  // FORMULAIRE
  // ──────────────────────────────────────────────────────────────

  Widget _buildTopBar() => GestureDetector(
    onTap: () => Navigator.pushNamed(context, AppRoutes.home),
    child: const MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back_ios_new, size: 14, color: AppColors.primary),
          SizedBox(width: 4),
          Text(
            'Retour à l\'accueil',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildFormHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.lock_outline,
          color: AppColors.primary,
          size: 24,
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Bon retour !',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryDark,
          letterSpacing: -0.3,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Connectez-vous à votre compte professionnel.',
        style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5),
      ),
    ],
  );

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildField(
            controller: _emailController,
            label: 'Adresse email',
            hint: 'exemple@gmail.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: AppValidators.email,
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: _passwordController,
            label: 'Mot de passe',
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
              onPressed:
                  () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator:
                (v) =>
                    v == null || v.isEmpty
                        ? 'Le mot de passe est requis.'
                        : null,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() => Align(
    alignment: Alignment.centerRight,
    child: GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
      child: const MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          'Mot de passe oublié ?',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
          ),
        ),
      ),
    ),
  );

  Widget _buildErrorBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFECACA), width: 1),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626)),
          ),
        ),
      ],
    ),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _loading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child:
          _loading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
              : const Text(
                'Se connecter',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
    ),
  );

  Widget _buildRegisterLink() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Pas encore de compte ? ",
        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.register),
        child: const MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            "S'inscrire",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
      ),
    ],
  );
}
