import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = 'Meuturbo12309@gmail.com';
    _senhaController.text = '1234567';
    _nomeController.text = 'Usuário 1';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Alterações salvas com sucesso!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

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
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
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
                              color: Colors
                                  .grey[300], // Fundo cinza do ícone de lápis
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ), // Borda branca para destacar
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
                                debugPrint("Trocar foto clicado");
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
                    controller: _emailController,
                    label: 'Email:',
                    obscureText: false,
                    readOnly: false,
                  ),
                  const SizedBox(height: 20),

                  // Campo 2: Senha (Agora editável)
                  _buildLabelAndField(
                    controller: _senhaController,
                    label: 'Senha:',
                    obscureText: true,
                    readOnly: false,
                  ),
                  const SizedBox(height: 20),

                  // Campo 3: Nome de usuário (Editável)
                  _buildLabelAndField(
                    controller: _nomeController,
                    label: 'Nome de usuario:',
                    obscureText: false,
                    readOnly: false,
                  ),
                  const SizedBox(height: 24),

                  // Botão Salvar
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 64,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Colors.black54,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'SALVAR',
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

  // Helper padronizado para renderizar as caixas de texto iguais às de Login e Cadastro
  Widget _buildLabelAndField({
    TextEditingController? controller,
    required String label,
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
          controller: controller,
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
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 16.0,
            ),

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
