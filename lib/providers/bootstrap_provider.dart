import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bootstrap_data.dart';

final bootstrapDataProvider = Provider<BootstrapData>((ref) {
  throw StateError('bootstrapDataProvider must be overridden in main()');
});
