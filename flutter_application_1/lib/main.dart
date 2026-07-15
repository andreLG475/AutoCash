// Importa o pacote principal do Flutter para Material Design
import 'package:flutter/material.dart';

// Importa as páginas de cadastro de veículos
import 'cadastro_veiculos.dart';
// Importa a página de cadastro de gastos/manutenção
import 'cadastro_gastos.dart';
// Importa a página de edição de perfil do usuário
import 'editar_usuario.dart';
// Importa a página de login
import 'login.dart';
// Importa a página de registro/cadastro
import 'registrar.dart';
// Importa a página de visualização de um gasto específico
import 'visualizacao_gasto.dart';
// Importa a página de visualização de gastos por veículo
import 'visualizar_veiculo.dart';
// Importa a página de testes de navegação
import 'exercise_all.dart';
// Importa o helper do banco de dados
import 'data/database_helper.dart';
// Importa o modelo de dados do carro
import 'models/car.dart';
// Importa o modelo de dados de gasto/manutenção
import 'models/gasto.dart';
// Importa o widget personalizado para exibir imagens
import 'widgets/image_display_widget.dart';
// Importa o widget de avatar do perfil
import 'widgets/profile_avatar.dart';
// Importa funções de formatação de texto e valores
import 'utils/formatters.dart';

// Função principal que inicia o aplicativo
Future<void> main() async {
  // Inicializa o binding do Flutter para usar plugins nativos
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o banco de dados antes de executar o app
  await DatabaseHelper.instance.initialize();
  // Executa o aplicativo MyApp
  runApp(const MyApp());
}

// Classe raiz do aplicativo que estende StatelessWidget (não muda de estado)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Verifica se existe um usuário logado verificando se há um ID de usuário atual
    final hasActiveSession = DatabaseHelper.instance.currentUserId != null;

    // Cria e retorna um MaterialApp com configurações do aplicativo
    return MaterialApp(
      // Remove o banner de debug que aparece no canto da tela
      debugShowCheckedModeBanner: false,
      // Define o título do aplicativo
      title: 'AutoCash',
      // Define o tema do aplicativo
      theme: ThemeData(
        // Cor primária vermelha
        primarySwatch: Colors.red,
        // Cor de fundo dos scaffolds em cinza claro
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      // Define a tela inicial: se tem sessão ativa, vai para MainScreen, senão para LoginPage
      home: hasActiveSession ? const MainScreen() : const LoginPage(),
      // Define rotas nomeadas para navegação entre telas
      routes: {
        // Rota para a página de login
        '/login': (context) => const LoginPage(),
        // Rota para a página de registro
        '/register': (context) => const RegisterPage(),
        // Rota para a tela principal (home)
        '/home': (context) => const MainScreen(),
        // Rota para a página de testes de navegação
        '/exercise': (context) => const ExerciseAllPage(),
        // Rota para a página de cadastro de veículos
        '/add-car': (context) => const CadastroVeiculosPage(),
        // Rota para a página de cadastro de gastos, recebendo um carro como argumento
        '/add-expense': (context) {
          // Obtém os argumentos passados na navegação
          final args = ModalRoute.of(context)!.settings.arguments;
          // Verifica se o argumento é um Car
          if (args is Car) {
            return CadastroGastosPage(car: args);
          }
          // Se não for, mostra uma mensagem de erro
          return const Scaffold(
            body: Center(child: Text('Veículo não encontrado')),
          );
        },
        // Rota para visualizar um gasto específico
        '/view-expense': (context) => const VisualizacaoGastoPage(),
        // Rota para visualizar os gastos de um veículo específico, recebendo um carro como argumento
        '/vehicle-expenses': (context) {
          // Obtém os argumentos passados na navegação
          final args = ModalRoute.of(context)!.settings.arguments;
          // Verifica se o argumento é um Car
          if (args is Car) {
            return VisualizarVeiculoPage(car: args);
          }
          // Se não for, mostra uma mensagem de erro
          return const Scaffold(
            body: Center(child: Text('Veículo não encontrado')),
          );
        },
        // Rota para a página de edição do perfil do usuário
        '/edit-user': (context) => const AccountPage(),
      },
    );
  }
}

// Classe que define a tela principal, que é um StatefulWidget (muda de estado)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Cria o estado da tela principal
  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Estado da classe MainScreen
class _MainScreenState extends State<MainScreen> {
  // Lista que armazena todos os carros do usuário
  List<Car> _carros = [];
  // Mapa que armazena os gastos por ID do carro
  final Map<int, List<Gasto>> _gastosPorCarro = {};
  // Variável que controla se está carregando dados
  bool _loading = true;

