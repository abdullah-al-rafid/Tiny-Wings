import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/volunteer_repository.dart';
import '../../../core/models/opportunity_model.dart';
import '../../profile/providers/user_providers.dart';
import '../../../core/models/user_model.dart';

final volunteerOpportunitiesProvider = StreamProvider<List<VolunteerOpportunity>>((ref) {
  final repository = ref.watch(volunteerRepositoryProvider);
  return repository.watchVolunteerOpportunities();
});

final lifeOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  final repository = ref.watch(volunteerRepositoryProvider);
  final user = ref.watch(userProfileProvider).value;
  
  return repository.watchLifeOpportunities().map((allOpps) {
    // Admins see all for moderation
    if (user?.role == UserRole.admin) {
      return allOpps;
    }
    
    // Others only see approved ones
    return allOpps.where((o) => o.status == OpportunityStatus.approved).toList();
  });
});

final volunteerSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredVolunteerOpportunitiesProvider = Provider<AsyncValue<List<VolunteerOpportunity>>>((ref) {
  final oppsAsync = ref.watch(volunteerOpportunitiesProvider);
  final searchQuery = ref.watch(volunteerSearchQueryProvider).toLowerCase();

  return oppsAsync.whenData((opps) {
    if (searchQuery.isEmpty) return opps;
    return opps.where((o) {
      return o.title.toLowerCase().contains(searchQuery) ||
             o.organizationName.toLowerCase().contains(searchQuery) ||
             o.location.toLowerCase().contains(searchQuery);
    }).toList();
  });
});

final volunteerActionsProvider = Provider((ref) {
  final repository = ref.watch(volunteerRepositoryProvider);
  return VolunteerActions(ref, repository);
});

class VolunteerActions {
  final Ref _ref;
  final VolunteerRepository _repository;

  VolunteerActions(this._ref, this._repository);

  Future<void> addVolunteerOpportunity(VolunteerOpportunity opp) async {
    await _repository.addOpportunity(opp);
    _invalidateVolunteer();
  }

  Future<void> deleteVolunteerOpportunity(String id) async {
    await _repository.deleteVolunteerOpportunity(id);
    _invalidateVolunteer();
  }

  Future<void> addLifeOpportunity(Opportunity opp) async {
    await _repository.addLifeOpportunity(opp);
    _invalidateLife();
  }

  Future<void> deleteLifeOpportunity(String id) async {
    await _repository.deleteLifeOpportunity(id);
    _invalidateLife();
  }

  Future<void> updateLifeOpportunityStatus(String id, OpportunityStatus status) async {
    // We don't have a direct patch for LifeOpportunity yet, so we get it and update it
    final allOpps = await _repository.getLifeOpportunities();
    final opp = allOpps.firstWhere((o) => o.id == id);
    final updatedOpp = Opportunity(
      id: opp.id,
      title: opp.title,
      description: opp.description,
      category: opp.category,
      deadline: opp.deadline,
      location: opp.location,
      contactMethod: opp.contactMethod,
      postedBy: opp.postedBy,
      organizationId: opp.organizationId,
      status: status,
      createdAt: opp.createdAt,
      eligibility: opp.eligibility,
    );
    await _repository.saveLifeOpportunity(updatedOpp);
    _invalidateLife();
  }

  void _invalidateVolunteer() {
    _ref.invalidate(volunteerOpportunitiesProvider);
    _ref.invalidate(filteredVolunteerOpportunitiesProvider);
  }

  void _invalidateLife() {
    _ref.invalidate(lifeOpportunitiesProvider);
  }
}

