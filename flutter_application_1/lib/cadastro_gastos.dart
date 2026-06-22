import 'package:flutter/material.dart';

class CadastroGastosPage extends StatefulWidget {
  const CadastroGastosPage({super.key});

  @override
  State<CadastroGastosPage> createState() => _CadastroGastosPageState();
}

class _CadastroGastosPageState extends State<CadastroGastosPage> {
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
                    
                    // --- AQUI ESTÁ O CARD COM A BORDA/FUNDO CINZA UNIFICADO ---
                    Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        color: Colors.grey[400], // Mesma cor cinza de fundo usada nas outras telas
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Campo 1: Manutenção
                            _buildLabelAndField(
                              label: 'Manutenção:', 
                              hint: 'EX: Troca de óleo',
                            ),
                            const SizedBox(height: 16),

                            // Campo 2: Valor Gasto
                            _buildLabelAndField(
                              label: 'Valor gasto:', 
                              hint: 'EX: R\$ 200,00',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            // Campo 3: Data
                            _buildLabelAndField(
                              label: 'Data:', 
                              hint: 'DD/MM/AAAA',
                              keyboardType: TextInputType.datetime,
                            ),
                            const SizedBox(height: 16),

                            // Campo 4: Quilometragem do veículo
                            _buildLabelAndField(
                              label: 'Quilometragem do veículo:', 
                              hint: 'EX: 140.000',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            // Campo 5: Descrição (Opcional)
                            _buildLabelAndField(
                              label: 'Descrição: (opcional)', 
                              hint: 'Digite detalhes adicionais sobre o serviço...',
                              maxLines: 5,
                            ),
                            const SizedBox(height: 16),

                            // Campo 6: Área de Upload da Nota Fiscal
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
                              color: Colors.grey[300], // Caixa interna levemente mais clara
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
                      onPressed: () {
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
    required String label, 
    required String hint, 
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF2F2F2), // Cor clara de dentro dos inputs
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
              borderSide: BorderSide(color: Colors.redAccent[700]!, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}