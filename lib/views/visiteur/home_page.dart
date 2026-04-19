// import 'package:flutter/material.dart';
// import 'package:mts_medico_dentaire/style/constants/app_colors.dart'
//     show AppColors;
// import '../style/constants/app_dimens.dart';
// import '../style/constants/app_routes.dart';
// import '../widgets/app_search_bar.dart';
// import '../widgets/info_card.dart';
// import '../widgets/login_link.dart';
// import '../widgets/nav_item.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final TextEditingController _searchController = TextEditingController();
//   bool _menuOpen = false;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ── Helpers responsive ──────────────────────────────────────
//   bool get _isMobile =>
//       MediaQuery.of(context).size.width < AppDimens.mobileBreak;
//   bool get _isTablet =>
//       MediaQuery.of(context).size.width >= AppDimens.mobileBreak &&
//       MediaQuery.of(context).size.width < AppDimens.tabletBreak;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [_buildBackground(), _buildOverlay(), _buildBody()],
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // BACKGROUND & OVERLAY
//   // ──────────────────────────────────────────────────────────────

//   Widget _buildBackground() {
//     return SizedBox.expand(
//       child: Image.asset('images/backg4.jpg', fit: BoxFit.cover),
//     );
//   }

//   Widget _buildOverlay() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             AppColors.bannerGradTop,
//             AppColors.bannerGradMid,
//             AppColors.bannerGradBottom,
//           ],
//         ),
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // BODY PRINCIPAL
//   // ──────────────────────────────────────────────────────────────

//   Widget _buildBody() {
//     return Column(
//       children: [
//         SafeArea(child: _buildNavbar()),
//         if (_isMobile && _menuOpen) _buildMobileMenu(),
//         const Spacer(),
//         _buildHeroText(),
//         const Spacer(),
//         _buildInfoBar(),
//       ],
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // NAVBAR
//   // ──────────────────────────────────────────────────────────────

//   Widget _buildNavbar() {
//     return Container(
//       height:
//           _isMobile
//               ? AppDimens.navbarHeightMobile
//               : AppDimens.navbarHeightDesktop,
//       margin: EdgeInsets.symmetric(
//         horizontal:
//             _isMobile ? AppDimens.navbarMarginHMobile : AppDimens.navbarMarginH,
//         vertical: AppDimens.navbarMarginV,
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: AppColors.navbarBg,
//         borderRadius: BorderRadius.circular(AppDimens.navbarRadius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           _buildLogo(),
//           const SizedBox(width: 10),
//           if (!_isMobile) _buildLogoText(),
//           const Spacer(),
//           if (!_isMobile) ..._buildDesktopNavLinks(),
//           if (!_isMobile) const SizedBox(width: 8),
//           if (!_isMobile) _buildSearchBar(),
//           if (!_isMobile) const SizedBox(width: 14),
//           if (!_isMobile) _buildLoginLink(),
//           if (_isMobile) _buildHamburger(),
//         ],
//       ),
//     );
//   }

//   Widget _buildLogo() {
//     return Image.asset(
//       'images/logo1.png',
//       height:
//           _isMobile ? AppDimens.logoHeightMobile : AppDimens.logoHeightDesktop,
//       width: _isMobile ? AppDimens.logoWidthMobile : AppDimens.logoWidthDesktop,
//       fit: BoxFit.contain,
//       errorBuilder: (_, __, ___) => _buildLogoFallback(),
//     );
//   }

//   Widget _buildLogoFallback() {
//     return Container(
//       width: _isMobile ? AppDimens.logoWidthMobile : AppDimens.logoWidthDesktop,
//       height:
//           _isMobile ? AppDimens.logoHeightMobile : AppDimens.logoHeightDesktop,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(color: AppColors.primary, width: 2),
//       ),
//       child: const Icon(
//         Icons.medical_services_outlined,
//         color: AppColors.primary,
//         size: 20,
//       ),
//     );
//   }

