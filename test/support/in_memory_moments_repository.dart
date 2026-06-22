import 'package:album_app/moments/data/moments_repository.dart';
import 'package:album_app/moments/models/custom_moment.dart';

/// Implementación en memoria de [MomentsRepository] para widget tests
/// (evita Hive, incompatible con el `FakeAsync` de `testWidgets`).
class InMemoryMomentsRepository implements MomentsRepository {
  InMemoryMomentsRepository([Iterable<CustomMoment> initial = const []]) {
    for (final moment in initial) {
      _store[moment.id] = moment;
    }
  }

  final Map<String, CustomMoment> _store = {};

  @override
  List<CustomMoment> getAll() {
    final all = _store.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  @override
  Future<void> save(CustomMoment moment) async {
    _store[moment.id] = moment;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }
}
