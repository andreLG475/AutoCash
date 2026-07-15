// Importa o pacote principal do Flutter
import 'package:flutter/material.dart';
// Importa o pacote para obter diretório de downloads
import 'package:path_provider/path_provider.dart';
// Importa o pacote universal_io para trabalhar com arquivos em diferentes plataformas
import 'package:universal_io/io.dart';

/// Widget para exibir fotos de arquivo local, URL ou ícone padrão
class ImageDisplay extends StatelessWidget {
  // Caminho da imagem (pode ser URL, arquivo local ou data URI)
  final String? imagePath;
  // Altura da imagem
  final double height;
  // Largura da imagem
  final double width;
  // Como a imagem deve se ajustar ao espaço (cover, contain, etc)
  final BoxFit fit;
  // Ícone padrão a mostrar quando não há imagem
  final IconData defaultIcon;

  // Construtor com valores padrão
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
    // Se não há caminho de imagem ou está vazio, mostra placeholder
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder();
    }

    // Verifica se é uma URL (http ou https)
    if (imagePath!.startsWith('http://') || imagePath!.startsWith('https://')) {
      // Carrega a imagem da internet
      return Image.network(
        imagePath!,
        height: height,
        width: width,
        fit: fit,
        // Se houver erro ao carregar, mostra placeholder
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Verifica se é uma imagem em formato data URI (base64)
    if (imagePath!.startsWith('data:image')) {
      // Parse do data URI para extrair os bytes da imagem
      final uri = Uri.parse(imagePath!);
      final bytes = uri.data?.contentAsBytes();
      // Se não conseguir extrair bytes, mostra placeholder
      if (bytes == null) {
        return _buildPlaceholder();
      }
      // Carrega a imagem a partir dos bytes
      return Image.memory(
        bytes,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Trata como arquivo local
    final file = File(imagePath!);
    // Verifica se o arquivo existe
    if (!file.existsSync()) {
      return _buildPlaceholder();
    }

    // Carrega a imagem a partir do arquivo
    return Image.file(
      file,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  // Widget placeholder que mostra quando não há imagem válida
  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Center(
        child: Image.asset(
          'assets/logo.png',
          height: height * 0.5,
          fit: BoxFit.contain,
          color: Colors.grey,
          // Se o logo também falhar, mostra o ícone padrão
          errorBuilder: (context, error, stackTrace) =>
              Icon(defaultIcon, size: 60, color: Colors.grey),
        ),
      ),
    );
  }
}

/// Widget para exibir PDF ou arquivo com opção de download
class FileDisplay extends StatefulWidget {
  // Caminho do arquivo a exibir
  final String? filePath;
  // Altura do widget
  final double height;
  // Largura do widget
  final double width;
  // Se o widget deve ser clicável para download
  final bool isClickable;

  // Construtor com valores padrão
  const FileDisplay({
    super.key,
    this.filePath,
    this.height = 150,
    this.width = double.infinity,
    this.isClickable = true,
  });

  @override
  State<FileDisplay> createState() => _FileDisplayState();
}

// Estado do FileDisplay
class _FileDisplayState extends State<FileDisplay> {
  // Flag que indica se está em processo de download
  bool _isDownloading = false;

  // Método que extrai o nome do arquivo a partir do caminho
  String _getFileNameWithExtension() {
    // Se não há caminho, retorna string vazia
    if (widget.filePath == null || widget.filePath!.isEmpty) return '';
    // Divide o caminho por "/" e pega o último elemento (nome do arquivo)
    final parts = widget.filePath!.split('/');
    return parts.last;
  }

  // Método assíncrono que baixa o arquivo para a pasta Downloads
  Future<void> _downloadFile() async {
    // Se não há caminho válido, retorna
    if (widget.filePath == null || widget.filePath!.isEmpty) return;

    // Cria um File a partir do caminho
    final file = File(widget.filePath!);
    // Verifica se o arquivo existe
    if (!file.existsSync()) {
      if (!mounted) return;
      // Mostra erro se arquivo não encontrado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arquivo não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Atualiza o estado para mostrar que está baixando
    setState(() => _isDownloading = true);

    try {
      // Obtém o diretório de Downloads do dispositivo
      final downloadsDirectory = await getDownloadsDirectory();
      // Se não conseguir acessar Downloads, mostra erro
      if (downloadsDirectory == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível acessar a pasta de Downloads'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Cria o caminho de destino para o arquivo
      final destinationPath =
          '${downloadsDirectory.path}/${_getFileNameWithExtension()}';
      // Copia o arquivo para a pasta Downloads
      await file.copy(destinationPath);

      if (!mounted) return;
      // Mostra sucesso ao usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Arquivo salvo em Downloads: ${_getFileNameWithExtension()}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Mostra erro se falhar no download
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao baixar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Finaliza o estado de download
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se não há caminho válido, mostra placeholder vazio
    if (widget.filePath == null || widget.filePath!.isEmpty) {
      return _buildEmpty();
    }

    // Se é um data URI de imagem, exibe como imagem
    if (widget.filePath!.startsWith('data:image')) {
      final uri = Uri.parse(widget.filePath!);
      final bytes = uri.data?.contentAsBytes();
      if (bytes == null) {
        return _buildEmpty();
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          bytes,
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
        ),
      );
    }

    // Verifica se o arquivo existe
    final file = File(widget.filePath!);
    if (!file.existsSync()) {
      return _buildEmpty();
    }

    // Obtém a extensão do arquivo
    final ext = widget.filePath!.split('.').last.toLowerCase();
    // Verifica se é PDF
    final isPdf = ext == 'pdf';
    // Verifica se é imagem
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
    // Obtém o nome do arquivo
    final fileName = _getFileNameWithExtension();

    // Widget de conteúdo que será exibido
    Widget content;

    // Se é imagem, exibe com opção de download
    if (isImage) {
      content = Stack(
        children: [
          // Imagem do arquivo
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              file,
              height: widget.height,
              width: widget.width,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildEmpty(),
            ),
          ),
          // Overlay com botão de download na parte inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                color: Color.fromRGBO(0, 0, 0, 0.65),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.download, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _isDownloading ? 'Baixando...' : 'Baixar arquivo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } 
    // Se é PDF, exibe ícone de PDF com informações
    else if (isPdf) {
      content = Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent, width: 2),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent[700],
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Baixar arquivo',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    } 
    // Para outros tipos de arquivo, exibe ícone de arquivo genérico
    else {
      content = Container(
        height: widget.height,
        width: widget.width,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent[700],
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Baixar arquivo',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Se é clicável, envolve em GestureDetector para detectar cliques
    if (widget.isClickable) {
      return GestureDetector(
        // Ao clicar, executa download se não estiver já baixando
        onTap: _isDownloading ? null : _downloadFile,
        // Muda o cursor do mouse para indicar que é clicável
        child: MouseRegion(cursor: SystemMouseCursors.click, child: content),
      );
    }

    return content;
  }

  // Widget que mostra quando não há arquivo válido
  Widget _buildEmpty() {
    return Container(
      height: widget.height,
      width: widget.width,
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
          children: [
            Hero(
              tag: 'app_brand_icon',
              child: Image.asset(
                'assets/logo.png',
                height: 20,
                width: 20,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
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
                      color: Colors.white,
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
                  ? 'Use o botão abaixo para baixar este PDF em Downloads.'
                  : 'Use o botão abaixo para baixar este arquivo em Downloads.',
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
