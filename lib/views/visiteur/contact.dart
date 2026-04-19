import 'package:flutter/material.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_dimens.dart';
import '../../style/constants/app_routes.dart';
import '../../widgets/nav_item.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/login_link.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();

  bool _menuOpen = false;
  bool _sending = false;
  bool _sent = false;

  bool get _isMobile =>
      MediaQuery.of(context).size.width < AppDimens.mobileBreak;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= AppDimens.mobileBreak &&
      MediaQuery.of(context).size.width < AppDimens.tabletBreak;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    // TODO: intégrer Firestore / Firebase Functions / EmailJS
    await Future.delayed(const Duration(seconds: 2)); // simulation
    setState(() {
      _sending = false;
      _sent = true;
    });
  }

  void _reset() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _subjectController.clear();
    _messageController.clear();
    setState(() => _sent = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            if (_isMobile && _menuOpen) _buildMobileMenu(),
            _buildBody(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // HEADER (même navbar que home)
  // ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bannerGradTop,
            AppColors.primaryDeep,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildNavbar(),
            const SizedBox(height: 48),
            _buildPageTitle(),
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar() {
    return Container(
      height: _isMobile
          ? AppDimens.navbarHeightMobile
          : AppDimens.navbarHeightDesktop,
      margin: EdgeInsets.symmetric(
        horizontal:
            _isMobile ? AppDimens.navbarMarginHMobile : AppDimens.navbarMarginH,
        vertical: AppDimens.navbarMarginV,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.navbarBg,
        borderRadius: BorderRadius.circular(AppDimens.navbarRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'images/logo1.png',
            height: _isMobile
                ? AppDimens.logoHeightMobile
                : AppDimens.logoHeightDesktop,
            width: _isMobile
                ? AppDimens.logoWidthMobile
                : AppDimens.logoWidthDesktop,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.medical_services_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          if (!_isMobile) _buildLogoText(),
          const Spacer(),
          if (!_isMobile) ...[
            NavItem(
              title: 'Boutique',
              onTap: () => Navigator.pushNamed(context, AppRoutes.boutique),
            ),
            NavItem(
              title: 'À Propos',
              onTap: () => Navigator.pushNamed(context, AppRoutes.about),
            ),
            NavItem(
              title: 'Contactez-nous',
              onTap: () => Navigator.pushNamed(context, AppRoutes.contact),
            ),
            NavItem(
              title: 'CGU',
              onTap: () => Navigator.pushNamed(context, AppRoutes.cgu),
            ),
            const SizedBox(width: 8),
            AppSearchBar(
              controller: _searchController,
              width: _isTablet
                  ? AppDimens.searchWidthTablet
                  : AppDimens.searchWidthDesktop,
              onSubmitted: (val) => Navigator.pushNamed(
                context,
                AppRoutes.boutique,
                arguments: {'query': val},
              ),
            ),
            const SizedBox(width: 14),
            LoginLink(
              onLogin: () => Navigator.pushNamed(context, AppRoutes.login),
              onRegister: () =>
                  Navigator.pushNamed(context, AppRoutes.register),
            ),
          ],
          if (_isMobile)
            IconButton(
              icon: Icon(
                _menuOpen ? Icons.close : Icons.menu,
                color: AppColors.primaryDark,
              ),
              onPressed: () => setState(() => _menuOpen = !_menuOpen),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'MTS Médico Dentaire',
          style: TextStyle(
            fontSize: AppDimens.fontLogoName,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          'COMPTOIR DENTAIRE',
          style: TextStyle(
            fontSize: AppDimens.fontLogoSub,
            color: AppColors.primary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.navbarMarginHMobile),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mobileMenuBg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _mobileNavItem(Icons.store_outlined, 'Boutique', () {
            _closeMobileMenu();
            Navigator.pushNamed(context, AppRoutes.boutique);
          }),
          _mobileNavItem(Icons.info_outline, 'À Propos', () {
            _closeMobileMenu();
            Navigator.pushNamed(context, AppRoutes.about);
          }),
          _mobileNavItem(Icons.mail_outline, 'Contactez-nous', () {
            _closeMobileMenu();
            Navigator.pushNamed(context, AppRoutes.contact);
          }),
          _mobileNavItem(Icons.description_outlined, 'CGU', () {
            _closeMobileMenu();
            Navigator.pushNamed(context, AppRoutes.cgu);
          }),
          const Divider(height: 16),
          GestureDetector(
            onTap: () {
              _closeMobileMenu();
              Navigator.pushNamed(context, AppRoutes.login);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Se connecter / S'inscrire",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppDimens.fontConnexion,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileNavItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark)),
      onTap: onTap,
    );
  }

  void _closeMobileMenu() => setState(() => _menuOpen = false);

  Widget _buildPageTitle() {
    return Column(
      children: [
        const Text(
          'NOUS CONTACTER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: AppColors.bannerWelcome,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Contactez-nous',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Notre équipe est disponible pour répondre à toutes vos questions.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.bannerDesc,
            height: 1.6,
          ),
        ),
        // Breadcrumb
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.home),
              child: const Text('Accueil',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.bannerWelcome,
                      fontWeight: FontWeight.w500)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.chevron_right,
                  color: AppColors.bannerDesc, size: 16),
            ),
            const Text('Contactez-nous',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // BODY : cartes info + formulaire
  // ──────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Container(
      color: const Color(0xFFF8FAFF),
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 16 : 64,
        vertical: 56,
      ),
      child: _isMobile
          ? Column(
              children: [
                _buildInfoCards(),
                const SizedBox(height: 40),
                _buildFormCard(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: _buildInfoCards(),
                ),
                const SizedBox(width: 40),
                Expanded(child: _buildFormCard()),
              ],
            ),
    );
  }

  Widget _buildInfoCards() {
    final items = [
      _ContactInfo(
        icon: Icons.phone_outlined,
        title: 'Téléphone',
        value: '07 82 58 00 55',
        sub: 'Disponible 7j/7',
        color: AppColors.primary,
      ),
      _ContactInfo(
        icon: Icons.mail_outline,
        title: 'Email',
        value: 'mtsmedicodentaire\n@gmail.com',
        sub: 'Réponse sous 24h',
        color: const Color(0xFF059669),
      ),
      _ContactInfo(
        icon: Icons.access_time_outlined,
        title: 'Horaires',
        value: '24h / 24 — 7j / 7',
        sub: 'Service continu',
        color: const Color(0xFFF59E0B),
      ),
      _ContactInfo(
        icon: Icons.location_on_outlined,
        title: 'Localisation',
        value: 'Algérie',
        sub: 'Livraison nationale',
        color: const Color(0xFFEC4899),
      ),
    ];

    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildInfoCard(item),
              ))
          .toList(),
    );
  }

  Widget _buildInfoCard(_ContactInfo info) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: info.color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: info.color.withOpacity(0.12), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(info.icon, color: info.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.title,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(info.value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                        height: 1.4)),
                const SizedBox(height: 2),
                Text(info.sub,
                    style: TextStyle(
                        fontSize: 11,
                        color: info.color,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // FORMULAIRE
  // ──────────────────────────────────────────────────────────────

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _sent ? _buildSuccessState() : _buildForm(),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline,
              color: Color(0xFF059669), size: 40),
        ),
        const SizedBox(height: 20),
        const Text('Message envoyé !',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark)),
        const SizedBox(height: 12),
        const Text(
          'Merci pour votre message. Notre équipe vous répondra dans les meilleurs délais.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14, color: AppColors.textMuted, height: 1.6),
        ),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Envoyer un autre message'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Envoyez-nous un message',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 6),
          const Text('Remplissez le formulaire et nous vous répondrons rapidement.',
              style:
                  TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
          const SizedBox(height: 28),

          // Nom + Email (côte à côte sur desktop)
          _isMobile
              ? Column(
                  children: [
                    _buildField(
                      controller: _nameController,
                      label: 'Nom complet',
                      hint: 'Dr. Ahmed Benali',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _emailController,
                      label: 'Adresse email',
                      hint: 'exemple@gmail.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Champ requis';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _nameController,
                        label: 'Nom complet',
                        hint: 'Dr. Ahmed Benali',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(
                        controller: _emailController,
                        label: 'Adresse email',
                        hint: 'exemple@gmail.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Champ requis';
                          if (!v.contains('@')) return 'Email invalide';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

          const SizedBox(height: 16),

          // Téléphone + Sujet
          _isMobile
              ? Column(
                  children: [
                    _buildField(
                      controller: _phoneController,
                      label: 'Téléphone (optionnel)',
                      hint: '07 XX XX XX XX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _subjectController,
                      label: 'Sujet',
                      hint: 'Demande de devis / Commande...',
                      icon: Icons.subject_outlined,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _phoneController,
                        label: 'Téléphone (optionnel)',
                        hint: '07 XX XX XX XX',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(
                        controller: _subjectController,
                        label: 'Sujet',
                        hint: 'Demande de devis / Commande...',
                        icon: Icons.subject_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                      ),
                    ),
                  ],
                ),

          const SizedBox(height: 16),

          // Message
          _buildTextAreaField(
            controller: _messageController,
            label: 'Votre message',
            hint:
                'Décrivez votre demande en détail (produit recherché, quantité, questions...)',
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Champ requis';
              if (v.trim().length < 10) return 'Message trop court (min. 10 caractères)';
              return null;
            },
          ),

          const SizedBox(height: 28),

          // Bouton submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sending ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _sending
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
                        Text('Envoyer le message',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
            ),
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
                letterSpacing: 0.3)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
              fontSize: 14, color: AppColors.primaryDark, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
                letterSpacing: 0.3)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: 5,
          style: const TextStyle(
              fontSize: 14, color: AppColors.primaryDark, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            contentPadding: const EdgeInsets.all(16),
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
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // FOOTER (simplifié — identique au home)
  // ──────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      color: AppColors.footerBg,
      padding: EdgeInsets.fromLTRB(
          _isMobile ? 20 : 48, 36, _isMobile ? 20 : 48, 24),
      child: Column(
        children: [
          Container(height: 1, color: AppColors.footerBorder),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('© 2025 MTS Médico-Dentaire — Tous droits réservés',
                  style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
              if (!_isMobile)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: const Text('Flutter + Firebase',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.footerAccent)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Data class locale ────────────────────────────────────────────────────────

class _ContactInfo {
  final IconData icon;
  final String title;
  final String value;
  final String sub;
  final Color color;
  const _ContactInfo({
    required this.icon,
    required this.title,
    required this.value,
    required this.sub,
    required this.color,
  });
}