import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      // print(e.toString()); // Remove print in production
      rethrow;
    }
  }

  // Sign Up (Auth Only)
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Create initial user document with just the name and email
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'fullName': fullName,
          'createdAt': FieldValue.serverTimestamp(),
          'profileComplete': false, // Check this flag for navigation
        });
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Save/Update User Profile (Health Data)
  Future<void> saveUserProfile({
    required String uid,
    required DateTime birthDate,
    required String gender,
    required double height,
    required double weight,
    // required String diabetesType, // Kept for future or if needed in this step
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender,
      'height': height,
      'weight': weight,
      // 'diabetesType': diabetesType, // If we want to add it back
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Check if profile is complete
  Future<bool> isProfileComplete(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['profileComplete'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
