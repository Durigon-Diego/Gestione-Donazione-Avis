import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:avis_donor_app/helpers/connection_status_controller.dart';
import 'fake_components/fake_app_info.dart';

class FakeInternetConnection extends Mock implements InternetConnection {}

class FakeWebSocketChannel extends Mock implements WebSocketChannel {}

class _FakeWebSocketSink extends Mock implements WebSocketSink {}

void main() {
  group('ConnectionStatusController', () {
    late FakeInternetConnection fakeInternet;

    setUp(() {
      fakeInternet = FakeInternetConnection();
      when(() => fakeInternet.internetStatus)
          .thenAnswer((_) async => InternetStatus.connected);
      when(() => fakeInternet.onStatusChange)
          .thenAnswer((_) => const Stream.empty());
      when(() => fakeInternet.checkInterval)
          .thenReturn(const Duration(milliseconds: 10));
    });

    test('initial state is disconnected before init', () {
      final controller = ConnectionStatusController(
        appInfo: FakeAppInfo(),
        internetChecker: fakeInternet,
      );
      expect(controller.state, ConnectionStatus.disconnected);
    });

    test('init sets initial state based on internet status', () async {
      final controller = ConnectionStatusController(
        appInfo: FakeAppInfo(),
        internetChecker: fakeInternet,
      );
      await controller.init();
      expect(controller.state, ConnectionStatus.supabaseOffline);
      controller.dispose();
    });

    testWidgets('reacts to internet disconnected and reconnected',
        (tester) async {
      final controllerStream = StreamController<InternetStatus>.broadcast();
      final socket = FakeWebSocketChannel();
      final sink = _FakeWebSocketSink();

      when(() => fakeInternet.onStatusChange)
          .thenAnswer((_) => controllerStream.stream);
      when(() => fakeInternet.internetStatus)
          .thenAnswer((_) async => InternetStatus.connected);
      when(() => socket.stream).thenAnswer((_) => const Stream.empty());
      when(() => socket.sink).thenReturn(sink);
      when(() => sink.add(any())).thenReturn(null);
      when(() => sink.close()).thenAnswer((_) async => null);

      final controller = ConnectionStatusController(
        appInfo: FakeAppInfo(),
        internetChecker: fakeInternet,
        connectWebSocket: (_) => socket,
      );

      await controller.init();

      controllerStream.add(InternetStatus.disconnected);
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.disconnected);

      controllerStream.add(InternetStatus.connected);
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.supabaseOffline);

      controller.dispose();
      await controllerStream.close();
    });

    test('dispose works safely after init', () async {
      final controller = ConnectionStatusController(
        appInfo: FakeAppInfo(),
        internetChecker: fakeInternet,
      );
      await controller.init();
      controller.dispose();
    });

    testWidgets('WebSocket events: connected, closed, error', (tester) async {
      final socketStream = StreamController<dynamic>.broadcast();
      final socket = FakeWebSocketChannel();
      final sink = _FakeWebSocketSink();

      when(() => socket.stream).thenAnswer((_) => socketStream.stream);
      when(() => socket.sink).thenReturn(sink);
      when(() => sink.add(any())).thenReturn(null);
      when(() => sink.close()).thenAnswer((_) async => null);

      final controller = ConnectionStatusController(
        appInfo: FakeAppInfo(),
        internetChecker: fakeInternet,
        connectWebSocket: (_) => socket,
      );

      await controller.init();

      socketStream.add('some data');
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.connected);

      socketStream.addError('socket error');
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.supabaseOffline);

      socketStream.add('some data');
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.connected);

      when(() => socket.closeCode).thenReturn(42);
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.supabaseOffline);

      await socketStream.close();
      controller.dispose();
    });

    testWidgets('full state transition sequence', (tester) async {
      final internetStream = StreamController<InternetStatus>.broadcast();
      final socketStream = StreamController<dynamic>.broadcast();
      final socket = FakeWebSocketChannel();
      final sink = _FakeWebSocketSink();

      when(() => fakeInternet.onStatusChange)
          .thenAnswer((_) => internetStream.stream);
      when(() => fakeInternet.internetStatus)
          .thenAnswer((_) async => InternetStatus.connected);
      when(() => socket.stream).thenAnswer((_) => socketStream.stream);
      when(() => socket.sink).thenReturn(sink);
      when(() => sink.add(any())).thenReturn(null);
      when(() => sink.close()).thenAnswer((_) async => null);

      final controller = ConnectionStatusController(
        appInfo: FakeAppInfo(),
        internetChecker: fakeInternet,
        connectWebSocket: (_) => socket,
      );

      await controller.init();

      internetStream.add(InternetStatus.disconnected);
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.disconnected);

      internetStream.add(InternetStatus.connected);
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.supabaseOffline);

      socketStream.add('data');
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.connected);

      internetStream.add(InternetStatus.disconnected);
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.disconnected);

      internetStream.add(InternetStatus.connected);
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.supabaseOffline);

      socketStream.add('data');
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.connected);

      socketStream.addError('error');
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.supabaseOffline);

      socketStream.add('data');
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.connected);

      await socketStream.close();
      await internetStream.close();
      controller.dispose();
    });

    testWidgets('WebSocket connect throws exception', (tester) async {
      when(() => fakeInternet.internetStatus)
          .thenAnswer((_) async => InternetStatus.connected);
      when(() => fakeInternet.onStatusChange)
          .thenAnswer((_) => const Stream.empty());
      when(() => fakeInternet.checkInterval)
          .thenReturn(const Duration(milliseconds: 10));

      final controller = ConnectionStatusController(
        appInfo: FakeAppInfo(),
        internetChecker: fakeInternet,
        connectWebSocket: (_) => throw Exception('Connection failed'),
      );

      await controller.init();
      await tester.pump(const Duration(milliseconds: 20));
      controller.dispose();
    });

    testWidgets('WebSocket sink.add throws exception', (tester) async {
      final internetStream = StreamController<InternetStatus>.broadcast();
      final socketStream = StreamController<dynamic>.broadcast();
      final socket = FakeWebSocketChannel();
      final sink = _FakeWebSocketSink();

      bool checkReceived = false;

      when(() => fakeInternet.onStatusChange)
          .thenAnswer((_) => internetStream.stream);
      when(() => fakeInternet.internetStatus)
          .thenAnswer((_) async => InternetStatus.connected);
      when(() => socket.stream).thenAnswer((_) => socketStream.stream);
      when(() => socket.sink).thenReturn(sink);
      when(() => sink.add(any())).thenAnswer((_) {
        checkReceived = true;
      });
      when(() => sink.close()).thenAnswer((_) async => null);

      final controller = ConnectionStatusController(
        appInfo: FakeAppInfo(),
        internetChecker: fakeInternet,
        connectWebSocket: (_) => socket,
      );

      await controller.init();
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.supabaseOffline);
      expect(checkReceived, true);

      checkReceived = false;
      socketStream.add('data');
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.connected);
      expect(checkReceived, true);

      when(() => sink.add(any())).thenThrow(Exception('sink error'));
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.state, ConnectionStatus.supabaseOffline);

      controller.dispose();
    });

    test('default internetChecker initialization', () async {
      final controller = ConnectionStatusController(
        appInfo: FakeAppInfo(),
      );

      expect(controller, isNotNull);
      await controller.init();
      controller.dispose();
    });
  });
}
