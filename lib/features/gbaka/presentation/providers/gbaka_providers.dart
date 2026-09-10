import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_gbaka_repository.dart';
import '../../domain/transit_line.dart';

final gbakaRepositoryProvider = Provider((ref) => MockGbakaRepository());

final linesProvider = FutureProvider.family<List<TransitLine>, LineMode?>((ref, mode) {
  return ref.read(gbakaRepositoryProvider).lines(mode: mode);
});

final lineDetailProvider = FutureProvider.family<TransitLine, String>((ref, id) {
  return ref.read(gbakaRepositoryProvider).lineDetail(id);
});
