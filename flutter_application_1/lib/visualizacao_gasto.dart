// Importa pacote Material Design do Flutter
import 'package:flutter/material.dart';

// Importa modelo de dados de gasto/despesa
import 'models/gasto.dart';
// Importa funções de lógica de gastos
import 'services/expense_logic.dart';
// Importa widget para exibir imagens
import 'widgets/image_display_widget.dart';
// Importa funções de formatação
import 'utils/formatters.dart';

// Classe que exibe os detalhes de um gasto específico - é um StatefulWidget
class VisualizacaoGastoPage extends StatefulWidget {
  const VisualizacaoGastoPage({super.key});

  @override
  State<VisualizacaoGastoPage> createState() => _VisualizacaoGastoPageState();
}

// Estado da página de visualização de gasto
class _VisualizacaoGastoPageState extends State<VisualizacaoGastoPage> {
  // Armazena o objeto de gasto sendo exibido
  Gasto? _gasto;

  // Chamado quando as dependências mudam (por exemplo, quando o widget é criado)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carrega o gasto passado como argumento
    _loadGasto();
  }

  // Método que carrega o gasto dos argumentos da navegação
  void _loadGasto() {
    // Obtém os argumentos passados via navegação
    final args = ModalRoute.of(context)?.settings.arguments;
    // Se o argumento é um objeto Gasto, atualiza o estado
    if (args is Gasto) {
      setState(() {
        _gasto = args;
      });
    }
  }

  // Constrói a interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Barra superior vermelha
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700],
        elevation: 0,
        centerTitle: true,
        // Botão de voltar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // Título com logo e texto
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
                'Manutenção',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        // Ações na barra (logout e perfil)
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
      // Corpo da página com scroll
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo de descrição da manutenção
                    _buildDisplayField(
                      label: 'Manutenção:',
                      value: _gasto?.descricao ?? '',
                    ),
                    const SizedBox(height: 16),

                    // Campo de valor gasto formatado em moeda
                    _buildDisplayField(
                      label: 'Valor gasto:',
                      value: _gasto != null
                          ? formatCurrency(_gasto!.valor)
                          : '',
                    ),
                    const SizedBox(height: 16),

                    // Campo de data da manutenção formatado
                    _buildDisplayField(
                      label: 'Data:',
                      value: formatDateFromStorage(_gasto?.data),
                    ),
                    const SizedBox(height: 16),

                    // Campo de quilometragem do veículo
                    _buildDisplayField(
                      label: 'Kilomentragem do veiculo:',
                      value: _gasto?.quilometragem.toString() ?? '',
                    ),
                    const SizedBox(height: 16),

                    // Campo de descrição detalhada (opcional)
                    _buildDisplayField(
                      label: 'Descrição:',
                      value: _gasto?.descricaoDetalhada ?? '',
                    ),
                    const SizedBox(height: 16),

                    // Seção de nota fiscal
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
                        // Widget que exibe imagem ou arquivo PDF
                        FileDisplay(filePath: _gasto?.notaFiscal, height: 180),
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

  // Widget helper que constrói um campo de exibição (somente leitura)
  Widget _buildDisplayField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rótulo do campo
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
        // Container com o texto do valor
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black54,
              width: 1,
            ),
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
