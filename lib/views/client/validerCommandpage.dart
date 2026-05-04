import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/cart_service.dart';
import '../../services/commission_service.dart';
import '../../services/order_service.dart';
import '../../services/payment_service.dart';
import '../../style/constants/app_colors.dart';
import '../../style/constants/app_routes.dart';

// ─────────────────────────────────────────────
// CheckoutScreen — Page de paiement
// Gauche  : Détails de facturation
// Droite  : Récapitulatif + Paiement carte
// ─────────────────────────────────────────────
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ── Facturation ──
  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _rueCtrl = TextEditingController();
  final _rue2Ctrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _codePostalCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedRegion;

  // ── Paiement ──
  final _cardCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();

  // ── État ──
  List<CartItem> _items = [];
  bool _loadingCart = true;
  bool _cgvAccepted = false;
  bool _paying = false;
  String? _cardError;
  String? _cvvError;
  String? _expiryError;

  static const double _fraisExpedition = 600.0;

  // Wilayas d'Algérie
  static const List<String> _wilayas = [
    'Adrar',
    'Chlef',
    'Laghouat',
    'Oum El Bouaghi',
    'Batna',
    'Béjaïa',
    'Biskra',
    'Béchar',
    'Blida',
    'Bouira',
    'Tamanrasset',
    'Tébessa',
    'Tlemcen',
    'Tiaret',
    'Tizi Ouzou',
    'Alger',
    'Djelfa',
    'Jijel',
    'Sétif',
    'Saïda',
    'Skikda',
    'Sidi Bel Abbès',
    'Annaba',
    'Guelma',
    'Constantine',
    'Médéa',
    'Mostaganem',
    "M'Sila",
    'Mascara',
    'Ouargla',
    'Oran',
    'El Bayadh',
    'Illizi',
    'Bordj Bou Arréridj',
    'Boumerdès',
    'El Tarf',
    'Tindouf',
    'Tissemsilt',
    'El Oued',
    'Khenchela',
    'Souk Ahras',
    'Tipaza',
    'Mila',
    'Aïn Defla',
    'Naâma',
    'Aïn Témouchent',
    'Ghardaïa',
    'Relizane',
  ];

  @override
  void initState() {
    super.initState();
    _loadCart();
    _cardCtrl.addListener(_formatCard);
    _expiryCtrl.addListener(_formatExpiry);
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _rueCtrl.dispose();
    _rue2Ctrl.dispose();
    _villeCtrl.dispose();
    _codePostalCtrl.dispose();
    _phoneCtrl.dispose();
    _cardCtrl.dispose();
    _cvvCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    final items = await CartService.fetchCart();
    if (mounted)
      setState(() {
        _items = items;
        _loadingCart = false;
      });
  }

  double get _sousTotal => _items.fold(0, (s, i) => s + i.total);
  double get _total => _sousTotal + _fraisExpedition;

  bool get _isMobile => MediaQuery.of(context).size.width < 900;

  // ── Formatage numéro de carte (XXXX XXXX XXXX XXXX) ──
  void _formatCard() {
    final text = _cardCtrl.text.replaceAll(' ', '');
    if (text.length > 16) return;
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    if (_cardCtrl.text != formatted) {
      _cardCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  // ── Formatage date expiration (MM/YY) ──
  void _formatExpiry() {
    final text = _expiryCtrl.text.replaceAll('/', '');
    if (text.length > 4) return;
    String formatted = text;
    if (text.length > 2) {
      formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    if (_expiryCtrl.text != formatted) {
      _expiryCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  // ── Validation carte ──
  bool _validateCard() {
    bool valid = true;
    setState(() {
      // Numéro carte
      final cardNum = _cardCtrl.text.replaceAll(' ', '');
      if (cardNum.length != 16 || !RegExp(r'^\d+$').hasMatch(cardNum)) {
        _cardError = 'Numéro de carte invalide (16 chiffres requis)';
        valid = false;
      } else {
        _cardError = null;
      }

      // CVV
      final cvv = _cvvCtrl.text.trim();
      if (cvv.length < 3 || cvv.length > 4 || !RegExp(r'^\d+$').hasMatch(cvv)) {
        _cvvError = 'CVV invalide (3 ou 4 chiffres)';
        valid = false;
      } else {
        _cvvError = null;
      }

      // Date expiration
      final expiry = _expiryCtrl.text.trim();
      if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
        _expiryError = 'Format invalide (MM/AA)';
        valid = false;
      } else {
        final parts = expiry.split('/');
        final month = int.tryParse(parts[0]) ?? 0;
        final year = int.tryParse(parts[1]) ?? 0;
        final now = DateTime.now();
        final expDate = DateTime(2000 + year, month + 1);
        if (month < 1 || month > 12) {
          _expiryError = 'Mois invalide';
          valid = false;
        } else if (expDate.isBefore(now)) {
          _expiryError = 'Carte expirée';
          valid = false;
        } else {
          _expiryError = null;
        }
      }
    });
    return valid;
  }

  // ── Validation facturation ──
  bool _validateBilling() {
    if (_prenomCtrl.text.trim().isEmpty) {
      _showError('Le prénom est requis.');
      return false;
    }
    if (_nomCtrl.text.trim().isEmpty) {
      _showError('Le nom est requis.');
      return false;
    }
    if (_rueCtrl.text.trim().isEmpty) {
      _showError('L\'adresse est requise.');
      return false;
    }
    if (_villeCtrl.text.trim().isEmpty) {
      _showError('La ville est requise.');
      return false;
    }
    if (_selectedRegion == null) {
      _showError('Veuillez sélectionner une wilaya.');
      return false;
    }
    if (_codePostalCtrl.text.trim().isEmpty) {
      _showError('Le code postal est requis.');
      return false;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      _showError('Le téléphone est requis.');
      return false;
    }
    if (!_cgvAccepted) {
      _showError('Veuillez accepter les conditions générales.');
      return false;
    }
    return true;
  }

  Future<void> _pay() async {
    if (!_validateBilling()) return;
    if (!_validateCard()) return;

    setState(() => _paying = true);

    try {
      final cardNum = _cardCtrl.text.replaceAll(' ', '');

      // 1. Vérifier la carte et effectuer le paiement
      final paymentResult = await PaymentService.processPayment(
        numeroCarte: cardNum,
        cvv: _cvvCtrl.text.trim(),
        dateExpiration: _expiryCtrl.text.trim(),
        montant: _total,
      );

      if (!paymentResult.isSuccess) {
        // Paiement refusé — afficher le message d'erreur approprié
        if (mounted) {
          setState(() => _paying = false);
          _showPaymentError(paymentResult);
        }
        return;
      }

      // 2. Paiement OK → enregistrer la commande
      final orderId = await OrderService.createOrder(
        prenom: _prenomCtrl.text.trim(),
        nom: _nomCtrl.text.trim(),
        telephone: _phoneCtrl.text.trim(),
        adresse: '${_rueCtrl.text.trim()} ${_rue2Ctrl.text.trim()}'.trim(),
        ville: _villeCtrl.text.trim(),
        wilaya: _selectedRegion ?? '',
        codePostal: _codePostalCtrl.text.trim(),
        lignes: _items,
        sousTotal: _sousTotal,
        fraisExpedition: _fraisExpedition,
      );

      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await CommissionService.traiterCommissions(
        orderId: orderId,
        clientId: uid,
        lignes:
            _items
                .map(
                  (i) => {
                    'productId': i.productId,
                    'nom': i.nom,
                    'prix': i.prix,
                    'quantite': i.quantite,
                  },
                )
                .toList(),
      );

      // 3. Vider le panier
      await CartService.clearCart();

      if (mounted) {
        setState(() => _paying = false);
        _showSuccessDialog(orderId);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _paying = false);
        _showError('Erreur lors de la commande : $e');
      }
    }
  }

  void _showPaymentError(PaymentResult result) {
    IconData icon;
    Color color;
    String title;

    switch (result.status) {
      case PaymentStatus.cardNotFound:
        icon = Icons.credit_card_off_outlined;
        color = const Color(0xFFDC2626);
        title = 'Carte introuvable';
        break;
      case PaymentStatus.wrongCvv:
        icon = Icons.lock_outline;
        color = const Color(0xFFDC2626);
        title = 'CVV incorrect';
        break;
      case PaymentStatus.cardExpired:
        icon = Icons.event_busy_outlined;
        color = const Color(0xFFF59E0B);
        title = 'Carte expirée';
        break;
      case PaymentStatus.insufficientFunds:
        icon = Icons.account_balance_wallet_outlined;
        color = const Color(0xFFF59E0B);
        title = 'Solde insuffisant';
        break;
      default:
        icon = Icons.error_outline;
        color = const Color(0xFFDC2626);
        title = 'Erreur de paiement';
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(28),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  result.message ?? 'Une erreur est survenue.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
                ),
                if (result.status == PaymentStatus.insufficientFunds &&
                    result.soldeActuel != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Solde disponible : ${result.soldeActuel!.toStringAsFixed(0)} DA',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Réessayer',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  //  Future<void> _pay() async {
  //     if (!_validateBilling()) return;
  //     if (!_validateCard()) return;

  //     setState(() => _paying = true);

  //     try {
  //       // 1. Enregistrer la commande dans Firestore
  //       final orderId = await OrderService.createOrder(
  //         prenom:          _prenomCtrl.text.trim(),
  //         nom:             _nomCtrl.text.trim(),
  //         telephone:       _phoneCtrl.text.trim(),
  //         adresse:         '${_rueCtrl.text.trim()} ${_rue2Ctrl.text.trim()}'.trim(),
  //         ville:           _villeCtrl.text.trim(),
  //         wilaya:          _selectedRegion ?? '',
  //         codePostal:      _codePostalCtrl.text.trim(),
  //         lignes:          _items,
  //         sousTotal:       _sousTotal,
  //         fraisExpedition: _fraisExpedition,
  //       );

  //       // 2. Vider le panier
  //       await CartService.clearCart();

  //       if (mounted) {
  //         setState(() => _paying = false);
  //         _showSuccessDialog(orderId);
  //       }
  //     } catch (e) {
  //       if (mounted) {
  //         setState(() => _paying = false);
  //         _showError('Erreur lors de la commande : $e');
  //       }
  //     }
  //   }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
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
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Commande confirmée !',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Votre commande #${orderId.substring(0, 8).toUpperCase()} a été enregistrée.\nNous vous contacterons dès que possible.',
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
                      Navigator.of(context).popUntil((r) => r.isFirst);
                      Navigator.pushReplacementNamed(
                        context,
                        '/acheteur',
                        arguments: {'role': 'autre'},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Retour à l\'accueil',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // void _showSuccessDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder:
  //         (_) => AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(
  //                 width: 72,
  //                 height: 72,
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFF059669).withOpacity(0.1),
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: const Icon(
  //                   Icons.check_circle_outline,
  //                   color: Color(0xFF059669),
  //                   size: 40,
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //               const Text(
  //                 'Commande confirmée !',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w800,
  //                   color: AppColors.primaryDark,
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               const Text(
  //                 'Votre paiement a été traité avec succès.\nVotre commande est en cours de traitement.',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   fontSize: 13,
  //                   color: AppColors.textMuted,
  //                   height: 1.6,
  //                 ),
  //               ),
  //               const SizedBox(height: 24),
  //               SizedBox(
  //                 width: double.infinity,
  //                 child: ElevatedButton(
  //                   onPressed: () async {
  //                     await CartService.clearCart();
  //                     if (mounted) {
  //                       Navigator.of(context).popUntil((r) => r.isFirst);
  //                       Navigator.pushReplacementNamed(
  //                         context,
  //                         AppRoutes.acheteurHome,
  //                         arguments: {'role': 'autre'},
  //                       );
  //                     }
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: AppColors.primary,
  //                     foregroundColor: Colors.white,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     elevation: 0,
  //                   ),
  //                   child: const Text(
  //                     'Retour à l\'accueil',
  //                     style: TextStyle(fontWeight: FontWeight.w700),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //   );
  // }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        child: Column(children: [_buildHeader(), _buildBody(), _buildFooter()]),
      ),
    );
  }

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
            // Navbar
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.navbarBg,
                borderRadius: BorderRadius.circular(16),
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
                    height: 36,
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.medical_services_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'MTS Médico Dentaire',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed:
                        () => Navigator.pushNamed(context, AppRoutes.cart),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    label: const Text(
                      'Retour au panier',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Finaliser la commande',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.acheteurHome,
                        arguments: {'role': 'autre'},
                      ),
                  child: const Text(
                    'Accueil',
                    style: TextStyle(
                      color: AppColors.bannerWelcome,
                      fontSize: 13,
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
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
                  child: const Text(
                    'Panier',
                    style: TextStyle(
                      color: AppColors.bannerWelcome,
                      fontSize: 13,
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
                  'Commande',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 16 : 48,
        vertical: 40,
      ),
      child:
          _isMobile
              ? Column(
                children: [
                  _buildBillingForm(),
                  const SizedBox(height: 32),
                  _buildOrderSummary(),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildBillingForm()),
                  const SizedBox(width: 35),
                  SizedBox(width: 700, child: _buildOrderSummary()),
                ],
              ),
    );
  }

  // ── Formulaire facturation ──
  Widget _buildBillingForm() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DÉTAILS DE FACTURATION',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),

          // Prénom + Nom
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Prénom *',
                  ctrl: _prenomCtrl,
                  hint: '',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildField(label: 'Nom *', ctrl: _nomCtrl, hint: ''),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pays fixe
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Pays/région *'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Text('🇩🇿', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Text(
                      'Algérie',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rue
          _buildField(
            label: 'Numéro et nom de rue *',
            ctrl: _rueCtrl,
            hint: 'Numéro de voie et nom de la rue',
          ),
          const SizedBox(height: 12),
          _buildField(
            label: '',
            ctrl: _rue2Ctrl,
            hint: 'Bâtiment, appartement, lot, etc. (facultatif)',
          ),
          const SizedBox(height: 16),

          // Ville
          _buildField(label: 'Ville *', ctrl: _villeCtrl, hint: ''),
          const SizedBox(height: 16),

          // Wilaya dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Région / Wilaya *'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        _selectedRegion != null
                            ? AppColors.primary
                            : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRegion,
                    isExpanded: true,
                    hint: const Text(
                      'Sélectionner une option...',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                    ),
                    onChanged: (v) => setState(() => _selectedRegion = v),
                    items:
                        _wilayas
                            .map(
                              (w) => DropdownMenuItem(value: w, child: Text(w)),
                            )
                            .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Code postal
          _buildField(
            label: 'Code postal *',
            ctrl: _codePostalCtrl,
            hint: '',
            type: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),

          // Téléphone
          _buildField(
            label: 'Téléphone *',
            ctrl: _phoneCtrl,
            hint: '05XXXXXXXX',
            type: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  // ── Récapitulatif + Paiement ──
  Widget _buildOrderSummary() {
    return Column(
      children: [
        // Récapitulatif
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VOTRE COMMANDE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              if (_loadingCart)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              else ...[
                // Lignes produits
                ..._items.map((item) => _buildOrderLine(item)),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                _orderRow('Sous-Total', '${_sousTotal.toStringAsFixed(0)} DA'),
                const SizedBox(height: 10),
                _orderRow(
                  'Expédition',
                  'Forfait: ${_fraisExpedition.toStringAsFixed(0)} DA',
                  bold: true,
                ),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                _orderRow(
                  'Total',
                  '${_total.toStringAsFixed(0)} DA',
                  large: true,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Formulaire paiement carte
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre paiement
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.credit_card_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Paiement par carte',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  // Logos cartes
                  Row(
                    children: [
                      _cardLogo('CIB'),
                      const SizedBox(width: 6),
                      _cardLogo('EDAHABIA'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Numéro carte
              _label('Numéro de carte'),
              const SizedBox(height: 6),
              TextField(
                controller: _cardCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
                  LengthLimitingTextInputFormatter(19),
                ],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'XXXX XXXX XXXX XXXX',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  errorText: _cardError,
                  prefixIcon: const Icon(
                    Icons.credit_card_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFDC2626),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // CVV + Expiration
              Row(
                children: [
                  // Expiration
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Date d\'expiration'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _expiryCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
                            LengthLimitingTextInputFormatter(5),
                          ],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'MM/AA',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                            errorText: _expiryError,
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFDC2626),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // CVV
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _label('CVV'),
                            const SizedBox(width: 6),
                            Tooltip(
                              message: '3 ou 4 chiffres au dos de votre carte',
                              child: Icon(
                                Icons.help_outline,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _cvvCtrl,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                          decoration: InputDecoration(
                            hintText: '•••',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 18,
                            ),
                            errorText: _cvvError,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFDC2626),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // CGV
              GestureDetector(
                onTap: () => setState(() => _cgvAccepted = !_cgvAccepted),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color:
                            _cgvAccepted
                                ? AppColors.primary
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color:
                              _cgvAccepted
                                  ? AppColors.primary
                                  : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child:
                          _cgvAccepted
                              ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              )
                              : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'Vos données personnelles seront utilisées pour traiter votre commande. J\'ai lu et j\'accepte les ',
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.cgu,
                                    ),
                                child: const Text(
                                  'conditions générales',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ' *'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bouton Payer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _paying ? null : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  ),
                  child:
                      _paying
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Traitement en cours...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outline, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                'Payer ${_total.toStringAsFixed(0)} DA',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 12),
              // Sécurité
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Paiement sécurisé SSL',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderLine(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                item.imgProd != null && item.imgProd!.isNotEmpty
                    ? Image.network(
                      item.imgProd!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgFallback(),
                    )
                    : _imgFallback(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nom,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  '× ${item.quantite}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.total.toStringAsFixed(0)} DA',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.medical_services_outlined,
        color: AppColors.primary.withOpacity(0.3),
        size: 24,
      ),
    );
  }

  Widget _orderRow(
    String label,
    String value, {
    bool bold = false,
    bool large = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: large ? 15 : 13,
            fontWeight: bold || large ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 16 : 13,
            fontWeight: bold || large ? FontWeight.w800 : FontWeight.w600,
            color: large ? AppColors.primary : AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _cardLogo(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[_label(label), const SizedBox(height: 6)],
        TextField(
          controller: ctrl,
          keyboardType: type,
          inputFormatters: formatters,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryDark,
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: AppColors.footerBg,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      child: Column(
        children: [
          Container(height: 1, color: AppColors.footerBorder),
          const SizedBox(height: 16),
          const Text(
            '© 2025 MTS Médico-Dentaire — Tous droits réservés',
            style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }
}
