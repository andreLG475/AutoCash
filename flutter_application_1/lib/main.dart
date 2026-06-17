import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> carros = [
      {
        "nome": "PEUGEOT 206",
        "imagem": "https://i.pinimg.com/1200x/37/83/0b/37830b80bb58fdbbe09550abe626b796.jpg", // Link temporário simulando o image.asset
        "gasto": "500",
        "detalhes": [
          "Troca de óleo: R\$ 10,00",
          "Pneus novos: R\$ 200,00",
          "Vitrificação do farol: R\$ 100,00",
          "Outros: R\$ 190,00"
        ]
      },
      {
        "nome": "PEUGEOT 208",
        "imagem": "https://i.pinimg.com/736x/4e/39/82/4e39824343598a34100c493feda8b05c.jpg",
        "gasto": "500",
        "detalhes": [
          "Troca de óleo: R\$ 10,00",
          "Pneus novos: R\$ 200,00",
          "Vitrificação do farol: R\$ 100,00",
          "Outros: R\$ 190,00"
        ]
      },
      {
        "nome": "PEUGEOT 306",
        "imagem": "https://onlycars.com.br/wp-content/uploads/2013/02/306.jpg",
        "gasto": "500",
        "detalhes": [
          "Troca de óleo: R\$ 10,00",
          "Pneus novos: R\$ 200,00",
          "Vitrificação do farol: R\$ 100,00",
          "Outros: R\$ 190,00"
        ]
      },
    ];

    // Estrutura Base: Scaffold
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.account_circle, color: Colors.white, size: 35),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: carros.length,
        itemBuilder: (context, index) {
          final carro = carros[index];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 24.0),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.redAccent[700],
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    carro["nome"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                Image.network(
                  carro["imagem"],
                  height: 220,
                  fit: BoxFit.cover,
                ),

                Container(
                  color: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                    "GASTO MENSAL ATUAL: R\$ ${carro['gasto']}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                Container(
                  color: Colors.grey[400],
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: carro["detalhes"].map<Widget>((detalhe) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          detalhe,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}