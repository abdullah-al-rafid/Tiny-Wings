import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/firebase_providers.dart';
import '../../../core/models/application_model.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ApplicationRepository(firestore);
});

class ApplicationRepository {
  final FirebaseFirestore _firestore;

  ApplicationRepository(this._firestore);

  Future<void> submitApplication(VolunteerApplication application) async {
    if (application.id.isNotEmpty) {
      await _firestore.collection('applications').doc(application.id).set(
        application.toJson(),
        SetOptions(merge: true),
      );
      return;
    }

    await _firestore.collection('applications').add(application.toJson());
  }

  Future<List<VolunteerApplication>> getUserApplications(String userId) async {
    final snapshot = await _firestore.collection('applications')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => VolunteerApplication.fromJson(doc.id, doc.data())).toList();
  }

  Future<void> updateApplicationStatus(String id, ApplicationStatus status) async {
    await _firestore.collection('applications').doc(id).update({'status': status.name});
  }

  Future<void> deleteAllApplications() async {
    final snapshot = await _firestore.collection('applications').get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}

final userApplicationsProvider = FutureProvider.family<List<VolunteerApplication>, String>((ref, userId) async {
  return ref.watch(applicationRepositoryProvider).getUserApplications(userId);
});
