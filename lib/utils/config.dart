import 'dart:io';
import 'package:yaml/yaml.dart';

Future<void> initConfig() async {
  final String jsonString = File('config.yaml').readAsStringSync();
  final YamlMap json = loadYaml(jsonString);
  Config.instance.parse(json);
}

class Config {
  Config._();

  /// The shared instance of [Config].
  static final Config instance = Config._();

  void parse(YamlMap json) {
    env = json['env'] as String;
    githubToken = json['githubToken'] as String;
  }

  String env;
  String githubToken;
}
