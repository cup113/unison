//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FriendsRefusePostRequest {
  /// Returns a new [FriendsRefusePostRequest] instance.
  FriendsRefusePostRequest({
    required this.relation,
    required this.reason,
  });

  String relation;

  String reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FriendsRefusePostRequest &&
    other.relation == relation &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (relation.hashCode) +
    (reason.hashCode);

  @override
  String toString() => 'FriendsRefusePostRequest[relation=$relation, reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'relation'] = this.relation;
      json[r'reason'] = this.reason;
    return json;
  }

  /// Returns a new [FriendsRefusePostRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FriendsRefusePostRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FriendsRefusePostRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FriendsRefusePostRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FriendsRefusePostRequest(
        relation: mapValueOfType<String>(json, r'relation')!,
        reason: mapValueOfType<String>(json, r'reason')!,
      );
    }
    return null;
  }

  static List<FriendsRefusePostRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FriendsRefusePostRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FriendsRefusePostRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FriendsRefusePostRequest> mapFromJson(dynamic json) {
    final map = <String, FriendsRefusePostRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FriendsRefusePostRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FriendsRefusePostRequest-objects as value to a dart map
  static Map<String, List<FriendsRefusePostRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FriendsRefusePostRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FriendsRefusePostRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'relation',
    'reason',
  };
}

