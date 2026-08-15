import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/firebase_providers.dart';
import '../../../core/models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return NotificationRepository(firestore);
});

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  Future<void> sendNotification(AppNotification notification) async {
    if (notification.id.isNotEmpty) {
      await _firestore.collection('notifications').doc(notification.id).set(
        notification.toMap(),
        SetOptions(merge: true),
      );
      return;
    }

    await _firestore.collection('notifications').add(notification.toMap());
  }

  Future<List<AppNotification>> getNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();
    final notifications = snapshot.docs
        .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
        .toList();
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({'isRead': true});
  }

  Future<void> markAllAsRead(List<String> ids) async {
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.update(_firestore.collection('notifications').doc(id), {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String id) async {
    await _firestore.collection('notifications').doc(id).delete();
  }

  Future<void> deleteAllNotifications() async {
    final snapshot = await _firestore.collection('notifications').get();
    for (var doc in snapshot.docs) await doc.reference.delete();
  }
}
