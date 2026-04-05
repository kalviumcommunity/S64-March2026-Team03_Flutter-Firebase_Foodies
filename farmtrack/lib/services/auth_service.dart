import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Sign up with email, password, and additional details
  Future<User?> signUp(String email, String password, {String? name, String? phone}) async {
    try {
      // Create user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      // Update display name
      if (name != null) {
        await credential.user?.updateDisplayName(name);
      }
      
      // Save additional user info to Firestore via FirestoreService
      if (credential.user != null) {
        await _firestoreService.saveUser(credential.user!.uid, {
          'name': name,
          'email': email.trim(),
          'phone': phone?.trim(),
        });
      }
      
      return credential.user;
    } catch (e) {
      print('Sign Up Error: $e');
      return null;
    }
  }

  // Sign in with email or phone number
  Future<User?> signIn(String emailOrPhone, String password) async {
    try {
      String loginEmail = emailOrPhone.trim();
      
      // If no '@', assume it's a phone number and try to look up the email
      if (!loginEmail.contains('@')) {
        final userData = await _firestoreService.getUserByPhone(loginEmail);
        if (userData != null && userData.containsKey('email')) {
          loginEmail = userData['email'];
        } else {
          // If not found in users collection, try using it as a direct email for edge cases
          loginEmail = '$loginEmail@farmtrack.app'; 
        }
      }

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: loginEmail,
        password: password.trim(),
      );
      return credential.user;
    } catch (e) {
      print('Sign In Error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }
}
