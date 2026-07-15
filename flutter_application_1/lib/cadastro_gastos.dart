// Importa o pacote principal do Flutter para Material Design
import 'package:flutter/material.dart';
// Importa serviços de entrada de texto formatada (para filtros de input)
import 'package:flutter/services.dart';
// Importa I/O universal para operações com arquivos
import 'package:universal_io/io.dart';

// Importa o helper do banco de dados
import 'data/database_helper.dart';
// Importa o modelo de dados de gasto
import 'models/gasto.dart';
// Importa o modelo de dados de carro
import 'models/car.dart';
// Importa funções de validação e lógica de despesas
import 'services/expense_logic.dart';
// Importa o serviço de mídia (câmera, galeria, arquivos)
import 'services/media_service.dart';
// Importa o widget de exibição de imagens e arquivos
import 'widgets/image_display_widget.dart';
// Importa funções de formatação de texto e valores
import 'utils/formatters.dart';

// Classe CadastroGastosPage que estende StatefulWidget (página que muda de estado)
class CadastroGastosPage extends StatefulWidget {
  // Propriedade que recebe o carro para o qual está sendo adicionado um gasto
  final Car? car;

  // Construtor com chave opcional e parâmetro de carro
  const CadastroGastosPage({super.key, this.car});

  // Cria o estado da página de cadastro de gastos
  @override
  State<CadastroGastosPage> createState() => _CadastroGastosPageState();
}

// Estado da classe CadastroGastosPage
class _CadastroGastosPageState extends State<CadastroGastosPage> {
  // Chave de validação do formulário
  final _formKey = GlobalKey<FormState>();
  // Controlador de texto para a descrição do gasto
  final _descricaoController = TextEditingController();
  // Controlador de texto para o valor do gasto
  final _valorController = TextEditingController();
  // Controlador de texto para a data do gasto
  final _dataController = TextEditingController();
  // Controlador de texto para a quilometragem do veículo
  final _quilometragemController = TextEditingController();
  // Controlador de texto para a descrição detalhada do gasto
  final _descricaoDetalhadaController = TextEditingController();

  // Variável que armazena o carro para o qual está sendo adicionado um gasto
  Car? _car;
  // Variável que armazena a data selecionada
  DateTime? _selectedDate;
  // Variável que armazena o caminho da nota fiscal (imagem ou arquivo)
  String? _notaFiscalPath;

  // Método chamado quando o widget é inicializado
  @override
  void initState() {
    super.initState();
    // Carrega o carro passado como argumento
    _loadCar();
    // Inicializa os campos com valores padrão (data hoje, quilometragem atual)
    _initializeAutoFill();
  }

  // Método assíncrono que carrega o carro do widget
  Future<void> _loadCar() async {
    // Verifica se um carro foi passado como argumento
    if (widget.car != null) {
      // Atualiza o estado com o carro
      setState(() {
        _car = widget.car;
      });
    }
  }

  // Método assíncrono que preenche automaticamente os campos com valores padrão
  Future<void> _initializeAutoFill() async {
    // Obtém a data de hoje
    final today = DateTime.now();
    // Atualiza o estado com a data e seu formato
    setState(() {
      _selectedDate = today;
      _dataController.text = _formatDate(today);
    });

    // Aguarda um pequeno delay para garantir que o carro foi carregado
    await Future.delayed(const Duration(milliseconds: 100));

    // Verifica se o carro foi carregado e tem quilometragem válida
    if (_car != null && _car!.km > 0) {
      // Atualiza o estado com a quilometragem atual do carro
      setState(() {
        _quilometragemController.text = _car!.km.toString();
      });
    }
  }

  // Método chamado quando o widget é removido da árvore
  @override
  void dispose() {
    // Descarta todos os controladores de texto
    _descricaoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    _quilometragemController.dispose();
    _descricaoDetalhadaController.dispose();
    super.dispose();
  }

