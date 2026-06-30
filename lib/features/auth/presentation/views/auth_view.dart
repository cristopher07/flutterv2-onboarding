import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

const _primaryColor = Color(0xFF067DF7);
const _textColor = Color(0xFF202124);
const _surfaceColor = Color(0xFFF8F9FD);

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegisterMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegisterMode) {
        await ref.read(signUpProvider)(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await ref.read(signInProvider)(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      await ref.read(getCurrentUserProfileProvider)();

      if (mounted) context.goNamed('ecommerce-home');
    } on FirebaseAuthException catch (error) {
      setState(() {
        _errorMessage = _messageForAuthError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _messageForAuthError(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'El correo no tiene un formato valido.',
      'user-not-found' => 'No existe una cuenta con ese correo.',
      'wrong-password' => 'La contrasena no es correcta.',
      'email-already-in-use' => 'Ese correo ya tiene una cuenta registrada.',
      'weak-password' => 'La contrasena debe tener al menos 6 caracteres.',
      _ => error.message ?? 'No se pudo completar la autenticacion.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: _primaryColor,
                      size: 42,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _isRegisterMode ? 'Crear cuenta' : 'Iniciar sesion',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: _textColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRegisterMode
                          ? 'Registra un usuario para entrar al ecommerce.'
                          : 'Accede con el usuario creado en Firebase.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5F6368),
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.login),
                          label: Text('Login'),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.person_add_alt_1),
                          label: Text('Registro'),
                        ),
                      ],
                      selected: {_isRegisterMode},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _isRegisterMode = selection.first;
                          _errorMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo electronico',
                        prefixIcon: Icon(Icons.mail_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Ingresa tu correo.';
                        if (!email.contains('@')) return 'Correo invalido.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Contrasena',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 6) {
                          return 'Minimo 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFB3261E),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Icon(
                                  _isRegisterMode
                                      ? Icons.person_add_alt_1
                                      : Icons.login,
                                ),
                        label: Text(_isRegisterMode ? 'Registrarme' : 'Entrar'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // child: const Text(
                      //   'Puedes probar con el usuario que creaste en Firebase, por ejemplo test@test.com y contrasena 123456.',
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(letterSpacing: 0),
                      // ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
