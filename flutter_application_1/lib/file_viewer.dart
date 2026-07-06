import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileViewerPage extends StatefulWidget {
  final String filePath;
  final String fileName;

  const FileViewerPage({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<FileViewerPage> createState() => _FileViewerPageState();
}

class _FileViewerPageState extends State<FileViewerPage> {
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

      // Obter o diretório de download
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível acessar pasta de downloads'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Copiar arquivo para pasta de downloads
      final destinationPath = '${downloadsDirectory.path}/${widget.fileName}';
      await file.copy(destinationPath);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arquivo salvo em downloads: ${widget.fileName}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao baixar: $e'),
          backgroundColor: Colors.red,
        ),
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
                    _isDownloading ? 'Baixando...' : 'Baixar Arquivo',
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
                  ? 'Para visualizar este PDF, use seu leitor favorito após baixar.'
                  : 'Para visualizar este arquivo, use um aplicativo compatível após baixar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.amber[800]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Clique em "Baixar Arquivo" para salvar em seu dispositivo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
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
