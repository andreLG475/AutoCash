import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_io/io.dart';

import 'data/database_helper.dart';
import 'models/gasto.dart';
import 'models/car.dart';
import 'services/expense_logic.dart';
import 'services/media_service.dart';
import 'widgets/image_display_widget.dart';
import 'utils/formatters.dart';

class CadastroGastosPage extends StatefulWidget {
  final Car? car;

  const CadastroGastosPage({super.key, this.car});

  @override
  State<CadastroGastosPage> createState() => _CadastroGastosPageState();
}

class _CadastroGastosPageState extends State<CadastroGastosPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();
  final _quilometragemController = TextEditingController();
  final _descricaoDetalhadaController = TextEditingController();

  Car? _car;
  DateTime? _selectedDate;
  String? _notaFiscalPath;

  @override
  void initState() {
    super.initState();
    _loadCar();
    _initializeAutoFill();
  }

  Future<void> _loadCar() async {
    if (widget.car != null) {
      setState(() {
        _car = widget.car;
      });
    }
  }

  Future<void> _initializeAutoFill() async {
    // Preencher com a data de hoje
    final today = DateTime.now();
    setState(() {
      _selectedDate = today;
      _dataController.text = _formatDate(today);
    });

    // Esperar um pequeno delay para garantir que o carro foi carregado
    await Future.delayed(const Duration(milliseconds: 100));

    // Preencher quilometragem com o valor atual do carro
    if (_car != null && _car!.km > 0) {
      setState(() {
        _quilometragemController.text = _car!.km.toString();
      });
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    _quilometragemController.dispose();
    _descricaoDetalhadaController.dispose();
    super.dispose();
  }

  Future<void> _handleMediaUpload() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecione uma opção',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Tirar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.green),
                title: const Text('Escolher Foto da Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_present, color: Colors.orange),
                title: const Text('Importar Arquivo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
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

  Future<void> _takePhoto() async {
    final savedPath = await MediaService.takePhotoFromCamera();
    if (savedPath != null) {
      setState(() {
        _notaFiscalPath = savedPath;
      });
      _showSuccessMessage('Foto capturada com sucesso!');
    }
  }

  Future<void> _pickPhoto() async {
    final savedPath = await MediaService.pickPhotoFromGallery();
    if (savedPath != null) {
      setState(() {
        _notaFiscalPath = savedPath;
      });
      _showSuccessMessage('Foto selecionada com sucesso!');
    }
  }

  Future<void> _pickFile() async {
    final savedPath = await MediaService.pickFile();
    if (savedPath != null) {
      setState(() {
        _notaFiscalPath = savedPath;
      });
      _showSuccessMessage('Arquivo importado com sucesso!');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveGasto() async {
    if (_car == null || _car!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Veículo não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final valor = double.tryParse(
      _valorController.text.trim().replaceAll(',', '.'),
    );
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um valor válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma data válida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentCar = await DatabaseHelper.instance.getCarById(_car!.id!);
    if (!mounted) return;
    if (currentCar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Veículo não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quilometragem = int.parse(_quilometragemController.text.trim());
    final existingGastos = await DatabaseHelper.instance.getGastosByCarId(
      _car!.id!,
    );
    final chronologyError = validateMileageAgainstChronology(
      selectedDate: _selectedDate!,
      mileage: quilometragem,
      existingGastos: existingGastos,
      initialMileage: currentCar.kmInicial,
    );

    if (chronologyError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chronologyError), backgroundColor: Colors.red),
      );
      return;
    }

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

    await DatabaseHelper.instance.insertGasto(gasto);
    await DatabaseHelper.instance.syncCarMetrics(
      _car!.id!,
      referenceDate: _selectedDate!,
    );

    if (!mounted) return;

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

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dataController.text = _formatDate(pickedDate);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateForStorage(DateTime date) {
    return '${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700],
        elevation: 0,
        centerTitle: true,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        color: Colors
                            .grey[400], // Mesma cor cinza de fundo usada nas outras telas
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabelAndField(
                              controller: _descricaoController,
                              label: 'Manutenção:',
                              hint: 'EX: Troca de óleo',
                            ),
                            const SizedBox(height: 16),

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

                            _buildLabelAndField(
                              controller: _descricaoDetalhadaController,
                              label: 'Descrição: (opcional)',
                              hint:
                                  'Digite detalhes adicionais sobre o serviço...',
                              maxLines: 5,
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Nota fiscal: (opcional)',
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                  // Info do arquivo
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

                    // Botão Inferior (Fica fora do card cinza, alinhado na base)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(
              0xFFF2F2F2,
            ), // Cor clara de dentro dos inputs
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
