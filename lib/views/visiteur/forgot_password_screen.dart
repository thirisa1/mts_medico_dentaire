import 'package:flutter/material.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_dimens.dart';
import '../../style/constants/app_routes.dart';
import '../../utils/app_validators.dart';

/// Page mot de passe oublié — MTS Médico Dentaire
/// Envoie un email de réinitialisation via Firebase Auth
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _loading = false;
  bool _sent = false;
  String? _errorMessage;

  bool get _isMobile =>
      MediaQuery.of(context).size.width < AppDimens.mobileBreak;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      // ── TODO: Firebase Auth ──────────────────────────────────
      // await FirebaseAuth.instance.sendPasswordResetEmail(
      //   email: _emailController.text.trim(),
      // );
      // ─────────────────────────────────────────────────────────

      await Future.delayed(const Duration(seconds: 2)); // simulation
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      setState(() => _errorMessage = _mapFirebaseError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapFirebaseError(String error) {
    if (error.contains('user-not-found'))
      return 'Aucun compte associé à cette adresse email.';
    if (error.contains('invalid-email'))
      return 'Adresse email invalide.';
    if (error.contains('too-many-requests'))
      return 'Trop de tentatives. Réessayez dans quelques minutes.';
    return 'Une erreur est survenue. Réessayez.';
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _sent
                        ? _buildSuccessState()
                        : _buildFormState(),
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
      width: 440,
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
            child: _decor(200, Colors.white.withOpacity(0.03)),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: _decor(250, Colors.white.withOpacity(0.03)),
          ),
          Positioned(
            top: 220,
            left: -50,
            child: _decor(120, AppColors.primary.withOpacity(0.12)),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                _buildPanelLogo(),

                const Spacer(),

                // Illustration centrale
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1), width: 1),
                    ),
                    child: const Icon(Icons.lock_reset_outlined,
                        color: Colors.white, size: 52),
                  ),
                ),
                const SizedBox(height: 36),

                const Text(
                  'Réinitialisation\ndu mot de passe',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Vous recevrez un lien par email pour créer un nouveau mot de passe en toute sécurité.',
                  style: TextStyle(
                      color: AppColors.bannerDesc,
                      fontSize: 13,
                      height: 1.7),
                ),
                const SizedBox(height: 32),

                // Étapes
                _buildInfoRow(
                  Icons.mail_outline,
                  'Entrez votre adresse email',
                ),
                _buildInfoRow(
                  Icons.mark_email_read_outlined,
                  'Vérifiez votre boîte de réception',
                ),
                _buildInfoRow(
                  Icons.link_outlined,
                  'Cliquez sur le lien reçu',
                ),
                _buildInfoRow(
                  Icons.lock_outline,
                  'Créez un nouveau mot de passe',
                ),

                const Spacer(),
                const Text('© 2025 MTS Médico-Dentaire',
                    style: TextStyle(
                        color: AppColors.textFooter, fontSize: 11)),
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
          errorBuilder: (_, __, ___) => Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: const Icon(Icons.medical_services_outlined,
                color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MTS Médico Dentaire',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
            Text('COMPTOIR DENTAIRE',
                style: TextStyle(
                    color: AppColors.bannerWelcome,
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600)),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // ÉTAT FORMULAIRE
  // ──────────────────────────────────────────────────────────────

  Widget _buildFormState() {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopBar(),
        const SizedBox(height: 40),
        _buildFormHeader(),
        const SizedBox(height: 32),
        _buildForm(),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(),
        ],
        const SizedBox(height: 24),
        _buildSubmitButton(),
        const SizedBox(height: 28),
        _buildBackToLogin(),
      ],
    );
  }

  Widget _buildTopBar() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.login),
      child: const MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new,
                size: 14, color: AppColors.primary),
            SizedBox(width: 4),
            Text('Retour à la connexion',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.lock_reset_outlined,
              color: AppColors.primary, size: 26),
        ),
        const SizedBox(height: 18),
        const Text('Mot de passe oublié ?',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
                letterSpacing: -0.3)),
        const SizedBox(height: 8),
        const Text(
          'Entrez votre adresse email ci-dessous. Nous vous enverrons un lien pour réinitialiser votre mot de passe.',
          style: TextStyle(
              fontSize: 13, color: AppColors.textMuted, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Adresse email',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                  letterSpacing: 0.3)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: AppValidators.email,
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'exemple@gmail.com',
              hintStyle:
                  const TextStyle(color: AppColors.textHint, fontSize: 13),
              prefixIcon: const Icon(Icons.mail_outline,
                  color: AppColors.primary, size: 18),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFEF4444), width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_errorMessage!,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _sendReset,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Envoyer le lien de réinitialisation',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Vous vous souvenez ? ',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.login),
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text('Se connecter',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // ÉTAT SUCCÈS (email envoyé)
  // ──────────────────────────────────────────────────────────────

  Widget _buildSuccessState() {
    return Column(
      key: const ValueKey('success'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        // Icône animée
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                color: Color(0xFF059669), size: 48),
          ),
        ),
        const SizedBox(height: 28),

        const Text('Email envoyé !',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
                letterSpacing: -0.3)),
        const SizedBox(height: 12),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
                fontSize: 14, color: AppColors.textMuted, height: 1.7),
            children: [
              const TextSpan(text: 'Un lien de réinitialisation a été envoyé à\n'),
              TextSpan(
                text: _emailController.text.trim(),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark),
              ),
              const TextSpan(
                  text:
                      '\n\nVérifiez votre boîte de réception et vos spams.'),
            ],
          ),
        ),

        const SizedBox(height: 36),

        // Infos pratiques
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              _buildTip(Icons.schedule_outlined,
                  'Le lien expire dans 24 heures.'),
              const SizedBox(height: 10),
              _buildTip(Icons.folder_outlined,
                  'Vérifiez aussi votre dossier spams.'),
              const SizedBox(height: 10),
              _buildTip(Icons.refresh_outlined,
                  'Vous n\'avez rien reçu ? Vérifiez l\'adresse saisie.'),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Renvoyer l'email
        OutlinedButton.icon(
          onPressed: () => setState(() => _sent = false),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Renvoyer un email'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: () =>
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (_) => false),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text('Retour à la connexion',
              style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.4)),
        ),
      ],
    );
  }
}