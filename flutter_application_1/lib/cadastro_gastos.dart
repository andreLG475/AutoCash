import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/database_helper.dart';
import 'models/gasto.dart';
import 'models/car.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCar();
  }

  Future<void> _loadCar() async {
    if (widget.car != null) {
      setState(() {
        _car = widget.car;
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

  Future<void> _saveGasto() async {
    if (_car == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Veículo não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final valor = double.tryParse(_valorController.text.trim().replaceAll(',', '.'));
    if (valor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um valor válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final gasto = Gasto(
      carId: _car!.id!,
      descricao: _descricaoController.text.trim(),
      valor: valor,
      data: _dataController.text.trim(),
      quilometragem: int.parse(_quilometragemController.text.trim()),
      descricaoDetalhada: _descricaoDetalhadaController.text.trim().isEmpty
          ? null
          : _descricaoDetalhadaController.text.trim(),
    );

    await DatabaseHelper.instance.insertGasto(gasto);

    final totalGastos = await DatabaseHelper.instance.getTotalGastosByCarId(_car!.id!);
    final updatedCar = _car!.copy(gastos: totalGastos);
    await DatabaseHelper.instance.updateCar(updatedCar);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Cadastro de manutenção",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
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
                              hint: 'EX: R\$ 200,00',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            _buildLabelAndField(
                              controller: _dataController,
                              label: 'Data:',
                              hint: 'DD/MM/AAAA',
                              keyboardType: TextInputType.datetime,
                            ),
                            const SizedBox(height: 16),

                            _buildLabelAndField(
                              controller: _quilometragemController,
                              label: 'Quilometragem do veículo:',
                              hint: 'EX: 140.000',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              color: Colors
                                  .grey[300], // Caixa interna levemente mais clara
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  debugPrint("Importar arquivo / Câmera");
                                },
                                child: SizedBox(
                                  height: 180,
                                  child: Center(
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
