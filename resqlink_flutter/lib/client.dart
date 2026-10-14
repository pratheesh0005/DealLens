import 'dart:async';

import 'package:resqlink_client/resqlink_client.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

final serverUrl = getServerUrl();

late final Client client;
late final SessionManager sessionManager;

Future<void> initializeClient() async {
  client = Client(await serverUrl)
    ..authKeyProvider = FlutterAuthenticationKeyManager()
    ..connectivityMonitor = FlutterConnectivityMonitor();

  sessionManager = SessionManager(
    caller: client.modules.auth,
  );
  await sessionManager.initialize();
}
