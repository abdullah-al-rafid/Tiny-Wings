import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/firebase_client.dart';
import '../../../models/need_model.dart';

final needRepositoryProvider = Provider<NeedRepository>((ref) {
  final client = ref.watch(firebaseClientProvider);
  return NeedRepository(client);
});

class NeedRepository {
  final FirebaseClient _client;

  NeedRepository(this._client);

  Future<void> saveNeed(Need need) async {
    if (need.id.isEmpty) {
      await _client.post('needs', need.toJson());
    } else {
      await _client.put('needs/${need.id}', need.toJson());
    }
  }

  Future<void> updateNeedStatus(String id, String status) async {
    await _client.patch('needs/$id', {'status': status});
  }

  Future<void> updateNeedFulfillment(String needId, double amountAdded) async {
    final response = await _client.get('needs/$needId');
    if (response.body == 'null') return;
    
    final needData = json.decode(response.body);
    final need = Need.fromJson(needId, needData);
    
    final newFulfilled = need.fulfilledQuantity + amountAdded;
    final newStatus = (newFulfilled >= need.targetQuantity && need.targetQuantity > 0) ? 'fulfilled' : need.status;
    
    final updatedNeed = Need(
      id: need.id,
      organizationId: need.organizationId,
      organizationName: need.organizationName,
      title: need.title,
      category: need.category,
      priority: need.priority,
      subtitle: need.subtitle,
      quantityOrAmount: need.quantityOrAmount,
      targetQuantity: need.targetQuantity,
      fulfilledQuantity: newFulfilled,
      unit: need.unit,
      deadline: need.deadline,
      status: newStatus,
      createdAt: need.createdAt,
    );
    
    await saveNeed(updatedNeed);
  }

  Future<List<Need>> getAllNeeds() async {
    final response = await _client.get('needs');
    
    if (response.body == 'null') return [];

    final Map<String, dynamic> data = json.decode(response.body);
    final List<Need> needs = [];

    data.forEach((id, needData) {
      needs.add(Need.fromJson(id, needData));
    });

    // Sort by newest first
    needs.sort((a, b) {
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    return needs;
  }

  Future<List<Need>> getNeedsByStatus(String status) async {
    final needs = await getAllNeeds();
    return needs.where((n) => n.status == status).toList();
  }

  Future<List<Need>> getNeedsByOrganizationId(String orgId) async {
    final needs = await getAllNeeds();
    return needs.where((n) => n.organizationId == orgId).toList();
  }
}
