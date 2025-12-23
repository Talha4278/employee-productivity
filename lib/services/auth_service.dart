import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Add a small delay to ensure Firestore document is available
        await Future.delayed(const Duration(milliseconds: 100));
        return await getUserData(credential.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<UserModel?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    UserType userType,
    String? phoneNumber,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          userType: userType,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
        );

        final userMap = userModel.toMap();
        // Convert DateTime to Timestamp for Firestore
        userMap['createdAt'] = Timestamp.fromDate(userModel.createdAt);

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userMap);

        // Verify the document was saved correctly
        await Future.delayed(const Duration(milliseconds: 100));
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return UserModel.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

      await _firestore.collection('users').doc(user.uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}

