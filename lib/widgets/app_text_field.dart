// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../style/theme/colors.dart';

// // ─────────────────────────────────────────────
// // Champ de texte stylisé MTS — réutilisable
// // Usage :
// //   AppTextField(
// //     controller: _emailCtrl,
// //     label: 'Email',
// //     icon: Icons.email_outlined,
// //     keyboardType: TextInputType.emailAddress,
// //     inputFormatters: AppFormatters.email,
// //   )
// // ─────────────────────────────────────────────
// class AppTextField extends StatelessWidget {
//   const AppTextField({
//     super.key,
//     required this.controller,
//     required this.label,
//     required this.icon,
//     this.keyboardType = TextInputType.text,
//     this.inputFormatters = const [],
//     this.obscureText = false, required String hint, required int maxLines,
//   });

//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final TextInputType keyboardType;
//   final List<TextInputFormatter> inputFormatters;
//   final bool obscureText;

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       inputFormatters: inputFormatters,
//       obscureText: obscureText,
//       style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle:
//             TextStyle(color: AppColors.textSecondary, fontSize: 13),
//         prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
//         filled: true,
//         fillColor: AppColors.background,
//         contentPadding:
//             const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../style/theme/colors.dart';

// ─────────────────────────────────────────────
// Champ de texte stylisé MTS — réutilisable
// Usage :
//   AppTextField(
//     controller: _emailCtrl,
//     label: 'Email',
//     icon: Icons.email_outlined,
//     keyboardType: TextInputType.emailAddress,
//     inputFormatters: AppFormatters.email,
//   )
// ─────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint = '',
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.obscureText = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint.isNotEmpty ? hint : null,
        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
        labelStyle:
            TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
