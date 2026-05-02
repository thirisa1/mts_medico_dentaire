import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

/// Service d'authentification — MTS Médico Dentaire
/// Firebase Auth + Firestore + Cloudinary (upload justificatif)
///
/// ⚠️  SÉCURITÉ :
/// - Upload Preset UNSIGNED → pas besoin d'API Secret côté client
/// - L'API Secret ne doit JAMAIS être dans le code Flutter
/// - Preset créé sur : Cloudinary Dashboard → Settings → Upload
///   → Add upload preset → Signing mode = Unsigned
///   → Nom du preset : mts_justificatifs_preset
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Cloudinary ────────────────────────────────────────────────
  static const String _cloudName = 'dtthbibks';
  static const String _uploadPreset = 'mts_justificatifs_preset';
  static const String _folder = 'mts_justificatifs';

  // ── Auth state ────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ════════════════════════════════════════════════════════════════
  // INSCRIPTION
  // ════════════════════════════════════════════════════════════════

  Future<UserModel> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
    required String role,
    Uint8List? pdfBytes,
    String? pdfFileName,
  }) async {
    // 1. Créer le compte Firebase Auth
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final String uid = cred.user!.uid;

    try {
      // 2. Upload Cloudinary si professionnel
      String? justificatifUrl;
      if (role == 'professionnel' && pdfBytes != null && pdfFileName != null) {
        justificatifUrl = await _uploadToCloudinary(
          fileBytes: pdfBytes,
          fileName: pdfFileName,
          uid: uid,
        );
      }

      // 3. Mettre à jour le display name
      await cred.user!.updateDisplayName('$prenom $nom');

      // 4. Créer le modèle utilisateur
      final UserModel user = UserModel(
        idUser: uid,
        nom: nom.trim(),
        prenom: prenom.trim(),
        email: email.trim(),
        telephone: telephone.trim(),
        role: role,
        justificatif: justificatifUrl,
        verified: role == 'autre', // pro = false, attend validation admin
        createdAt: DateTime.now(),
      );

      // 5. Sauvegarder dans Firestore
      await _db.collection('users').doc(uid).set(user.toFirestore());

      return user;
    } catch (e) {
      // ⚠️ ROLLBACK : si Cloudinary ou Firestore échoue,
      // on supprime le compte Auth pour éviter l'état incohérent
      // (sinon l'utilisateur ne pourra plus s'inscrire avec ce mail)
      await cred.user!.delete();
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // CONNEXION
  // ════════════════════════════════════════════════════════════════

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final UserModel? user = await getUserById(cred.user!.uid);
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-data-not-found',
        message: 'Profil utilisateur introuvable.',
      );
    }
    return user;
  }

  // ════════════════════════════════════════════════════════════════
  // DÉCONNEXION
  // ════════════════════════════════════════════════════════════════

  Future<void> logout() => _auth.signOut();

  // ════════════════════════════════════════════════════════════════
  // MOT DE PASSE OUBLIÉ
  // ════════════════════════════════════════════════════════════════

  Future<void> sendPasswordResetEmail(String email) async {
    // 1. Vérifier que l'email existe dans Firestore
    final query =
        await _db
            .collection('users')
            .where('email', isEqualTo: email.trim())
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Aucun compte associé à cette adresse email.',
      );
    }

    // 2. Email existe → envoyer le lien
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
  // ════════════════════════════════════════════════════════════════
  // FIRESTORE — lecture utilisateur
  // ════════════════════════════════════════════════════════════════

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel?> getCurrentUserModel() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return getUserById(u.uid);
  }

  // ════════════════════════════════════════════════════════════════
  // UPLOAD CLOUDINARY — preset NON SIGNÉ (unsigned)
  // ════════════════════════════════════════════════════════════════

  Future<String> _uploadToCloudinary({
    required Uint8List fileBytes,
    required String fileName,
    required String uid,
  }) async {
    // final uri = Uri.parse(
    //   'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload',
    // );

    final ext = fileName.split('.').last.toLowerCase();
    final resourceType = ext == 'pdf' ? 'raw' : 'image';
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
    );

    final String publicId =
        '${uid}_${fileName.replaceAll(RegExp(r'\.[^.]+$'), '')}';

    // ✅ MultipartRequest — fonctionne sur Flutter Web (pas de CORS)
    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = _uploadPreset
          ..fields['folder'] = _folder
          ..fields['public_id'] = publicId
          ..files.add(
            http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
          );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = body['error']?['message'] ?? 'Erreur inconnue';
      throw Exception('Cloudinary : $msg (code ${response.statusCode})');
    }

    return (jsonDecode(response.body))['secure_url'] as String;
  }

  String _mimeType(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  // ════════════════════════════════════════════════════════════════
  // TRADUCTION ERREURS FIREBASE
  // ════════════════════════════════════════════════════════════════

  static String translateError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Un compte existe déjà avec cette adresse email.';
        case 'invalid-email':
          return 'Adresse email invalide.';
        case 'weak-password':
          return 'Mot de passe trop faible (minimum 8 caractères).';
        case 'user-not-found':
          return 'Aucun compte associé à cette adresse email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email ou mot de passe incorrect.';
        case 'user-disabled':
          return 'Ce compte a été désactivé. Contactez le support.';
        case 'too-many-requests':
          return 'Trop de tentatives. Réessayez dans quelques minutes.';
        case 'network-request-failed':
          return 'Erreur réseau. Vérifiez votre connexion internet.';
        case 'user-data-not-found':
          return 'Profil introuvable. Contactez le support.';
        default:
          return 'Erreur d\'authentification (${error.code}).';
      }
    }
    if (error.toString().contains('Cloudinary')) {
      return 'Erreur lors de l\'upload du justificatif. Réessayez.';
    }
    return 'Une erreur inattendue est survenue. Réessayez.';
  }
}