  // Método que abre um modal com opções para adicionar mídia (foto, arquivo)
  Future<void> _handleMediaUpload() async {
    // Mostra um modal bottom sheet com as opções
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // Container com padding
        return Container(
          padding: const EdgeInsets.all(16),
          // Coluna que organiza as opções verticalmente
          child: Column(
            // Ocupar apenas o espaço necessário
            mainAxisSize: MainAxisSize.min,
            children: [
              // Texto de instrução
              const Text(
                'Selecione uma opção',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Espaço vertical
              const SizedBox(height: 16),
              // Opção para tirar foto com câmera
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Tirar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              // Opção para escolher foto da galeria
              ListTile(
                leading: const Icon(Icons.image, color: Colors.green),
                title: const Text('Escolher Foto da Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto();
                },
              ),
              // Opção para importar arquivo
              ListTile(
                leading: const Icon(Icons.file_present, color: Colors.orange),
                title: const Text('Importar Arquivo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
              // Se há arquivo selecionado, mostra opção para remover
              if (_notaFiscalPath != null && _notaFiscalPath!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.red),
                  title: const Text('Remover Arquivo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _notaFiscalPath = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Método assíncrono que tira uma foto com a câmera
  Future<void> _takePhoto() async {
    // Chama o serviço de mídia para tirar foto
    final savedPath = await MediaService.takePhotoFromCamera();
    // Verifica se a foto foi tirada com sucesso
    if (savedPath != null) {
      // Atualiza o estado com o caminho da foto
      setState(() {
        _notaFiscalPath = savedPath;
      });
      // Mostra mensagem de sucesso
      _showSuccessMessage('Foto capturada com sucesso!');
    }
  }

  // Método assíncrono que seleciona uma foto da galeria
  Future<void> _pickPhoto() async {
    // Chama o serviço de mídia para selecionar foto
    final savedPath = await MediaService.pickPhotoFromGallery();
    // Verifica se a foto foi selecionada com sucesso
    if (savedPath != null) {
      // Atualiza o estado com o caminho da foto
      setState(() {
        _notaFiscalPath = savedPath;
      });
      // Mostra mensagem de sucesso
      _showSuccessMessage('Foto selecionada com sucesso!');
    }
  }

  // Método assíncrono que seleciona um arquivo
  Future<void> _pickFile() async {
    // Chama o serviço de mídia para selecionar arquivo
    final savedPath = await MediaService.pickFile();
    // Verifica se o arquivo foi selecionado com sucesso
    if (savedPath != null) {
      // Atualiza o estado com o caminho do arquivo
      setState(() {
        _notaFiscalPath = savedPath;
      });
      // Mostra mensagem de sucesso
      _showSuccessMessage('Arquivo importado com sucesso!');
    }
  }

  // Método que mostra uma mensagem de sucesso
  void _showSuccessMessage(String message) {
    // Mostra um SnackBar com a mensagem
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Método assíncrono que salva o gasto no banco de dados
  Future<void> _saveGasto() async {
    // Verifica se o carro foi carregado e tem um ID válido
    if (_car == null || _car!.id == null) {
      // Mostra mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Veículo não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Valida o formulário
    if (!_formKey.currentState!.validate()) return;

    // Tenta converter o valor para double
    final valor = double.tryParse(
      _valorController.text.trim().replaceAll(',', '.'),
    );
    // Verifica se o valor é válido e maior que zero
    if (valor == null || valor <= 0) {
      // Mostra mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um valor válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verifica se uma data foi selecionada
    if (_selectedDate == null) {
      // Mostra mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma data válida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Busca o carro atualizado no banco de dados
    final currentCar = await DatabaseHelper.instance.getCarById(_car!.id!);
    // Verifica se o widget ainda está montado
    if (!mounted) return;
    // Verifica se o carro ainda existe
    if (currentCar == null) {
      // Mostra mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Veículo não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obtém a quilometragem digitada
    final quilometragem = int.parse(_quilometragemController.text.trim());
    // Busca todos os gastos já cadastrados do carro
    final existingGastos = await DatabaseHelper.instance.getGastosByCarId(
      _car!.id!,
    );
    // Valida se a quilometragem está em ordem cronológica
    final chronologyError = validateMileageAgainstChronology(
      selectedDate: _selectedDate!,
      mileage: quilometragem,
      existingGastos: existingGastos,
      initialMileage: currentCar.kmInicial,
    );

    // Se houver erro de cronologia, mostra a mensagem
    if (chronologyError != null) {
      // Verifica se o widget ainda está montado
      if (!mounted) return;
      // Mostra mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chronologyError), backgroundColor: Colors.red),
      );
      return;
    }

    // Cria um novo objeto Gasto com os dados digitados
    final gasto = Gasto(
      carId: _car!.id!,
      descricao: capitalizeFirst(_descricaoController.text),
      valor: valor,
      data: _formatDateForStorage(_selectedDate!),
      quilometragem: quilometragem,
      descricaoDetalhada: _descricaoDetalhadaController.text.trim().isEmpty
          ? null
          : capitalizeFirst(_descricaoDetalhadaController.text),
      notaFiscal: _notaFiscalPath,
    );

    // Insere o gasto no banco de dados
    await DatabaseHelper.instance.insertGasto(gasto);
    // Sincroniza as métricas do carro (quilometragem, gastos totais, etc)
    await DatabaseHelper.instance.syncCarMetrics(
      _car!.id!,
      referenceDate: _selectedDate!,
    );

    // Verifica se o widget ainda está montado
    if (!mounted) return;

    // Mostra mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Gasto de manutenção adicionado com sucesso!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Volta para a página anterior
    Navigator.pop(context);
  }

  // Método assíncrono que abre o seletor de data
  Future<void> _pickDate() async {
    // Obtém a data de hoje
    final now = DateTime.now();
    // Abre o picker de data
    final pickedDate = await showDatePicker(
      context: context,
      // Data inicial (data selecionada ou hoje)
      initialDate: _selectedDate ?? now,
      // Primeira data permitida (1900)
      firstDate: DateTime(1900),
      // Última data permitida (hoje)
      lastDate: now,
    );

    // Se uma data foi selecionada
    if (pickedDate != null) {
      // Atualiza o estado com a nova data
      setState(() {
        _selectedDate = pickedDate;
        _dataController.text = _formatDate(pickedDate);
      });
    }
  }

  // Método que formata uma data para o formato de exibição (DD/MM/YYYY)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Método que formata uma data para armazenamento no banco (YYYY-MM-DD)
  String _formatDateForStorage(DateTime date) {
    return '${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Constrói a interface de usuário da página de cadastro de gastos
  @override
  Widget build(BuildContext context) {
    // Retorna um Scaffold que é a estrutura base de uma tela
    return Scaffold(
      // Cor de fundo cinza
      backgroundColor: Colors.grey[200],
      // Define a barra superior
      appBar: AppBar(
        // Cor de fundo vermelha
        backgroundColor: Colors.redAccent[700],
        // Elevação (sombra) em 0
        elevation: 0,
        // Centraliza o título
        centerTitle: true,
        // Título com logo e texto
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Widget Hero que anima o logo
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
                'Cadastro de manutenção',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        // Botão de voltar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // Ações na barra (logout e perfil)
        actions: [
          // Botão de logout
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
          // Avatar do usuário
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.pushNamed(context, '/edit-user');
              },
              child: const CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
      // Define o corpo da página
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Limita a largura máxima a 500 pixels
            constraints: const BoxConstraints(maxWidth: 500),
            // SingleChildScrollView permite fazer scroll se necessário
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              // Formulário com os campos de gasto
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card com fundo cinza contendo todos os campos
                    Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        color: Colors.grey[400],
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Campo de descrição do gasto
                            _buildLabelAndField(
                              controller: _descricaoController,
                              label: 'Manutenção:',
                              hint: 'EX: Troca de óleo',
                            ),
                            const SizedBox(height: 16),

                            // Campo de valor do gasto
                            _buildLabelAndField(
                              controller: _valorController,
                              label: 'Valor gasto:',
                              hint: 'EX: 200,00',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9,]'),
                                ),
                              ],
                              onChanged: (value) {
                                // Formata o valor enquanto o usuário digita
                                final cleaned = value.replaceAll(
                                  RegExp(r'[^0-9]'),
                                  '',
                                );
                                if (cleaned.isEmpty) {
                                  if (_valorController.text != '') {
                                    _valorController.value =
                                        const TextEditingValue(
                                          text: '',
                                          selection: TextSelection.collapsed(
                                            offset: 0,
                                          ),
                                        );
                                  }
                                  return;
                                }

                                // Adiciona 2 dígitos para centavos
                                final digits = cleaned.padLeft(3, '0');
                                final centavos = digits.substring(
                                  digits.length - 2,
                                );
                                final reais = digits.length <= 2
                                    ? '0'
                                    : digits
                                          .substring(0, digits.length - 2)
                                          .replaceFirst(
                                            RegExp(r'^0+(?!$)'),
                                            '',
                                          );
                                final formatted = '$reais,$centavos';

                                if (_valorController.text != formatted) {
                                  _valorController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                      offset: formatted.length,
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Campo de data do gasto
                            _buildLabelAndField(
                              controller: _dataController,
                              label: 'Data:',
                              hint: 'DD/MM/AAAA',
                              keyboardType: TextInputType.none,
                              readOnly: true,
                              onTap: _pickDate,
                              validator: (value) {
                                if (_selectedDate == null) {
                                  return 'Selecione uma data';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Campo de quilometragem
                            _buildLabelAndField(
                              controller: _quilometragemController,
                              label: 'Quilometragem do veículo:',
                              hint: 'EX: 140.000',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Campo de descrição detalhada (opcional)
                            _buildLabelAndField(
                              controller: _descricaoDetalhadaController,
                              label: 'Descrição: (opcional)',
                              hint:
                                  'Digite detalhes adicionais sobre o serviço...',
                              maxLines: 5,
                            ),
                            const SizedBox(height: 16),

                            // Seção de nota fiscal
                            const Text(
                              'Nota fiscal: (opcional)',
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Se não há arquivo, mostra área para upload
                            if (_notaFiscalPath == null ||
                                _notaFiscalPath!.isEmpty)
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                color: Colors.grey[300],
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: _handleMediaUpload,
                                  child: const SizedBox(
                                    height: 180,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_file,
                                          size: 56,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Tirar foto ou importar arquivo',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Foto | PDF | Imagem | Arquivo',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            // Se há arquivo, mostra preview e opções
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Preview do arquivo
                                  FileDisplay(
                                    filePath: _notaFiscalPath,
                                    height: 200,
                                    isClickable: false,
                                  ),
                                  const SizedBox(height: 12),
                                  // Informações do arquivo
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue[200]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Arquivo selecionado:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        SelectableText(
                                          _notaFiscalPath!.startsWith('data:')
                                              ? 'Arquivo anexado'
                                              : _notaFiscalPath!
                                                    .split('/')
                                                    .last,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _notaFiscalPath!.startsWith(
                                                    'data:',
                                                  )
                                                  ? 'Tamanho: anexado via navegador'
                                                  : 'Tamanho: ${MediaService.getFileSizeInMB(File(_notaFiscalPath!)).toStringAsFixed(2)} MB',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            // Botão para remover arquivo
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _notaFiscalPath = null;
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red[50],
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: Colors.red[300]!,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.close,
                                                      size: 14,
                                                      color: Colors.red,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Remover',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.red[700],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Botão para trocar arquivo
                                  OutlinedButton.icon(
                                    onPressed: _handleMediaUpload,
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Trocar Arquivo'),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botão de adicionar gasto
                    ElevatedButton(
                      onPressed: _saveGasto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 1,
                      ),
                      child: const Text(
                        'ADICIONAR GASTO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
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
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    // Retorna uma coluna com rótulo e campo
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rótulo do campo
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        // Espaço vertical
        const SizedBox(height: 8),
        // Campo de entrada
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          onChanged: onChanged,
          // Decoração do campo
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 16.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
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
