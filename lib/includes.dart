
import './networking/networking.dart';
import './utils/utils.dart';

export './models/models.dart';
export './networking/networking.dart';
export './utils/utils.dart';

Future<void> init() async {
  await initConfig();
  await initLocalDb();
}
