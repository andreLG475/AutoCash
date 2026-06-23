import 'package:flutter/material.dart';

class ExerciseAllPage extends StatefulWidget {
  const ExerciseAllPage({super.key});

  @override
  State<ExerciseAllPage> createState() => _ExerciseAllPageState();
}

class _ExerciseAllPageState extends State<ExerciseAllPage> {
  final List<String> _routes = [
    '/login',
    '/register',
    '/home',
    '/add-car',
    '/add-expense',
    '/view-expense',
    '/vehicle-expenses',
  ];

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
    for (final route in _routes) {
      if (!mounted) return;
      setState(() => _status = 'Abrindo $route');
      try {
        await navigator.pushNamed(route);
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('Falha ao navegar para $route: $e');
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
