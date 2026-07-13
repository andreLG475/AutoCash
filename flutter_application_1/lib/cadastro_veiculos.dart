import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_io/io.dart';

import 'data/database_helper.dart';
import 'models/car.dart';
import 'services/media_service.dart';
import 'utils/formatters.dart';

class CadastroVeiculosPage extends StatefulWidget {
  const CadastroVeiculosPage({super.key});

  @override
  State<CadastroVeiculosPage> createState() => _CadastroVeiculosPageState();
}

class _CadastroVeiculosPageState extends State<CadastroVeiculosPage> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _kmController = TextEditingController();
  File? _carPhotoFile;
  String? _carPhotoPath;
  Uint8List? _carPhotoBytes;

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  Future<void> _handlePhotoUpload() async {
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
              if (_carPhotoFile != null)
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.red),
                  title: const Text('Remover Foto'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _carPhotoFile = null;
                      _carPhotoPath = null;
                      _carPhotoBytes = null;
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
        _carPhotoPath = savedPath;
        _carPhotoBytes = _decodePhotoBytes(savedPath);
        _carPhotoFile = savedPath.startsWith('data:image')
            ? null
            : File(savedPath);
      });
      _showSuccessMessage('Foto capturada com sucesso!');
    }
  }

  Future<void> _pickPhoto() async {
    final savedPath = await MediaService.pickPhotoFromGallery();
    if (savedPath != null) {
      setState(() {
        _carPhotoPath = savedPath;
        _carPhotoBytes = _decodePhotoBytes(savedPath);
        _carPhotoFile = savedPath.startsWith('data:image')
            ? null
            : File(savedPath);
      });
      _showSuccessMessage('Foto selecionada com sucesso!');
    }
  }

  Uint8List? _decodePhotoBytes(String? imagePath) {
    if (imagePath == null || !imagePath.startsWith('data:image')) {
      return null;
    }

    final uri = Uri.parse(imagePath);
    return uri.data?.contentAsBytes();
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

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    final carro = Car(
      marca: capitalizeFirst(_marcaController.text),
      modelo: capitalizeFirst(_modeloController.text),
      ano: int.parse(_anoController.text.trim()),
      km: int.parse(_kmController.text.trim()),
      kmInicial: int.parse(_kmController.text.trim()),
      image: _carPhotoPath ?? '',
      gastos: 0.0,
    );

    await DatabaseHelper.instance.insertCar(carro);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Veículo adicionado com sucesso!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    Navigator.pop(context);
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
                'Cadastro de Veículos',
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
                        color: Colors.grey[400],
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabelAndField(
                              controller: _marcaController,
                              label: 'Marca:',
                              hint: 'EX: Chevrolet',
                            ),
                            const SizedBox(height: 16),
                            _buildLabelAndField(
                              controller: _modeloController,
                              label: 'Modelo:',
                              hint: 'EX: Chevette',
                            ),
                            const SizedBox(height: 16),
                            _buildLabelAndField(
                              controller: _anoController,
                              label: 'Ano:',
                              hint: 'EX: 1984',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              maxLength: 4,
                            ),
                            const SizedBox(height: 16),
                            _buildLabelAndField(
                              controller: _kmController,
                              label: 'Quilometragem do veículo:',
                              hint: 'EX: 140000',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              maxLength: 12,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Foto do veículo:',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              color: Colors.grey[300],
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: _handlePhotoUpload,
                                child: SizedBox(
                                  height: _carPhotoPath != null ? 200 : 180,
                                  child: _carPhotoPath != null
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              child: _carPhotoBytes != null
                                                  ? Image.memory(
                                                      _carPhotoBytes!,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : _carPhotoFile != null
                                                  ? Image.file(
                                                      _carPhotoFile!,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : const SizedBox(),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                color: Colors.black.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.camera_alt,
                                                    size: 48,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'Trocar Foto',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.upload_file,
                                                size: 56,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Tirar foto e importar arquivos',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveCar,
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
                        'ADICIONAR VEÍCULO',
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
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
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
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo obrigatório';
            }
            if ((label == 'Ano:' || label == 'Quilometragem do veículo:') &&
                int.tryParse(value.trim()) == null) {
              return 'Digite um número válido';
            }
            return null;
          },
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
