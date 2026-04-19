import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/support_repository.dart';
import '../../profile/providers/user_providers.dart';
import '../../../models/support_ticket_model.dart';

final userTicketsProvider = FutureProvider<List<SupportTicket>>((ref) async {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return [];
  
  return ref.watch(supportRepositoryProvider).getUserTickets(user.uid);
});

final unreadUserTicketsCountProvider = Provider<int>((ref) {
  final tickets = ref.watch(userTicketsProvider).value ?? [];
  return tickets.where((t) => !t.isReadByUser).length;
});

final allAdminTicketsProvider = FutureProvider<List<SupportTicket>>((ref) async {
  return ref.watch(supportRepositoryProvider).getAllTickets();
});

final unreadAdminTicketsCountProvider = Provider<int>((ref) {
  final tickets = ref.watch(allAdminTicketsProvider).value ?? [];
  return tickets.where((t) => !t.isReadByAdmin).length;
});
