import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/firebase_providers.dart';
import '../../../core/models/support_ticket_model.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return SupportRepository(firestore);
});

class SupportRepository {
  final FirebaseFirestore _firestore;

  SupportRepository(this._firestore);

  Future<void> saveTicket(SupportTicket ticket) async {
    final newTicket = ticket.copyWith(
      isReadByAdmin: false,
      isReadByUser: true,
    );
    await _firestore.collection('support_tickets').add(newTicket.toJson());
  }

  Future<void> updateTicket(SupportTicket ticket) async {
    await _firestore.collection('support_tickets').doc(ticket.id).set(ticket.toJson(), SetOptions(merge: true));
  }

  Future<void> markAsReadByUser(SupportTicket ticket) async {
    if (ticket.isReadByUser) return;
    await _firestore.collection('support_tickets').doc(ticket.id).update({'isReadByUser': true});
  }

  Future<void> markAsReadByAdmin(SupportTicket ticket) async {
    if (ticket.isReadByAdmin) return;
    await _firestore.collection('support_tickets').doc(ticket.id).update({'isReadByAdmin': true});
  }

  Future<List<SupportTicket>> getUserTickets(String userId) async {
    final snapshot = await _firestore
        .collection('support_tickets')
        .where('userId', isEqualTo: userId)
        .get();
    final tickets = snapshot.docs
        .map((doc) => SupportTicket.fromJson(doc.data(), doc.id))
        .toList();
    tickets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return tickets;
  }

  Future<List<SupportTicket>> getAllTickets() async {
    final snapshot = await _firestore.collection('support_tickets')
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => SupportTicket.fromJson(doc.data(), doc.id)).toList();
  }
}
