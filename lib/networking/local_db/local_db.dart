import 'dart:convert';
import 'dart:io';

import 'package:pub_api_client/pub_api_client.dart';
import 'package:yaml/yaml.dart';
import 'package:github/github.dart';

import '../../includes.dart';
import 'modifiers/apps_modifier.dart';
import 'modifiers/packages_modifier.dart';

export 'modifiers/apps_modifier.dart';
export 'modifiers/packages_modifier.dart';

class LocalDb {
  final DbData defaultDbData;

  LocalDb({
    this.defaultDbData,
  });

  DbData dbData;

  Map<String, dynamic> _cacheMap = {};

  PubClient _pubClient;
  GitHub _githubClient;

  AppsModifier _appsModifier;
  PackagesModifier _packagesModifier;

  PubClient get pubClient {
    if (_pubClient == null) _pubClient = PubClient();
    return _pubClient;
  }

  GitHub get githubClient {
    if (_githubClient == null) {
      _githubClient = GitHub(
        auth: Authentication.withToken(sharedConfig.githubToken),
      );
    }
    return _githubClient;
  }

  Future<List<App>> _readAppList(String fileName) async {
    File file = File('./source/$fileName');
    String content = file.readAsStringSync();
    var doc = loadYaml(content);

    if (doc == null) return [];

    List<App> appList = [];
    for (var item in doc) {
      App app = App.fromJson(Map<String, dynamic>.from(item));

      String cacheKey = 'github#${app.repo}';
      Repository repository;
      if (_cacheMap.containsKey(cacheKey)) {
        repository = Repository.fromJson(_cacheMap[cacheKey]);
      } else {
        repository = await githubClient.repositories.getRepository(
          RepositorySlug(app.repo.split('/')[0], app.repo.split('/')[1]),
        );
        _cacheMap.putIfAbsent(cacheKey, () => repository.toJson());
      }
      app.description = repository.description;
      appList.add(app);
    }
    return appList;
  }

  Future<List<Package>> _readPackageList(String fileName) async {
    File file = File('./source/$fileName');
    String content = file.readAsStringSync();
    var doc = loadYaml(content);

    List<Package> packageList = [];
    for (var item in doc) {
      Package package = Package.fromJson(Map<String, dynamic>.from(item));

      String cacheKey = 'pub#${package.name}';

      PubPackage pubPackage;
      if (_cacheMap.containsKey(cacheKey)) {
        pubPackage = PubPackage.fromJson(_cacheMap[cacheKey]);
      } else {
        pubPackage = await pubClient.packageInfo(package.name);
        _cacheMap.update(
          cacheKey,
          (_) => pubPackage.toJson(),
          ifAbsent: () => pubPackage.toJson(),
        );
      }

      package.description = pubPackage.description;
      packageList.add(package);
    }
    return packageList;
  }

  Future<DbData> read() async {
    this.dbData = defaultDbData;

    File _cacheFile = File('.cache.json');
    if (_cacheFile.existsSync()) {
      String cacheJsonString = await _cacheFile.readAsString();
      _cacheMap = json.decode(cacheJsonString);
    }

    List<App> closedSourceAppList;
    List<App> openSourceAppList;
    List<Package> packageList;

    closedSourceAppList = await _readAppList('closed-source-apps.yaml');
    openSourceAppList = await _readAppList('open-source-apps.yaml');
    packageList = await _readPackageList('packages.yaml');

    this.dbData.appList = []
      ..addAll(closedSourceAppList)
      ..addAll(openSourceAppList);
    this.dbData.packageList = packageList;

    final String cacheJsonString = prettyJsonString(_cacheMap);
    _cacheFile.writeAsStringSync(cacheJsonString);

    return this.dbData;
  }

  AppsModifier get apps {
    return app(null);
  }

  AppsModifier app(String name) {
    if (_appsModifier == null) {
      _appsModifier = AppsModifier(this.dbData);
    }
    _appsModifier.setName(name);
    return _appsModifier;
  }

  PackagesModifier get packages {
    return package(null);
  }

  PackagesModifier package(String name) {
    if (_packagesModifier == null) {
      _packagesModifier = PackagesModifier(this.dbData);
    }
    _packagesModifier.setName(name);
    return _packagesModifier;
  }
}

class DbData {
  List<App> appList;
  List<Package> packageList;

  DbData({
    this.appList,
    this.packageList,
  });

  factory DbData.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    List<App> appList = [];
    List<Package> packageList = [];

    if (json['appList'] != null) {
      Iterable l = json['appList'] as List;
      appList = l.map((item) => App.fromJson(item)).toList();
    }
    if (json['packageList'] != null) {
      Iterable l = json['packageList'] as List;
      packageList = l.map((item) => Package.fromJson(item)).toList();
    }

    return DbData(
      appList: appList,
      packageList: packageList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appList': (appList ?? []).map((e) => e.toJson()).toList(),
      'packageList': (packageList ?? []).map((e) => e.toJson()).toList(),
    };
  }
}

LocalDb sharedLocalDb = LocalDb(
  defaultDbData: DbData(
    appList: [],
    packageList: [],
  ),
);

Future<void> initLocalDb() async {
  await sharedLocalDb.read();
}
