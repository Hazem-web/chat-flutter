import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    required this.isCreatingAccount,
    required this.onSubmit,
    required this.onUnavailableAction,
    required this.isLoading,
    super.key,
  });

  final bool isCreatingAccount;
  final bool isLoading;
  final Function({
    required String email,
    required bool isLogin,
    required BuildContext ctx,
    required String password,
    Uint8List? image,
    String? username,
  })
  onSubmit;
  final VoidCallback onUnavailableAction;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Uint8List? _profileImage;
  bool _isPasswordVisible = false;

  Future<void> _pickProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
      );
      if (image == null) return;
      final imageBytes = await image.readAsBytes();

      if (!mounted) return;
      setState(() => _profileImage = imageBytes);
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Could not select a profile photo.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_profileImage == null && widget.isCreatingAccount) {
      return;
    }

    if ((_formKey.currentState?.validate() ?? false)) {
      widget.onSubmit(
        email: _emailController.text.trim(),
        isLogin: !widget.isCreatingAccount,
        ctx: context,
        image: _profileImage,
        password: _passwordController.text.trim(),
        username: widget.isCreatingAccount
            ? _usernameController.text.trim()
            : null,
      );
    }
  }

  @override
  void didUpdateWidget(covariant AuthForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCreatingAccount != widget.isCreatingAccount) {
      _isPasswordVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.isCreatingAccount) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: _profileImage == null
                      ? null
                      : MemoryImage(_profileImage!),
                  child: _profileImage == null
                      ? Icon(
                          Icons.person_outline_rounded,
                          size: 38,
                          color: colors.onPrimaryContainer,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile photo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextButton.icon(
                      onPressed: widget.isLoading ? null : _pickProfileImage,
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: Text(
                        _profileImage == null ? 'Add photo' : 'Change photo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            _AuthTextField(
              label: 'Username',
              hint: 'Choose a username',
              icon: Icons.person_outline_rounded,
              controller: _usernameController,
              validator: (value) {
                final username = value?.trim() ?? '';
                if (username.isEmpty) {
                  return 'Enter a username';
                }
                if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username)) {
                  return 'Use 3–20 letters, numbers, or underscores';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
          ],
          _AuthTextField(
            label: 'Email address',
            hint: 'you@example.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) {
                return 'Enter your email address';
              }
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          _AuthTextField(
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock_outline_rounded,
            obscureText: !_isPasswordVisible,
            controller: _passwordController,
            validator: (value) {
              final password = value ?? '';
              if (password.isEmpty) {
                return 'Enter your password';
              }
              if (widget.isCreatingAccount && password.length < 8) {
                return 'Use at least 8 characters';
              }
              return null;
            },
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
              tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
            ),
          ),
          if (!widget.isCreatingAccount) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onUnavailableAction,
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Forgot password?'),
              ),
            ),
          ] else
            const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: () {
                if (!widget.isLoading) _submit();
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(
                widget.isCreatingAccount ? 'Create account' : 'Sign in',
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFE9EBF1))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Color(0xFF9298A8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFE9EBF1))),
            ],
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: widget.onUnavailableAction,
            icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF30364A),
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: Color(0xFFE1E4EC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.controller,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF343B50),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFA4A9B7)),
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFFAFBFD),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFFE5E8EF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFFE5E8EF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
