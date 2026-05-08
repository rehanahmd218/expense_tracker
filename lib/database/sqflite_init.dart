import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Registers [databaseFactory] for the current platform.
///
/// On mobile, plugin registration can be skipped after a hot restart; calling
/// [SqflitePlugin.registerWith] ensures the default factory exists.
void initializeSqflite() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {
    SqflitePlugin.registerWith();
  }
}
