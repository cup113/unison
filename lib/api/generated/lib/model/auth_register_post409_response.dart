//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AuthRegisterPost409Response {
  /// Returns a new [AuthRegisterPost409Response] instance.
  AuthRegisterPost409Response({
    required this.code,
    required this.message,
  });

  String code;

  String message;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthRegisterPost409Response &&
    other.code == code &&
    other.message == message;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (message.hashCode);

  @override
  String toString() => 'AuthRegisterPost409Response[code=$code, message=$message]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'message'] = this.message;
    return json;
  }

  /// Returns a new [AuthRegisterPost409Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AuthRegisterPost409Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AuthRegisterPost409Response[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AuthRegisterPost409Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AuthRegisterPost409Response(
        code: mapValueOfType<String>(json, r'code')!,
        message: mapValueOfType<String>(json, r'message')!,
      );
    }
    return null;
  }

  static List<AuthRegisterPost409Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuthRegisterPost409Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuthRegisterPost409Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AuthRegisterPost409Response> mapFromJson(dynamic json) {
    final map = <String, AuthRegisterPost409Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AuthRegisterPost409Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AuthRegisterPost409Response-objects as value to a dart map
  static Map<String, List<AuthRegisterPost409Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AuthRegisterPost409Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AuthRegisterPost409Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'message',
  };
}

