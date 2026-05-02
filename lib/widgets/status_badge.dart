import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../../style/theme/colors.dart';

// ─────────────────────────────────────────────
// Badge de statut — réutilisable partout
// Usage : StatusBadge(status: order.status)
// ─────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final isEnAttente = status == OrderStatus.enAttente;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isEnAttente
            ? AppColors.statusEnAttente
            : status.badgeColor.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEnAttente
              ? AppColors.statusEnAttenteText.withValues(alpha: 0.4)
              : status.badgeColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 11,
            color: isEnAttente
                ? AppColors.statusEnAttenteText
                : status.badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: isEnAttente
                  ? AppColors.statusEnAttenteText
                  : status.badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}