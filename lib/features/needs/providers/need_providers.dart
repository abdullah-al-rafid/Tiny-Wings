import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/need_model.dart';
import '../data/need_repository.dart';

final allNeedsProvider = StreamProvider<List<Need>>((ref) {
  final repository = ref.watch(needRepositoryProvider);
  return repository.watchAllNeeds();
});

final approvedNeedsProvider = StreamProvider<List<Need>>((ref) {
  final repository = ref.watch(needRepositoryProvider);
  return repository.watchAllNeeds().map((needs) {
    const allowedStatuses = {'approved', 'open', 'active'};
    return needs.where((need) => allowedStatuses.contains(need.status)).toList();
  });
});

final pendingNeedsProvider = StreamProvider<List<Need>>((ref) {
  final repository = ref.watch(needRepositoryProvider);
  return repository.watchAllNeeds().map((needs) {
    return needs.where((need) => need.status == 'pending').toList();
  });
});

final needsByOrgProvider = StreamProvider.family<List<Need>, String>((ref, orgId) {
  final repository = ref.watch(needRepositoryProvider);
  return repository.watchNeedsByOrganizationId(orgId);
});

// Category filter provider for the local UI state
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final selectedPriorityProvider = StateProvider<String>((ref) => 'All');

final needActionsProvider = Provider((ref) {
  final repository = ref.watch(needRepositoryProvider);
  return NeedActions(ref, repository);
});

class NeedActions {
  final Ref _ref;
  final NeedRepository _repository;

  NeedActions(this._ref, this._repository);

  Future<void> saveNeed(Need need) async {
    await _repository.saveNeed(need);
    _invalidate();
  }

  Future<void> deleteNeed(String id) async {
    await _repository.deleteNeed(id);
    _invalidate();
  }

  Future<void> updateNeedStatus(String id, String status) async {
    await _repository.updateNeedStatus(id, status);
    _invalidate();
  }

  Future<void> updateNeedFulfillment(String needId, double amountAdded) async {
    await _repository.updateNeedFulfillment(needId, amountAdded);
    _invalidate();
  }

  void _invalidate() {
    _ref.invalidate(allNeedsProvider);
    _ref.invalidate(approvedNeedsProvider);
    _ref.invalidate(pendingNeedsProvider);
    _ref.invalidate(needsByOrgProvider);
  }
}

