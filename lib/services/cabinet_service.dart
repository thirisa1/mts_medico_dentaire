import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CabinetInfo {
  final String name;
  final String address;
  final String phone;
  final String email;

  const CabinetInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });

  factory CabinetInfo.defaults() => const CabinetInfo(
    name: 'MTS Médico-Dentaire',
    address: 'Souk El Tenine-Béjaïa, Algérie',
    phone: '+213 782580055',
    email: 'medicodentairemts@gmail.com',
  );

  factory CabinetInfo.fromMap(Map<String, dynamic> d) => CabinetInfo(
    name: d['name'] ?? 'MTS Médico-Dentaire',
    address: d['address'] ?? 'Souk El Tenine-Béjaïa, Algérie',
    phone: d['phone'] ?? '+213 782580055',
    email: d['email'] ?? 'medicodentairemts@gmail.com',
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'phone': phone,
    'email': email,
  };

  CabinetInfo copyWith({
    String? name,
    String? address,
    String? phone,
    String? email,
  }) => CabinetInfo(
    name: name ?? this.name,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    email: email ?? this.email,
  );
}

class CabinetService {
  static final _db = FirebaseFirestore.instance;
  static const _path = 'config/cabinet';

  // Stream temps réel
  static Stream<CabinetInfo> stream() {
    return _db.doc(_path).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return CabinetInfo.defaults();
      return CabinetInfo.fromMap(snap.data()!);
    });
  }

  // Lecture unique
  static Future<CabinetInfo> fetch() async {
    try {
      final snap = await _db.doc(_path).get();
      if (!snap.exists || snap.data() == null) return CabinetInfo.defaults();
      return CabinetInfo.fromMap(snap.data()!);
    } catch (e) {
      debugPrint('[CabinetService] Erreur fetch: $e');
      return CabinetInfo.defaults();
    }
  }

  // Sauvegarde
  static Future<void> save(CabinetInfo info) async {
    await _db.doc(_path).set(info.toMap(), SetOptions(merge: true));
    debugPrint('[CabinetService] Infos cabinet sauvegardées');
  }
}
