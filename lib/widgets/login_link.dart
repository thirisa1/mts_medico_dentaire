import 'package:flutter/material.dart';

import '../style/constants/app_colors.dart';
import '../style/constants/app_dimens.dart';

/// Lien "Se connecter / S'inscrire" (texte souligné, pas bouton)
class LoginLink extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback? onRegister;

  const LoginLink({
    super.key,
    required this.onLogin,
    this.onRegister,
  });

  static const _style = TextStyle(
    fontSize: AppDimens.fontConnexion,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );

  static const _sepStyle = TextStyle(
    fontSize: AppDimens.fontConnexion,
    color: AppColors.textMuted,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onLogin,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: const Text('Se connecter', style: _style),
          ),
        ),
        const Text(' / ', style: _sepStyle),
        GestureDetector(
          onTap: onRegister ?? onLogin,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: const Text("S'inscrire", style: _style),
          ),
        ),
      ],
    );
  }
}