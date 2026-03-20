import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/medication_model.dart';
import '../../data/services/medication_service.dart';

// Riverpod 3.x'de (kullandığın sürüm) StateNotifier yerine Notifier kullanılır.
final medicationSearchProvider = NotifierProvider<MedicationSearchNotifier, AsyncValue<List<Medication>>>(() {
  return MedicationSearchNotifier();
});

class MedicationSearchNotifier extends Notifier<AsyncValue<List<Medication>>> {
  @override
  AsyncValue<List<Medication>> build() {
    return const AsyncValue.data([]);
  }

  String _lastQuery = "";

  Future<List<Medication>> search(String query) async {
    if (query.trim().length < 2) {
      state = const AsyncValue.data([]);
      return [];
    }

    if (query == _lastQuery) return state.asData?.value ?? [];

    _lastQuery = query;
    state = const AsyncValue.loading();

    try {
      final results = await MedicationService().searchCatalog(query);
      state = AsyncValue.data(results);
      return results;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return [];
    }
  }
}
