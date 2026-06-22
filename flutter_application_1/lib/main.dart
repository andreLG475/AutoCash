import 'package:flutter/material.dart';
import 'adicionar_carro.dart';
import 'adicionar_pagamento.dart';
import 'login.dart';
import 'registrar.dart';
import 'visualizar_pagamento.dart';
import 'visualizar_veiculo.dart';
import 'exercise_all.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoCash',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      initialRoute: kDebugMode ? '/exercise' : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MainScreen(),
        '/exercise': (context) => const ExerciseAllPage(),
        '/add-car': (context) => const AddCarPage(),
        '/add-expense': (context) => const AddExpensePage(),
        '/view-expense': (context) => const ViewExpensePage(),
        '/vehicle-expenses': (context) => const VeiculoGastosScreen(),
      },
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
        "imagem": "https://i.pinimg.com/1200x/37/83/0b/37830b80bb58fdbbe09550abe626b796.jpg",
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700],
        elevation: 0,
        // Centraliza o título na AppBar
        centerTitle: true,
        // Nome do aplicativo no centro
        title: const Text(
          "autocash",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          onPressed: () {
            print("Botão Sair clicado");
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                print("Perfil/Avatar clicado! Ir para página de perfil no futuro.");
              },
              child: const CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.account_circle, color: Colors.white, size: 35),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: ListView.builder(
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
                child: InkWell(
                  onTap: () {
                    print("Card do ${carro['nome']} clicado! Abrindo detalhes...");
                    Navigator.pushNamed(context, '/vehicle-expenses');
                  },
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
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-car');
        },
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}