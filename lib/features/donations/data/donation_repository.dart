import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/firebase_providers.dart';
import '../../../core/models/donation_model.dart';

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return DonationRepository(firestore);
});

class DonationRepository {
  final FirebaseFirestore _firestore;

  DonationRepository(this._firestore);

  Future<void> saveDonation(Donation donation) async {
    if (donation.id != null && donation.id!.isNotEmpty) {
      await _firestore.collection('donations').doc(donation.id).set(
        donation.toJson(),
        SetOptions(merge: true),
      );
      return;
    }

    await _firestore.collection('donations').add(donation.toJson());
  }

  Future<void> updateDonation(String id, Map<String, dynamic> updates) async {
    await _firestore.collection('donations').doc(id).update(updates);
  }

  Future<List<Donation>> getAllDonations() async {
    final snapshot = await _firestore.collection('donations').orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => Donation.fromJson(doc.id, doc.data())).toList();
  }

  Future<List<Donation>> getDonationsByUser(String uid) async {
    final snapshot = await _firestore.collection('donations').where('donorId', isEqualTo: uid).get();
    return snapshot.docs.map((doc) => Donation.fromJson(doc.id, doc.data())).toList();
  }

  Future<List<Donation>> getDonationsByOrg(String orgId) async {
    final snapshot = await _firestore.collection('donations').where('organizationId', isEqualTo: orgId).get();
    return snapshot.docs.map((doc) => Donation.fromJson(doc.id, doc.data())).toList();
  }

  Future<void> deleteAllDonations() async {
    final snapshot = await _firestore.collection('donations').get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
