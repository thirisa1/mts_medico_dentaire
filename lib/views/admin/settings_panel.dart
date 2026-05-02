// import 'package:flutter/material.dart';
// import '../../restrictions/validators.dart';
// import '../../services/auth_service.dart';
// import '../../services/cabinet_service.dart';
// import '../../style/constants/app_routes.dart';
// import '../../style/theme/colors.dart';
// import '../../widgets/app_text_field.dart';
// import '../../widgets/settings_item.dart';

// void openSettingsPanel(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder:
//         (context) => Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 24,
//           ),
//           child: Container(
//             constraints: const BoxConstraints(maxWidth: 600),
//             child: const SettingsPanel(),
//           ),
//         ),
//   );
// }

// class SettingsPanel extends StatefulWidget {
//   const SettingsPanel({super.key});

//   @override
//   State<SettingsPanel> createState() => _SettingsPanelState();
// }

// class _SettingsPanelState extends State<SettingsPanel>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _staggerCtrl;
//   CabinetInfo _info = CabinetInfo.defaults();
//   bool _loadingInfo = true;

//   @override
//   void initState() {
//     super.initState();
//     _staggerCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     )..forward();
//     _loadInfo();
//   }

//   Future<void> _loadInfo() async {
//     final info = await CabinetService.fetch();
//     if (mounted)
//       setState(() {
//         _info = info;
//         _loadingInfo = false;
//       });
//   }

//   @override
//   void dispose() {
//     _staggerCtrl.dispose();
//     super.dispose();
//   }

//   Animation<double> _itemAnim(int index) {
//     final start = (index * 0.18).clamp(0.0, 1.0);
//     final end = (start + 0.55).clamp(0.0, 1.0);
//     return CurvedAnimation(
//       parent: _staggerCtrl,
//       curve: Interval(start, end, curve: Curves.easeOutCubic),
//     );
//   }

//   Widget _animated({required int index, required Widget child}) {
//     return FadeTransition(
//       opacity: _itemAnim(index),
//       child: SlideTransition(
//         position: Tween<Offset>(
//           begin: const Offset(0.25, 0),
//           end: Offset.zero,
//         ).animate(_itemAnim(index)),
//         child: child,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: AppColors.surface,
//       borderRadius: BorderRadius.circular(20),
//       elevation: 8,
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildHeader(),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _animated(index: 0, child: _buildProfileCard()),
//                   const SizedBox(height: 24),
//                   Divider(color: AppColors.background, thickness: 1.5),
//                   const SizedBox(height: 24),
//                   _animated(
//                     index: 1,
//                     child: SettingsItem(
//                       icon: Icons.storefront_outlined,
//                       iconColor: AppColors.accent,
//                       iconBg: AppColors.accentLight,
//                       title: 'Modifier informations',
//                       subtitle: 'Adresse, téléphone, email',
//                       onTap: () => _openEditSheet(context),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   _animated(index: 2, child: _buildLogoutButton(context)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
//       decoration: const BoxDecoration(
//         gradient: AppColors.appBarGradient,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         children: [
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Paramètres',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               SizedBox(height: 2),
//               Text(
//                 'MTS Médico-Dentaire',
//                 style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 11),
//               ),
//             ],
//           ),
//           const Spacer(),
//           GestureDetector(
//             onTap: () => Navigator.of(context).pop(),
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.close_rounded,
//                 color: Colors.white,
//                 size: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.surfaceAlt,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.background, width: 1.5),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               gradient: AppColors.appBarGradient,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: const Center(
//               child: Text(
//                 'MTS',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 13,
//                   letterSpacing: 1,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child:
//                 _loadingInfo
//                     ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                     : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _info.name,
//                           style: TextStyle(
//                             color: AppColors.textPrimary,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           _info.email,
//                           style: TextStyle(
//                             color: AppColors.textSecondary,
//                             fontSize: 11,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           _info.phone,
//                           style: TextStyle(
//                             color: AppColors.textMuted,
//                             fontSize: 11,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 3,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColors.accentLight,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: const Text(
//                             'Super Admin',
//                             style: TextStyle(
//                               color: AppColors.accent,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLogoutButton(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _showLogoutConfirm(context),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFFF0F0),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
//         ),
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.logout_rounded, color: Color(0xFFD32F2F), size: 20),
//             SizedBox(width: 10),
//             Text(
//               'Se déconnecter',
//               style: TextStyle(
//                 color: Color(0xFFD32F2F),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 15,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openEditSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder:
//           (_) => EditInfoSheet(
//             info: _info,
//             onSave: (info) async {
//               await CabinetService.save(info);
//               if (mounted) setState(() => _info = info);
//             },
//           ),
//     );
//   }

