import '../../../includes.dart';

import '../local_db.dart';

class AppsModifier {
  final DbData dbData;

  AppsModifier(this.dbData);

  String _name;

  void setName(String name) {
    _name = name;
  }

  int get _appIndex {
    return dbData.appList.indexWhere((e) => e.name == _name);
  }

  List<App> get _appList {
    return dbData.appList;
  }

  List<App> list({
    bool where(App element),
  }) {
    if (where != null) {
      return _appList.where(where).toList();
    }
    return _appList;
  }

  App get() {
    if (exists()) {
      return _appList[_appIndex];
    }
    return null;
  }

  bool exists() {
    return _appIndex != -1;
  }
}
