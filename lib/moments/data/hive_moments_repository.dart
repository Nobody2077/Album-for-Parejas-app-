import 'package:hive_ce/hive.dart';

import '../models/custom_moment.dart';
import 'moments_repository.dart';

/// Implementación de [MomentsRepository] sobre un box de Hive.
class HiveMomentsRepository implements MomentsRepository {
  HiveMomentsRepository(this._box);

  final Box<CustomMoment> _box;

  @override
  List<CustomMoment> getAll() {
    final all = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  @override
  Future<void> save(CustomMoment moment) => _box.put(moment.id, moment);

  @override
  Future<void> delete(String id) => _box.delete(id);
}
