import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/helpers/operator_data.dart';

void main() {
  group('OperatorData', () {
    final testMap = {
      'id': '123',
      'auth_user_id': 'auth123',
      'first_name': 'Mario',
      'last_name': 'Rossi',
      'nickname': 'Marietto',
      'active': true,
      'is_admin': false,
      'created_at': '2024-05-01T10:00:00Z',
      'created_by': 'c1',
      'created_by_first_name': 'Anna',
      'created_by_last_name': 'Bianchi',
      'created_by_nickname': 'annina',
      'updated_at': '2024-05-10T12:00:00Z',
      'updated_by': 'u1',
      'updated_by_first_name': 'Luca',
      'updated_by_last_name': 'Verdi',
      'updated_by_nickname': '',
      'deleted_at': null,
      'deleted_by': null,
      'deleted_by_first_name': null,
      'deleted_by_last_name': null,
      'deleted_by_nickname': null,
    };

    test('fromMap creates object correctly and exposes all values', () {
      final data = OperatorData.fromMap(testMap);

      expect(data.id, equals('123'));
      expect(data.authUserId, equals('auth123'));
      expect(data.firstName, equals('Mario'));
      expect(data.lastName, equals('Rossi'));
      expect(data.nickname, equals('Marietto'));
      expect(data.isActive, isTrue);
      expect(data.isAdmin, isFalse);

      expect(data.createdAt.toUtc().toIso8601String(),
          equals('2024-05-01T10:00:00.000Z'));
      expect(data.createdBy, equals('c1'));
      expect(data.createdByFirstName, equals('Anna'));
      expect(data.createdByLastName, equals('Bianchi'));
      expect(data.createdByNickname, equals('annina'));
      expect(data.createdByName, equals('Anna Bianchi (annina)'));

      expect(data.updatedAt.toUtc().toIso8601String(),
          equals('2024-05-10T12:00:00.000Z'));
      expect(data.updatedBy, equals('u1'));
      expect(data.updatedByFirstName, equals('Luca'));
      expect(data.updatedByLastName, equals('Verdi'));
      expect(data.updatedByNickname, equals(''));
      expect(data.updatedByName, equals('Luca Verdi'));

      expect(data.deletedAt, isNull);
      expect(data.deletedBy, isNull);
      expect(data.deletedByFirstName, isNull);
      expect(data.deletedByLastName, isNull);
      expect(data.deletedByNickname, isNull);
      expect(data.deletedByName, isNull);
    });

    test('formatName works with and without nickname', () {
      expect(
        OperatorData.formatName('Anna', 'Bianchi', 'annina'),
        equals('Anna Bianchi (annina)'),
      );
      expect(
        OperatorData.formatName('Luca', 'Verdi', ''),
        equals('Luca Verdi'),
      );
      expect(
        OperatorData.formatName('Luca', 'Verdi', null),
        equals('Luca Verdi'),
      );
    });

    test('name getter returns formatted full name', () {
      final data = OperatorData.fromMap(testMap);
      expect(data.name, equals('Mario Rossi (Marietto)'));
    });

    test('createdByName/updaterName/deletedByName handle null values', () {
      final map = Map<String, dynamic>.from(testMap);
      map['created_by'] = null;
      map['created_by_first_name'] = null;
      map['created_by_last_name'] = null;
      map['created_by_nickname'] = null;
      map['updated_by'] = null;
      map['updated_by_first_name'] = null;
      map['updated_by_last_name'] = null;
      map['updated_by_nickname'] = null;
      map['deleted_by'] = 'd1';
      map['deleted_by_first_name'] = 'Giulia';
      map['deleted_by_last_name'] = 'Neri';
      map['deleted_by_nickname'] = 'giuli';

      final data = OperatorData.fromMap(map);

      expect(data.createdByFirstName, isNull);
      expect(data.createdByLastName, isNull);
      expect(data.createdByNickname, isNull);
      expect(data.createdByName, isNull);
      expect(data.updatedByFirstName, isNull);
      expect(data.updatedByLastName, isNull);
      expect(data.updatedByNickname, isNull);
      expect(data.updatedByName, isNull);
      expect(data.deletedByFirstName, equals('Giulia'));
      expect(data.deletedByLastName, equals('Neri'));
      expect(data.deletedByNickname, equals('giuli'));
      expect(data.deletedByName, equals('Giulia Neri (giuli)'));
    });
  });
}
