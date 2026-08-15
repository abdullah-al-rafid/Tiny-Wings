import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/organization_repository.dart';
import '../../../core/models/organization_model.dart';
import '../../profile/providers/user_providers.dart';
import '../../../core/models/user_model.dart';

final organizationsProvider = StreamProvider<List<Organization>>((ref) {
  final repository = ref.watch(organizationRepositoryProvider);
  final user = ref.watch(userProfileProvider).value;

  return repository.watchOrganizations().map((allOrgs) {
    // If user is admin, they see everything for management
    if (user?.role == UserRole.admin) {
      return allOrgs;
    }

    // Otherwise, only show verified organizations to public/volunteers/donors
    return allOrgs
        .where((org) => org.status == VerificationStatus.verified)
        .toList();
  });
});

final organizationDetailsProvider =
    StreamProvider.family<Organization?, String>((ref, id) {
      final repository = ref.watch(organizationRepositoryProvider);

      return repository.watchOrganizations().map((orgs) {
        for (final org in orgs) {
          if (org.id == id) {
            return org;
          }
        }
        return null;
      });
    });

final organizationSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredOrganizationsProvider = Provider<AsyncValue<List<Organization>>>((
  ref,
) {
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

final organizationActionsProvider = Provider((ref) {
  final repository = ref.watch(organizationRepositoryProvider);
  return OrganizationActions(ref, repository);
});

class OrganizationActions {
  final Ref _ref;
  final OrganizationRepository _repository;

  OrganizationActions(this._ref, this._repository);

  Future<void> saveOrganization(Organization org) async {
    await _repository.saveOrganization(org);
    _invalidate();
  }

  Future<void> deleteOrganization(String id) async {
    await _repository.deleteOrganization(id);
    _invalidate();
  }

  Future<void> updateOrganizationStatus(
    String id,
    VerificationStatus status,
  ) async {
    final org = await _repository.getOrganizationById(id);
    if (org != null) {
      final updatedOrg = org.copyWith(status: status);
      await _repository.saveOrganization(updatedOrg);
      _invalidate();
    }
  }

  void _invalidate() {
    _ref.invalidate(organizationsProvider);
    _ref.invalidate(filteredOrganizationsProvider);
    _ref.invalidate(organizationDetailsProvider);
  }
}
