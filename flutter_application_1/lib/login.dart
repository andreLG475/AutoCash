import 'package:flutter/material.dart';

import 'data/database_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      _showMessage('Informe usuário/e-mail e senha para entrar.');
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await DatabaseHelper.instance.authenticateUser(
        identifier: identifier,
        password: password,
      );

      if (!mounted) return;

      if (user == null) {
        _showMessage('Usuário/e-mail ou senha inválidos.');
        return;
      }

      await DatabaseHelper.instance.setCurrentUserId(user.id);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Erro ao entrar: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.redAccent[700],
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'app_brand_icon',
              child: Image.asset(
                'assets/logo.png',
                height: 20,
                width: 20,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'AutoCash',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 110,
                    fit: BoxFit.contain,
                    color: Colors.redAccent[700],
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'LOGIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 48),

                  _buildLabelAndField(
                    controller: _identifierController,
                    label: 'Usuário ou E-mail',
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  _buildLabelAndField(
                    controller: _passwordController,
                    label: 'Senha',
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Colors.black87, // Efeito de clique mais suave
                    ),
                    child: const Text(
                      'Não possui conta? Cadastre-se',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botão de Login
                  Center(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.grey[300], // Fundo cinza do botão
                        foregroundColor: Colors.black, // Texto preto
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 64,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Colors.black54,
                            width: 1.5,
                          ), // Borda escura elegante
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget construtor dos campos com o exato padrão de escrita das outras páginas
  Widget _buildLabelAndField({
    TextEditingController? controller,
    required String label,
    required bool obscureText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15, // Tamanho padronizado com as outras telas
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(
              0xFFF2F2F2,
            ), // Cinza claro interno idêntico ao do cadastro
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 16.0,
            ),

            // Borda padrão unificada (fina e elegante)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                14,
              ), // Arredondamento igual às outras telas
              borderSide: const BorderSide(color: Colors.black54, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.black54, width: 1),
            ),
            // Borda de foco vermelha para manter a identidade do AutoCash
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.redAccent[700]!, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
