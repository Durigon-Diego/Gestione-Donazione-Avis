import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../helpers/logger_helper.dart';
import '../helpers/exceptions.dart';
import '../helpers/avis_theme.dart';
import '../helpers/operator_session_controller.dart';

/// Login page for AVIS operators
class LoginPage extends StatefulWidget {
  final OperatorSessionController operatorSession;
  const LoginPage({super.key, required this.operatorSession});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showContent = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;
  VoidCallback? _sessionListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRedirect());
    _loadLastEmail();
  }

  void _checkRedirect() {
    _showContent = false;
    if (Supabase.instance.client.auth.currentSession != null) {
      logWarning(
          "User '${widget.operatorSession.name}' already logged, redirecting");
      final nav =
          context.mounted ? Navigator.of(context) : navigatorKey.currentState;
      if (widget.operatorSession.isActive) {
        nav?.pushNamedAndRemoveUntil('/donation', (_) => false);
      } else {
        nav?.pushNamedAndRemoveUntil('/not_active', (_) => false);
      }
    } else {
      _showContent = true;
      setState(() {});
    }
  }

  /// Loads the last used email from shared preferences
  Future<void> _loadLastEmail() async {
    final preferences = await SharedPreferences.getInstance();
    final savedEmail = preferences.getString('last_email');
    if (savedEmail != null) {
      _emailController.text = savedEmail;
    }
  }

  /// Attempts login and waits for OperatorSession to be updated,
  /// then verifies if the user is active or an admin
  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final completer = Completer<void>();

      _sessionListener = () {
        // Ignore if the current active user is still the previous one
        if (widget.operatorSession.currentUserId != null) {
          completer.complete();
        }
      };

      widget.operatorSession.addListener(_sessionListener!);

      // Authenticate with Supabase
      final response = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);

      final userId = response.user?.id;
      if (userId == null) {
        throw LoginException('Autenticazione fallita.');
      }

      // Wait for OperatorSession to update automatically
      await completer.future;

      // Save email after successful login
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('last_email', email);

      if (!mounted) return;
      if (widget.operatorSession.isActive) {
        Navigator.of(context).pushReplacementNamed('/donation');
      } else {
        Navigator.of(context).pushReplacementNamed('/not_active');
      }
    } catch (e) {
      logError('Login failed', e, StackTrace.current, 'Login');

      setState(() {
        if (e is LoginException) {
          _errorMessage = e.message;
        } else if (e is AuthException && e.statusCode == '400') {
          _errorMessage = 'Credenziali errate. Riprova.';
        } else if (e is AuthException && e.statusCode == '429') {
          _errorMessage = 'Troppi tentativi. Riprova tra qualche minuto.';
        } else {
          _errorMessage =
              'Errore di autenticazione sconosciuto. Contatta un amministratore.';
        }
      });
    } finally {
      if (_sessionListener != null) {
        widget.operatorSession.removeListener(_sessionListener!);
        _sessionListener = null;
      }
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_showContent
        ? const Scaffold(body: SizedBox.shrink())
        : Scaffold(
            appBar: AppBar(title: const Text('Accesso Operatore')),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 16),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: AvisTheme.errorTextStyle,
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const CircularProgressIndicator()
                              : const Text('Accedi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
