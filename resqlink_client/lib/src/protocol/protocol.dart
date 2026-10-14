/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:resqlink_client/src/protocol/emergency_request.dart'
    as _ifv5qcq0;
import 'package:resqlink_client/src/protocol/emergency_status_event.dart'
    as _ia4k3xal;
import 'package:resqlink_client/src/protocol/responder_profile.dart'
    as _icqjyfds;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i312scxx;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'admin_stats.dart' as _iqygks5s;
import 'auth_success.dart' as _iuzf6lt3;
import 'emergency_request.dart' as _ivz8201e;
import 'emergency_status_event.dart' as _i3j0xm4u;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'responder_profile.dart' as _i1qre5nj;
import 'user_profile.dart' as _ir2mn8w1;
export 'admin_stats.dart';
export 'auth_success.dart';
export 'emergency_request.dart';
export 'emergency_status_event.dart';
export 'greetings/greeting.dart';
export 'responder_profile.dart';
export 'user_profile.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iqygks5s.AdminStats) {
      return _iqygks5s.AdminStats.fromJson(data) as T;
    }
    if (t == _iuzf6lt3.AuthSuccess) {
      return _iuzf6lt3.AuthSuccess.fromJson(data) as T;
    }
    if (t == _ivz8201e.EmergencyRequest) {
      return _ivz8201e.EmergencyRequest.fromJson(data) as T;
    }
    if (t == _i3j0xm4u.EmergencyStatusEvent) {
      return _i3j0xm4u.EmergencyStatusEvent.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _i1qre5nj.ResponderProfile) {
      return _i1qre5nj.ResponderProfile.fromJson(data) as T;
    }
    if (t == _ir2mn8w1.UserProfile) {
      return _ir2mn8w1.UserProfile.fromJson(data) as T;
    }
    if (t == _isc.getType<_iqygks5s.AdminStats?>()) {
      return (data != null ? _iqygks5s.AdminStats.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iuzf6lt3.AuthSuccess?>()) {
      return (data != null ? _iuzf6lt3.AuthSuccess.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ivz8201e.EmergencyRequest?>()) {
      return (data != null ? _ivz8201e.EmergencyRequest.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i3j0xm4u.EmergencyStatusEvent?>()) {
      return (data != null
              ? _i3j0xm4u.EmergencyStatusEvent.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i1qre5nj.ResponderProfile?>()) {
      return (data != null ? _i1qre5nj.ResponderProfile.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ir2mn8w1.UserProfile?>()) {
      return (data != null ? _ir2mn8w1.UserProfile.fromJson(data) : null) as T;
    }
    if (t == List<_ifv5qcq0.EmergencyRequest>) {
      return (data as List)
              .map((e) => deserialize<_ifv5qcq0.EmergencyRequest>(e))
              .toList()
          as T;
    }
    if (t == List<_icqjyfds.ResponderProfile>) {
      return (data as List)
              .map((e) => deserialize<_icqjyfds.ResponderProfile>(e))
              .toList()
          as T;
    }
    if (t == List<_ia4k3xal.EmergencyStatusEvent>) {
      return (data as List)
              .map((e) => deserialize<_ia4k3xal.EmergencyStatusEvent>(e))
              .toList()
          as T;
    }
    try {
      return _i312scxx.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iqygks5s.AdminStats => 'AdminStats',
      _iuzf6lt3.AuthSuccess => 'AuthSuccess',
      _ivz8201e.EmergencyRequest => 'EmergencyRequest',
      _i3j0xm4u.EmergencyStatusEvent => 'EmergencyStatusEvent',
      _izw8z7ou.Greeting => 'Greeting',
      _i1qre5nj.ResponderProfile => 'ResponderProfile',
      _ir2mn8w1.UserProfile => 'UserProfile',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('resqlink.', '');
    }

    switch (data) {
      case _iqygks5s.AdminStats():
        return 'AdminStats';
      case _iuzf6lt3.AuthSuccess():
        return 'AuthSuccess';
      case _ivz8201e.EmergencyRequest():
        return 'EmergencyRequest';
      case _i3j0xm4u.EmergencyStatusEvent():
        return 'EmergencyStatusEvent';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _i1qre5nj.ResponderProfile():
        return 'ResponderProfile';
      case _ir2mn8w1.UserProfile():
        return 'UserProfile';
    }
    className = _i312scxx.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AdminStats') {
      return deserialize<_iqygks5s.AdminStats>(data['data']);
    }
    if (dataClassName == 'AuthSuccess') {
      return deserialize<_iuzf6lt3.AuthSuccess>(data['data']);
    }
    if (dataClassName == 'EmergencyRequest') {
      return deserialize<_ivz8201e.EmergencyRequest>(data['data']);
    }
    if (dataClassName == 'EmergencyStatusEvent') {
      return deserialize<_i3j0xm4u.EmergencyStatusEvent>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'ResponderProfile') {
      return deserialize<_i1qre5nj.ResponderProfile>(data['data']);
    }
    if (dataClassName == 'UserProfile') {
      return deserialize<_ir2mn8w1.UserProfile>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i312scxx.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _i312scxx.Protocol().registerHostProtocol('resqlink', this);
  }

  @override
  String getModuleName() => 'resqlink';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i312scxx.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
