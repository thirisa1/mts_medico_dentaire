import 'package:flutter/material.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_dimens.dart';
import '../../style/constants/app_routes.dart';
import '../../utils/app_validators.dart';

/// Page d'inscription — MTS Médico Dentaire
/// Types de compte : Professionnel (justificatif requis) | Autre
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _loading = false;
  String? _errorMessage;

  // Type de compte : 'professionnel' | 'autre'
  String _accountType = 'professionnel';

  // Justificatif (fichier simulé — remplacer par file_picker)
  String? _justificatifName;
  bool _justificatifError = false;

  bool get _isMobile =>
      MediaQuery.of(context).size.width < AppDimens.mobileBreak;
  bool get _isPro => _accountType == 'professionnel';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Sélection du justificatif ─────────────────────────────────
  Future<void> _pickFile() async {
    // TODO: intégrer file_picker
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    // );
    // if (result != null) {
    //   setState(() {
    //     _justificatifName = result.files.single.name;
    //     _justificatifError = false;
    //   });
    // }

    // Simulation :
    setState(() {
      _justificatifName = 'justificatif_professionnel.pdf';
      _justificatifError = false;
    });
  }

  void _removeFile() => setState(() => _justificatifName = null);

  // ── Soumission ────────────────────────────────────────────────
  Future<void> _register() async {
    // Vérifier le justificatif pour les pros avant la validation du form
    if (_isPro && _justificatifName == null) {
      setState(() => _justificatifError = true);
    }

    final formValid = _formKey.currentState!.validate();
    final fileValid = !_isPro || _justificatifName != null;

    if (!formValid || !fileValid) return;

    if (!_acceptTerms) {
      setState(
        () => _errorMessage = 'Veuillez accepter les CGU pour continuer.',
      );
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // ── TODO: Firebase Auth ──────────────────────────────────
      // final credential = await FirebaseAuth.instance
      //     .createUserWithEmailAndPassword(
      //   email: _emailController.text.trim(),
      //   password: _passwordController.text,
      // );
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(credential.user!.uid)
      //     .set({
      //   'firstName': _firstNameController.text.trim(),
      //   'lastName': _lastNameController.text.trim(),
      //   'email': _emailController.text.trim(),
      //   'phone': _phoneController.text.trim(),
      //   'accountType': _accountType,
      //   'role': 'client',
      //   'justificatifUploaded': _isPro,
      //   'verified': false, // admin doit valider le justificatif
      //   'createdAt': FieldValue.serverTimestamp(),
      // });
      // ─────────────────────────────────────────────────────────

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _showSuccessDialog();
    } catch (e) {
      setState(() => _errorMessage = _mapFirebaseError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapFirebaseError(String error) {
    if (error.contains('email-already-in-use'))
      return 'Un compte existe déjà avec cet email.';
    if (error.contains('invalid-email')) return 'Adresse email invalide.';
    if (error.contains('weak-password'))
      return 'Mot de passe trop faible (min. 8 caractères).';
    if (error.contains('network-request-failed'))
      return 'Erreur réseau. Vérifiez votre connexion.';
    return 'Une erreur est survenue. Réessayez.';
  }

  void _showSuccessDialog() {
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
                    color: const Color(0xFF059669).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF059669),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Compte créé !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isPro
                      ? 'Votre compte professionnel a été créé. Un administrateur vérifiera votre justificatif avant activation.'
                      : 'Votre compte a été créé avec succès. Vous pouvez maintenant vous connecter.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

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
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 32),
                      _buildFormHeader(),
                      const SizedBox(height: 28),
                      _buildAccountTypeSelector(),
                      const SizedBox(height: 28),
                      _buildForm(),
                      // Justificatif uniquement pour pro
                      if (_isPro) ...[
                        const SizedBox(height: 20),
                        _buildJustificatifUploader(),
                      ],
                      const SizedBox(height: 20),
                      _buildTermsCheckbox(),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _buildErrorBanner(),
                      ],
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                      const SizedBox(height: 28),
                      _buildLoginLink(),
                      const SizedBox(height: 16),
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
      width: 380,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F3460), AppColors.primaryDeep],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: _decor(220, Colors.white.withOpacity(0.03)),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: _decor(280, Colors.white.withOpacity(0.03)),
          ),
          Positioned(
            top: 300,
            right: -30,
            child: _decor(100, AppColors.primary.withOpacity(0.12)),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo image ──────────────────────────────────
                _buildPanelLogo(),

                const Spacer(),

                const Text(
                  'Rejoignez\nnotre réseau',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Créez votre compte et bénéficiez d\'un accès complet à notre catalogue médico-dentaire professionnel.',
                  style: TextStyle(
                    color: AppColors.bannerDesc,
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 32),

                _buildStep(
                  1,
                  'Choisissez votre profil',
                  'Professionnel ou particulier',
                ),
                _buildStep(
                  2,
                  'Complétez vos informations',
                  'Données personnelles sécurisées',
                ),
                _buildStep(
                  3,
                  'Accédez au catalogue',
                  'Commandez en quelques clics',
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
        // Logo image avec fallback
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

  Widget _buildStep(int number, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.bannerDesc,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // HEADER FORMULAIRE
  // ──────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return GestureDetector(
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
  }

  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Container(
        //   width: 48,
        //   height: 48,
        //   decoration: BoxDecoration(
        //     color: AppColors.primary.withOpacity(0.1),
        //     borderRadius: BorderRadius.circular(14),
        //   ),
        //   // child: const Icon(Icons.person_add_outlined,
        //   //     color: AppColors.primary, size: 24),
        // ),
        const SizedBox(height: 16),
        const Text(
          'Créer un compte',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Remplissez le formulaire pour rejoindre MTS.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // SÉLECTEUR TYPE DE COMPTE
  // ──────────────────────────────────────────────────────────────

  Widget _buildAccountTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de compte',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTypeCard(
                type: 'professionnel',
                icon: Icons.medical_information_outlined,
                title: 'Professionnel',
                subtitle: 'Médecin, dentiste, clinique…',
                badge: 'Justificatif requis',
                badgeColor: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                type: 'autre',
                icon: Icons.person_outline,
                title: 'Autre',
                subtitle: 'Particulier ou revendeur',
                badge: 'Accès libre',
                badgeColor: const Color(0xFF059669),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required String type,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
  }) {
    final selected = _accountType == type;
    return GestureDetector(
      onTap:
          () => setState(() {
            _accountType = type;
            // Réinitialiser justificatif si on bascule sur "autre"
            if (type == 'autre') {
              _justificatifName = null;
              _justificatifError = false;
            }
          }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.primary.withOpacity(0.07)
                  : const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? AppColors.primary.withOpacity(0.12)
                            : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? AppColors.primary : AppColors.textMuted,
                    size: 18,
                  ),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          selected
                              ? AppColors.primary
                              : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                    color: selected ? AppColors.primary : Colors.transparent,
                  ),
                  child:
                      selected
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          )
                          : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primaryDark : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // FORMULAIRE
  // ──────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Prénom + Nom
          _isMobile
              ? Column(
                children: [
                  _buildField(
                    controller: _firstNameController,
                    label: 'Prénom',
                    hint: 'Ahmed',
                    icon: Icons.person_outline,
                    validator: (v) => AppValidators.name(v, label: 'Le prénom'),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _lastNameController,
                    label: 'Nom de famille',
                    hint: 'Benali',
                    icon: Icons.person_outline,
                    validator: (v) => AppValidators.name(v, label: 'Le nom'),
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      hint: 'Ahmed',
                      icon: Icons.person_outline,
                      validator:
                          (v) => AppValidators.name(v, label: 'Le prénom'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      controller: _lastNameController,
                      label: 'Nom de famille',
                      hint: 'Benali',
                      icon: Icons.person_outline,
                      validator: (v) => AppValidators.name(v, label: 'Le nom'),
                    ),
                  ),
                ],
              ),

          const SizedBox(height: 16),

          // Email + Téléphone
          _isMobile
              ? Column(
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
                    controller: _phoneController,
                    label: 'Téléphone',
                    hint: '07 XX XX XX XX',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: AppValidators.phone,
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _emailController,
                      label: 'Adresse email',
                      hint: 'exemple@gmail.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidators.email,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      controller: _phoneController,
                      label: 'Téléphone',
                      hint: '07 XX XX XX XX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: AppValidators.phone,
                    ),
                  ),
                ],
              ),

          const SizedBox(height: 16),

          // Mot de passe
          _buildField(
            controller: _passwordController,
            label: 'Mot de passe',
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            helperText: 'Min. 8 caractères, avec lettres et chiffres.',
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
            validator: AppValidators.password,
          ),

          const SizedBox(height: 16),

          // Confirmer mot de passe
          _buildField(
            controller: _confirmController,
            label: 'Confirmer le mot de passe',
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: _obscureConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
              onPressed:
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: AppValidators.confirmPassword(_passwordController.text),
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
    String? helperText,
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
            helperText: helperText,
            helperStyle: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
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

  // ──────────────────────────────────────────────────────────────
  // JUSTIFICATIF (pro uniquement)
  // ──────────────────────────────────────────────────────────────

  Widget _buildJustificatifUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Justificatif professionnel',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Requis',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD97706),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Carte professionnelle, diplôme ou attestation (PDF, JPG, PNG — max 5 Mo)',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),

        // Zone de dépôt
        _justificatifName == null
            ? GestureDetector(
              onTap: _pickFile,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color:
                        _justificatifError
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _justificatifError
                              ? const Color(0xFFEF4444)
                              : AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.upload_file_outlined,
                        color:
                            _justificatifError
                                ? const Color(0xFFEF4444)
                                : AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Cliquez pour sélectionner un fichier',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              _justificatifError
                                  ? const Color(0xFFEF4444)
                                  : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ou glissez-déposez ici',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file_outlined,
                    color: Color(0xFF059669),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _justificatifName!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF065F46),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Fichier sélectionné',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _removeFile,
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF059669),
                      size: 18,
                    ),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ),

        // Message d'erreur
        if (_justificatifError && _justificatifName == null) ...[
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 14),
              SizedBox(width: 4),
              Text(
                'Un justificatif est requis pour les comptes professionnels.',
                style: TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // CGU + ERREUR + BOUTON
  // ──────────────────────────────────────────────────────────────

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (v) => setState(() => _acceptTerms = v ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: "J'accepte les "),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.cgu),
                      child: const MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          "Conditions Générales d'Utilisation",
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
                  ),
                  const TextSpan(text: ' et la '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {},
                      child: const MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          'Politique de confidentialité',
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
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
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
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
                  'Créer mon compte',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Déjà un compte ? ',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.login),
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              'Se connecter',
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
}
