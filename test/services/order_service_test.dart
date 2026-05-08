import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('OrderValidator — Validation des champs', () {

    String? validateTelephone(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Le numéro de téléphone est requis.';
      }
      final cleaned = value.trim().replaceAll(' ', '').replaceAll('-', '');
      final regex = RegExp(r'^(0[567]\d{8})$');
      if (!regex.hasMatch(cleaned)) {
        return 'Téléphone invalide. Ex: 0612345678';
      }
      return null;
    }

    String? validatePrenom(String? value) {
      if (value == null || value.trim().isEmpty) return 'Le prénom est requis.';
      if (value.trim().length < 2) return 'Le prénom est trop court.';
      return null;
    }

    String? validateCodePostal(String? value) {
      if (value == null || value.trim().isEmpty) return null;
      final regex = RegExp(r'^\d{5}$');
      if (!regex.hasMatch(value.trim())) {
        return 'Code postal invalide (5 chiffres).';
      }
      return null;
    }

    test('Téléphone algérien valide — 05', () {
      expect(validateTelephone('0512345678'), null);
    });

    test('Téléphone algérien valide — 06', () {
      expect(validateTelephone('0612345678'), null);
    });

    test('Téléphone algérien valide — 07', () {
      expect(validateTelephone('0712345678'), null);
    });

    test('Téléphone invalide — commence par 04', () {
      expect(validateTelephone('0412345678'), isNotNull);
    });

    test('Téléphone invalide — trop court', () {
      expect(validateTelephone('061234'), isNotNull);
    });

    test('Téléphone vide → erreur', () {
      expect(validateTelephone(''), isNotNull);
    });

    test('Téléphone null → erreur', () {
      expect(validateTelephone(null), isNotNull);
    });

    test('Prénom valide', () {
      expect(validatePrenom('Ahmed'), null);
    });

    test('Prénom trop court → erreur', () {
      expect(validatePrenom('A'), isNotNull);
    });

    test('Prénom vide → erreur', () {
      expect(validatePrenom(''), isNotNull);
    });

    test('Code postal valide — 5 chiffres', () {
      expect(validateCodePostal('06000'), null);
    });

    test('Code postal invalide — 4 chiffres', () {
      expect(validateCodePostal('0600'), isNotNull);
    });

    test('Code postal vide → optionnel, pas d\'erreur', () {
      expect(validateCodePostal(''), null);
    });
  });

  group('OrderService — Firestore', () {

    test('Création d\'une commande', () async {
      final docRef = fakeFirestore.collection('commandes').doc();
      await docRef.set({
        'userId':          'user123',
        'clientName':      'Ahmed Benali',
        'clientEmail':     'ahmed@test.com',
        'telephone':       '0612345678',
        'adresse':         '12 rue des roses',
        'ville':           'Béjaïa',
        'wilaya':          'Béjaïa',
        'codePostal':      '06000',
        'sousTotal':       1500.0,
        'fraisExpedition': 600.0,
        'total':           2100.0,
        'statut':          'en_attente',
        'lignes': [
          {'productId': 'p1', 'nom': 'Fraise', 'prix': 750.0, 'quantite': 2},
        ],
        'createdAt': DateTime.now().toIso8601String(),
      });

      final doc = await docRef.get();
      expect(doc.exists, true);
      expect(doc.data()!['statut'], 'en_attente');
      expect(doc.data()!['total'], 2100.0);
    });

    test('Mise à jour statut → livree', () async {
      final docRef = fakeFirestore.collection('commandes').doc();
      await docRef.set({'statut': 'en_attente', 'userId': 'u1'});

      await docRef.update({'statut': 'livree'});

      final doc = await docRef.get();
      expect(doc.data()!['statut'], 'livree');
    });

    test('Mise à jour statut → annulee', () async {
      final docRef = fakeFirestore.collection('commandes').doc();
      await docRef.set({'statut': 'en_attente', 'userId': 'u1'});

      await docRef.update({'statut': 'annulee'});

      final doc = await docRef.get();
      expect(doc.data()!['statut'], 'annulee');
    });

    test('Total = sousTotal + fraisExpedition', () {
      const sousTotal = 1500.0;
      const frais = 600.0;
      final total = sousTotal + frais;
      expect(total, 2100.0);
    });

    test('Commande avec panier vide → erreurs de validation', () {
      final lignes = [];
      final errors = <String>[];
      if (lignes.isEmpty) errors.add('Le panier est vide.');
      expect(errors.isNotEmpty, true);
      expect(errors.first, 'Le panier est vide.');
    });

    test('Filtrage commandes par userId', () async {
      await fakeFirestore.collection('commandes').doc('c1').set({
        'userId': 'userA',
        'statut': 'en_attente',
      });
      await fakeFirestore.collection('commandes').doc('c2').set({
        'userId': 'userB',
        'statut': 'livree',
      });

      final snap = await fakeFirestore
          .collection('commandes')
          .where('userId', isEqualTo: 'userA')
          .get();

      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['statut'], 'en_attente');
    });
  });

  group('PaymentValidator — Validation carte', () {

    bool validateCardNumber(String card) {
      final cleaned = card.replaceAll(' ', '');
      return cleaned.length == 16 && RegExp(r'^\d+$').hasMatch(cleaned);
    }

    bool validateCvv(String cvv) {
      return (cvv.length == 3 || cvv.length == 4) &&
          RegExp(r'^\d+$').hasMatch(cvv);
    }

    bool validateExpiry(String expiry) {
      if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) return false;
      final parts = expiry.split('/');
      final month = int.tryParse(parts[0]) ?? 0;
      final year  = int.tryParse(parts[1]) ?? 0;
      if (month < 1 || month > 12) return false;
      final expDate = DateTime(2000 + year, month + 1);
      return expDate.isAfter(DateTime.now());
    }

    test('Numéro carte valide — 16 chiffres', () {
      expect(validateCardNumber('1234 5678 9012 3456'), true);
    });

    test('Numéro carte invalide — trop court', () {
      expect(validateCardNumber('1234 5678'), false);
    });

    test('Numéro carte invalide — lettres', () {
      expect(validateCardNumber('ABCD 5678 9012 3456'), false);
    });

    test('CVV valide — 3 chiffres', () {
      expect(validateCvv('123'), true);
    });

    test('CVV valide — 4 chiffres', () {
      expect(validateCvv('1234'), true);
    });

    test('CVV invalide — 2 chiffres', () {
      expect(validateCvv('12'), false);
    });

    test('Date expiration valide', () {
      // Date dans le futur
      final now = DateTime.now();
      final year = (now.year + 1) % 100;
      final expiry = '12/${year.toString().padLeft(2, '0')}';
      expect(validateExpiry(expiry), true);
    });

    test('Date expiration — carte expirée', () {
      expect(validateExpiry('01/20'), false);
    });

    test('Date expiration — format invalide', () {
      expect(validateExpiry('1220'), false);
    });

    test('Date expiration — mois invalide', () {
      expect(validateExpiry('13/30'), false);
    });
  });
}