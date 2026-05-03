import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cut_convert/main.dart';

void main() {
  testWidgets('Verifica se o app inicializa e mostra o título CutConvert', (WidgetTester tester) async {
    // Constrói o app dentro de um ProviderScope, pois o Riverpod é necessário.
    await tester.pumpWidget(
      const ProviderScope(
        child: CutConvertApp(),
      ),
    );

    // Verifica se o título principal do app está presente na tela inicial.
    expect(find.text('CutConvert'), findsAtLeastNWidgets(1));
    
    // Verifica se as opções de menu básicas estão visíveis.
    expect(find.text('Converter Mídia'), findsOneWidget);
    expect(find.text('Cortar Mídia'), findsOneWidget);
  });
}
