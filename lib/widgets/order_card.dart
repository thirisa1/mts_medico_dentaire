import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../../style/theme/colors.dart';
import 'status_badge.dart';

// ─────────────────────────────────────────────
// Carte de commande avec animation slide + fade
// ─────────────────────────────────────────────
class OrderCard extends StatefulWidget {
  const OrderCard({super.key, required this.order, required this.index});

  final Order order;
  final int index;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 80),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    Future.delayed(
      Duration(milliseconds: widget.index * 60),
      () { if (mounted) _ctrl.forward(); },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _CardContent(order: widget.order),
      ),
    );
  }
}

// ── Contenu visuel de la carte ──
class _CardContent extends StatelessWidget {
  const _CardContent({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: AppColors.accentLight,
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Barre colorée gauche
                Container(
                  width: 4,
                  height: 56,
                  decoration: BoxDecoration(
                    color: order.status.badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID + badge statut
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.id,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          StatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Nom client
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            order.clientName,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Date + montant
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                order.date,
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${order.amount.toStringAsFixed(0)} DA',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}