import 'package:flutter/material.dart';

class CadastroVeiculosPage extends StatefulWidget {
  const CadastroVeiculosPage({super.key});

  @override
  State<CadastroVeiculosPage> createState() => _CadastroVeiculosPageState();
}

class _CadastroVeiculosPageState extends State<CadastroVeiculosPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Fundo padrão do app
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700], // Vermelho padrão AutoCash
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Cadastro de Veículos",
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
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
                child: Icon(Icons.account_circle, color: Colors.white, size: 35),
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
                    
                    // --- O CARD COM A BORDA/FUNDO CINZA UNIFICADO ---
                    Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        color: Colors.grey[400], // Mesma cor cinza de fundo usada na AddExpensePage
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Campo 1: Marca
                            _buildLabelAndField(
                              label: 'Marca:', 
                              hint: 'EX: Peugeot',
                            ),
                            const SizedBox(height: 16),

                            // Campo 2: Modelo
                            _buildLabelAndField(
                              label: 'Modelo:', 
                              hint: 'EX: 206',
                            ),
                            const SizedBox(height: 16),

                            // Campo 3: Ano
                            _buildLabelAndField(
                              label: 'Ano:', 
                              hint: 'EX: 2008',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            // Campo 4: Quilometragem
                            _buildLabelAndField(
                              label: 'Quilometragem do veículo:', 
                              hint: 'EX: 140.000',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            // Campo 5: Área de Upload da Foto do Veículo
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
                              color: Colors.grey[300], // Caixa interna levemente mais clara
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  debugPrint("Acionar câmera ou importar imagem do veículo");
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

                    // Botão Inferior Externo
                    ElevatedButton(
                      onPressed: () {
                        // Feedback visual (SnackBar) ao tentar adicionar o veículo
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
                      },
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

  // Helper idêntico ao da tela de gastos para garantir 100% de consistência
  Widget _buildLabelAndField({
    required String label, 
    required String hint, 
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF2F2F2), // Fundo claro dos inputs
            contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
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
              borderSide: BorderSide(color: Colors.redAccent[700]!, width: 2), // Borda de foco vermelha
            ),
          ),
        ),
      ],
    );
  }
}