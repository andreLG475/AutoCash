import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco padronizado
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700], // Barra vermelha do AutoCash
        elevation: 0,
        centerTitle: true,
        // Título AUTOCASH adicionado
        title: const Text(
          "autocash",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        // Botão de voltar (seta)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // Ícones removidos das actions conforme solicitado
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // --- SEÇÃO DO AVATAR COM BOTÃO DE EDITAR ---
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // Ícone principal de usuário
                        const Icon(
                          Icons.account_circle,
                          size: 140,
                          color: Colors.black, // Cor preta
                        ),
                        // Botão flutuante de edição (Lápis) agora como IconButton
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300], // Fundo cinza do ícone de lápis
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3), // Borda branca para destacar
                            ),
                            child: IconButton(
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                // Ação para trocar a foto
                                print("Trocar foto clicado");
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Nome do usuário centralizado em destaque
                  const Text(
                    'Usuário 1',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- CAMPOS DE DADOS ---
                  
                  // Campo 1: Email (Agora editável)
                  _buildLabelAndField(
                    label: 'Email:',
                    initialValue: 'Meuturbo12309@gmail.com',
                    obscureText: false,
                    readOnly: false, 
                  ),
                  const SizedBox(height: 20),

                  // Campo 2: Senha (Agora editável)
                  _buildLabelAndField(
                    label: 'Senha:',
                    initialValue: '1234567', // O obscureText vai transformar em XXXXXXX / bolinhas
                    obscureText: true,
                    readOnly: false, 
                  ),
                  const SizedBox(height: 20),

                  // Campo 3: Nome de usuário (Editável)
                  _buildLabelAndField(
                    label: 'Nome de usuario:',
                    initialValue: 'Usuário 1',
                    obscureText: false,
                    readOnly: false, 
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper padronizado para renderizar as caixas de texto iguais às de Login e Cadastro
  Widget _buildLabelAndField({
    required String label, 
    required String initialValue,
    required bool obscureText,
    required bool readOnly,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          obscureText: obscureText,
          readOnly: readOnly,
          style: TextStyle(
            fontSize: 16, 
            color: readOnly ? Colors.black54 : Colors.black, 
            fontWeight: readOnly ? FontWeight.w600 : FontWeight.normal,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F2F2), // Fundo interno cinza claro
            contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            
            // Borda padrão
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.black54, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.black54, width: 1),
            ),
            // Borda de foco 
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: readOnly ? Colors.black54 : Colors.redAccent[700]!, 
                width: readOnly ? 1 : 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}