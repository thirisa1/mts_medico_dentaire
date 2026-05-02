

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import '../style/constants/app_colors.dart';

// ─────────────────────────────────────────────
// NotificationBellWidget — cloche navbar
// Badge rouge avec le nombre de notifs non lues
// Au clic → bottom sheet avec la liste
// ─────────────────────────────────────────────
class NotificationBellWidget extends StatelessWidget {
  const NotificationBellWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<int>(
      stream: NotificationService.unreadCountStream(),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return GestureDetector(
          onTap: () => _showNotificationsSheet(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
                if (count > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _NotificationsSheet(),
    );
  }
}

// ─────────────────────────────────────────────
// Bottom sheet liste notifications
// ─────────────────────────────────────────────
class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder:
          (_, scrollCtrl) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          await NotificationService.markAllAsRead();
                        },
                        child: const Text(
                          'Tout marquer lu',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                // Liste
                Expanded(
                  child: StreamBuilder<List<AppNotification>>(
                    stream: NotificationService.myNotificationsStream(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }
                      final notifs = snap.data ?? [];
                      if (notifs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 48,
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Aucune notification',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: notifs.length,
                        separatorBuilder:
                            (_, __) => const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: Color(0xFFF3F4F6),
                            ),
                        itemBuilder:
                            (context, i) => _NotifTile(notif: notifs[i]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

// ─────────────────────────────────────────────
// Tuile notification individuelle
// ─────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif});
  final AppNotification notif;

  // ── Helpers type ─────────────────────────────
  bool get _isLivree => notif.type == 'commande_livree';
  bool get _isCommentaire => notif.type == 'nouveau_commentaire';

  Color get _color {
    if (_isLivree) return const Color(0xFF059669);
    if (_isCommentaire) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  IconData get _icon {
    if (_isLivree) return Icons.local_shipping_outlined;
    if (_isCommentaire) return Icons.star_outline_rounded;
    return Icons.cancel_outlined;
  }

  IconData get _iconDetail {
    if (_isLivree) return Icons.local_shipping_outlined;
    if (_isCommentaire) return Icons.star_rounded;
    return Icons.cancel_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!notif.lu) {
          await NotificationService.markAsRead(notif.id);
        }
        if (context.mounted) {
          _showNotifDetail(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color:
            notif.lu ? Colors.transparent : AppColors.primary.withOpacity(0.04),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _color, size: 22),
            ),
            const SizedBox(width: 12),
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.titre,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                notif.lu ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      if (!notif.lu)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.orderRef,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notif.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifDetail(BuildContext context) {
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
                    color: _color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_iconDetail, color: _color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  notif.titre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _color.withOpacity(0.2)),
                  ),
                  child: Text(
                    notif.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryDark,
                      height: 1.7,
                    ),
                  ),
                ),
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
                      'Fermer',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
