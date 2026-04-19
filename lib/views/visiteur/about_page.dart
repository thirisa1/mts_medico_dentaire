import 'package:flutter/material.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_dimens.dart';
import '../../style/constants/app_routes.dart';
import '../../widgets/nav_item.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/login_link.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _menuOpen = false;

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

  void _closeMenu() => setState(() => _menuOpen = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavbarSection(),
            if (_isMobile && _menuOpen) _buildMobileMenu(),
            _buildAboutContent(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // NAVBAR
  // ════════════════════════════════════════════════════════════════

  Widget _buildNavbarSection() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(
        horizontal:
            _isMobile ? AppDimens.navbarMarginHMobile : AppDimens.navbarMarginH,
        vertical: AppDimens.navbarMarginV,
      ),
      child: Container(
        height:
            _isMobile
                ? AppDimens.navbarHeightMobile
                : AppDimens.navbarHeightDesktop,
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
            _buildLogo(),
            const SizedBox(width: 10),
            if (!_isMobile) _buildLogoText(),
            const Spacer(),
            if (!_isMobile) ..._buildDesktopNavLinks(),
            if (!_isMobile) const SizedBox(width: 8),
            if (!_isMobile) _buildSearchBar(),
            if (!_isMobile) const SizedBox(width: 14),
            if (!_isMobile) _buildLoginLink(),
            if (_isMobile) _buildHamburger(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'images/logo1.png',
      height:
          _isMobile ? AppDimens.logoHeightMobile : AppDimens.logoHeightDesktop,
      width: _isMobile ? AppDimens.logoWidthMobile : AppDimens.logoWidthDesktop,
      fit: BoxFit.contain,
      errorBuilder:
          (_, __, ___) => Container(
            width:
                _isMobile
                    ? AppDimens.logoWidthMobile
                    : AppDimens.logoWidthDesktop,
            height:
                _isMobile
                    ? AppDimens.logoHeightMobile
                    : AppDimens.logoHeightDesktop,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: AppColors.primary,
              size: 20,
            ),
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

  List<Widget> _buildDesktopNavLinks() {
    return [
      NavItem(
        title: 'Boutique',
        onTap: () => Navigator.pushNamed(context, AppRoutes.boutique),
      ),
      NavItem(title: 'À Propos', onTap: () {}), // page active
      NavItem(
        title: 'Contactez-nous',
        onTap: () => Navigator.pushNamed(context, AppRoutes.contact),
      ),
      NavItem(
        title: 'CGU',
        onTap: () => Navigator.pushNamed(context, AppRoutes.cgu),
      ),
    ];
  }

  Widget _buildSearchBar() {
    return AppSearchBar(
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
    );
  }

  Widget _buildLoginLink() {
    return LoginLink(
      onLogin: () => Navigator.pushNamed(context, AppRoutes.login),
      onRegister: () => Navigator.pushNamed(context, AppRoutes.register),
    );
  }

  Widget _buildHamburger() {
    return IconButton(
      icon: Icon(
        _menuOpen ? Icons.close : Icons.menu,
        color: AppColors.primaryDark,
      ),
      onPressed: () => setState(() => _menuOpen = !_menuOpen),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: AppSearchBar(
              controller: _searchController,
              hint: 'Chercher un produit...',
              onSubmitted: (val) {
                _closeMenu();
                Navigator.pushNamed(
                  context,
                  AppRoutes.boutique,
                  arguments: {'query': val},
                );
              },
            ),
          ),
          _mobileNavItem(Icons.store_outlined, 'Boutique', () {
            _closeMenu();
            Navigator.pushNamed(context, AppRoutes.boutique);
          }),
          _mobileNavItem(Icons.info_outline, 'À Propos', () {
            _closeMenu();
          }),
          _mobileNavItem(Icons.mail_outline, 'Contactez-nous', () {
            _closeMenu();
            Navigator.pushNamed(context, AppRoutes.contact);
          }),
          _mobileNavItem(Icons.description_outlined, 'CGU', () {
            _closeMenu();
            Navigator.pushNamed(context, AppRoutes.cgu);
          }),
          const Divider(height: 16),
          GestureDetector(
            onTap: () {
              _closeMenu();
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

  // ════════════════════════════════════════════════════════════════
  // CONTENU À PROPOS
  // ════════════════════════════════════════════════════════════════

  Widget _buildAboutContent() {
    return Container(
      color: const Color(0xFFF8FAFF),
      child: Column(
        children: [
          _buildHeroBanner(),
          _buildMainSection(),
          _buildValuesSection(),
          _buildCtaSection(),
        ],
      ),
    );
  }

  // ── Bannière hero ──────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 64,
        vertical: _isMobile ? 40 : 56,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDeep,
            AppColors.primaryDark,
            AppColors.primary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fil d'Ariane
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                child: const Text(
                  'Accueil',
                  style: TextStyle(fontSize: 12, color: AppColors.bannerDesc),
                ),
              ),
              const Text(
                '  /  ',
                style: TextStyle(fontSize: 12, color: AppColors.bannerDesc),
              ),
              const Text(
                'À Propos',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'À PROPOS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: AppColors.bannerWelcome,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Qui sommes-nous ?',
            style: TextStyle(
              fontSize: _isMobile ? 28 : 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Votre partenaire de confiance en matériel médico-dentaire',
            style: TextStyle(
              fontSize: _isMobile ? 14 : 16,
              color: AppColors.bannerDesc,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section principale : logo gauche + texte droite ───────────
  Widget _buildMainSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 64,
        vertical: _isMobile ? 40 : 64,
      ),
      child:
          _isMobile
              ? Column(
                children: [
                  _buildLogoBlock(),
                  const SizedBox(height: 32),
                  _buildTextBlock(),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildLogoBlock()),
                  const SizedBox(width: 56),
                  Expanded(flex: 3, child: _buildTextBlock()),
                ],
              ),
    );
  }

  Widget _buildLogoBlock() {
    return Column(
      crossAxisAlignment:
          _isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Logo grand format
        Container(
          width: _isMobile ? 140 : 180,
          height: _isMobile ? 140 : 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'images/logo1.png',
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => const Icon(
                    Icons.medical_services_outlined,
                    color: AppColors.primary,
                    size: 64,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Nom en gras
        Text(
          'MTS Médico\nDentaire',
          textAlign: _isMobile ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'COMPTOIR DENTAIRE PROFESSIONNEL',
          textAlign: _isMobile ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        // Badge "Algérie"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.location_on_outlined,
                size: 13,
                color: AppColors.primary,
              ),
              SizedBox(width: 4),
              Text(
                'Béjaïa, Algérie',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre section
        const Text(
          'Qui sommes-nous',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 24),

        // Paragraphes
        _buildParagraph(
          'MTS Médico Dentaire est un site de vente en ligne de produits médico-dentaires destiné aux cabinets dentaires, médecins, laboratoires et tout autres professionnels de la santé.',
        ),
        const SizedBox(height: 16),
        _buildParagraph(
          "L'équipe MTS Médico Dentaire a choisi la qualité et l'innovation dans le domaine de la distribution des produits médico-dentaires en facilitant l'accès à une très large gamme de produits et en se rapprochant de nos clients. Tout ça afin de faciliter la démarche d'achat.",
        ),
        const SizedBox(height: 16),
        _buildParagraph(
          'MTS Médico Dentaire vous offre un service de haute qualité en vous permettant la consultation détaillée des produits, la possibilité de passer une commande directement sur le site ou bien en appelant, puis la livraison de la commande directement chez vous.',
        ),
        const SizedBox(height: 16),
        _buildParagraph(
          'Notre équipe reste à votre écoute et toutes vos idées sont les bienvenues sur MTSMédicoDentairedz.com. Vous pouvez partager votre opinion ou votre conseil sur nos articles ou notre site web, surtout de nouveaux produits qui n\'existent pas sur notre site.',
        ),

        const SizedBox(height: 28),

        // Bouton "Voir l'aide / Contactez-nous"
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.contact),
          label: const Text(
            'Voir l\'aide — Contactez-nous',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textMuted,
        height: 1.8,
      ),
    );
  }

  // ── Section valeurs ────────────────────────────────────────────
  Widget _buildValuesSection() {
    final values = [
      _ValueItem(
        Icons.verified_outlined,
        'Qualité garantie',
        'Des produits sélectionnés avec soin pour les professionnels de la santé.',
      ),
      _ValueItem(
        Icons.local_shipping_outlined,
        'Livraison rapide',
        'Expédition sous 24h à Béjaïa, 1 à 5 jours sur tout le territoire national.',
      ),
      _ValueItem(
        Icons.support_agent_outlined,
        'Service client',
        'Notre équipe est disponible 7j/7, 24h/24 pour répondre à vos besoins.',
      ),
      _ValueItem(
        Icons.inventory_2_outlined,
        'Large gamme',
        'Des milliers de références pour équiper votre cabinet dentaire complètement.',
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 64,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDeep.withOpacity(0.04),
            AppColors.primary.withOpacity(0.06),
          ],
        ),
      ),
      child: Column(
        children: [
          // En-tête
          Column(
            children: [
              const Text(
                'NOS VALEURS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ce qui nous distingue',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Grille valeurs
          _isMobile
              ? Column(
                children:
                    values
                        .map(
                          (v) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildValueCard(v),
                          ),
                        )
                        .toList(),
              )
              : Row(
                children:
                    values
                        .map(
                          (v) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: _buildValueCard(v),
                            ),
                          ),
                        )
                        .toList(),
              ),
        ],
      ),
    );
  }

  Widget _buildValueCard(_ValueItem value) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(value.icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.desc,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── CTA final ──────────────────────────────────────────────────
  Widget _buildCtaSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 64,
        vertical: 48,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 24 : 48,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDeep, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child:
          _isMobile
              ? Column(
                children: [
                  _buildCtaTexts(),
                  const SizedBox(height: 24),
                  _buildCtaButtons(),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildCtaTexts()),
                  const SizedBox(width: 32),
                  _buildCtaButtons(),
                ],
              ),
    );
  }

  Widget _buildCtaTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Prêt à commander ?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Découvrez notre catalogue de produits médico-dentaires.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.bannerDesc,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildCtaButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.boutique),
          icon: const Icon(Icons.store_outlined, size: 16),
          label: const Text(
            'Voir la boutique',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.contact),
          icon: const Icon(Icons.mail_outline, size: 16),
          label: const Text(
            'Contactez-nous',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white54, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // FOOTER
  // ════════════════════════════════════════════════════════════════

  Widget _buildFooter() {
    return Container(
      color: AppColors.footerBg,
      padding: EdgeInsets.fromLTRB(
        _isMobile ? 20 : 48,
        48,
        _isMobile ? 20 : 48,
        24,
      ),
      child: Column(
        children: [
          _isMobile
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterBrand(),
                  const SizedBox(height: 32),
                  _buildFooterContact(),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFooterCol('Navigation', [
                          _footerLink('Boutique', AppRoutes.boutique),
                          _footerLink('À propos', AppRoutes.about),
                          _footerLink('Contactez-nous', AppRoutes.contact),
                        ]),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _buildFooterCol('Légal', [
                          _footerLink('CGV', AppRoutes.cgv),
                          _footerLink('CGU', AppRoutes.cgu),
                        ]),
                      ),
                    ],
                  ),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildFooterBrand()),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 2,
                    child: _buildFooterCol('Navigation', [
                      _footerLink('Boutique', AppRoutes.boutique),
                      _footerLink('À propos', AppRoutes.about),
                      _footerLink('Contactez-nous', AppRoutes.contact),
                    ]),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: _buildFooterCol('Légal', [
                      _footerLink('CGV', AppRoutes.cgv),
                      _footerLink('CGU', AppRoutes.cgu),
                    ]),
                  ),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: _buildFooterContact()),
                ],
              ),
          const SizedBox(height: 36),
          Container(height: 1, color: AppColors.footerBorder),
          const SizedBox(height: 20),
          Text(
            '© 2025 MTS Médico-Dentaire — Tous droits réservés',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'MTS Médico-Dentaire',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'COMPTOIR DENTAIRE PROFESSIONNEL',
          style: TextStyle(
            fontSize: 9,
            color: AppColors.footerAccent,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Votre partenaire de confiance pour tous vos besoins en matériel dentaire, livraison rapide partout en Algérie.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textFooter,
            height: 1.8,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterCol(String title, List<Widget> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppColors.footerAccent,
          ),
        ),
        const SizedBox(height: 14),
        ...links,
      ],
    );
  }

  Widget _footerLink(String label, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textFooter),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterContact() {
    final items = [
      _ContactItem(Icons.phone_outlined, '07 82 58 00 55'),
      _ContactItem(Icons.mail_outline, 'mtsmedicodentaire@gmail.com'),
      _ContactItem(Icons.access_time_outlined, 'Disponible 24h / 7j'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONTACT',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppColors.footerAccent,
          ),
        ),
        const SizedBox(height: 14),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(item.icon, size: 14, color: AppColors.footerAccent),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    item.text,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textFooter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────

class _ValueItem {
  final IconData icon;
  final String title;
  final String desc;
  const _ValueItem(this.icon, this.title, this.desc);
}

class _ContactItem {
  final IconData icon;
  final String text;
  const _ContactItem(this.icon, this.text);
}
