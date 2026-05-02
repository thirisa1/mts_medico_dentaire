import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final _searchController = TextEditingController();
  bool _menuOpen = false;

  // ── Coordonnées MTS ───────────────────────────────────────────
  static const String _email = 'mtsmedicodentaire@gmail.com';
  static const String _phone = '0782580055';
  static const String _phoneDisp = '07 82 58 00 55';

  bool get _isMobile =>
      MediaQuery.of(context).size.width < AppDimens.mobileBreak;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= AppDimens.mobileBreak &&
      MediaQuery.of(context).size.width < AppDimens.tabletBreak;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Ouvrir Gmail ──────────────────────────────────────────────
  Future<void> _openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {
        'subject': 'Demande de contact — MTS Médico Dentaire',
        'body':
            'Bonjour,\n\nJe souhaite vous contacter concernant...\n\nCordialement,',
      },
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  // ── Ouvrir le téléphone ───────────────────────────────────────

  Future<void> _openPhone() async {
    final uri = Uri(scheme: 'tel', path: _phone);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
  // HEADER
  // ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bannerGradTop, AppColors.primaryDeep],
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
      height:
          _isMobile
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
            height:
                _isMobile
                    ? AppDimens.logoHeightMobile
                    : AppDimens.logoHeightDesktop,
            width:
                _isMobile
                    ? AppDimens.logoWidthMobile
                    : AppDimens.logoWidthDesktop,
            fit: BoxFit.contain,
            errorBuilder:
                (_, __, ___) => const Icon(
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
              width:
                  _isTablet
                      ? AppDimens.searchWidthTablet
                      : AppDimens.searchWidthDesktop,
              onSubmitted:
                  (val) => Navigator.pushNamed(
                    context,
                    AppRoutes.boutique,
                    arguments: {'query': val},
                  ),
            ),
            const SizedBox(width: 14),
            LoginLink(
              onLogin: () => Navigator.pushNamed(context, AppRoutes.login),
              onRegister:
                  () => Navigator.pushNamed(context, AppRoutes.register),
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
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        horizontal: AppDimens.navbarMarginHMobile,
      ),
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
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
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
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.home),
              child: const Text(
                'Accueil',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.bannerWelcome,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.bannerDesc,
                size: 16,
              ),
            ),
            const Text(
              'Contactez-nous',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // BODY
  // ──────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Container(
      color: const Color(0xFFF8FAFF),
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 16 : 64,
        vertical: 56,
      ),
      child:
          _isMobile
              ? Column(
                children: [
                  _buildInfoCards(),
                  const SizedBox(height: 40),
                  _buildContactCard(),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 300, child: _buildInfoCards()),
                  const SizedBox(width: 40),
                  Expanded(child: _buildContactCard()),
                ],
              ),
    );
  }

  // ── Cartes info ───────────────────────────────────────────────

  Widget _buildInfoCards() {
    final items = [
      _ContactInfo(
        icon: Icons.phone_outlined,
        title: 'Téléphone',
        value: _phoneDisp,
        sub: 'Disponible 7j/7',
        color: AppColors.primary,
        onTap: _openPhone,
      ),
      _ContactInfo(
        icon: Icons.mail_outline,
        title: 'Email',
        value: 'mtsmedicodentaire\n@gmail.com',
        sub: 'Réponse sous 24h',
        color: const Color(0xFF059669),
        onTap: _openEmail,
      ),
      _ContactInfo(
        icon: Icons.access_time_outlined,
        title: 'Horaires',
        value: '24h / 24 — 7j / 7',
        sub: 'Service continu',
        color: const Color(0xFFF59E0B),
        onTap: null,
      ),
      _ContactInfo(
        icon: Icons.location_on_outlined,
        title: 'Localisation',
        value: 'Algérie',
        sub: 'Livraison nationale',
        color: const Color(0xFFEC4899),
        onTap: null,
      ),
    ];

    return Column(
      children:
          items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildInfoCard(item),
                ),
              )
              .toList(),
    );
  }

  Widget _buildInfoCard(_ContactInfo info) {
    final card = Container(
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
                Text(
                  info.title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info.sub,
                  style: TextStyle(
                    fontSize: 11,
                    color: info.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (info.onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: info.color.withOpacity(0.5),
            ),
        ],
      ),
    );

    if (info.onTap != null) {
      return GestureDetector(
        onTap: info.onTap,
        child: MouseRegion(cursor: SystemMouseCursors.click, child: card),
      );
    }
    return card;
  }

  // ── Carte contact principal ───────────────────────────────────

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(40),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),

          // Titre
          const Text(
            'Écrivez-nous directement',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cliquez sur le bouton ci-dessous pour ouvrir votre application email et nous envoyer un message. Notre équipe vous répondra dans les meilleurs délais.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 32),

          // Email affiché
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF059669).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    color: Color(0xFF059669),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adresse email',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _email,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Bouton principal — ouvre Gmail
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openEmail,
              icon: const Icon(Icons.send_outlined, size: 20),
              label: const Text(
                'Envoyer un email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Bouton secondaire — appel
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openPhone,
              icon: const Icon(Icons.phone_outlined, size: 20),
              label: Text(
                'Appeler le $_phoneDisp',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nous répondons généralement sous 24h. Pour les urgences, appelez-nous directement.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // FOOTER
  // ──────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      color: AppColors.footerBg,
      padding: EdgeInsets.fromLTRB(
        _isMobile ? 20 : 48,
        36,
        _isMobile ? 20 : 48,
        24,
      ),
      child: Column(
        children: [
          Container(height: 1, color: AppColors.footerBorder),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '© 2025 MTS Médico-Dentaire — Tous droits réservés',
                style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
              ),
              if (!_isMobile)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: const Text(
                    'Flutter + Firebase',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.footerAccent,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _ContactInfo {
  final IconData icon;
  final String title;
  final String value;
  final String sub;
  final Color color;
  final VoidCallback? onTap;

  const _ContactInfo({
    required this.icon,
    required this.title,
    required this.value,
    required this.sub,
    required this.color,
    this.onTap,
  });
}
