// Importa o pacote principal do Flutter para Material Design
import 'package:flutter/material.dart';

// Importa o helper do banco de dados para registro
import 'data/database_helper.dart';

// Classe RegisterPage que estende StatefulWidget (página que muda de estado)
class RegisterPage extends StatefulWidget {
  // Construtor com chave opcional
  const RegisterPage({super.key});

  // Cria o estado da página de registro
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// Estado da classe RegisterPage
class _RegisterPageState extends State<RegisterPage> {
  // Controlador de texto para o campo de nome de usuário
  final _nameController = TextEditingController();
  // Controlador de texto para o campo de email
  final _emailController = TextEditingController();
  // Controlador de texto para o campo de senha
  final _passwordController = TextEditingController();
  // Controlador de texto para confirmar a senha
  final _confirmPasswordController = TextEditingController();
  // Variável que controla se está em processo de registro
  bool _loading = false;

  // Método chamado quando o widget é removido da árvore
  @override
  void dispose() {
    // Descarta todos os controladores de texto
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Método assíncrono que realiza o registro do usuário
  Future<void> _register() async {
    // Obtém o nome e remove espaços em branco
    final name = _nameController.text.trim();
    // Obtém o email e remove espaços em branco
    final email = _emailController.text.trim();
    // Obtém a senha
    final password = _passwordController.text;
    // Obtém a confirmação de senha
    final confirmPassword = _confirmPasswordController.text;

    // Verifica se todos os campos estão preenchidos
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      // Mostra mensagem de aviso
      _showMessage('Preencha todos os campos.');
      return;
    }

    // Verifica se a senha tem pelo menos 6 caracteres
    if (password.length < 6) {
      // Mostra mensagem de aviso
      _showMessage('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }

    // Verifica se as duas senhas digitadas são iguais
    if (password != confirmPassword) {
      // Mostra mensagem de aviso
      _showMessage('As senhas não conferem.');
      return;
    }

    // Atualiza o estado para mostrar indicador de carregamento
    setState(() => _loading = true);

    try {
      // Tenta registrar o usuário no banco de dados
      await DatabaseHelper.instance.registerUser(
        name: name,
        email: email,
        password: password,
      );

      // Verifica se o widget ainda está montado
      if (!mounted) return;
      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          // Texto da mensagem
          content: Text(
            'Conta criada com sucesso!',
            // Estilo do texto em negrito
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // Cor de fundo verde para indicar sucesso
          backgroundColor: Colors.green,
        ),
      );
      // Navega para a página de login removendo a página de registro do histórico
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Verifica se o widget ainda está montado
      if (!mounted) return;
      // Mostra mensagem de erro
      _showMessage('Erro ao criar conta: $e');
    } finally {
      // Verifica se o widget ainda está montado
      if (mounted) {
        // Finaliza o carregamento
        setState(() => _loading = false);
      }
    }
  }

  // Método que mostra uma mensagem de erro na tela (SnackBar)
  void _showMessage(String message) {
    // Obtém o ScaffoldMessenger para mostrar a mensagem
    ScaffoldMessenger.of(context).showSnackBar(
      // Cria um SnackBar com a mensagem
      SnackBar(
        // Widget com o conteúdo da mensagem
        content: Text(
          message,
          // Estilo do texto em negrito
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // Cor de fundo vermelha para indicar erro
        backgroundColor: Colors.redAccent[700],
      ),
    );
  }

  // Constrói a interface de usuário da página de registro
  @override
  Widget build(BuildContext context) {
    // Retorna um Scaffold que é a estrutura base de uma tela
    return Scaffold(
      // Cor de fundo branca
      backgroundColor: Colors.white,
      // Define a barra superior
      appBar: AppBar(
        // Não mostra o botão de voltar automático
        automaticallyImplyLeading: false,
        // Cor de fundo vermelha
        backgroundColor: Colors.redAccent[700],
        // Elevação (sombra) da barra em 0
        elevation: 0,
        // Centraliza o título
        centerTitle: true,
        // Título com logo e texto
        title: Row(
          // Tamanho mínimo para encaixar o conteúdo
          mainAxisSize: MainAxisSize.min,
          children: [
            // Widget Hero que anima o logo
            Hero(
              // Tag para a animação
              tag: 'app_brand_icon',
              // Image.asset carrega a imagem do logo
              child: Image.asset(
                'assets/logo.png',
                // Altura do logo
                height: 20,
                // Largura do logo
                width: 20,
                // Ajusta a imagem para caber
                fit: BoxFit.contain,
                // Cor branca
                color: Colors.white,
              ),
            ),
            // Espaço horizontal
            SizedBox(width: 8),
            // Texto flexível
            Flexible(
              // Texto "AutoCash"
              child: Text(
                'AutoCash',
                // Estilo do texto
                style: TextStyle(
                  // Cor branca
                  color: Colors.white,
                  // Texto em negrito
                  fontWeight: FontWeight.bold,
                  // Espaçamento entre letras
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
      // Define o corpo da página
      body: SafeArea(
        // SafeArea evita que o conteúdo fique sob barra de status
        child: Center(
          // Centraliza o conteúdo
          child: ConstrainedBox(
            // Limita a largura máxima a 400 pixels
            constraints: const BoxConstraints(maxWidth: 400),
            // SingleChildScrollView permite fazer scroll se necessário
            child: SingleChildScrollView(
              // Espaço interno
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              // Coluna que organiza os elementos verticalmente
              child: Column(
                // Centraliza o conteúdo verticalmente
                mainAxisAlignment: MainAxisAlignment.center,
                // Estica o conteúdo horizontalmente
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícone representando porta (entrada)
                  Icon(
                    Icons.door_front_door,
                    // Tamanho do ícone
                    size: 110,
                    // Cor vermelha
                    color: Colors.redAccent[700],
                  ),
                  // Espaço vertical
                  const SizedBox(height: 12),

                  // Texto "REGISTRAR-SE"
                  const Text(
                    'REGISTRAR-SE',
                    // Alinha ao centro
                    textAlign: TextAlign.center,
                    // Estilo do texto
                    style: TextStyle(
                      // Tamanho da fonte
                      fontSize: 28,
                      // Muito negrito
                      fontWeight: FontWeight.w900,
                      // Espaçamento entre letras
                      letterSpacing: 2.0,
                      // Cor preta suave
                      color: Colors.black87,
                    ),
                  ),
                  // Espaço vertical
                  const SizedBox(height: 36),

                  // Campo de entrada de nome de usuário
                  _buildLabelAndField(
                    controller: _nameController,
                    label: 'Nome de usuário:',
                    obscureText: false,
                  ),
                  // Espaço vertical
                  const SizedBox(height: 16),

                  // Campo de entrada de email
                  _buildLabelAndField(
                    controller: _emailController,
                    label: 'Email',
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  // Espaço vertical
                  const SizedBox(height: 16),

                  // Campo de entrada de senha
                  _buildLabelAndField(
                    controller: _passwordController,
                    label: 'Senha',
                    obscureText: true,
                  ),
                  // Espaço vertical
                  const SizedBox(height: 16),

                  // Campo de entrada de confirmação de senha
                  _buildLabelAndField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar senha',
                    obscureText: true,
                  ),
                  // Espaço vertical
                  const SizedBox(height: 24),

                  // Botão para ir à página de login
                  TextButton(
                    // Navega para a página de login
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    // Estilo do botão
                    style: TextButton.styleFrom(
                      // Cor do texto preta
                      foregroundColor: Colors.black87,
                    ),
                    // Texto do botão
                    child: const Text(
                      'Possui conta? Login',
                      // Estilo do texto
                      style: TextStyle(
                        // Texto em negrito
                        fontWeight: FontWeight.bold,
                        // Tamanho da fonte
                        fontSize: 14,
                        // Espaçamento entre letras
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Espaço vertical
                  const SizedBox(height: 24),

                  // Botão de Cadastro
                  Center(
                    // Centraliza o botão
                    child: ElevatedButton(
                      // Se está carregando, desabilita o botão
                      onPressed: _loading ? null : _register,
                      // Estilo do botão
                      style: ElevatedButton.styleFrom(
                        // Cor de fundo cinza claro
                        backgroundColor: Colors.grey[300],
                        // Cor do texto preta
                        foregroundColor: Colors.black,
                        // Elevação (sombra) em 0
                        elevation: 0,
                        // Espaço interno do botão
                        padding: const EdgeInsets.symmetric(
                          horizontal: 64,
                          vertical: 16,
                        ),
                        // Forma do botão com cantos arredondados
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            // Cor da borda preta suave
                            color: Colors.black54,
                            // Largura da borda
                            width: 1.5,
                          ),
                        ),
                      ),
                      // Conteúdo do botão
                      child: _loading
                          // Se está carregando, mostra indicador de progresso
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          // Se não está carregando, mostra texto
                          : const Text(
                              'Cadastrar',
                              // Estilo do texto
                              style: TextStyle(
                                // Texto em negrito
                                fontWeight: FontWeight.bold,
                                // Tamanho da fonte
                                fontSize: 16,
                                // Espaçamento entre letras
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

  // Widget que constrói um rótulo e campo de entrada de texto
  Widget _buildLabelAndField({
    TextEditingController? controller,
    required String label,
    required bool obscureText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    // Retorna uma coluna com rótulo e campo
    return Column(
      // Alinha os itens à esquerda
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rótulo do campo
        Text(
          label,
          // Estilo do rótulo
          style: const TextStyle(
            // Texto em negrito
            fontWeight: FontWeight.bold,
            // Tamanho da fonte
            fontSize: 15,
            // Cor preta
            color: Colors.black,
            // Espaçamento entre letras
            letterSpacing: 0.5,
          ),
        ),
        // Espaço vertical entre rótulo e campo
        const SizedBox(height: 8),
        // Campo de entrada de texto
        TextFormField(
          // Controlador do campo
          controller: controller,
          // Define se o texto deve ser ocultado
          obscureText: obscureText,
          // Tipo de teclado a mostrar
          keyboardType: keyboardType,
          // Estilo do texto digitado
          style: const TextStyle(fontSize: 16),
          // Decoração do campo
          decoration: InputDecoration(
            // Campo com fundo preenchido
            filled: true,
            // Cor de fundo cinza claro
            fillColor: const Color(0xFFF2F2F2),
            // Espaço interno do campo
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 16.0,
            ),

            // Borda padrão do campo
            border: OutlineInputBorder(
              // Cantos arredondados
              borderRadius: BorderRadius.circular(14),
              // Cor e largura da borda
              borderSide: const BorderSide(color: Colors.black54, width: 1),
            ),
            // Borda quando o campo está habilitado
            enabledBorder: OutlineInputBorder(
              // Cantos arredondados
              borderRadius: BorderRadius.circular(14),
              // Cor e largura da borda
              borderSide: const BorderSide(color: Colors.black54, width: 1),
            ),
            // Borda quando o campo está em foco
            focusedBorder: OutlineInputBorder(
              // Cantos arredondados
              borderRadius: BorderRadius.circular(14),
              // Cor vermelha e largura maior
              borderSide: BorderSide(color: Colors.redAccent[700]!, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
