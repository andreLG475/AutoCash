import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco padrão
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove completamente qualquer seta de voltar automática
        backgroundColor: Colors.redAccent[700], // Barra vermelha padronizada do AutoCash
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "autocash",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícone da porta (Icons.door_front_door) em preto conforme a imagem
                  Icon(
                    Icons.door_front_door,
                    size: 110,
                    color: Colors.redAccent[700],
                  ),
                  const SizedBox(height: 12),
                  
                  // Título REGISTRAR-SE padronizado
                  const Text(
                    'REGISTRAR-SE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Campo 1: Nome de usuário
                  _buildLabelAndField(
                    label: 'Nome de usuário:',
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),

                  // Campo 2: Email
                  _buildLabelAndField(
                    label: 'Email',
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Campo 3: Senha
                  _buildLabelAndField(
                    label: 'Senha',
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  // Campo 4: Confirmar senha
                  _buildLabelAndField(
                    label: 'Confirmar senha',
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  // Link para voltar para o Login
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text(
                      'Possui conta? Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão de Cadastrar
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Conta criada com sucesso!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], // Fundo cinza do botão
                        foregroundColor: Colors.black, // Texto preto
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black54, width: 1.5), // Borda contornada escura
                        ),
                      ),
                      child: const Text(
                        'Cadastrar',
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

  // Helper idêntico para renderizar os campos perfeitamente
  Widget _buildLabelAndField({
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
            fontSize: 15,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F2F2), // Fundo interno cinza claro
            contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.black54, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.black54, width: 1),
            ),
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