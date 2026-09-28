import 'package:flutter_test/flutter_test.dart';
import 'package:tecnomarket/main.dart';

void main() {
  testWidgets('TecnoMarket S.A.C. smoke test', (WidgetTester tester) async {
    // Verificar que la aplicación cargue la pantalla principal correctamente
    await tester.pumpWidget(const TecnoMarketApp());
    expect(find.text('TecnoMarket S.A.C.'), findsWidgets);
    expect(find.text('Productos tecnológicos'), findsWidgets);
    expect(find.text('Clientes'), findsWidgets);
    expect(find.text('Servicios técnicos'), findsWidgets);
  });
}