//   void _showLogoutConfirm(BuildContext context) {
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             backgroundColor: AppColors.surface,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Row(
//               children: [
//                 Icon(Icons.logout_rounded, color: Color(0xFFD32F2F)),
//                 SizedBox(width: 10),
//                 Text(
//                   'Déconnexion',
//                   style: TextStyle(fontWeight: FontWeight.w700),
//                 ),
//               ],
//             ),
//             content: Text(
//               'Voulez-vous vraiment vous déconnecter ?',
//               style: TextStyle(color: AppColors.textSecondary),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   'Annuler',
//                   style: TextStyle(color: AppColors.textSecondary),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   await AuthService.instance.logout();
//                   if (context.mounted) {
//                     Navigator.of(
//                       context,
//                     ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFD32F2F),
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 10,
//                   ),
//                 ),
//                 child: const Text(
//                   'Se déconnecter',
//                   style: TextStyle(fontWeight: FontWeight.w700),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // Bottom sheet — Modifier informations
// // ─────────────────────────────────────────────
// class EditInfoSheet extends StatefulWidget {
//   const EditInfoSheet({super.key, required this.info, required this.onSave});

//   final CabinetInfo info;
//   final void Function(CabinetInfo) onSave;

//   @override
//   State<EditInfoSheet> createState() => _EditInfoSheetState();
// }

// class _EditInfoSheetState extends State<EditInfoSheet> {
//   late final TextEditingController _nameCtrl;
//   late final TextEditingController _addressCtrl;
//   late final TextEditingController _phoneCtrl;
//   late final TextEditingController _emailCtrl;

//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl = TextEditingController(text: widget.info.name);
//     _addressCtrl = TextEditingController(text: widget.info.address);
//     _phoneCtrl = TextEditingController(text: widget.info.phone);
//     _emailCtrl = TextEditingController(text: widget.info.email);
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _addressCtrl.dispose();
//     _phoneCtrl.dispose();
//     _emailCtrl.dispose();
//     super.dispose();
//   }

//   void _save() {
//     final name = _nameCtrl.text.trim();
//     final address = _addressCtrl.text.trim();
//     final phone = _phoneCtrl.text.trim();
//     final email = _emailCtrl.text.trim();

//     final phoneError = AppValidators.phone(phone);
//     if (phoneError != null) {
//       _showError(phoneError);
//       return;
//     }

//     final emailError = AppValidators.email(email);
//     if (emailError != null) {
//       _showError(emailError);
//       return;
//     }

//     widget.onSave(
//       CabinetInfo(
//         name: name.isEmpty ? widget.info.name : name,
//         address: address,
//         phone: phone,
//         email: email,
//       ),
//     );

//     Navigator.pop(context);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Row(
//           children: [
//             Icon(Icons.check_circle_outline_rounded, color: Colors.white),
//             SizedBox(width: 10),
//             Text('Informations mises à jour !'),
//           ],
//         ),
//         backgroundColor: AppColors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color(0xFFD32F2F),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         left: 24,
//         right: 24,
//         top: 24,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 28,
//       ),
//       decoration: const BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: AppColors.textHint,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Informations du cabinet',
//             style: TextStyle(
//               color: AppColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Les modifications seront visibles partout sur le site.',
//             style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
//           ),
//           const SizedBox(height: 20),
//           AppTextField(
//             controller: _addressCtrl,
//             label: 'Adresse',
//             icon: Icons.location_on_outlined,
//             inputFormatters: AppFormatters.address,
//           ),
//           const SizedBox(height: 14),
//           AppTextField(
//             controller: _phoneCtrl,
//             label: 'Téléphone',
//             icon: Icons.phone_outlined,
//             keyboardType: TextInputType.phone,
//             inputFormatters: AppFormatters.phone,
//           ),
//           const SizedBox(height: 14),
//           AppTextField(
//             controller: _emailCtrl,
//             label: 'Email',
//             icon: Icons.email_outlined,
//             keyboardType: TextInputType.emailAddress,
//             inputFormatters: AppFormatters.email,
//           ),
//           const SizedBox(height: 24),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     side: BorderSide(color: AppColors.textHint),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: Text(
//                     'Annuler',
//                     style: TextStyle(
//                       color: AppColors.textSecondary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 flex: 2,
//                 child: ElevatedButton(
//                   onPressed: _save,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.save_outlined, size: 18),
//                       SizedBox(width: 8),
//                       Text(
//                         'Sauvegarder',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../restrictions/validators.dart';
import '../../services/auth_service.dart';
import '../../services/cabinet_service.dart';
import '../../style/constants/app_routes.dart';
import '../../style/theme/colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/settings_item.dart';

void openSettingsPanel(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SettingsPage()),
  );
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  CabinetInfo _info = CabinetInfo.defaults();
  bool _loadingInfo = true;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final info = await CabinetService.fetch();
    if (mounted) {
      setState(() {
        _info = info;
        _loadingInfo = false;
      });
    }
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Animation<double> _itemAnim(int index) {
    final start = (index * 0.18).clamp(0.0, 1.0);
    final end = (start + 0.55).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerCtrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  Widget _animated({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _itemAnim(index),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.25, 0),
          end: Offset.zero,
        ).animate(_itemAnim(index)),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _animated(index: 0, child: _buildProfileCard()),
                  const SizedBox(height: 24),
                  Divider(color: AppColors.background, thickness: 1.5),
                  const SizedBox(height: 24),
                  _animated(
                    index: 1,
                    child: SettingsItem(
                      icon: Icons.storefront_outlined,
                      iconColor: AppColors.accent,
                      iconBg: AppColors.accentLight,
                      title: 'Modifier informations',
                      subtitle: 'Adresse, téléphone, email',
                      onTap: () => _openEditSheet(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _animated(index: 2, child: _buildLogoutButton(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
      child: SafeArea(
        child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paramètres',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'MTS Médico-Dentaire',
                  style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Carte profil ──────────────────────────────────────────────

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.appBarGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'MTS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                _loadingInfo
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _info.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _info.email,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _info.phone,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Super Admin',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
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

  // ── Bouton déconnexion ────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutConfirm(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFD32F2F), size: 20),
            SizedBox(width: 10),
            Text(
              'Se déconnecter',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Ouvrir le bottom sheet d'édition ─────────────────────────

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => EditInfoSheet(
            info: _info,
            onSave: (info) async {
              await CabinetService.save(info);
              if (mounted) setState(() => _info = info);
            },
          ),
    );
  }

  // ── Dialog déconnexion ────────────────────────────────────────

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.logout_rounded, color: Color(0xFFD32F2F)),
                SizedBox(width: 10),
                Text(
                  'Déconnexion',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: Text(
              'Voulez-vous vraiment vous déconnecter ?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.instance.logout();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'Se déconnecter',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// Bottom sheet — Modifier informations
// ═════════════════════════════════════════════════════════════════

class EditInfoSheet extends StatefulWidget {
  const EditInfoSheet({super.key, required this.info, required this.onSave});

  final CabinetInfo info;
  final void Function(CabinetInfo) onSave;

  @override
  State<EditInfoSheet> createState() => _EditInfoSheetState();
}

class _EditInfoSheetState extends State<EditInfoSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.info.name);
    _addressCtrl = TextEditingController(text: widget.info.address);
    _phoneCtrl = TextEditingController(text: widget.info.phone);
    _emailCtrl = TextEditingController(text: widget.info.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    final phoneError = AppValidators.phone(phone);
    if (phoneError != null) {
      _showError(phoneError);
      return;
    }

    final emailError = AppValidators.email(email);
    if (emailError != null) {
      _showError(emailError);
      return;
    }

    widget.onSave(
      CabinetInfo(
        name: name.isEmpty ? widget.info.name : name,
        address: address,
        phone: phone,
        email: email,
      ),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Informations mises à jour !'),
          ],
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Informations du cabinet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Les modifications seront visibles partout sur le site.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _nameCtrl,
            label: 'Nom du cabinet',
            icon: Icons.storefront_outlined,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _addressCtrl,
            label: 'Adresse',
            icon: Icons.location_on_outlined,
            inputFormatters: AppFormatters.address,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _phoneCtrl,
            label: 'Téléphone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: AppFormatters.phone,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _emailCtrl,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            inputFormatters: AppFormatters.email,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: AppColors.textHint),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Sauvegarder',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
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
