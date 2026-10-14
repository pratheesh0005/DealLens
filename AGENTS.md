# ResQLink — Real-Time Community Emergency Response Platform

ResQLink is a full-stack emergency response and first-responder coordination platform built with Flutter and Serverpod 4.x.

## Core Features & Architecture
- **Citizen SOS Portal**: 1-tap categorized emergency dispatch with auto GPS telemetry, idempotency keys, real-time audit event stream, and live status tracking.
- **Responder Dispatch Console**: Live on/off duty status toggle, live GPS telemetry pinging, real-time dispatch alerts, and a 4-stage lifecycle transition stepper (Accepted -> En Route -> Arrived -> Resolved).
- **Incident Command Center (Admin)**: Real-time telemetry KPI dashboard (active incidents, matching queue, fleet readiness, resolved incidents), incident feed with status filtering, and administrative force-resolution override.
- **Smart Matching Engine**: Haversine distance calculation and fairness scoring to automatically route emergency calls to the optimal nearby available responder.
- **Serverpod 4 Real-time Streaming**: Full duplex streaming methods over Serverpod MessageCentral channels (`emergency_$id`, `emergency_feed`, `responder_$id`).
- **Data Persistence**: PostgreSQL database with Serverpod ORM models (`user_profiles`, `responder_profiles`, `emergency_requests`, `emergency_status_events`).

## Serverpod & Flutter Development

This project is a Flutter app (frontend) backed by a Serverpod server (backend). Always build the app's backend with Serverpod.

The user starts the server and Flutter app with `serverpod start`. There is no need to check if the server is running: make the changes and call the `serverpod` MCP tools as needed. If the server is not running, an informative error message will be received from the MCP server. Then STOP and ask the user to start it. NEVER start the server yourself. The Flutter app is started along with it, or can be launched from the MCP tool `spawn_flutter_app`.

While running, `serverpod start` watches for file changes to run incremental code generation and hot reload both the server and the Flutter app.

Calling `serverpod generate` directly is not needed, but might be useful to troubleshoot when an incremental generation fails.

ALWAYS use the MCP server instead of the command line. Use the MCP server to:

- `tail_server_logs` to read logs from the server.
- `tail_flutter_logs` to read the raw stdout/stderr of the Flutter app.
- `hot_reload` / `hot_restart` to reload or restart the server and the Flutter app. ALWAYS call `hot_restart` after doing changes in the Flutter app that may not work with normal hot reload (which is automatically applied).
- `spawn_flutter_app` to start a Flutter app declared under `serverpod: flutter_apps:` in the server `pubspec.yaml`.
- `get_flutter_app_dtd` (Dart tooling daemon) for connecting to the app through the `dart` MCP.

NEVER edit generated code. The server's `lib/src/generated/` directory and the whole `resqlink_client` package are rewritten by the code generator. Change the `.spy.yaml` models, the endpoints, or `lib/server.dart` instead.

Only when the server cannot be started at all, fall back to the CLI in the server package:

- `serverpod generate` to regenerate the client and the generated server code.

Checklist after doing changes, in this order:

- `dart analyze` (CLI)
- `dart format` (CLI)
- Do `serverpod` MCP `hot_restart` if required (hot reload is done automatically). Will also hot restart Flutter app
- Run tests, if applicable (`dart test` in the server package)
- Check `serverpod` MCP `tail_server_logs` and `tail_flutter_logs` for any issues.

If the user asks you to test the app:

1. Use `get_flutter_app_dtd` (`serverpod` MCP) to get the Flutter app's DTD
2. Pass the DTD to `connect_dart_tooling_daemon` (`dart` MCP) to connect to the app
3. Use `flutter_driver` (`dart` MCP) to navigate through the app

The app is launched from `resqlink_flutter/lib/driver.dart`, which starts the Flutter driver extension with text entry emulation turned off so the app stays usable by hand. To let the driver type, set `enableTextEntryEmulation: true` there and `hot_restart` the app.
