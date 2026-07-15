// Importa o pacote principal do Flutter para Material Design
import 'package:flutter/material.dart';

// Importa o helper do banco de dados
import 'data/database_helper.dart';
// Importa o modelo de usuário
import 'models/user.dart';
// Importa o serviço de mídia (câmera e galeria)
import 'services/media_service.dart';
// Importa o widget de exibição de imagens
import 'widgets/image_display_widget.dart';

// Classe AccountPage que estende StatefulWidget (página que muda de estado)
class AccountPage extends StatefulWidget {
  // Construtor com chave opcional
  const AccountPage({super.key});

  // Cria o estado da página de conta
  @override
  State<AccountPage> createState() => _AccountPageState();
}

// Estado da classe AccountPage
class _AccountPageState extends State<AccountPage> {
  // Controlador de texto para o campo de email
  final _emailController = TextEditingController();
  // Controlador de texto para o campo de senha
  final _senhaController = TextEditingController();
  // Controlador de texto para o campo de nome
  final _nomeController = TextEditingController();
  // Variável que armazena o usuário atual
  User? _currentUser;
  // Variável que controla se está carregando os dados
  bool _loading = true;
  // Variável que armazena o caminho da foto do avatar
  String? _avatarPath;

  // Método chamado quando o widget é inicializado
  @override
  void initState() {
    super.initState();
    // Carrega os dados do usuário atual
    _loadCurrentUser();
  }

  // Método assíncrono que carrega os dados do usuário atual
  Future<void> _loadCurrentUser() async {
    // Obtém o ID do usuário atual do banco de dados
    final userId = DatabaseHelper.instance.currentUserId;
    // Verifica se não há usuário logado
    if (userId == null) {
      // Verifica se o widget ainda está montado
      if (!mounted) return;
      // Atualiza o estado para parar de carregar
      setState(() => _loading = false);
      return;
    }

    // Busca o usuário no banco de dados pelo ID
    final user = await DatabaseHelper.instance.getUserById(userId);
    // Verifica se o widget ainda está montado
    if (!mounted) return;

    // Atualiza o estado com os dados do usuário
    setState(() {
      // Armazena o usuário
      _currentUser = user;
      // Preenche o controlador de email
      _emailController.text = user?.email ?? '';
      // Preenche o controlador de senha
      _senhaController.text = user?.password ?? '';
      // Preenche o controlador de nome
      _nomeController.text = user?.name ?? '';
      // Armazena o caminho da foto
      _avatarPath = user?.photoPath;
      // Define que o carregamento foi concluído
      _loading = false;
    });
  }

  // Método chamado quando o widget é removido da árvore
  @override
  void dispose() {
    // Descarta todos os controladores de texto
    _emailController.dispose();
    _senhaController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  // Método assíncrono que salva as alterações do usuário
  Future<void> _saveChanges() async {
    // Obtém o nome e remove espaços em branco
    final name = _nomeController.text.trim();
    // Obtém o email e remove espaços em branco
    final email = _emailController.text.trim();
    // Obtém a senha
    final password = _senhaController.text;

    // Verifica se algum campo está vazio
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      // Mostra mensagem de aviso
      _showMessage('Preencha todos os campos.');
      return;
    }

    // Verifica se o usuário atual tem um ID válido
    if (_currentUser?.id == null) {
      // Mostra mensagem de erro
      _showMessage('Usuário não carregado.');
      return;
    }

    try {
      // Tenta atualizar os dados do usuário no banco de dados
      final updatedUser = await DatabaseHelper.instance.updateUserProfile(
        userId: _currentUser!.id!,
        name: name,
        email: email,
        password: password,
        photoPath: _avatarPath,
      );

      // Atualiza o estado com o usuário atualizado
      setState(() => _currentUser = updatedUser);
      // Mostra mensagem de sucesso
      _showMessage('Alterações salvas com sucesso!', isSuccess: true);
    } catch (e) {
      // Mostra mensagem de erro
      _showMessage('Erro ao salvar: $e');
    }
  }

