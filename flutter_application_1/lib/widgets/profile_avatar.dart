// Importa a biblioteca IO para trabalhar com arquivos
import 'dart:io';

// Importa o pacote principal do Flutter
import 'package:flutter/material.dart';

// Importa o helper do banco de dados
import '../data/database_helper.dart';

// Widget que exibe o avatar (foto de perfil) do usuário atual
class ProfileAvatar extends StatefulWidget {
  // Construtor com parâmetros opcionais
  const ProfileAvatar({
    super.key,
    // Raio do avatar em pixels
    this.radius = 18,
    // Cor de fundo do avatar quando não há foto
    this.fallbackColor,
  });

  // Raio do círculo do avatar
  final double radius;
  // Cor de fallback quando não há foto
  final Color? fallbackColor;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

// Estado do ProfileAvatar
class _ProfileAvatarState extends State<ProfileAvatar> {
  // Caminho da foto de perfil do usuário
  String? _avatarPath;
  // Flag que indica se está carregando a foto
  bool _loading = true;

  // Método chamado quando o widget é inicializado
  @override
  void initState() {
    super.initState();
    // Carrega o avatar do usuário atual
    _loadAvatar();
  }

  // Método que carrega a foto de perfil do usuário
  Future<void> _loadAvatar() async {
    // Obtém o ID do usuário atual
    final userId = DatabaseHelper.instance.currentUserId;
    // Se não há usuário logado, para o carregamento
    if (userId == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    // Busca o usuário no banco de dados
    final user = await DatabaseHelper.instance.getUserById(userId);
    if (!mounted) return;

    // Atualiza o estado com o caminho da foto
    setState(() {
      _avatarPath = user?.photoPath;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se ainda está carregando, mostra um spinner
    if (_loading) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: widget.fallbackColor ?? Colors.white24,
        // Mostra um indicador de carregamento
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Obtém o caminho da foto
    final avatarPath = _avatarPath;
    // Se existe um caminho de foto válido
    if (avatarPath != null && avatarPath.isNotEmpty) {
      // Cria um File a partir do caminho
      final file = File(avatarPath);
      // Verifica se o arquivo existe
      if (file.existsSync()) {
        // Retorna um avatar com a imagem do arquivo
        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: widget.fallbackColor ?? Colors.white24,
          backgroundImage: FileImage(file),
        );
      }
    }

    // Se não há foto, mostra um ícone padrão de conta
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.fallbackColor ?? Colors.white24,
      child: const Icon(Icons.account_circle, color: Colors.white, size: 30),
    );
  }
}
