// Importa o pacote principal do Flutter para Material Design
import 'package:flutter/material.dart';

// Importa o helper do banco de dados para autenticação
import 'data/database_helper.dart';

// Classe LoginPage que estende StatefulWidget (página que muda de estado)
class LoginPage extends StatefulWidget {
  // Construtor com chave opcional para identificar o widget
  const LoginPage({super.key});

  // Cria o estado da página de login
  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Estado da classe LoginPage
class _LoginPageState extends State<LoginPage> {
  // Controlador de texto para o campo de usuário/e-mail
  final _identifierController = TextEditingController();
  // Controlador de texto para o campo de senha
  final _passwordController = TextEditingController();
  // Variável booleana que controla se está em processo de login
  bool _loading = false;

  // Método chamado quando o widget é removido da árvore de widgets
  @override
  void dispose() {
    // Descarta o controlador de usuário/e-mail
    _identifierController.dispose();
    // Descarta o controlador de senha
    _passwordController.dispose();
    // Chama o dispose da classe pai
    super.dispose();
  }

  // Método assíncrono que realiza o login do usuário
  Future<void> _login() async {
    // Obtém o usuário/e-mail e remove espaços em branco
    final identifier = _identifierController.text.trim();
    // Obtém a senha do campo de texto
    final password = _passwordController.text;

    // Verifica se os campos de usuário/e-mail ou senha estão vazios
    if (identifier.isEmpty || password.isEmpty) {
      // Mostra mensagem de aviso
      _showMessage('Informe usuário/e-mail e senha para entrar.');
      return;
    }

    // Atualiza o estado para mostrar indicador de carregamento
    setState(() => _loading = true);

    try {
      // Tenta autenticar o usuário com o identificador e senha
      final user = await DatabaseHelper.instance.authenticateUser(
        identifier: identifier,
        password: password,
      );

      // Verifica se o widget ainda está montado na árvore
      if (!mounted) return;

      // Verifica se o usuário foi encontrado
      if (user == null) {
        // Mostra mensagem de erro
        _showMessage('Usuário/e-mail ou senha inválidos.');
        return;
      }

      // Define o ID do usuário atual no banco de dados
      await DatabaseHelper.instance.setCurrentUserId(user.id);
      // Verifica se o widget ainda está montado
      if (!mounted) return;
      // Navega para a tela inicial removendo a página de login do histórico
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Verifica se o widget ainda está montado
      if (!mounted) return;
      // Mostra mensagem de erro
      _showMessage('Erro ao entrar: $e');
    } finally {
      // Verifica se o widget ainda está montado
      if (mounted) {
        // Finaliza o carregamento
        setState(() => _loading = false);
      }
    }
  }

  // Método que mostra uma mensagem na tela (SnackBar)
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
        // Cor de fundo vermelha
        backgroundColor: Colors.redAccent[700],
      ),
    );
  }

  // Constrói a interface de usuário da página de login
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
            // Texto flexível que se adapta ao tamanho
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
        // SafeArea evita que o conteúdo fique sob barra de status ou notch
        child: Center(
          // Centraliza o conteúdo
          child: ConstrainedBox(
            // Limita a largura máxima a 400 pixels
            constraints: const BoxConstraints(maxWidth: 400),
            // SingleChildScrollView permite fazer scroll se o conteúdo não caber
            child: SingleChildScrollView(
              // Espaço interno
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              // Coluna que organiza os elementos verticalmente
              child: Column(
                // Centraliza o conteúdo verticalmente
                mainAxisAlignment: MainAxisAlignment.center,
                // Estica o conteúdo horizontalmente
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo do AutoCash
                  Image.asset(
                    'assets/logo.png',
                    // Altura do logo
                    height: 110,
                    // Ajusta a imagem para caber
                    fit: BoxFit.contain,
                    // Cor vermelha
                    color: Colors.redAccent[700],
                  ),
                  // Espaço vertical
                  const SizedBox(height: 12),

                  // Texto "LOGIN"
                  const Text(
                    'LOGIN',
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
                  // Espaço vertical grande
                  const SizedBox(height: 48),

                  // Campo de entrada de usuário/e-mail
                  _buildLabelAndField(
                    controller: _identifierController,
                    label: 'Usuário ou E-mail',
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  // Espaço vertical
                  const SizedBox(height: 20),

                  // Campo de entrada de senha
                  _buildLabelAndField(
                    controller: _passwordController,
                    label: 'Senha',
                    obscureText: true,
                  ),
                  // Espaço vertical
                  const SizedBox(height: 24),

                  // Botão para ir à página de registro
                  TextButton(
                    // Navega para a página de registro
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    // Estilo do botão
                    style: TextButton.styleFrom(
                      // Cor do texto em preto suave
                      foregroundColor: Colors.black87,
                    ),
                    // Texto do botão
                    child: const Text(
                      'Não possui conta? Cadastre-se',
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
                  // Espaço vertical grande
                  const SizedBox(height: 32),

                  // Botão de Login
                  Center(
                    // Centraliza o botão
                    child: ElevatedButton(
                      // Se está carregando, desabilita o botão
                      onPressed: _loading ? null : _login,
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
                        // Forma do botão com cantos arredondados e borda
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
                              'LOGIN',
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
          // Define se o texto deve ser ocultado (para senha)
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

            // Borda padrão do campo (não focado)
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
            // Borda quando o campo está em foco (com destaque vermelho)
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
