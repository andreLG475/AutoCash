import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('renderiza a tela de login ao iniciar o app', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('LOGIN'), findsAtLeastNWidgets(1));
    expect(find.text('Não possui conta? Cadastre-se'), findsOneWidget);
  });
}
