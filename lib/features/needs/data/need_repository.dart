import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/firebase_providers.dart';
import '../../../core/models/need_model.dart';

final needRepositoryProvider = Provider<NeedRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return NeedRepository(firestore);
});

class NeedRepository {
  final FirebaseFirestore _firestore;

  NeedRepository(this._firestore);

  Future<void> saveNeed(Need need) async {
    if (need.id.isEmpty) {
      final docRef = _firestore.collection('needs').doc();
      final needWithId = Need(
        id: docRef.id,
        organizationId: need.organizationId,
        organizationName: need.organizationName,
        title: need.title,
        category: need.category,
        priority: need.priority,
        subtitle: need.subtitle,
        quantityOrAmount: need.quantityOrAmount,
        targetQuantity: need.targetQuantity,
        fulfilledQuantity: need.fulfilledQuantity,
        unit: need.unit,
        deadline: need.deadline,
        status: need.status,
        createdAt: need.createdAt ?? DateTime.now(),
      );
      await docRef.set(needWithId.toJson());
    } else {
      await _firestore.collection('needs').doc(need.id).set(need.toJson(), SetOptions(merge: true));
    }
  }

  Future<void> deleteNeed(String id) async {
    await _firestore.collection('needs').doc(id).delete();
  }

  Future<void> deleteAllNeeds() async {
    final snapshot = await _firestore.collection('needs').get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateNeedStatus(String id, String status) async {
    await _firestore.collection('needs').doc(id).update({'status': status});
  }

  Future<void> updateNeedFulfillment(String needId, double amountAdded) async {
    final docRef = _firestore.collection('needs').doc(needId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      
      final need = Need.fromJson(needId, snapshot.data()!);
      final newFulfilled = need.fulfilledQuantity + amountAdded;
      final newStatus = (newFulfilled >= need.targetQuantity && need.targetQuantity > 0) ? 'fulfilled' : need.status;
      
      transaction.update(docRef, {
        'fulfilledQuantity': newFulfilled,
        'status': newStatus,
      });
    });
  }

  Future<List<Need>> getAllNeeds() async {
    final snapshot = await _firestore.collection('needs').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Need.fromJson(doc.id, doc.data())).toList();
  }

  Stream<List<Need>> watchAllNeeds() {
    return _firestore.collection('needs').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Need.fromJson(doc.id, doc.data())).toList();
    });
  }

  Future<List<Need>> getNeedsByStatus(String status) async {
    final snapshot = await _firestore.collection('needs').get();
    final allowedStatuses = switch (status) {
      'approved' => {'approved', 'open', 'active'},
      _ => {status},
    };
    return snapshot.docs
        .map((doc) => Need.fromJson(doc.id, doc.data()))
        .where((need) => allowedStatuses.contains(need.status))
        .toList();
  }

  Future<List<Need>> getNeedsByOrganizationId(String orgId) async {
    final snapshot = await _firestore.collection('needs').where('organizationId', isEqualTo: orgId).get();
    return snapshot.docs.map((doc) => Need.fromJson(doc.id, doc.data())).toList();
  }

  Stream<List<Need>> watchNeedsByOrganizationId(String orgId) {
    return _firestore.collection('needs').where('organizationId', isEqualTo: orgId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Need.fromJson(doc.id, doc.data())).toList();
    });
  }
}
