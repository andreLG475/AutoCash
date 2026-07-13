import 'package:flutter/material.dart';

import 'data/database_helper.dart';
import 'models/car.dart';
import 'models/gasto.dart';
import 'services/expense_logic.dart';
import 'services/media_service.dart';
import 'widgets/image_display_widget.dart';
import 'utils/formatters.dart';

class VisualizarVeiculoPage extends StatefulWidget {
  const VisualizarVeiculoPage({super.key, required this.car});

  final Car car;

  @override
  State<VisualizarVeiculoPage> createState() => _VisualizarVeiculoPageState();
}

class _VisualizarVeiculoPageState extends State<VisualizarVeiculoPage> {
  final Map<String, List<Gasto>> _gastosPorMes = {};
  Car? _currentCar;
  String? _mesSelecionado;
  double _monthlyTotal = 0.0;
  double _costPerKm = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGastos();
  }

  Future<void> _loadGastos() async {
    if (widget.car.id == null) return;

    final refreshedCar = await DatabaseHelper.instance.syncCarMetrics(
      widget.car.id!,
      referenceDate: DateTime.now(),
    );
    final gastos = await DatabaseHelper.instance.getGastosByCarId(
      widget.car.id!,
    );
    final gastosPorMes = <String, List<Gasto>>{};
    for (final gasto in gastos) {
      final date = DateTime.tryParse(gasto.data);
      final key = date == null
          ? 'sem-data'
          : '${date.year.toString()}-${date.month.toString().padLeft(2, '0')}';
      gastosPorMes.putIfAbsent(key, () => []).add(gasto);
    }

    final sortedKeys = gastosPorMes.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    final mesSelecionado =
        _mesSelecionado != null && gastosPorMes.containsKey(_mesSelecionado)
        ? _mesSelecionado
        : (sortedKeys.isNotEmpty ? sortedKeys.first : null);
    final gastosDoMesSelecionado = mesSelecionado == null
        ? <Gasto>[]
        : gastosPorMes[mesSelecionado] ?? <Gasto>[];
    final totalMonthly = gastosDoMesSelecionado.fold<double>(
      0.0,
      (sum, gasto) => sum + gasto.valor,
    );
    final totalSpent = gastos.fold<double>(
      0.0,
      (sum, gasto) => sum + gasto.valor,
    );
    final costPerKm = calculateCostPerKm(
      totalSpent: totalSpent,
      initialKm: refreshedCar.kmInicial,
      currentKm: refreshedCar.km,
    );

    setState(() {
      _currentCar = refreshedCar;
      _gastosPorMes
        ..clear()
        ..addAll(gastosPorMes);
      _mesSelecionado = mesSelecionado;
      _monthlyTotal = totalMonthly;
      _costPerKm = costPerKm;
      _loading = false;
    });
  }

  String _formatarMes(String key) {
    if (key == 'sem-data') {
      return 'Sem data';
    }

    final parts = key.split('-');
    if (parts.length != 2) {
      return key;
    }

    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 1;
    final date = DateTime(year, month);
    return '${_nomeMes(date.month)} ${date.year}';
  }

  String _nomeMes(int mes) {
    const nomes = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return nomes[mes - 1];
  }

  Future<void> _updateCarImageFromMedia(String mediaPath) async {
    if (!mounted) return;

    final savedPath = await MediaService.persistMediaFile(
      mediaPath,
      subFolder: 'cars',
    );
    if (savedPath == null) return;

    final updatedCar = (_currentCar ?? widget.car).copy(image: savedPath);
    await DatabaseHelper.instance.updateCar(updatedCar);

    if (!mounted) return;
    setState(() => _currentCar = updatedCar);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto do veículo atualizada!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _changeCarImage() async {
    final sheet = showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text('Tirar foto'),
              onTap: () async {
                if (!mounted) return;
                Navigator.pop(sheetContext);
                final mediaPath = await MediaService.takePhotoFromCamera();
                if (mediaPath != null) {
                  await _updateCarImageFromMedia(mediaPath);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.redAccent),
              title: const Text('Escolher da galeria'),
              onTap: () async {
                if (!mounted) return;
                Navigator.pop(sheetContext);
                final mediaPath = await MediaService.pickPhotoFromGallery();
                if (mediaPath != null) {
                  await _updateCarImageFromMedia(mediaPath);
                }
              },
            ),
          ],
        ),
      ),
    );

    await sheet;
  }

  Future<void> _confirmDeleteGasto(Gasto gasto) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação'),
        content: Text('Deseja realmente excluir o gasto "${gasto.descricao}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (gasto.id == null) return;

    await DatabaseHelper.instance.deleteGasto(gasto.id!);

    final carId = _currentCar?.id ?? widget.car.id;
    if (carId != null) {
      await DatabaseHelper.instance.syncCarMetrics(
        carId,
        referenceDate: DateTime.now(),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gasto excluído com sucesso'),
        backgroundColor: Colors.green,
      ),
    );

    await _loadGastos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                (_currentCar ?? widget.car).modelo,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
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
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text(
                  'Excluir veículo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                content: Text(
                  'Tem certeza que deseja apagar o veículo ${widget.car.marca} ${widget.car.modelo}?',
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      if (widget.car.id != null) {
                        await DatabaseHelper.instance.deleteCar(widget.car.id!);
                      }
                      if (!mounted) return;
                      navigator.pop();
                      if (!mounted) return;
                      navigator.pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        child: const Icon(Icons.delete),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                color: Colors.redAccent[700],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      (_currentCar ?? widget.car).marca,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      (_currentCar ?? widget.car).modelo,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Stack(
                                children: [
                                  ImageDisplay(
                                    imagePath:
                                        (_currentCar ?? widget.car)
                                            .image
                                            .isNotEmpty
                                        ? (_currentCar ?? widget.car).image
                                        : null,
                                    height: 220,
                                    defaultIcon: Icons.directions_car,
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    right: 12,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: const Color.fromRGBO(
                                        158,
                                        158,
                                        158,
                                        0.9,
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.black54,
                                          size: 20,
                                        ),
                                        onPressed: () async {
                                          await _changeCarImage();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Container(
                                color: Colors.grey[400],
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      "Gasto mensal deste mês: ${formatCurrency(_monthlyTotal)}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Gasto por KM: ${formatCurrency(_costPerKm)}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),

                                    Text(
                                      'Ano: ${(_currentCar ?? widget.car).ano}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Quilometragem: ${(_currentCar ?? widget.car).km}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    ExpansionTile(
                                      tilePadding: EdgeInsets.zero,
                                      title: const Text(
                                        'Selecionar mês',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      children: [
                                        if (_gastosPorMes.isEmpty)
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Text(
                                              'Nenhum gasto registrado.',
                                            ),
                                          )
                                        else
                                          ..._gastosPorMes.keys
                                              .toList()
                                              .toList()
                                              .map((key) {
                                                final gastosDoMes =
                                                    _gastosPorMes[key] ??
                                                    <Gasto>[];
                                                final totalDoMes = gastosDoMes
                                                    .fold<double>(
                                                      0.0,
                                                      (sum, gasto) =>
                                                          sum + gasto.valor,
                                                    );
                                                return ListTile(
                                                  dense: true,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 2.0,
                                                      ),
                                                  title: Text(
                                                    _formatarMes(key),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    'Total: ${formatCurrency(totalDoMes)}',
                                                  ),
                                                  trailing:
                                                      _mesSelecionado == key
                                                      ? const Icon(
                                                          Icons.check_circle,
                                                          color:
                                                              Colors.redAccent,
                                                        )
                                                      : const Icon(
                                                          Icons.chevron_right,
                                                        ),
                                                  onTap: () {
                                                    setState(() {
                                                      _mesSelecionado = key;
                                                      _monthlyTotal =
                                                          totalDoMes;
                                                    });
                                                  },
                                                );
                                              }),
                                      ],
                                    ),

                                    const SizedBox(height: 12),
                                    Text(
                                      _mesSelecionado == null
                                          ? 'Nenhum mês selecionado'
                                          : 'Exibindo: ${_formatarMes(_mesSelecionado!)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    ...(_mesSelecionado == null
                                            ? <Gasto>[]
                                            : _gastosPorMes[_mesSelecionado!] ??
                                                  <Gasto>[])
                                        .map((gasto) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: Material(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                          context,
                                                          '/view-expense',
                                                          arguments: gasto,
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 12.0,
                                                              horizontal: 16.0,
                                                            ),
                                                        child: Text(
                                                          "${gasto.descricao}: ${formatCurrency(gasto.valor)}",
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.redAccent,
                                                    ),
                                                    onPressed: () =>
                                                        _confirmDeleteGasto(
                                                          gasto,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),

                                    const SizedBox(height: 4),
                                    if ((_mesSelecionado == null
                                            ? <Gasto>[]
                                            : _gastosPorMes[_mesSelecionado!] ??
                                                  <Gasto>[])
                                        .isEmpty)
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(16.0),
                                        child: const Text(
                                          'Nenhum gasto registrado para este mês.',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
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

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/add-expense',
                                arguments: _currentCar ?? widget.car,
                              );
                              _loadGastos();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
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
