import 'package:flutter/material.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_dimens.dart';
import '../../style/constants/app_routes.dart';
import '../../widgets/nav_item.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/login_link.dart';

class CgvCguScreen extends StatefulWidget {
  /// Passer initialTab: 0 → CGV, 1 → CGU
  final int initialTab;
  const CgvCguScreen({super.key, this.initialTab = 0});

  @override
  State<CgvCguScreen> createState() => _CgvCguScreenState();
}

class _CgvCguScreenState extends State<CgvCguScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _menuOpen = false;

  bool get _isMobile =>
      MediaQuery.of(context).size.width < AppDimens.mobileBreak;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= AppDimens.mobileBreak &&
      MediaQuery.of(context).size.width < AppDimens.tabletBreak;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            _buildHeroBanner(),
            _buildTabContent(),
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
            if (!_isMobile)
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
            if (!_isMobile) const SizedBox(width: 14),
            if (!_isMobile)
              LoginLink(
                onLogin: () => Navigator.pushNamed(context, AppRoutes.login),
                onRegister:
                    () => Navigator.pushNamed(context, AppRoutes.register),
              ),
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
      NavItem(
        title: 'À Propos',
        onTap: () => Navigator.pushNamed(context, AppRoutes.about),
      ),
      NavItem(
        title: 'Contactez-nous',
        onTap: () => Navigator.pushNamed(context, AppRoutes.contact),
      ),
      NavItem(title: 'CGU', onTap: () {}), // page active
    ];
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
            Navigator.pushNamed(context, AppRoutes.about);
          }),
          _mobileNavItem(Icons.mail_outline, 'Contactez-nous', () {
            _closeMenu();
            Navigator.pushNamed(context, AppRoutes.contact);
          }),
          _mobileNavItem(Icons.description_outlined, 'CGU', () {
            _closeMenu();
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
  // HERO BANNER
  // ════════════════════════════════════════════════════════════════

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 20 : 64,
        vertical: _isMobile ? 36 : 48,
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
                'CGV / CGU',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'LÉGAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: AppColors.bannerWelcome,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Conditions Générales',
            style: TextStyle(
              fontSize: _isMobile ? 26 : 38,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'En navigant et en utilisant ce site, vous acceptez nos conditions générales d\'utilisation (CGU) et conditions générales de vente (CGV).',
            style: TextStyle(
              fontSize: _isMobile ? 13 : 15,
              color: AppColors.bannerDesc,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Dernière mise à jour : janvier 2025',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.bannerWelcome,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ONGLETS CGV / CGU
  // ════════════════════════════════════════════════════════════════

  Widget _buildTabContent() {
    return Container(
      color: const Color(0xFFF8FAFF),
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 16 : 64,
        vertical: 40,
      ),
      child: Column(
        children: [
          // ── Sélecteur d'onglets custom ─────────────────────────
          _buildTabSelector(),
          const SizedBox(height: 32),

          // ── Contenu selon onglet ───────────────────────────────
          AnimatedBuilder(
            animation: _tabController,
            builder: (_, __) {
              return _tabController.index == 0
                  ? _buildCgvContent()
                  : _buildCguContent();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTab(
            0,
            Icons.shopping_cart_outlined,
            'Conditions Générales de Vente',
            'CGV',
          ),
          _buildTab(
            1,
            Icons.gavel_outlined,
            'Conditions Générales d\'Utilisation',
            'CGU',
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    int index,
    IconData icon,
    String fullLabel,
    String shortLabel,
  ) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (_, __) {
        final isSelected = _tabController.index == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tabController.animateTo(index)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _isMobile ? shortLabel : fullLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _isMobile ? 13 : 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Contenu CGV ────────────────────────────────────────────────
  Widget _buildCgvContent() {
    return _buildLegalCard(
      title: 'Conditions Générales de Vente',
      subtitle:
          'MTS Médico Dentaire assure la distribution de produits dentaires. Elle s\'adresse principalement aux chirurgiens-dentistes en exercice et aux structures professionnelles de l\'art dentaire. Toute commande implique l\'acceptation des présentes conditions.',
      articles: [
        _LegalArticle(
          number: '1',
          title: 'Commande',
          icon: Icons.shopping_bag_outlined,
          items: [
            'La passation de la commande se fait soit en ligne via le panier, soit au téléphone en indiquant avec précision les articles concernés.',
            'Toute commande en ligne sera impérativement validée par téléphone, sous réserve d\'annulation.',
            'L\'enregistrement de la commande peut être invalidé en cas d\'informations manquantes ou si le client ne répond pas au téléphone.',
            'Le client est tenu de renseigner toutes les informations nécessaires à la validation de la commande, y compris l\'adresse complète et le code postal.',
            'Les frais de livraison indiqués à la page finale de la commande sont à la charge du client.',
            'En cas d\'annulation, le client doit nous informer par email ou téléphone dans les plus brefs délais.',
            'En cas d\'échec de livraison sur 3 tentatives (absence, téléphone éteint…), le client paiera les frais engagés.',
          ],
        ),
        _LegalArticle(
          number: '2',
          title: 'Paiement',
          icon: Icons.payment_outlined,
          items: [
            'Deux moyens de paiement sont autorisés : paiement à la livraison et virement bancaire sur demande.',
            'Le paiement se fait lors de la réception des articles ou avant. Les crédits ne sont pas autorisés.',
            'L\'émetteur de la commande est prié de préparer la somme exacte en espèces lors de la livraison.',
          ],
        ),
        _LegalArticle(
          number: '3',
          title: 'Expédition et délai de livraison',
          icon: Icons.local_shipping_outlined,
          items: [
            'La livraison est assurée soit par MTS Médico Dentaire, soit par l\'un de ses sous-traitants.',
            'Le délai de livraison varie entre 1 et 5 jours selon la disponibilité et la distance (généralement sous 24h à Béjaïa).',
            'Le client est tenu de vérifier les articles livrés sur place lors de la livraison. Le retour partiel est autorisé sur place en indiquant la raison.',
            'En cas d\'erreur de MTS Médico Dentaire (articles, quantités…), le client doit nous informer dans les 24h suivant la livraison. MTS Médico Dentaire remplacera l\'article manquant et/ou défectueux à sa charge.',
          ],
        ),
        _LegalArticle(
          number: '4',
          title: 'Frais de livraison',
          icon: Icons.receipt_long_outlined,
          items: [
            'Les frais de livraison sont calculés en général selon la distance.',
            'La livraison est gratuite pour toute commande dépassant 10 000 DA dans la région de Béjaïa.',
            'La livraison est gratuite pour toute commande dépassant 20 000 DA sur tout le territoire national.',
          ],
        ),
      ],
    );
  }

  // ── Contenu CGU ────────────────────────────────────────────────
  Widget _buildCguContent() {
    return _buildLegalCard(
      title: 'Conditions Générales d\'Utilisation',
      subtitle:
          'En naviguant et en utilisant ce site, vous acceptez les présentes conditions générales d\'utilisation. Ces conditions peuvent être modifiées à tout moment par MTS Médico Dentaire.',
      articles: [
        _LegalArticle(
          number: '1',
          title: 'Accès au site',
          icon: Icons.public_outlined,
          items: [
            'Le site MTSedicoDentairedz.com est accessible à tout utilisateur disposant d\'un accès à internet.',
            'MTS Médico Dentaire se réserve le droit de suspendre l\'accès au site pour des raisons de maintenance ou de mise à jour.',
            'L\'utilisation du site est réservée aux professionnels de la santé et aux particuliers majeurs.',
          ],
        ),
        _LegalArticle(
          number: '2',
          title: 'Propriété intellectuelle',
          icon: Icons.copyright_outlined,
          items: [
            'L\'ensemble du contenu du site (textes, images, logos) est la propriété exclusive de MTS Médico Dentaire.',
            'Toute reproduction, même partielle, est interdite sans autorisation préalable écrite de MTS Médico Dentaire.',
          ],
        ),
        _LegalArticle(
          number: '3',
          title: 'Données personnelles',
          icon: Icons.shield_outlined,
          items: [
            'Les données collectées lors de votre inscription sont utilisées uniquement pour la gestion de votre compte et de vos commandes.',
            'Conformément à la réglementation en vigueur, vous disposez d\'un droit d\'accès, de modification et de suppression de vos données.',
            'Pour exercer ces droits, contactez-nous à : mtsmedicodentaire@gmail.com.',
          ],
        ),
        _LegalArticle(
          number: '4',
          title: 'Responsabilité',
          icon: Icons.gavel_outlined,
          items: [
            'MTS Médico Dentaire ne saurait être tenu responsable des dommages résultant d\'une utilisation non conforme du site.',
            'Les informations présentes sur le site sont fournies à titre indicatif et peuvent être modifiées sans préavis.',
          ],
        ),
        _LegalArticle(
          number: '5',
          title: 'Contact & réclamations',
          icon: Icons.support_agent_outlined,
          items: [
            'Pour toute question relative aux CGU, vous pouvez nous contacter par email ou téléphone.',
            'Email : mtsmedicodentaire@gmail.com',
            'Téléphone : 07 82 58 00 55 — Disponible 7j/7, 24h/24.',
          ],
        ),
      ],
    );
  }

  // ── Template carte légale ──────────────────────────────────────
  Widget _buildLegalCard({
    required String title,
    required String subtitle,
    required List<_LegalArticle> articles,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(_isMobile ? 20 : 32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.primary.withOpacity(0.1)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _isMobile ? 18 : 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),

          // Articles
          Padding(
            padding: EdgeInsets.all(_isMobile ? 20 : 32),
            child: Column(
              children: articles.map((a) => _buildArticle(a)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticle(_LegalArticle article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de l'article
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    article.number,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(article.icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  article.items.map((item) => _buildBulletItem(item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
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
          const Text(
            '© 2025 MTS Médico-Dentaire — Tous droits réservés',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
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

class _LegalArticle {
  final String number;
  final String title;
  final IconData icon;
  final List<String> items;
  const _LegalArticle({
    required this.number,
    required this.title,
    required this.icon,
    required this.items,
  });
}

class _ContactItem {
  final IconData icon;
  final String text;
  const _ContactItem(this.icon, this.text);
}
