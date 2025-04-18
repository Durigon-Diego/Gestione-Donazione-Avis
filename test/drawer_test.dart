import 'package:flutter/material.dart'; import 'package:flutter_test/flutter_test.dart'; import 'package:avis_donor_app/helpers/avis_drawer.dart'; import 'package:avis_donor_app/helpers/operator_session.dart';

void main() { testWidgets('drawer mostra elementi base per operatore non admin', (tester) async { OperatorSession.name = 'Mario'; OperatorSession.isActive = true; OperatorSession.isAdmin = false;

await tester.pumpWidget(const MaterialApp(
  home: Scaffold(
    drawer: AvisDrawer(),
    body: Text('Home'),
  ),
));

await tester.tap(find.byIcon(Icons.menu));
await tester.pumpAndSettle();

expect(find.text('Gestione Account'), findsOneWidget);
expect(find.text('Donazione'), findsOneWidget);
expect(find.text('Gestione Operatori'), findsNothing);
expect(find.text('Gestione Giornate Donazioni'), findsNothing);

});

testWidgets('drawer mostra voci admin se isAdmin=true', (tester) async { OperatorSession.name = 'Admin'; OperatorSession.isActive = true; OperatorSession.isAdmin = true;

await tester.pumpWidget(const MaterialApp(
  home: Scaffold(
    drawer: AvisDrawer(),
    body: Text('Home'),
  ),
));

await tester.tap(find.byIcon(Icons.menu));
await tester.pumpAndSettle();

expect(find.text('Gestione Operatori'), findsOneWidget);
expect(find.text('Gestione Giornate Donazioni'), findsOneWidget);

}); }

