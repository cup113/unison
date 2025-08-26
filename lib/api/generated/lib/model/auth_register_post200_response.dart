//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AuthRegisterPost200Response {
  /// Returns a new [AuthRegisterPost200Response] instance.
  AuthRegisterPost200Response({
    required this.token,
    required this.user,
  });

  String token;

  AuthRegisterPost200ResponseUser user;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthRegisterPost200Response &&
    other.token == token &&
    other.user == user;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (token.hashCode) +
    (user.hashCode);

  @override
  String toString() => 'AuthRegisterPost200Response[token=$token, user=$user]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'token'] = this.token;
      json[r'user'] = this.user;
    return json;
  }

  /// Returns a new [AuthRegisterPost200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AuthRegisterPost200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AuthRegisterPost200Response[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AuthRegisterPost200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AuthRegisterPost200Response(
        token: mapValueOfType<String>(json, r'token')!,
        user: AuthRegisterPost200ResponseUser.fromJson(json[r'user'])!,
      );
    }
    return null;
  }

  static List<AuthRegisterPost200Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuthRegisterPost200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuthRegisterPost200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AuthRegisterPost200Response> mapFromJson(dynamic json) {
    final map = <String, AuthRegisterPost200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AuthRegisterPost200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AuthRegisterPost200Response-objects as value to a dart map
  static Map<String, List<AuthRegisterPost200Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AuthRegisterPost200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AuthRegisterPost200Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'token',
    'user',
  };
}

