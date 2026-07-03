import 'package:flutter/material.dart';

import 'models/gasto.dart';
import 'widgets/image_display_widget.dart';

class VisualizacaoGastoPage extends StatefulWidget {
  const VisualizacaoGastoPage({super.key});

  @override
  State<VisualizacaoGastoPage> createState() => _VisualizacaoGastoPageState();
}

class _VisualizacaoGastoPageState extends State<VisualizacaoGastoPage> {
  Gasto? _gasto;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadGasto();
  }

  void _loadGasto() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Gasto) {
      setState(() {
        _gasto = args;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Manutenção',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
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
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Fundo levemente contrastante
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDisplayField(
                      label: 'Manutenção:',
                      value: _gasto?.descricao ?? '',
                    ),
                    const SizedBox(height: 16),

                    // 2. Valor Gasto
                    _buildDisplayField(
                      label: 'Valor gasto:',
                      value: _gasto != null
                          ? r'R$ ' + _gasto!.valor.toStringAsFixed(2)
                          : '',
                    ),
                    const SizedBox(height: 16),

                    // 3. Data da Manutenção
                    _buildDisplayField(
                      label: 'Data:',
                      value: _gasto?.data ?? '',
                    ),
                    const SizedBox(height: 16),

                    // 4. Quilometragem do Veículo
                    _buildDisplayField(
                      label: 'Kilomentragem do veiculo:',
                      value: _gasto?.quilometragem.toString() ?? '',
                    ),
                    const SizedBox(height: 16),

                    // 5. Descrição Detalhada
                    _buildDisplayField(
                      label: 'Descrição:',
                      value: _gasto?.descricaoDetalhada ?? '',
                    ),
                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nota fiscal:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FileDisplay(filePath: _gasto?.notaFiscal, height: 180),
                      ],
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

  // Helper unificado para manter as caixas de exibição idênticas aos inputs do app
  Widget _buildDisplayField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color(
              0xFFF2F2F2,
            ), // Mesmo cinza claro do restante do app
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black54,
              width: 1,
            ), // Borda escura fina
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
