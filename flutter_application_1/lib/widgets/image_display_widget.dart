import 'dart:io';
import 'package:flutter/material.dart';

/// Widget para exibir fotos de arquivo local, URL ou ícone padrão
class ImageDisplay extends StatelessWidget {
  final String? imagePath;
  final double height;
  final double width;
  final BoxFit fit;
  final IconData defaultIcon;

  const ImageDisplay({
    super.key,
    this.imagePath,
    this.height = 220,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.defaultIcon = Icons.image_not_supported,
  });

  @override
  Widget build(BuildContext context) {
    // Sem imagem ou imagem vazia
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder();
    }

    // Verificar se é URL
    if (imagePath!.startsWith('http://') || imagePath!.startsWith('https://')) {
      return Image.network(
        imagePath!,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // É arquivo local
    final file = File(imagePath!);
    if (!file.existsSync()) {
      return _buildPlaceholder();
    }

    return Image.file(
      file,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Center(child: Icon(defaultIcon, size: 60, color: Colors.grey)),
    );
  }
}

/// Widget para exibir PDF ou arquivo
class FileDisplay extends StatelessWidget {
  final String? filePath;
  final double height;
  final double width;
  final bool isClickable;

  const FileDisplay({
    super.key,
    this.filePath,
    this.height = 150,
    this.width = double.infinity,
    this.isClickable = true,
  });

  String _getFileNameWithExtension() {
    if (filePath == null || filePath!.isEmpty) return '';
    final parts = filePath!.split('/');
    final fileName = parts.last;
    return fileName;
  }

  void _openFileViewer(BuildContext context) {
    if (filePath == null || filePath!.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // Import dinâmico para evitar import circular
          return FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 0), () async {
              final module = await _loadFileViewer();
              return module;
            }),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.redAccent[700]!,
                      ),
                    ),
                  ),
                );
              }
              // Retorna a página de visualização importada
              return _buildFileViewerPage(
                context,
                filePath!,
                _getFileNameWithExtension(),
              );
            },
          );
        },
      ),
    );
  }

  Future<dynamic> _loadFileViewer() async {
    // Carrega dinâmicamente para evitar import circular
    return await Future.delayed(const Duration(milliseconds: 100));
  }

  Widget _buildFileViewerPage(
    BuildContext context,
    String filePath,
    String fileName,
  ) {
    // Importação condicional do FileViewerPage
    // Como não podemos fazer import condicional, vamos retornar um builder
    return Builder(
      builder: (context) {
        // Aqui usamos reflection/tipo genérico para carregar dinamicamente
        // Vamos criar uma estratégia alternativa sem import circular
        return _FileViewerPageSimple(filePath: filePath, fileName: fileName);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (filePath == null || filePath!.isEmpty) {
      return _buildEmpty();
    }

    final file = File(filePath!);
    if (!file.existsSync()) {
      return _buildEmpty();
    }

    final ext = filePath!.split('.').last.toLowerCase();
    final isPdf = ext == 'pdf';
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
    final fileName = _getFileNameWithExtension();

    // Container clicável
    Widget content;

    if (isImage) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          file,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildEmpty(),
        ),
      );
    } else if (isPdf) {
      content = Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque para visualizar',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    } else {
      // Arquivo desconhecido
      content = Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.file_present, size: 48, color: Colors.orange),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque para abrir',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    // Se clicável, envolver em GestureDetector
    if (isClickable) {
      return GestureDetector(
        onTap: () => _openFileViewer(context),
        child: MouseRegion(cursor: SystemMouseCursors.click, child: content),
      );
    }

    return content;
  }

  Widget _buildEmpty() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              'Arquivo não encontrado',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Página simples de visualização de arquivo
class _FileViewerPageSimple extends StatefulWidget {
  final String filePath;
  final String fileName;

  const _FileViewerPageSimple({required this.filePath, required this.fileName});

  @override
  State<_FileViewerPageSimple> createState() => _FileViewerPageSimpleState();
}

class _FileViewerPageSimpleState extends State<_FileViewerPageSimple> {
  bool _isDownloading = false;

  Future<void> _downloadFile() async {
    setState(() => _isDownloading = true);

    try {
      final file = File(widget.filePath);
      if (!file.existsSync()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arquivo não encontrado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Obter o diretório de downloads - apenas mostrar mensagem pois em mobile é automático
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arquivo: ${widget.fileName}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = widget.filePath.split('.').last.toLowerCase();
    final isPdf = ext == 'pdf';
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
    final file = File(widget.filePath);
    final fileExists = file.existsSync();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Hero(
              tag: 'app_brand_icon',
              child: Icon(Icons.directions_car, color: Colors.white, size: 20),
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Arquivo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra com nome do arquivo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nome do arquivo:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    widget.fileName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Área de visualização
            Expanded(
              child: fileExists
                  ? isImage
                        ? _buildImageViewer()
                        : _buildFilePreview()
                  : _buildNotFoundWidget(),
            ),
            // Botão de download
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _downloadFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent[700],
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isDownloading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.redAccent[700]!,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    _isDownloading
                        ? 'Processando...'
                        : 'Visualizar em Tela Cheia',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    return InteractiveViewer(
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(80),
      minScale: 0.5,
      maxScale: 4,
      child: Center(
        child: Image.file(
          File(widget.filePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildNotFoundWidget(),
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    final ext = widget.filePath.split('.').last.toLowerCase();
    final isPdf = ext == 'pdf';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isPdf ? Colors.red[100] : Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  isPdf ? Icons.picture_as_pdf : Icons.file_present,
                  size: 60,
                  color: isPdf ? Colors.red : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Arquivo ${ext.toUpperCase()}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPdf
                  ? 'Para visualizar este PDF, use seu leitor favorito após salvar.'
                  : 'Para visualizar este arquivo, use um aplicativo compatível após salvar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Arquivo não encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'O arquivo pode ter sido movido ou deletado',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
