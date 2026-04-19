import 'dart:convert';
import '../../../core/api/firebase_client.dart';
import '../../../models/support_ticket_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final client = ref.watch(firebaseClientProvider);
  return SupportRepository(client);
});

class SupportRepository {
  final FirebaseClient _client;
  SupportRepository(this._client);

  Future<void> saveTicket(SupportTicket ticket) async {
    // New tickets are unread by admin, and "read" by user (since they just wrote it)
    final newTicket = ticket.copyWith(
      isReadByAdmin: false,
      isReadByUser: true,
    );
    await _client.post('support_tickets', newTicket.toJson());
  }

  Future<void> updateTicket(SupportTicket ticket) async {
    await _client.put('support_tickets/${ticket.id}', ticket.toJson());
  }

  Future<void> markAsReadByUser(SupportTicket ticket) async {
    if (ticket.isReadByUser) return;
    final updated = ticket.copyWith(isReadByUser: true);
    await updateTicket(updated);
  }

  Future<void> markAsReadByAdmin(SupportTicket ticket) async {
    if (ticket.isReadByAdmin) return;
    final updated = ticket.copyWith(isReadByAdmin: true);
    await updateTicket(updated);
  }

  Future<List<SupportTicket>> getUserTickets(String userId) async {
    final response = await _client.get('support_tickets');
    if (response.body == 'null') return [];
    
    final Map<String, dynamic>? data = json.decode(response.body);
    if (data == null) return [];

    return data.entries
        .map((e) => SupportTicket.fromJson(e.value as Map<String, dynamic>, e.key))
        .where((t) => t.userId == userId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<List<SupportTicket>> getAllTickets() async {
    final response = await _client.get('support_tickets');
    if (response.body == 'null') return [];
    
    final Map<String, dynamic>? data = json.decode(response.body);
    if (data == null) return [];

    return data.entries
        .map((e) => SupportTicket.fromJson(e.value as Map<String, dynamic>, e.key))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
