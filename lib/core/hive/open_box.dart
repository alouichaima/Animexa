import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<Box> openBox(String boxName) async {
  if (!Hive.isBoxOpen(boxName)) {
    Hive.init((await getApplicationDocumentsDirectory()).path);
  }
  return await Hive.openBox(boxName);
}
