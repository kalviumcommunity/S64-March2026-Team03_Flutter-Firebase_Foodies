import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/login_screen.dart';
import 'role_wrapper.dart';
import '../screens/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while waiting for the stream
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // Handle any errors gracefully
          return const Scaffold(
            body: Center(
              child: Text('Something went wrong checking authentication state!'),
            ),
          );
        } else if (snapshot.hasData) {
          // Check for role-based navigation using RoleWrapper
          return RoleWrapper(user: snapshot.data!);
        } else {
          // User is not authenticated, navigate to the LoginScreen
          return const LoginScreen();
        }
      },
    );
  }
}
