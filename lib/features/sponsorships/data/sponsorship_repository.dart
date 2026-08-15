import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/firebase_providers.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/subscription_model.dart';
import '../../../core/models/child_sponsorship_model.dart';

final sponsorshipRepositoryProvider = Provider<SponsorshipRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(storageServiceProvider);
  return SponsorshipRepository(firestore, storage);
});

class SponsorshipRepository {
  final FirebaseFirestore _firestore;
  final StorageService _storage;

  SponsorshipRepository(this._firestore, this._storage);

  // --- Child Sponsorship Metadata CRUD ---

  Future<List<ChildSponsorship>> getChildSponsorships() async {
    final snapshot = await _firestore.collection('child_sponsorships').get();
    return snapshot.docs.map((doc) => ChildSponsorship.fromJson(doc.id, doc.data())).toList();
  }

  Future<void> saveChildSponsorship(ChildSponsorship child) async {
    if (child.id != null && child.id!.isNotEmpty) {
      await _firestore.collection('child_sponsorships').doc(child.id).set(child.toJson(), SetOptions(merge: true));
    } else {
      await _firestore.collection('child_sponsorships').add(child.toJson());
    }
  }

  Future<void> deleteChildSponsorship(String id) async {
    await _firestore.collection('child_sponsorships').doc(id).delete();
  }

  Future<String> uploadChildImage(String childId, List<int> bytes, String extension) async {
    final mimeType = (extension.toLowerCase() == 'jpg' || extension.toLowerCase() == 'jpeg') 
        ? 'image/jpeg' 
        : 'image/${extension.toLowerCase()}';
    
    try {
      return await _storage.uploadImage(
        path: 'children/$childId/profile.$extension',
        bytes: Uint8List.fromList(bytes),
        mimeType: mimeType,
      );
    } catch (e) {
      final base64String = base64Encode(bytes);
      return 'data:$mimeType;base64,$base64String';
    }
  }

  // --- Subscriptions ---
  Future<void> saveSubscription(Subscription sub) async {
    if (sub.id != null && sub.id!.isNotEmpty) {
      await _firestore.collection('subscriptions').doc(sub.id).set(sub.toJson(), SetOptions(merge: true));
    } else {
      await _firestore.collection('subscriptions').add(sub.toJson());
    }
  }

  Future<List<Subscription>> getAllSubscriptions() async {
    final snapshot = await _firestore.collection('subscriptions').get();
    return snapshot.docs.map((doc) => Subscription.fromJson(doc.id, doc.data())).toList();
  }

  Future<List<Subscription>> getOrgSponsors(String orgId) async {
    // Note: Firestore doesn't support OR queries across different fields easily without composite indexes or separate queries
    // We'll filter in memory for now or do two queries if needed.
    final snapshot = await _firestore.collection('subscriptions').where('status', isEqualTo: 'active').get();
    return snapshot.docs
        .map((doc) => Subscription.fromJson(doc.id, doc.data()))
        .where((s) => s.orgId == orgId || (s.targetType == 'org' && s.targetId == orgId))
        .toList();
  }

  Future<List<Subscription>> getUserSubscriptions(String donorId) async {
    final snapshot = await _firestore.collection('subscriptions').where('donorId', isEqualTo: donorId).get();
    return snapshot.docs.map((doc) => Subscription.fromJson(doc.id, doc.data())).toList();
  }

  Future<void> updateSubscriptionStatus(String subId, String status) async {
    await _firestore.collection('subscriptions').doc(subId).update({'status': status});
  }
  
  Future<void> logPayment(Subscription sub) async {
    await _firestore.collection('subscriptions').doc(sub.id).update({
      'lastPaymentDate': DateTime.now().toIso8601String(),
      'totalPayments': sub.totalPayments + 1,
      'totalAmountPaid': sub.totalAmountPaid + sub.amount,
    });
  }

  Future<void> updateSubscriptionAmount(String subId, double newAmount) async {
    await _firestore.collection('subscriptions').doc(subId).update({'amount': newAmount});
  }
}
