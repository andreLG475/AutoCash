import 'package:flutter/material.dart';

import 'cadastro_veiculos.dart';
import 'cadastro_gastos.dart';
import 'editar_usuario.dart';
import 'login.dart';
import 'registrar.dart';
import 'visualizacao_gasto.dart';
import 'visualizar_veiculo.dart';
import 'exercise_all.dart';
import 'data/database_helper.dart';
import 'models/car.dart';
import 'models/gasto.dart';
import 'widgets/image_display_widget.dart';
import 'widgets/profile_avatar.dart';
import 'utils/formatters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hasActiveSession = DatabaseHelper.instance.currentUserId != null;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoCash',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: hasActiveSession ? const MainScreen() : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MainScreen(),
        '/exercise': (context) => const ExerciseAllPage(),
        '/add-car': (context) => const CadastroVeiculosPage(),
        '/add-expense': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is Car) {
            return CadastroGastosPage(car: args);
          }
          return const Scaffold(
            body: Center(child: Text('Veículo não encontrado')),
          );
        },
        '/view-expense': (context) => const VisualizacaoGastoPage(),
        '/vehicle-expenses': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is Car) {
            return VisualizarVeiculoPage(car: args);
          }
          return const Scaffold(
            body: Center(child: Text('Veículo não encontrado')),
          );
        },
        '/edit-user': (context) => const AccountPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Car> _carros = [];
  final Map<int, List<Gasto>> _gastosPorCarro = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    final carros = await DatabaseHelper.instance.getCars();
    final carrosAtualizados = <Car>[];
    final gastosPorCarro = <int, List<Gasto>>{};

    for (final carro in carros) {
      if (carro.id != null) {
        final updatedCar = await DatabaseHelper.instance.syncCarMetrics(
          carro.id!,
        );
        carrosAtualizados.add(updatedCar);
        gastosPorCarro[carro.id!] = await DatabaseHelper.instance
            .getGastosByCarId(carro.id!);
      } else {
        carrosAtualizados.add(carro);
      }
    }

    setState(() {
      _carros = carrosAtualizados;
      _gastosPorCarro
        ..clear()
        ..addAll(gastosPorCarro);
      _loading = false;
    });
  }

  /// Calcula o gasto do mês atual para um carro
  double _calculateMonthlyExpense(int carId) {
    final gastos = _gastosPorCarro[carId] ?? [];
    final now = DateTime.now();
    final currentMonthKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    double total = 0;
    for (final gasto in gastos) {
      final date = DateTime.tryParse(gasto.data);
      if (date != null) {
        final gastoMonthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';
        if (gastoMonthKey == currentMonthKey) {
          total += gasto.valor;
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'AutoCash',
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
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          onPressed: () async {
            await DatabaseHelper.instance.setCurrentUserId(null);
            if (!mounted) return;
            if (!context.mounted) return;

            final navigator = Navigator.of(context);
            navigator.pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.pushNamed(context, '/edit-user');
              },
              child: const ProfileAvatar(
                radius: 18,
                fallbackColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: _carros.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Nenhum veículo cadastrado ainda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.pushNamed(context, '/add-car');
                                await _loadCars();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Cadastrar primeiro veículo'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _carros.length,
                        itemBuilder: (context, index) {
                          final carro = _carros[index];

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 24.0),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/vehicle-expenses',
                                  arguments: carro,
                                );
                                _loadCars();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    color: Colors.redAccent[700],
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 12,
                                      runSpacing: 8,
                                      children: [
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 220,
                                          ),
                                          child: Text(
                                            '${carro.marca} ${carro.modelo}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ImageDisplay(
                                    imagePath: carro.image.isNotEmpty
                                        ? carro.image
                                        : null,
                                    height: 220,
                                    defaultIcon: Icons.directions_car,
                                  ),
                                  Container(
                                    color: Colors.grey[300],
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "GASTO MENSAL ATUAL: ${formatCurrency(_calculateMonthlyExpense(carro.id!))}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Builder(
                                            builder: (_) {
                                              final gastos =
                                                  _gastosPorCarro[carro.id!] ??
                                                  [];
                                              final ultimosGastos = gastos
                                                  .take(3)
                                                  .toList();
                                              final temMais = gastos.length > 3;

                                              if (ultimosGastos.isEmpty) {
                                                return const Text(
                                                  'Nenhuma manutenção registrada.',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 12,
                                                  ),
                                                );
                                              }

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ...ultimosGastos.map((gasto) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 4.0,
                                                          ),
                                                      child: Text(
                                                        '${gasto.descricao}: ${formatCurrency(gasto.valor)}',
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                  if (temMais)
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                        top: 2.0,
                                                      ),
                                                      child: Text(
                                                        'outros...',
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
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
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-car');
          await _loadCars();
        },
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
