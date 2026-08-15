import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_repository.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/models/notification_model.dart';

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final user = ref.watch(authModelProvider);
  if (user == null) return [];
  
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications(user.uid);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final notificationActionsProvider = Provider((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  
  return NotificationActions(ref, repository);
});

class NotificationActions {
  final Ref _ref;
  final NotificationRepository _repository;

  NotificationActions(this._ref, this._repository);

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    _ref.invalidate(notificationsProvider);
  }

  Future<void> markAllAsRead() async {
    final notifications = _ref.read(notificationsProvider).value ?? [];
    final unreadIds = notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    
    if (unreadIds.isNotEmpty) {
      await _repository.markAllAsRead(unreadIds);
      _ref.invalidate(notificationsProvider);
    }
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
    _ref.invalidate(notificationsProvider);
  }
}