  // Método que abre um modal para escolher a foto do avatar
  Future<void> _pickAvatarImage() async {
    // Mostra um modal bottom sheet com opções de câmera e galeria
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // SafeArea evita que o conteúdo fique sob a barra de navegação
        return SafeArea(
          // Wrap organiza os itens em uma grade ou coluna
          child: Wrap(
            children: [
              // Opção de tirar foto com a câmera
              ListTile(
                // Ícone de câmera
                leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
                // Texto da opção
                title: const Text('Tirar foto'),
                // Função ao tocar
                onTap: () async {
                  // Fecha o modal
                  Navigator.pop(context);
                  // Chama a função de tirar foto
                  final savedPath = await MediaService.takePhotoFromCamera();
                  // Verifica se a foto foi tirada com sucesso
                  if (savedPath != null) {
                    // Atualiza o caminho do avatar
                    setState(() => _avatarPath = savedPath);
                    // Mostra mensagem de sucesso
                    _showMessage(
                      'Foto atualizada com sucesso!',
                      isSuccess: true,
                    );
                  }
                },
              ),
              // Opção de escolher foto da galeria
              ListTile(
                // Ícone de galeria
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.redAccent,
                ),
                // Texto da opção
                title: const Text('Escolher da galeria'),
                // Função ao tocar
                onTap: () async {
                  // Fecha o modal
                  Navigator.pop(context);
                  // Chama a função de selecionar foto
                  final savedPath = await MediaService.pickPhotoFromGallery();
                  // Verifica se a foto foi selecionada com sucesso
                  if (savedPath != null) {
                    // Atualiza o caminho do avatar
                    setState(() => _avatarPath = savedPath);
                    // Mostra mensagem de sucesso
                    _showMessage(
                      'Foto atualizada com sucesso!',
                      isSuccess: true,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Método que mostra uma mensagem na tela (SnackBar)
  void _showMessage(String message, {bool isSuccess = false}) {
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
        // Cor de fundo: verde se sucesso, vermelho se erro
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent[700],
        // Duração que a mensagem fica na tela
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Constrói a interface de usuário da página de conta
  @override
  Widget build(BuildContext context) {
    // Retorna um Scaffold que é a estrutura base de uma tela
    return Scaffold(
      // Cor de fundo branca
      backgroundColor: Colors.white,
      // Define a barra superior
      appBar: AppBar(
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
        // Botão de voltar
        leading: IconButton(
          // Ícone de seta para trás
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          // Função ao pressionar: volta para a página anterior
          onPressed: () => Navigator.pop(context),
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
                vertical: 32.0,
              ),
              // Coluna que organiza os elementos verticalmente
              child: Column(
                // Estica o conteúdo horizontalmente
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- SEÇÃO DO AVATAR COM BOTÃO DE EDITAR ---
                  Center(
                    // Centraliza o conteúdo
                    child: Stack(
                      // Alinha os elementos no canto inferior direito
                      alignment: Alignment.bottomRight,
                      children: [
                        // Verifica se há uma imagem de avatar
                        if (_avatarPath != null && _avatarPath!.isNotEmpty)
                          // ClipOval corta a imagem em forma de círculo
                          ClipOval(
                            // Widget que exibe a imagem
                            child: ImageDisplay(
                              imagePath: _avatarPath,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              defaultIcon: Icons.account_circle,
                            ),
                          )
                        // Se não há imagem, mostra um ícone padrão
                        else
                          const Icon(
                            Icons.account_circle,
                            size: 140,
                            color: Colors.black,
                          ),
                        // Botão de edição (lápis) no canto inferior direito
                        Positioned(
                          bottom: 10,
                          right: 10,
                          // Container que envolve o botão
                          child: Container(
                            // Decoração do container
                            decoration: BoxDecoration(
                              // Cor de fundo cinza
                              color: Colors.grey[300],
                              // Forma circular
                              shape: BoxShape.circle,
                              // Borda branca
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            // IconButton que abre o modal de seleção de foto
                            child: IconButton(
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.black87,
                              ),
                              onPressed: _pickAvatarImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Espaço vertical
                  const SizedBox(height: 16),

                  // Nome do usuário centralizado em destaque
                  Text(
                    // Nome do usuário ou "Usuário" se não houver
                    _currentUser?.name ?? 'Usuário',
                    // Alinha ao centro
                    textAlign: TextAlign.center,
                    // Estilo do texto
                    style: const TextStyle(
                      // Tamanho da fonte
                      fontSize: 26,
                      // Muito negrito
                      fontWeight: FontWeight.w900,
                      // Cor preta
                      color: Colors.black,
                    ),
                  ),
                  // Espaço vertical
                  const SizedBox(height: 40),

                  // --- CAMPOS DE DADOS ---

                  // Campo 1: Email (editável)
                  _buildLabelAndField(
                    controller: _emailController,
                    label: 'Email:',
                    obscureText: false,
                    readOnly: false,
                  ),
                  // Espaço vertical
                  const SizedBox(height: 20),

                  // Campo 2: Senha (editável)
                  _buildLabelAndField(
                    controller: _senhaController,
                    label: 'Senha:',
                    obscureText: true,
                    readOnly: false,
                  ),
                  // Espaço vertical
                  const SizedBox(height: 20),

                  // Campo 3: Nome de usuário (editável)
                  _buildLabelAndField(
                    controller: _nomeController,
                    label: 'Nome de usuario:',
                    obscureText: false,
                    readOnly: false,
                  ),
                  // Espaço vertical
                  const SizedBox(height: 24),

                  // Botão Salvar
                  Center(
                    // Centraliza o botão
                    child: ElevatedButton(
                      // Se está carregando, desabilita o botão
                      onPressed: _loading ? null : _saveChanges,
                      // Estilo do botão
                      style: ElevatedButton.styleFrom(
                        // Cor de fundo cinza claro
                        backgroundColor: Colors.grey[300],
                        // Cor do texto preta
                        foregroundColor: Colors.black,
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
                              'SALVAR',
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
    required bool readOnly,
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
            fontSize: 16,
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
          // Define se o campo é somente leitura
          readOnly: readOnly,
          // Estilo do texto digitado
          style: TextStyle(
            // Tamanho da fonte
            fontSize: 16,
            // Cor do texto: cinza se somente leitura, preta se editável
            color: readOnly ? Colors.black54 : Colors.black,
            // Negrito se somente leitura
            fontWeight: readOnly ? FontWeight.w600 : FontWeight.normal,
          ),
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
              // Cor vermelha se editável, cinza se somente leitura
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
