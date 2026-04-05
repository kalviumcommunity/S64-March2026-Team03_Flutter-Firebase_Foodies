import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../screens/main_screen.dart';
import '../screens/admin/admin_main_screen.dart';

class RoleWrapper extends StatelessWidget {
  final User user;
  const RoleWrapper({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return StreamBuilder<String>(
      stream: firestoreService.getUserRoleStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF678D46),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Error loading user role'),
            ),
          );
        }

        final String role = snapshot.data ?? 'user';

        if (role == 'admin') {
          return const AdminMainScreen();
        } else {
          return const MainScreen();
        }
      },
    );
  }
}
