import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/api/firebase_providers.dart';
import '../../../core/models/opportunity_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final volunteerRepositoryProvider = Provider<VolunteerRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return VolunteerRepository(firestore);
});

class VolunteerRepository {
  final FirebaseFirestore _firestore;

  VolunteerRepository(this._firestore);

  Future<List<VolunteerOpportunity>> getVolunteerOpportunities() async {
    final snapshot = await _firestore.collection('volunteer_opportunities').get();
    return snapshot.docs.map((doc) => VolunteerOpportunity.fromJson(doc.id, doc.data())).toList();
  }

  Stream<List<VolunteerOpportunity>> watchVolunteerOpportunities() {
    return _firestore.collection('volunteer_opportunities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => VolunteerOpportunity.fromJson(doc.id, doc.data())).toList();
    });
  }

  Future<void> saveVolunteerOpportunity(VolunteerOpportunity opp) async {
    if (opp.id.isNotEmpty) {
      await _firestore.collection('volunteer_opportunities').doc(opp.id).set(opp.toJson(), SetOptions(merge: true));
    } else {
      await _firestore.collection('volunteer_opportunities').add(opp.toJson());
    }
  }

  Future<void> addOpportunity(VolunteerOpportunity opp) async {
    await _firestore.collection('volunteer_opportunities').add(opp.toJson());
  }

  Future<void> applyForOpportunity(String opportunityId, String userId) async {
    await _firestore.collection('volunteer_opportunities').doc(opportunityId).update({
      'appliedUserIds': FieldValue.arrayUnion([userId])
    });
  }

  // Opportunity Board (Career/Education)
  Future<List<Opportunity>> getLifeOpportunities() async {
    final snapshot = await _firestore.collection('life_opportunities').get();
    return snapshot.docs.map((doc) => Opportunity.fromJson(doc.id, doc.data())).toList();
  }

  Stream<List<Opportunity>> watchLifeOpportunities() {
    return _firestore.collection('life_opportunities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Opportunity.fromJson(doc.id, doc.data())).toList();
    });
  }

  Future<void> saveLifeOpportunity(Opportunity opp) async {
    await _firestore.collection('life_opportunities').doc(opp.id).set(opp.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteVolunteerOpportunity(String id) async {
    await _firestore.collection('volunteer_opportunities').doc(id).delete();
  }

  Future<void> deleteLifeOpportunity(String id) async {
    await _firestore.collection('life_opportunities').doc(id).delete();
  }

  Future<void> addLifeOpportunity(Opportunity opp) async {
    await _firestore.collection('life_opportunities').add(opp.toJson());
  }

  Future<void> deleteAllOpportunities() async {
    final volSnapshot = await _firestore.collection('volunteer_opportunities').get();
    for (var doc in volSnapshot.docs) await doc.reference.delete();
    
    final lifeSnapshot = await _firestore.collection('life_opportunities').get();
    for (var doc in lifeSnapshot.docs) await doc.reference.delete();
  }

  Future<void> saveOpportunity(VolunteerOpportunity opp) async {
    await saveVolunteerOpportunity(opp);
  }
}
