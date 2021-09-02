import 'dart:core';

Map<String, dynamic> removeNullsFromMap(Map<String, dynamic> json) => json
  ..removeWhere((String key, dynamic value) => value == null)
  ..map<String, dynamic>((key, value) => MapEntry(key, removeNulls(value)));

List removeNullsFromList(List list) => list
  ..removeWhere((value) => value == null)
  ..map(removeNulls).toList();

dynamic removeNulls(dynamic e) => (e is List)
    ? removeNullsFromList(e)
    : (e is Map ? removeNullsFromMap(e as Map<String, dynamic>) : e);

extension ListExtension on List {
  List removeNulls() => removeNullsFromList(this);
}

extension MapExtension on Map {
  Map removeNulls() => removeNullsFromMap(this as Map<String, dynamic>);
}
