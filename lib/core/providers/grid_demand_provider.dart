import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grid_demand_reading.dart';
import '../services/grid_demand_service.dart';

/// Polls Nova Scotia Power's public report without blocking the forecast.
final liveGridDemandProvider = StreamProvider<GridDemandStatus>((ref) {
  return GridDemandService().watchLatest();
});
