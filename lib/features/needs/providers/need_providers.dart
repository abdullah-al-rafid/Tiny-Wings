import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/need_model.dart';
import '../data/need_repository.dart';

final allNeedsProvider = FutureProvider<List<Need>>((ref) async {
  final repository = ref.watch(needRepositoryProvider);
  return repository.getAllNeeds();
});

final approvedNeedsProvider = FutureProvider<List<Need>>((ref) async {
  final repository = ref.watch(needRepositoryProvider);
  return repository.getNeedsByStatus('approved');
});

final pendingNeedsProvider = FutureProvider<List<Need>>((ref) async {
  final repository = ref.watch(needRepositoryProvider);
  return repository.getNeedsByStatus('pending');
});

final needsByOrgProvider = FutureProvider.family<List<Need>, String>((ref, orgId) async {
  final repository = ref.watch(needRepositoryProvider);
  return repository.getNeedsByOrganizationId(orgId);
});

// Category filter provider for the local UI state
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final selectedPriorityProvider = StateProvider<String>((ref) => 'All');
