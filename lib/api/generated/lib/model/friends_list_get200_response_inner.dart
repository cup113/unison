//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FriendsListGet200ResponseInner {
  /// Returns a new [FriendsListGet200ResponseInner] instance.
  FriendsListGet200ResponseInner({
    required this.id,
    this.updated,
    required this.name,
    required this.accepted,
    required this.refuseReason,
    required this.acceptable,
    required this.relationId,
  });

  String id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? updated;

  String name;

  bool accepted;

  String refuseReason;

  bool acceptable;

  String relationId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FriendsListGet200ResponseInner &&
    other.id == id &&
    other.updated == updated &&
    other.name == name &&
    other.accepted == accepted &&
    other.refuseReason == refuseReason &&
    other.acceptable == acceptable &&
    other.relationId == relationId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (updated == null ? 0 : updated!.hashCode) +
    (name.hashCode) +
    (accepted.hashCode) +
    (refuseReason.hashCode) +
    (acceptable.hashCode) +
    (relationId.hashCode);

  @override
  String toString() => 'FriendsListGet200ResponseInner[id=$id, updated=$updated, name=$name, accepted=$accepted, refuseReason=$refuseReason, acceptable=$acceptable, relationId=$relationId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.updated != null) {
      json[r'updated'] = this.updated;
    } else {
      json[r'updated'] = null;
    }
      json[r'name'] = this.name;
      json[r'accepted'] = this.accepted;
      json[r'refuseReason'] = this.refuseReason;
      json[r'acceptable'] = this.acceptable;
      json[r'relationId'] = this.relationId;
    return json;
  }

  /// Returns a new [FriendsListGet200ResponseInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FriendsListGet200ResponseInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FriendsListGet200ResponseInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FriendsListGet200ResponseInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FriendsListGet200ResponseInner(
        id: mapValueOfType<String>(json, r'id')!,
        updated: mapValueOfType<String>(json, r'updated'),
        name: mapValueOfType<String>(json, r'name')!,
        accepted: mapValueOfType<bool>(json, r'accepted')!,
        refuseReason: mapValueOfType<String>(json, r'refuseReason')!,
        acceptable: mapValueOfType<bool>(json, r'acceptable')!,
        relationId: mapValueOfType<String>(json, r'relationId')!,
      );
    }
    return null;
  }

  static List<FriendsListGet200ResponseInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FriendsListGet200ResponseInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FriendsListGet200ResponseInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FriendsListGet200ResponseInner> mapFromJson(dynamic json) {
    final map = <String, FriendsListGet200ResponseInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FriendsListGet200ResponseInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FriendsListGet200ResponseInner-objects as value to a dart map
  static Map<String, List<FriendsListGet200ResponseInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FriendsListGet200ResponseInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FriendsListGet200ResponseInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'accepted',
    'refuseReason',
    'acceptable',
    'relationId',
  };
}