  // Método chamado quando o widget é inicializado
  @override
  void initState() {
    super.initState();
    // Carrega os dados dos carros quando a tela é aberta
    _loadCars();
  }

  // Método assíncrono que carrega todos os carros do banco de dados
  Future<void> _loadCars() async {
    // Busca todos os carros do usuário atual no banco de dados
    final carros = await DatabaseHelper.instance.getCars();
    // Lista para armazenar carros atualizados
    final carrosAtualizados = <Car>[];
    // Mapa para armazenar gastos organizados por carro
    final gastosPorCarro = <int, List<Gasto>>{};

    // Itera sobre cada carro
    for (final carro in carros) {
      // Verifica se o carro tem um ID válido
      if (carro.id != null) {
        // Sincroniza as métricas do carro com o banco de dados
        final updatedCar = await DatabaseHelper.instance.syncCarMetrics(
          carro.id!,
        );
        // Adiciona o carro atualizado à lista
        carrosAtualizados.add(updatedCar);
        // Obtém todos os gastos do carro e os armazena no mapa
        gastosPorCarro[carro.id!] = await DatabaseHelper.instance
            .getGastosByCarId(carro.id!);
      } else {
        // Se não tiver ID, apenas adiciona o carro como está
        carrosAtualizados.add(carro);
      }
    }

    // Atualiza o estado da tela com os dados carregados
    setState(() {
      // Substitui a lista de carros pela lista atualizada
      _carros = carrosAtualizados;
      // Limpa o mapa de gastos e adiciona os gastos carregados
      _gastosPorCarro
        ..clear()
        ..addAll(gastosPorCarro);
      // Define que o carregamento foi concluído
      _loading = false;
    });
  }

  // Método que calcula o gasto do mês atual para um carro específico
  double _calculateMonthlyExpense(int carId) {
    // Obtém os gastos do carro, ou uma lista vazia se não houver
    final gastos = _gastosPorCarro[carId] ?? [];
    // Obtém a data/hora atual
    final now = DateTime.now();
    // Cria uma chave de mês no formato "YYYY-MM"
    final currentMonthKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // Inicia o total em zero
    double total = 0;
    // Itera sobre cada gasto
    for (final gasto in gastos) {
      // Converte a data do gasto de string para DateTime
      final date = DateTime.tryParse(gasto.data);
      // Verifica se a data foi convertida com sucesso
      if (date != null) {
        // Cria a chave de mês do gasto no mesmo formato "YYYY-MM"
        final gastoMonthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';
        // Verifica se o gasto é do mês atual
        if (gastoMonthKey == currentMonthKey) {
          // Adiciona o valor do gasto ao total
          total += gasto.valor;
        }
      }
    }
    // Retorna o total de gastos do mês
    return total;
  }

