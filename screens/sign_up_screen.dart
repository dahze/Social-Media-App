// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/retro_button.dart';
import '../widgets/glitch_letter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: '2001'
              .split('')
              .map((letter) => GlitchLetter(
                    letter: letter,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 35,
                      color: Colors.white,
                    ),
                  ))
              .toList(),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffc7a3ef),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        color: const Color(0xfffef9ef),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Spacer(),
              _buildTextField(
                _usernameController,
                'Username',
                false,
                maxLength: 10,
              ),
              const SizedBox(height: 20),
              _buildTextField(_emailController, 'Email', false),
              const SizedBox(height: 20),
              _buildTextField(_passwordController, 'Password', true),
              const SizedBox(height: 30),
              RetroButton(
                text: 'Sign Up',
                onPressed: () async {
                  try {
                    await authProvider.signUp(
                      _emailController.text,
                      _passwordController.text,
                      _usernameController.text,
                    );
                    Navigator.pushReplacementNamed(context, '/signin');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signin');
                },
                child: const Text(
                  'Already have an account? Sign In',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'PressStart2P',
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool obscure, {
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black,
            fontFamily: 'PressStart2P',
            fontSize: 12,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
          counterText: '',
          suffix: label == 'Username'
              ? Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    '${controller.text.length}/$maxLength',
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                )
              : null,
        ),
        style: const TextStyle(
          fontFamily: 'PressStart2P',
          color: Colors.black,
          fontSize: 12,
        ),
        obscureText: obscure,
        maxLength: maxLength,
        onChanged: (text) {
          setState(() {});
        },
      ),
    );
  }
}
