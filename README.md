# AutoCash

Aplicativo Flutter para controle financeiro e gestão de gastos relacionados a veículos.

## Visão geral

O AutoCash permite registrar veículos, cadastrar despesas associadas a cada carro, acompanhar o gasto mensal e manter documentos como notas fiscais ou fotos diretamente no app.

## Funcionalidades principais

- Cadastro e gerenciamento de veículos
- Registro de gastos por veículo
- Preenchimento automático de data e quilometragem ao cadastrar um gasto
- Upload de nota fiscal por câmera, galeria ou arquivo
- Visualização de despesas e histórico por veículo
- Autenticação de usuário com login e cadastro
- Persistência local com SQLite
- Interface responsiva para Android, iOS, Windows e Web

## Tecnologias utilizadas

- Flutter
- Dart
- SQLite
- Provider/Stateful widgets nativos do Flutter
- Pacotes adicionais para mídia, arquivos e persistência

## Requisitos

- Flutter SDK 3.9 ou superior
- Dart SDK compatível com o Flutter instalado
- Emulador ou dispositivo físico para execução
- Permissões de câmera e armazenamento conforme o sistema operacional

## Como executar o projeto

1. Acesse a pasta do projeto:
   ```bash
   cd flutter_application_1
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Execute o app:
   ```bash
   flutter run
   ```

4. Para uma plataforma específica:
   ```bash
   flutter run -d android
   flutter run -d windows
   ```

## Estrutura principal

- lib/main.dart: ponto de entrada e navegação principal
- lib/cadastro_veiculos.dart: cadastro de veículos
- lib/cadastro_gastos.dart: cadastro de despesas
- lib/visualizar_veiculo.dart: visualização detalhada de um veículo
- lib/visualizacao_gasto.dart: visualização de gastos
- lib/data/: camada de acesso a dados e SQLite
- lib/models/: modelos de domínio
- lib/services/: regras de negócio e integração com mídia
- lib/widgets/: componentes reutilizáveis

## Funcionalidades de mídia

O app permite anexar arquivos nas telas de cadastro de gasto e veículo. As opções incluem:

- Tirar foto com a câmera
- Escolher imagem da galeria
- Importar arquivos como PDF ou outros formatos

## Testes

Para executar os testes do projeto:

```bash
flutter test
```

## Observações

- Os dados são armazenados localmente para uso offline.
- Arquivos multimídia podem ser salvos conforme o fluxo de seleção do sistema operacional.
- A documentação adicional de implementação pode ser consultada no arquivo IMPLEMENTATION_SUMMARY.md.

## Licença

Este projeto é de uso acadêmico e de desenvolvimento interno, sujeito às regras do repositório e do ambiente em que estiver sendo utilizado.
