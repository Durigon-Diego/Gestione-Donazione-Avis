import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avis_donation_management/helpers/logger_helper.dart';
import 'package:avis_donation_management/helpers/exceptions.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/components/avis_theme.dart';

/// Login page for AVIS operators
class LoginPage extends StatefulWidget {
  final ConnectionStatusController connectionStatus;
  final OperatorSessionController operatorSession;
  const LoginPage({
    super.key,
    required this.connectionStatus,
    required this.operatorSession,
  });

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
    widget.connectionStatus.addListener(_onConnectionChange);
    _loadLastEmail();
  }

  @override
  void dispose() {
    widget.connectionStatus.removeListener(_onConnectionChange);
    super.dispose();
  }

  void _onConnectionChange() {
    setState(() {});
  }

  void _checkRedirect() {
    _showContent = false;
    if (widget.operatorSession.isConnected) {
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
        if (widget.operatorSession.currentOperatorID != null) {
          completer.complete();
        }
      };

      widget.operatorSession.addListener(_sessionListener!);

      // Authenticate with Supabase
      final response = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);

      if (response.user?.id == null) {
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
    } catch (error, stackTrace) {
      logError(
        'Login failed',
        error,
        stackTrace,
        'Login',
      );

      setState(() {
        if (error is LoginException) {
          _errorMessage = error.message;
        } else if (error is AuthException && error.statusCode == '400') {
          _errorMessage = 'Credenziali errate. Riprova.';
        } else if (error is AuthException && error.statusCode == '429') {
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
    final connected = widget.connectionStatus.state == ServerStatus.connected;

    final (color, label) = switch (widget.connectionStatus.state) {
      ServerStatus.disconnected => (AvisColors.red, 'Nessuna connessione'),
      ServerStatus.supabaseOffline => (
          AvisColors.amber,
          'Server non raggiungibile'
        ),
      ServerStatus.connected => (AvisColors.green, 'Connesso'),
    };

    return !_showContent
        ? const Scaffold(body: SizedBox.shrink())
        : Stack(
            children: [
              Scaffold(
                appBar: AppBar(title: const Text('Accesso Operatore')),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
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
                                    decoration: const InputDecoration(
                                        labelText: 'Email'),
                                    keyboardType: TextInputType.emailAddress,
                                    onSubmitted: (_) => _login(),
                                    enabled: connected && !_loading,
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _passwordController,
                                    decoration: const InputDecoration(
                                        labelText: 'Password'),
                                    obscureText: true,
                                    onSubmitted: (_) => _login(),
                                    enabled: connected && !_loading,
                                  ),
                                  const SizedBox(height: 16),
                                  if (_errorMessage != null)
                                    Text(
                                      _errorMessage!,
                                      style: AvisTheme.errorTextStyle,
                                    ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: (_loading || !connected)
                                        ? null
                                        : _login,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, color: color, size: 12),
                          const SizedBox(width: 8),
                          Text(label, style: TextStyle(color: color)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!connected)
                Container(
                  color: AvisColors.overlay,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
  }
}
