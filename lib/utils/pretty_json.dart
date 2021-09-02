import 'dart:convert';

String prettyJsonString(dynamic json) {
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  String jsonString = encoder.convert(json);

  return jsonString;
}
