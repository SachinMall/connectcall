import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<AppUser> signIn({required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    await _setOnlineStatus(uid, true);
    return _fetchProfile(uid);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    await credential.user!.updateDisplayName(name);

    final newUser = AppUser(id: uid, name: name, email: email.trim(), isOnline: true);
    await _firestore.collection('users').doc(uid).set(newUser.toMap());
    return newUser;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid != null) {
      await _setOnlineStatus(uid, false);
    }
    await _firebaseAuth.signOut();
  }

  Future<AppUser> _fetchProfile(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (!snapshot.exists) {
      final fallback = AppUser(
        id: uid,
        name: _firebaseAuth.currentUser?.displayName ?? 'User',
        email: _firebaseAuth.currentUser?.email ?? '',
        isOnline: true,
      );
      await _firestore.collection('users').doc(uid).set(fallback.toMap());
      return fallback;
    }
    return AppUser.fromMap(uid, snapshot.data()!);
  }

  Future<void> _setOnlineStatus(String uid, bool isOnline) {
    return _firestore.collection('users').doc(uid).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}