//   Widget _buildLogoText() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: const [
//         Text(
//           'MTS Médico Dentaire',
//           style: TextStyle(
//             fontSize: AppDimens.fontLogoName,
//             fontWeight: FontWeight.w800,
//             color: AppColors.primaryDark,
//             letterSpacing: -0.3,
//           ),
//         ),
//         Text(
//           'COMPTOIR DENTAIRE',
//           style: TextStyle(
//             fontSize: AppDimens.fontLogoSub,
//             color: AppColors.primary,
//             letterSpacing: 1.2,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   List<Widget> _buildDesktopNavLinks() {
//     return [
//       NavItem(
//         title: 'Boutique',
//         onTap: () => Navigator.pushNamed(context, AppRoutes.boutique),
//       ),
//       NavItem(
//         title: 'À Propos',
//         onTap: () => Navigator.pushNamed(context, AppRoutes.about),
//       ),
//       NavItem(
//         title: 'Contactez-nous',
//         onTap: () => Navigator.pushNamed(context, AppRoutes.contact),
//       ),
//       NavItem(
//         title: 'CGU',
//         onTap: () => Navigator.pushNamed(context, AppRoutes.cgu),
//       ),
//     ];
//   }

//   Widget _buildSearchBar() {
//     return AppSearchBar(
//       controller: _searchController,
//       width:
//           _isTablet
//               ? AppDimens.searchWidthTablet
//               : AppDimens.searchWidthDesktop,
//       onSubmitted:
//           (val) => Navigator.pushNamed(
//             context,
//             AppRoutes.boutique,
//             arguments: {'query': val},
//           ),
//     );
//   }

//   Widget _buildLoginLink() {
//     return LoginLink(
//       onLogin: () => Navigator.pushNamed(context, AppRoutes.login),
//       onRegister: () => Navigator.pushNamed(context, AppRoutes.register),
//     );
//   }

//   Widget _buildHamburger() {
//     return IconButton(
//       icon: Icon(
//         _menuOpen ? Icons.close : Icons.menu,
//         color: AppColors.primaryDark,
//       ),
//       onPressed: () => setState(() => _menuOpen = !_menuOpen),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // MENU MOBILE DROPDOWN
//   // ──────────────────────────────────────────────────────────────

