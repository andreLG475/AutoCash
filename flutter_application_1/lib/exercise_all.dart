import 'package:flutter/material.dart';

import 'data/database_helper.dart';

class ExerciseAllPage extends StatefulWidget {
  const ExerciseAllPage({super.key});

  @override
  State<ExerciseAllPage> createState() => _ExerciseAllPageState();
}

class _ExerciseAllPageState extends State<ExerciseAllPage> {
  String _status = 'Pronto para executar rota(s)';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSequence());
  }

  Future<void> _runSequence() async {
    if (!mounted) return;
    setState(() => _status = 'Iniciando sequência de navegação...');
    final navigator = Navigator.of(context);

    // Testar login
    if (!mounted) return;
    setState(() => _status = 'Abrindo /login');
    try {
      await navigator.pushNamed('/login');
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Falha ao navegar para /login: $e');
    }
    if (!mounted) return;
    try {
      Navigator.popUntil(context, ModalRoute.withName('/exercise'));
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 500));

    // Testar registro
    if (!mounted) return;
    setState(() => _status = 'Abrindo /register');
    try {
      await navigator.pushNamed('/register');
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Falha ao navegar para /register: $e');
    }
    if (!mounted) return;
    try {
      Navigator.popUntil(context, ModalRoute.withName('/exercise'));
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 500));

    // Testar home
    if (!mounted) return;
    setState(() => _status = 'Abrindo /home');
    try {
      await navigator.pushNamed('/home');
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Falha ao navegar para /home: $e');
    }
    if (!mounted) return;
    try {
      Navigator.popUntil(context, ModalRoute.withName('/exercise'));
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 500));

    // Testar cadastro de veículo
    if (!mounted) return;
    setState(() => _status = 'Abrindo /add-car');
    try {
      await navigator.pushNamed('/add-car');
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Falha ao navegar para /add-car: $e');
    }
    if (!mounted) return;
    try {
      Navigator.popUntil(context, ModalRoute.withName('/exercise'));
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 500));

    // Testar visualização de veículo (precisa de um Car)
    final cars = await DatabaseHelper.instance.getCars();
    if (cars.isNotEmpty) {
      if (!mounted) return;
      setState(() => _status = 'Abrindo /vehicle-expenses');
      try {
        await navigator.pushNamed('/vehicle-expenses', arguments: cars.first);
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        debugPrint('Falha ao navegar para /vehicle-expenses: $e');
      }
      if (!mounted) return;
      try {
        Navigator.popUntil(context, ModalRoute.withName('/exercise'));
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;
    setState(() => _status = 'Sequência finalizada');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise All Pages (debug)')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_status, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Abrir /login manualmente'),
            ),
          ],
        ),
      ),
    );
  }
}
