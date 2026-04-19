import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/organization_repository.dart';
import '../../../models/organization_model.dart';

final organizationsProvider = FutureProvider<List<Organization>>((ref) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return repository.getOrganizations();
});

final organizationDetailsProvider = FutureProvider.family<Organization?, String>((ref, id) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return repository.getOrganizationById(id);
});

final organizationSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredOrganizationsProvider = Provider<AsyncValue<List<Organization>>>((ref) {
  final organizationsAsync = ref.watch(organizationsProvider);
  final searchQuery = ref.watch(organizationSearchQueryProvider).toLowerCase();

  return organizationsAsync.whenData((organizations) {
    if (searchQuery.isEmpty) return organizations;
    return organizations.where((org) {
      return org.name.toLowerCase().contains(searchQuery) ||
             org.description.toLowerCase().contains(searchQuery) ||
             org.location.toLowerCase().contains(searchQuery);
    }).toList();
  });
});