//   Widget _buildMobileMenu() {
//     return Container(
//       margin: const EdgeInsets.symmetric(
//         horizontal: AppDimens.navbarMarginHMobile,
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: AppColors.mobileMenuBg,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: AppSearchBar(
//               controller: _searchController,
//               hint: 'Chercher un produit...',
//               onSubmitted: (val) {
//                 _closeMenu();
//                 Navigator.pushNamed(
//                   context,
//                   AppRoutes.boutique,
//                   arguments: {'query': val},
//                 );
//               },
//             ),
//           ),
//           _buildMobileNavItem(Icons.store_outlined, 'Boutique', () {
//             _closeMenu();
//             Navigator.pushNamed(context, AppRoutes.boutique);
//           }),
//           _buildMobileNavItem(Icons.info_outline, 'À Propos', () {
//             _closeMenu();
//             Navigator.pushNamed(context, AppRoutes.about);
//           }),
//           _buildMobileNavItem(Icons.mail_outline, 'Contactez-nous', () {
//             _closeMenu();
//             Navigator.pushNamed(context, AppRoutes.contact);
//           }),
//           _buildMobileNavItem(Icons.description_outlined, 'CGU', () {
//             _closeMenu();
//             Navigator.pushNamed(context, AppRoutes.cgu);
//           }),
//           const Divider(height: 16),
//           GestureDetector(
//             onTap: () {
//               _closeMenu();
//               Navigator.pushNamed(context, AppRoutes.login);
//             },
//             child: const Padding(
//               padding: EdgeInsets.symmetric(vertical: 8),
//               child: Text(
//                 "Se connecter / S'inscrire",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: AppDimens.fontConnexion,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.primary,
//                   decoration: TextDecoration.underline,
//                   decorationColor: AppColors.primary,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMobileNavItem(IconData icon, String label, VoidCallback onTap) {
//     return ListTile(
//       dense: true,
//       leading: Icon(icon, color: AppColors.primary, size: 20),
//       title: Text(
//         label,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           color: AppColors.primaryDark,
//         ),
//       ),
//       onTap: onTap,
//     );
//   }

//   void _closeMenu() => setState(() => _menuOpen = false);

//   // ──────────────────────────────────────────────────────────────
//   // HERO TEXT
//   // ──────────────────────────────────────────────────────────────

//   Widget _buildHeroText() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         children: [
//           Text(
//             'Bienvenue chez',
//             style: TextStyle(
//               color: AppColors.bannerWelcome,
//               fontSize:
//                   _isMobile
//                       ? AppDimens.fontBannerWelcomeMobile
//                       : AppDimens.fontBannerWelcome,
//               letterSpacing: 2,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'MTS Médico Dentaire',
//             style: TextStyle(
//               color: AppColors.bannerTitle,
//               fontSize:
//                   _isMobile
//                       ? AppDimens.fontBannerTitleMobile
//                       : AppDimens.fontBannerTitle,
//               fontWeight: FontWeight.w900,
//               letterSpacing: -1,
//               height: 1.05,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: _isMobile ? 8 : 80),
//             child: Text(
//               'Un comptoir dentaire qui offre tout ce dont vous avez besoin '
//               'pour votre cabinet dentaire.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: AppColors.bannerDesc,
//                 fontSize:
//                     _isMobile
//                         ? AppDimens.fontBannerDescMobile
//                         : AppDimens.fontBannerDesc,
//                 height: 1.7,
//               ),
//             ),
//           ),
//           const SizedBox(height: 28),
//           _buildDiscoverButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildDiscoverButton() {
//     return OutlinedButton.icon(
//       onPressed: () => Navigator.pushNamed(context, AppRoutes.boutique),
//       icon: Container(
//         width: 22,
//         height: 22,
//         decoration: BoxDecoration(
//           color: Colors.white24,
//           borderRadius: BorderRadius.circular(11),
//         ),
//         child: const Icon(Icons.arrow_forward, color: Colors.white, size: 13),
//       ),
//       label: Text(
//         'Nos Produits',
//         style: TextStyle(
//           color: AppColors.bannerTitle,
//           fontSize:
//               _isMobile
//                   ? AppDimens.btnDiscoverFontMobile
//                   : AppDimens.btnDiscoverFontSize,
//           fontWeight: FontWeight.w700,
//           letterSpacing: 1,
//         ),
//       ),
//       style: OutlinedButton.styleFrom(
//         side: const BorderSide(color: AppColors.bannerBtnBorder, width: 1.5),
//         padding: EdgeInsets.symmetric(
//           horizontal:
//               _isMobile
//                   ? AppDimens.btnDiscoverPadHMobile
//                   : AppDimens.btnDiscoverPadH,
//           vertical:
//               _isMobile
//                   ? AppDimens.btnDiscoverPadVMobile
//                   : AppDimens.btnDiscoverPadV,
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // INFO BAR (bas du banner)
//   // ──────────────────────────────────────────────────────────────

//   Widget _buildInfoBar() {
//     final cards = [
//       _InfoCardData(
//         icon: Icons.phone_outlined,
//         title: 'Appelez-nous',
//         text: '07 82 58 00 55',
//       ),
//       _InfoCardData(
//         icon: Icons.mail_outline,
//         title: 'Écrivez-nous',
//         text: 'mtsmedicodentaire@gmail.com',
//       ),
//       _InfoCardData(
//         icon: Icons.calendar_today_outlined,
//         title: 'Disponibilité',
//         text: 'Disponible 7j / 7',
//       ),
//       _InfoCardData(
//         icon: Icons.access_time_outlined,
//         title: 'Service continu',
//         text: '24 Heures / 24',
//       ),
//     ];

//     if (_isMobile) {
//       return Column(
//         children:
//             cards
//                 .map(
//                   (c) => InfoCard(
//                     icon: c.icon,
//                     title: c.title,
//                     text: c.text,
//                     isMobile: true,
//                   ),
//                 )
//                 .toList(),
//       );
//     }

//     return Row(
//       children:
//           cards
//               .map(
//                 (c) => Expanded(
//                   child: InfoCard(
//                     icon: c.icon,
//                     title: c.title,
//                     text: c.text,
//                     isMobile: false,
//                   ),
//                 ),
//               )
//               .toList(),
//     );
//   }
// }

// // ── Data class locale pour les info cards ────────────────────────────────────
// class _InfoCardData {
//   final IconData icon;
//   final String title;
//   final String text;
//   const _InfoCardData({
//     required this.icon,
//     required this.title,
//     required this.text,
//   });
// }

import 'package:flutter/material.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_dimens.dart';
import '../../style/constants/app_routes.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/info_card.dart';
import '../../widgets/login_link.dart';
import '../../widgets/nav_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Clé globale pour scroller vers la section produits
  final GlobalKey _productsSectionKey = GlobalKey();

  bool _menuOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Helpers responsive ────────────────────────────────────────
  bool get _isMobile =>
      MediaQuery.of(context).size.width < AppDimens.mobileBreak;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= AppDimens.mobileBreak &&
      MediaQuery.of(context).size.width < AppDimens.tabletBreak;

  /// Scroll fluide vers la section produits
  void _scrollToProducts() {
    final ctx = _productsSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // ── 1. SECTION BANNER (photo + overlay + navbar + hero + infobar) ──
            _buildBannerSection(),

            // ── 2. SECTION PRODUITS ───────────────────────────────────────────
            _buildProductsSection(),

            // ── 3. FOOTER ─────────────────────────────────────────────────────
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 1. SECTION BANNER
  // ════════════════════════════════════════════════════════════════

  Widget _buildBannerSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          _buildBackground(),
          _buildOverlay(),
          Column(
            children: [
              SafeArea(child: _buildNavbar()),
              if (_isMobile && _menuOpen) _buildMobileMenu(),
              const Spacer(),
              _buildHeroText(),
              const Spacer(),
              _buildInfoBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return SizedBox.expand(
      child: Image.asset('images/backg4.jpg', fit: BoxFit.cover),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bannerGradTop,
            AppColors.bannerGradMid,
            AppColors.bannerGradBottom,
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // NAVBAR
  // ──────────────────────────────────────────────────────────────

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

  // ──────────────────────────────────────────────────────────────
  // MENU MOBILE
  // ──────────────────────────────────────────────────────────────

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
                "Se connecter /",
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
          GestureDetector(
            onTap: () {
              _closeMenu();
              Navigator.pushNamed(context, AppRoutes.register);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                " S'inscrire",
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

  void _closeMenu() => setState(() => _menuOpen = false);

  // ──────────────────────────────────────────────────────────────
  // HERO TEXT
  // ──────────────────────────────────────────────────────────────

  Widget _buildHeroText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Bienvenue chez',
            style: TextStyle(
              color: AppColors.bannerWelcome,
              fontSize:
                  _isMobile
                      ? AppDimens.fontBannerWelcomeMobile
                      : AppDimens.fontBannerWelcome,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'MTS Médico Dentaire',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.bannerTitle,
              fontSize:
                  _isMobile
                      ? AppDimens.fontBannerTitleMobile
                      : AppDimens.fontBannerTitle,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _isMobile ? 8 : 80),
            child: Text(
              'Un comptoir dentaire qui offre tout ce dont vous avez besoin '
              'pour votre cabinet dentaire.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.bannerDesc,
                fontSize:
                    _isMobile
                        ? AppDimens.fontBannerDescMobile
                        : AppDimens.fontBannerDesc,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Bouton → scroll vers section produits
          OutlinedButton.icon(
            onPressed: _scrollToProducts,
            icon: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.arrow_downward,
                color: Colors.white,
                size: 13,
              ),
            ),
            label: Text(
              'Nos Produits',
              style: TextStyle(
                color: AppColors.bannerTitle,
                fontSize:
                    _isMobile
                        ? AppDimens.btnDiscoverFontMobile
                        : AppDimens.btnDiscoverFontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppColors.bannerBtnBorder,
                width: 1.5,
              ),
              padding: EdgeInsets.symmetric(
                horizontal:
                    _isMobile
                        ? AppDimens.btnDiscoverPadHMobile
                        : AppDimens.btnDiscoverPadH,
                vertical:
                    _isMobile
                        ? AppDimens.btnDiscoverPadVMobile
                        : AppDimens.btnDiscoverPadV,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // INFO BAR
  // ──────────────────────────────────────────────────────────────

  Widget _buildInfoBar() {
    final cards = [
      _InfoCardData(Icons.phone_outlined, 'Appelez-nous', '07 82 58 00 55'),
      _InfoCardData(
        Icons.mail_outline,
        'Écrivez-nous',
        'mtsmedicodentaire@gmail.com',
      ),
      _InfoCardData(
        Icons.calendar_today_outlined,
        'Disponibilité',
        'Disponible 7j / 7',
      ),
      _InfoCardData(
        Icons.access_time_outlined,
        'Service continu',
        '24 Heures / 24',
      ),
    ];

    if (_isMobile) {
      return Column(
        children:
            cards
                .map(
                  (c) => InfoCard(
                    icon: c.icon,
                    title: c.title,
                    text: c.text,
                    isMobile: true,
                  ),
                )
                .toList(),
      );
    }
    return Row(
      children:
          cards
              .map(
                (c) => Expanded(
                  child: InfoCard(
                    icon: c.icon,
                    title: c.title,
                    text: c.text,
                    isMobile: false,
                  ),
                ),
              )
              .toList(),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 2. SECTION PRODUITS
  // ════════════════════════════════════════════════════════════════

  Widget _buildProductsSection() {
    return Container(
      key: _productsSectionKey, // ← ancre pour le scroll
      color: const Color(0xFFF8FAFF),
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 16 : 48,
        vertical: 56,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête section ─────────────────────────────────
          _buildSectionHeader(
            eyebrow: 'CATALOGUE',
            title: 'Nos Produits',
            desc:
                'Découvrez notre sélection de matériel médico-dentaire professionnel.',
          ),
          const SizedBox(height: 32),

          // ── Placeholder "pas de produits" ────────────────────
          //_buildEmptyProducts(),
          const SizedBox(height: 56),

          // ── En-tête meilleures ventes ────────────────────────
          _buildSectionHeader(
            eyebrow: 'TOP VENTES',
            title: 'Meilleures ventes',
            desc: 'Les produits les plus commandés par nos praticiens.',
          ),
          const SizedBox(height: 32),

          //_buildEmptyProducts(),
          const SizedBox(height: 56),

          // ── En-tête mieux notés ──────────────────────────────
          _buildSectionHeader(
            eyebrow: 'TOP AVIS',
            title: 'Mieux notés',
            desc: 'Sélectionnés selon les évaluations de nos clients.',
            accentColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 32),
          //_buildEmptyProducts(accentColor: const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String eyebrow,
    required String title,
    required String desc,
    Color accentColor = AppColors.primary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 3. FOOTER
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
          // ── Grille footer ────────────────────────────────────
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
                          _footerLink('Confidentialité', '/privacy'),
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
                      _footerLink('Confidentialité', '/privacy'),
                    ]),
                  ),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: _buildFooterContact()),
                ],
              ),

          // ── Ligne de séparation ───────────────────────────────
          const SizedBox(height: 36),
          Container(height: 1, color: AppColors.footerBorder),
          const SizedBox(height: 20),

          // ── Copyright ─────────────────────────────────────────
          _isMobile
              ? const Text(
                '© 2025 MTS Médico-Dentaire — Tous droits réservés',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Color(0xFF334155)),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '© 2025 MTS Médico-Dentaire — Tous droits réservés',
                    style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
                  ),
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
          'Votre partenaire de confiance pour tous vos besoins '
          'en matériel dentaire, livraison rapide partout en Algérie.',
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

// ── Data classes locales ─────────────────────────────────────────────────────

class _InfoCardData {
  final IconData icon;
  final String title;
  final String text;
  const _InfoCardData(this.icon, this.title, this.text);
}

class _ContactItem {
  final IconData icon;
  final String text;
  const _ContactItem(this.icon, this.text);
}
