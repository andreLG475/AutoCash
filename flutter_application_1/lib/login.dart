import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco conforme a imagem
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove completamente o ícone/botão de voltar
        backgroundColor: Colors.redAccent[700], // Barra vermelha padronizada
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "autocash",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5, // Mantém a identidade visual das outras telas
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícone do carro mantido na cor primária do app
                  Icon(
                    Icons.directions_car, 
                    size: 110, 
                    color: Colors.redAccent[700],
                  ),
                  const SizedBox(height: 12),
                  
                  // Título Login com tipografia mais elegante
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

                  // Campo 1: Nome ou Email
                  _buildLabelAndField(
                    label: 'Nome ou Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),

                  // Campo 2: Senha
                  _buildLabelAndField(
                    label: 'Senha',
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  // Botão de Cadastre-se
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87, // Efeito de clique mais suave
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
                      onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], // Fundo cinza do botão
                        foregroundColor: Colors.black, // Texto preto
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black54, width: 1.5), // Borda escura elegante
                        ),
                      ),
                      child: const Text(
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
  Widget _buildLabelAndField({required String label, required bool obscureText}) {
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
          obscureText: obscureText,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F2F2), // Cinza claro interno idêntico ao do cadastro
            contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            
            // Borda padrão unificada (fina e elegante)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), // Arredondamento igual às outras telas
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