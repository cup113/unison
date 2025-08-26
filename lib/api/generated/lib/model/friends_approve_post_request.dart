//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FriendsApprovePostRequest {
  /// Returns a new [FriendsApprovePostRequest] instance.
  FriendsApprovePostRequest({
    required this.id,
  });

  String id;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FriendsApprovePostRequest &&
    other.id == id;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode);

  @override
  String toString() => 'FriendsApprovePostRequest[id=$id]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    return json;
  }

  /// Returns a new [FriendsApprovePostRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FriendsApprovePostRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FriendsApprovePostRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FriendsApprovePostRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FriendsApprovePostRequest(
        id: mapValueOfType<String>(json, r'id')!,
      );
    }
    return null;
  }

  static List<FriendsApprovePostRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FriendsApprovePostRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FriendsApprovePostRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FriendsApprovePostRequest> mapFromJson(dynamic json) {
    final map = <String, FriendsApprovePostRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FriendsApprovePostRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FriendsApprovePostRequest-objects as value to a dart map
  static Map<String, List<FriendsApprovePostRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FriendsApprovePostRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FriendsApprovePostRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
  };
}

