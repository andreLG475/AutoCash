import 'package:flutter/material.dart';

class VisualizacaoGastoPage extends StatefulWidget {
  const VisualizacaoGastoPage({super.key});

  @override
  State<VisualizacaoGastoPage> createState() => _VisualizacaoGastoPageState();
}

class _VisualizacaoGastoPageState extends State<VisualizacaoGastoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco padrão do app
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700], // Barra vermelha padrão AutoCash
        elevation: 0,
        centerTitle: true,
        // Seta de voltar para a tela anterior
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manutenção",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          // Botão de Sair da conta
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
          // Avatar na barra superior
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
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                // Container/Card principal interno que envelopa o gasto
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color:Colors.grey[200], // Fundo levemente contrastante
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    // 1. Tipo de Manutenção
                    _buildDisplayField(
                      label: 'Manutenção:',
                      value: 'Troca de oleo',
                    ),
                    const SizedBox(height: 16),

                    // 2. Valor Gasto
                    _buildDisplayField(
                      label: 'Valor gasto:',
                      value: r'R$ 200,00',
                    ),
                    const SizedBox(height: 16),

                    // 3. Data da Manutenção
                    _buildDisplayField(
                      label: 'Data:',
                      value: '26/05/2026',
                    ),
                    const SizedBox(height: 16),

                    // 4. Quilometragem do Veículo
                    _buildDisplayField(
                      label: 'Kilomentragem do veiculo:',
                      value: '67676767',
                    ),
                    const SizedBox(height: 16),

                    // 5. Descrição Detalhada
                    _buildDisplayField(
                      label: 'Descrição:',
                      value: 'Feita a troca do oleo, foi posto 4Litros de 20W50',
                    ),
                    const SizedBox(height: 16),

                    // 6. Seção de Nota Fiscal (Imagem + Nome do PDF)
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
                        
                        // Bloco de visualização do anexo
                        GestureDetector(
                          onTap: () {
                            // Integração futura para abrir o PDF/Visualizador de fotos
                            debugPrint("Abrir ou baixar nota fiscal");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2), // Cinza de fundo das caixas
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.black54, width: 1),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                // Área de pré-visualização da imagem da nota
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: double.infinity,
                                    height: 180,
                                    color: Colors.white,
                                    // DICA: Substitua o Icon abaixo por Image.asset('assets/danfe.png') quando tiver o arquivo
                                    child: const Icon(
                                      Icons.receipt_long,
                                      size: 60,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // Texto descritivo do arquivo anexado
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      'PDF:nota fiscal 34364053',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
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
            color: const Color(0xFFF2F2F2), // Mesmo cinza claro do restante do app
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black54, width: 1), // Borda escura fina
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