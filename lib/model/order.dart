import 'package:flutter/material.dart';
import '../style/theme/colors.dart';

// ─────────────────────────────────────────────
// Enum statut de commande
// ─────────────────────────────────────────────
enum OrderStatus { enAttente, livree }

extension OrderStatusStyle on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.enAttente: return 'En attente';
      case OrderStatus.livree:    return 'Livrée';
    }
  }

  Color get badgeColor {
    switch (this) {
      case OrderStatus.enAttente: return AppColors.statusEnAttente;
      case OrderStatus.livree:    return AppColors.statusLivree;
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.enAttente: return AppColors.statusEnAttenteText;
      default:                    return AppColors.textOnDark;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.enAttente: return Icons.access_time_rounded;
      case OrderStatus.livree:    return Icons.done_all_rounded;
    }
  }
}

// ─────────────────────────────────────────────
// Modèle Order
// ─────────────────────────────────────────────
class Order {
  final String id;
  final String clientName;
  final String date;
  final double amount;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.clientName,
    required this.date,
    required this.amount,
    required this.status,
  });
}

// ─────────────────────────────────────────────
// Données fictives
// ─────────────────────────────────────────────
const List<Order> kSampleOrders = [
  Order(id: 'CMD-001', clientName: 'Jean Dupont',    date: '31/03/2026', amount: 250,  status: OrderStatus.enAttente),
  Order(id: 'CMD-004', clientName: 'Sophie Laurent', date: '30/03/2026', amount: 95,   status: OrderStatus.livree),
  Order(id: 'CMD-005', clientName: 'Lucas Bernard',  date: '29/03/2026', amount: 410,  status: OrderStatus.enAttente),
];