  // Constrói a interface de usuário da tela principal
  @override
  Widget build(BuildContext context) {
    // Retorna um Scaffold que é a estrutura base de uma tela no Flutter
    return Scaffold(
      // Define a barra superior (AppBar) da aplicação
      appBar: AppBar(
        // Cor de fundo da barra: vermelho intenso
        backgroundColor: Colors.redAccent[700],
        // Elevação (sombra) da barra em 0
        elevation: 0,
        // Centraliza o título na barra
        centerTitle: true,
        // Define o título da barra como uma linha com logo e texto
        title: Row(
          // Define o tamanho mínimo para encaixar o conteúdo
          mainAxisSize: MainAxisSize.min,
          children: [
            // Widget Hero que anima o logo quando navegando entre telas
            Hero(
              // Identifica o widget para a animação
              tag: 'app_brand_icon',
              // Image.asset carrega a imagem do logo do projeto
              child: Image.asset(
                'assets/logo.png',
                // Altura do logo
                height: 20,
                // Largura do logo
                width: 20,
                // Ajusta a imagem para caber no espaço
                fit: BoxFit.contain,
                // Cor do logo (branco)
                color: Colors.white,
              ),
            ),
            // Espaço horizontal entre o logo e o texto
            SizedBox(width: 8),
            // Texto flexível que se adapta ao tamanho disponível
            Flexible(
              // Widget de texto que mostra "AutoCash"
              child: Text(
                'AutoCash',
                // Estilo do texto
                style: TextStyle(
                  // Cor branca
                  color: Colors.white,
                  // Texto em negrito
                  fontWeight: FontWeight.bold,
                  // Espaçamento entre letras
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),

        // Define o ícone à esquerda da barra (botão de logout)
        leading: IconButton(
          // Ícone de saída/logout
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          // Função executada quando o ícone é pressionado
          onPressed: () async {
            // Remove o ID do usuário atual do banco de dados (logout)
            await DatabaseHelper.instance.setCurrentUserId(null);
            // Verifica se o widget ainda está montado na árvore de widgets
            if (!mounted) return;
            // Verifica se o contexto ainda está válido
            if (!context.mounted) return;

            // Obtém o navigator (gerenciador de navegação) do contexto
            final navigator = Navigator.of(context);
            // Navega para login removendo todas as rotas anteriores
            navigator.pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
        // Define os ícones à direita da barra (ações)
        actions: [
          // Padding adiciona espaço ao redor do widget
          Padding(
            // Define o espaço só à direita
            padding: const EdgeInsets.only(right: 16.0),
            // InkWell adiciona efeito de toque/ripple ao widget
            child: InkWell(
              // Borda arredondada ao redor do widget
              borderRadius: BorderRadius.circular(20),
              // Função executada quando o widget é pressionado
              onTap: () {
                // Navega para a página de edição de perfil
                Navigator.pushNamed(context, '/edit-user');
              },
              // Widget que exibe o avatar do perfil do usuário
              child: const ProfileAvatar(
                // Raio do avatar
                radius: 18,
                // Cor de fundo fallback (transparente)
                fallbackColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
      // Define o corpo principal da tela
      body: Center(
        // Centraliza o conteúdo horizontalmente
        child: _loading
            // Se estiver carregando, mostra um indicador de progresso circular
            ? const CircularProgressIndicator()
            // Se não estiver carregando, mostra o conteúdo principal
            : ConstrainedBox(
                // Limita a largura máxima a 500 pixels (para telas grandes)
                constraints: const BoxConstraints(maxWidth: 500),
                // Verifica se há carros cadastrados
                child: _carros.isEmpty
                    // Se não houver carros, exibe uma mensagem e botão para adicionar
                    ? Padding(
                        // Espaço ao redor do conteúdo
                        padding: const EdgeInsets.all(24.0),
                        // Coluna que organiza o conteúdo verticalmente
                        child: Column(
                          // Ocupa apenas o espaço necessário
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Texto informando que não há veículos
                            const Text(
                              'Nenhum veículo cadastrado ainda.',
                              // Alinha o texto ao centro
                              textAlign: TextAlign.center,
                              // Estilo do texto
                              style: TextStyle(
                                // Tamanho da fonte
                                fontSize: 18,
                                // Texto em negrito
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Espaço vertical entre os widgets
                            const SizedBox(height: 16),
                            // Botão para adicionar o primeiro veículo
                            ElevatedButton(
                              // Função executada ao pressionar o botão
                              onPressed: () async {
                                // Navega para a página de cadastro de veículos
                                await Navigator.pushNamed(context, '/add-car');
                                // Recarrega a lista de carros após retornar
                                await _loadCars();
                              },
                              // Estilo do botão
                              style: ElevatedButton.styleFrom(
                                // Cor de fundo cinza claro
                                backgroundColor: Colors.grey[300],
                                // Cor do texto e ícone preta
                                foregroundColor: Colors.black,
                              ),
                              // Texto do botão
                              child: const Text('Cadastrar primeiro veículo'),
                            ),
                          ],
                        ),
                      )
                    // Se houver carros, exibe uma lista deles
                    : ListView.builder(
                        // Espaço ao redor da lista
                        padding: const EdgeInsets.all(16.0),
                        // Número de itens na lista (número de carros)
                        itemCount: _carros.length,
                        // Função que constrói cada item da lista
                        itemBuilder: (context, index) {
                          // Obtém o carro da posição atual
                          final carro = _carros[index];

                          // Retorna um Card para cada carro
                          return Card(
                            // Sombra do card
                            elevation: 4,
                            // Espaço abaixo de cada card
                            margin: const EdgeInsets.only(bottom: 24.0),
                            // Corta o conteúdo que excede a borda
                            clipBehavior: Clip.antiAlias,
                            // Forma do card com cantos arredondados
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // InkWell adiciona efeito de toque ao card
                            child: InkWell(
                              // Função executada ao tocar o card
                              onTap: () async {
                                // Navega para a página de gastos do veículo
                                await Navigator.pushNamed(
                                  context,
                                  '/vehicle-expenses',
                                  // Passa o carro como argumento
                                  arguments: carro,
                                );
                                // Recarrega a lista de carros ao retornar
                                _loadCars();
                              },
                              // Coluna que organiza os elementos do card verticalmente
                              child: Column(
                                // Estica o conteúdo horizontalmente
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Container com a informação do carro (marca e modelo)
                                  Container(
                                    // Cor de fundo vermelha
                                    color: Colors.redAccent[700],
                                    // Espaço interno do container
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 16.0,
                                    ),
                                    // Widget Wrap para envolver o conteúdo
                                    child: Wrap(
                                      // Alinha o conteúdo ao centro
                                      alignment: WrapAlignment.center,
                                      // Espaço horizontal entre elementos
                                      spacing: 12,
                                      // Espaço vertical entre linhas
                                      runSpacing: 8,
                                      children: [
                                        // Limita a largura do texto
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 220,
                                          ),
                                          // Texto com marca e modelo do carro
                                          child: Text(
                                            '${carro.marca} ${carro.modelo}',
                                            // Corta o texto se ultrapassar a largura
                                            overflow: TextOverflow.ellipsis,
                                            // Máximo de linhas do texto
                                            maxLines: 1,
                                            // Estilo do texto
                                            style: const TextStyle(
                                              // Cor branca
                                              color: Colors.white,
                                              // Tamanho da fonte
                                              fontSize: 20,
                                              // Texto em negrito
                                              fontWeight: FontWeight.bold,
                                              // Espaçamento entre letras
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Widget que exibe a imagem do carro
                                  ImageDisplay(
                                    // Caminho da imagem do carro
                                    imagePath: carro.image.isNotEmpty
                                        ? carro.image
                                        : null,
                                    // Altura da imagem
                                    height: 220,
                                    // Ícone padrão se não houver imagem
                                    defaultIcon: Icons.directions_car,
                                  ),
                                  // Container com informações de gasto
                                  Container(
                                    // Cor de fundo cinza
                                    color: Colors.grey[300],
                                    // Espaço interno
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 16.0,
                                    ),
                                    // Coluna com informações de gasto
                                    child: Column(
                                      // Alinha itens à esquerda
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Texto mostrando o gasto mensal
                                        Text(
                                          "GASTO MENSAL ATUAL: ${formatCurrency(_calculateMonthlyExpense(carro.id!))}",
                                          // Estilo do texto
                                          style: const TextStyle(
                                            // Cor preta
                                            color: Colors.black,
                                            // Texto em negrito
                                            fontWeight: FontWeight.bold,
                                            // Tamanho da fonte
                                            fontSize: 14,
                                          ),
                                        ),
                                        // Espaço vertical
                                        const SizedBox(height: 8),
                                        // Container com os últimos gastos
                                        Container(
                                          // Largura total disponível
                                          width: double.infinity,
                                          // Espaço interno
                                          padding: const EdgeInsets.all(10.0),
                                          // Decoração com cor de fundo cinza
                                          decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          // Builder constrói o conteúdo dinamicamente
                                          child: Builder(
                                            builder: (_) {
                                              // Obtém os gastos do carro
                                              final gastos =
                                                  _gastosPorCarro[carro.id!] ??
                                                  [];
                                              // Obtém apenas os 3 últimos gastos
                                              final ultimosGastos = gastos
                                                  .take(3)
                                                  .toList();
                                              // Verifica se há mais de 3 gastos
                                              final temMais = gastos.length > 3;

                                              // Se não há gastos, mostra uma mensagem
                                              if (ultimosGastos.isEmpty) {
                                                return const Text(
                                                  'Nenhuma manutenção registrada.',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 12,
                                                  ),
                                                );
                                              }

                                              // Se há gastos, mostra-os em uma coluna
                                              return Column(
                                                // Alinha itens à esquerda
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Itera sobre cada gasto e cria um widget de texto
                                                  ...ultimosGastos.map((gasto) {
                                                    return Padding(
                                                      // Espaço abaixo de cada gasto
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 4.0,
                                                          ),
                                                      // Texto com descrição e valor do gasto
                                                      child: Text(
                                                        '${gasto.descricao}: ${formatCurrency(gasto.valor)}',
                                                        // Estilo do texto
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                  // Se há mais de 3 gastos, mostra "outros..."
                                                  if (temMais)
                                                    const Padding(
                                                      // Espaço acima do texto "outros..."
                                                      padding: EdgeInsets.only(
                                                        top: 2.0,
                                                      ),
                                                      // Texto indicando que há mais gastos
                                                      child: Text(
                                                        'outros...',
                                                        // Estilo do texto
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
      // Botão de ação flutuante (FAB) para adicionar novo carro
      floatingActionButton: FloatingActionButton(
        // Função executada ao pressionar o botão
        onPressed: () async {
          // Navega para a página de cadastro de veículos
          await Navigator.pushNamed(context, '/add-car');
          // Recarrega a lista de carros após retornar
          await _loadCars();
        },
        // Cor de fundo do botão (cinza claro)
        backgroundColor: Colors.grey[300],
        // Cor do ícone e foreground (preta)
        foregroundColor: Colors.black,
        // Ícone do botão (ícone de mais/adicionar)
        child: const Icon(Icons.add),
      ),
    );
  }
}
