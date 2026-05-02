import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../../style/theme/colors.dart';

// ─────────────────────────────────────────────
// Chip résumé statut — barre horizontale HomePage
// Usage : StatusChip(status: OrderStatus.enCours, count: 3)
// ─────────────────────────────────────────────
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, required this.count});

  final OrderStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final isEnAttente = status == OrderStatus.enAttente;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: status.badgeColor.withValues(alpha: isEnAttente ? 1 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isEnAttente
                  ? AppColors.statusEnAttenteText.withValues(alpha: 0.3)
                  : status.badgeColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 13,
            color:
                isEnAttente ? AppColors.statusEnAttenteText : status.badgeColor,
          ),
          const SizedBox(width: 5),
          Text(
            '${status.label} ($count)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  isEnAttente
                      ? AppColors.statusEnAttenteText
                      : status.badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
