import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/helpers/operator_data.dart';
import 'package:avis_donation_management/pages/account_page.dart';
import 'fake_components/fake_app_info.dart';
import 'fake_components/fake_connection_status_controller.dart';
import 'fake_components/fake_operator_session.dart';

void main() {
  group('AccountPage', () {
    late FakeAppInfo fakeAppInfo;
    late FakeConnectionStatus fakeConnectionStatus;
    late FakeOperatorSession fakeOperatorSession;

    setUp(() {
      fakeAppInfo = FakeAppInfo();
      fakeConnectionStatus = FakeConnectionStatus();
      final operatorData = OperatorData(
        id: '123',
        authUserId: 'auth123',
        firstName: 'Mario',
        lastName: 'Rossi',
        nickname: 'Marietto',
        isActive: true,
        isAdmin: false,
        createdAt: DateTime.parse('2024-05-01T10:00:00Z'),
        createdBy: 'c1',
        createdByFirstName: 'Anna',
        createdByLastName: 'Bianchi',
        createdByNickname: 'annina',
        updatedAt: DateTime.parse('2024-05-10T12:00:00Z'),
        updatedBy: 'u1',
        updatedByFirstName: 'Luca',
        updatedByLastName: 'Verdi',
        updatedByNickname: '',
        deletedAt: null,
        deletedBy: null,
        deletedByFirstName: null,
        deletedByLastName: null,
        deletedByNickname: null,
      );
      fakeOperatorSession =
          FakeOperatorSession(initialized: true, data: operatorData);
    });

    tearDown(() async {
      fakeConnectionStatus.dispose();
      fakeOperatorSession.dispose();
    });

    testWidgets('find the expected title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (_) => AccountPage(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Gestione Account Operatore'), findsOneWidget);
    });
  });
}
