import 'package:flutter/material.dart';

class VisualizarVeiculoPage extends StatefulWidget {
  const VisualizarVeiculoPage({super.key});

  @override
  State<VisualizarVeiculoPage> createState() => _VisualizarVeiculoPageState();
}

class _VisualizarVeiculoPageState extends State<VisualizarVeiculoPage> {
  final List<Map<String, String>> _gastos = [
    {'descricao': 'Troca de oleo', 'valor': 'R\$ 50,00'},
    {'descricao': 'Troca de Motor', 'valor': 'R\$ 150,00'},
    {'descricao': 'Troca de Pneus', 'valor': 'R\$ 100,00'},
    {'descricao': 'Calibração de pneus', 'valor': 'R\$ 15,00'},
    {'descricao': '5L de gasolina', 'valor': 'R\$ 35,00'},
    {'descricao': 'Cortar as molas', 'valor': 'R\$ 150,00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Cor de fundo idêntica à MainScreen
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700], // Mesma cor vermelha da MainScreen
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Gastos",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5, // Mantém o padrão estético do título de cima
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
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500, // Alinhamento responsivo idêntico à MainScreen
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Estrutura Base - Card do Veículo
                  Card(
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cabeçalho do Card
                        Container(
                          color: Colors.redAccent[700],
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: const Text(
                            "PEUGEOT 206",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        // Stack + Positioned para imagem e botão flutuante de edição
                        Stack(
                          children: [
                            Container(
                              height: 220,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.directions_car,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color.fromRGBO(158, 158, 158, 0.9),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.edit, color: Colors.black54, size: 20),
                                  onPressed: () {
                                    debugPrint("Editar imagem clicado");
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Container de fundo cinza unificado para os gastos
                        Container(
                          color: Colors.grey[400],
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "GASTO MENSAL ATUAL: R\$ 500,00",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "GASTO POR KM: R\$ 20,00",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Lista Dinâmica de Gastos Individuais Clicáveis
                              ..._gastos.map((gasto) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Material(
                                    color: Colors.grey[300], // Cor das cápsulas internas
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        Navigator.pushNamed(context, '/view-expense');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12.0,
                                          horizontal: 16.0,
                                        ),
                                        child: Text(
                                          "${gasto['descricao']}: ${gasto['valor']}",
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              const SizedBox(height: 4),

                              // ExpansionTile customizado para remover bordas indesejadas
                              Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const ExpansionTile(
                                    title: Text(
                                      'Junho 2026',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      ListTile(
                                        title: Text('Nenhum gasto adicional registrado.'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botão Adicionar Gasto na parte inferior externa do Card
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add-expense');
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}