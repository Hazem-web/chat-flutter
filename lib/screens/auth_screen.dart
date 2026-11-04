import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isCreatingAccount = true;
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  void _submit({
    required String email,
    required String password,
    Uint8List? image,
    required bool isLogin,
    required BuildContext ctx,
    String? username,
  }) async {
    UserCredential result;
    setState(() {
      _isLoading = true;
    });
    try {
      if (isLogin) {
        result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        setState(() {
          _isLoading = false;
        });
      } else {
        result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final imageBytes = image;
        if (imageBytes == null) {
          throw StateError('A profile photo is required to create an account.');
        }
        final storageResponse = await Supabase.instance.client.storage
            .from('user_image')
            .uploadBinary(
              "${result.user!.uid}.jpg",
              imageBytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
        final imageUrl = await Supabase.instance.client.storage
            .from('user_image')
            .getPublicUrl(storageResponse);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(result.user?.uid)
            .set({'username': username, 'email': email, 'image_url': imageUrl});
        setState(() {
          _isLoading = false;
        });
      }
    } on PlatformException catch (err) {
      var massage = 'There is Something wrong with your Credentials';
      if (err.message != null) massage = err.message!;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(massage), behavior: SnackBarBehavior.floating),
      );
    } catch (error) {
      print(error);
    }
  }

  void _showUnavailableActionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This option is not connected yet.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.22),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _isCreatingAccount
                            ? 'Create your account'
                            : 'Welcome back',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.7,
                              color: const Color(0xFF19213A),
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isCreatingAccount
                            ? 'Start your journey with us today.'
                            : 'Sign in to continue where you left off.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: const Color(0xFF747B90)),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFEAECF2)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D18213A),
                              blurRadius: 30,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: AuthForm(
                          isCreatingAccount: _isCreatingAccount,
                          isLoading: _isLoading,
                          onSubmit: _submit,
                          onUnavailableAction: _showUnavailableActionMessage,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            _isCreatingAccount
                                ? 'Already have an account?'
                                : 'New here?',
                            style: const TextStyle(color: Color(0xFF747B90)),
                          ),
                          TextButton(
                            onPressed: () => setState(
                              () => _isCreatingAccount = !_isCreatingAccount,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: colors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: Text(
                              _isCreatingAccount ? 'Sign in' : 'Create account',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF9298A8),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(child: _isLoading ? CircularProgressIndicator() : null),
          ],
        ),
      ),
    );
  }
}
