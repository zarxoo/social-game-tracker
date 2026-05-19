import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

import '../main_screen.dart';

class RegisterScreen
    extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final usernameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final authService = AuthService();

  final firestoreService =
      FirestoreService();

  bool isLoading = false;

  Future<void> register() async {
    try {
      setState(() {
        isLoading = true;
      });

      final credential =
          await authService.register(
        email:
            emailController.text.trim(),

        password:
            passwordController.text.trim(),
      );

      await firestoreService.createUser(
        uid: credential.user!.uid,

        username:
            usernameController.text.trim(),

        email:
            emailController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const MainScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.message ??
                'Register gagal',
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Register'),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller:
                  usernameController,

              decoration:
                  const InputDecoration(
                labelText:
                    'Username',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  emailController,

              decoration:
                  const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  passwordController,

              obscureText: true,

              decoration:
                  const InputDecoration(
                labelText:
                    'Password',
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed:
                  isLoading
                      ? null
                      : register,

              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                        'Register',
                      ),
            ),
          ],
        ),
      ),
    );
  }
}