import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service class for handling authentication operations
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  /// Get current user data from Firestore
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (currentUserId == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    final userData = await getCurrentUserData();
    return userData?['role'] == 'admin';
  }

  /// Get user availability status
  static Future<String> getCurrentUserAvailability() async {
    final userData = await getCurrentUserData();
    return userData?['availability'] ?? 'available';
  }

  /// Update user availability
  static Future<void> updateUserAvailability(String availability) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'availability': availability,
      });
    } catch (e) {
      throw Exception('Failed to update availability: $e');
    }
  }

  /// Update user with event information when registering
  static Future<void> updateUserEventInfo({
    required String eventId,
    required String role,
  }) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'availability': 'active duty',
        'currentEventId': eventId,
        'currentRole': role,
      });
    } catch (e) {
      throw Exception('Failed to update user event info: $e');
    }
  }

  /// Clear user event information
  static Future<void> clearUserEventInfo() async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'availability': 'available',
        'currentEventId': FieldValue.delete(),
        'currentRole': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Failed to clear user event info: $e');
    }
  }

  /// Sign in with email and password
  static Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan. Coba lagi.');
    }
  }

  /// Sign up with email and password
  static Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan. Coba lagi.');
    }
  }

  /// Sign in with Google
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Force account picker

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      return {
        'user': user,
        'isNewUser': userCredential.additionalUserInfo?.isNewUser ?? false,
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan Google Sign-In.');
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      throw Exception('Gagal logout: $e');
    }
  }

  /// Create user profile in Firestore
  static Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String emergencyContact,
    required List<String> skills,
    String? profileImageUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'emergencyContact': emergencyContact,
        'skills': skills,
        'profileImageUrl': profileImageUrl,
        'role': 'relawan',
        'availability': 'available',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal membuat profil: $e');
    }
  }

  /// Get auth error message in Indonesian
  static String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return e.message ?? 'Terjadi kesalahan autentikasi.';
    }
  }
}
