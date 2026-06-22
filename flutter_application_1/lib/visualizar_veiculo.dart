import 'package:flutter/material.dart';

class VeiculoGastosScreen extends StatefulWidget {
  const VeiculoGastosScreen({super.key});

  @override
  State<VeiculoGastosScreen> createState() => _VeiculoGastosScreenState();
}

class _VeiculoGastosScreenState extends State<VeiculoGastosScreen> {
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
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Gastos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              // Ação de sair
            },
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero / SizedBox
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Card do veículo
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Column(
                        children: [
                          // Cabeçalho vermelho com nome do veículo
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'PEUGEOT 206',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),

                          // Imagem do veículo com Stack + Positioned (botão editar)
                          Stack(
                            children: [
                              Image.asset(
                                'assets/images/peugeot206.jpg',
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.directions_car,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white70,
                                  child: const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Gastos resumo
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 12,
                                  ),
                                  color: Colors.grey[200],
                                  child: const Text(
                                    'GASTO MENSAL ATUAL:R\$ 500,00',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 12,
                                  ),
                                  color: Colors.grey[200],
                                  child: const Text(
                                    'GASTO POR KM:R\$ 20,00',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Lista de gastos individuais
                                ..._gastos.map(
                                  (gasto) => Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${gasto['descricao']}: ${gasto['valor']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // ExpansionTile - Junho 2026
                                ExpansionTile(
                                  title: const Text(
                                    'Junho 2026',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 16,
                                  ),
                                  children: const [
                                    ListTile(
                                      title: Text('Nenhum gasto registrado.'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ElevatedButton - ADICIONAR GASTO
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Ação de adicionar gasto
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
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

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}