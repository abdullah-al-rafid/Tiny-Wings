import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/firebase_client.dart';
import '../../../models/subscription_model.dart';


final sponsorshipRepositoryProvider = Provider<SponsorshipRepository>((ref) {
  final client = ref.watch(firebaseClientProvider);
  return SponsorshipRepository(client);
});

class SponsorshipRepository {
  final FirebaseClient _client;

  SponsorshipRepository(this._client);

  // --- Subscriptions ---
  Future<void> saveSubscription(Subscription sub) async {
    if (sub.id != null && sub.id!.isNotEmpty) {
      await _client.put('subscriptions/${sub.id}', sub.toJson());
    } else {
      await _client.post('subscriptions', sub.toJson());
    }
  }

  Future<List<Subscription>> getAllSubscriptions() async {
    final response = await _client.get('subscriptions');
    if (response.body == 'null') return [];

    final Map<String, dynamic> data = json.decode(response.body);
    return data.entries.map((e) => Subscription.fromJson(e.key, e.value)).toList();
  }

  Future<List<Subscription>> getOrgSponsors(String orgId) async {
    final subs = await getAllSubscriptions();
    return subs.where((s) => (s.orgId == orgId || (s.targetType == 'org' && s.targetId == orgId)) && s.status == 'active').toList();
  }

  Future<List<Subscription>> getUserSubscriptions(String donorId) async {
    final subs = await getAllSubscriptions();
    return subs.where((s) => s.donorId == donorId).toList();
  }

  Future<void> updateSubscriptionStatus(String subId, String status) async {
    await _client.patch('subscriptions/$subId', {'status': status});
  }
  
  Future<void> logPayment(Subscription sub) async {
    await _client.patch('subscriptions/${sub.id}', {
      'lastPaymentDate': DateTime.now().toIso8601String(),
      'totalPayments': sub.totalPayments + 1,
      'totalAmountPaid': sub.totalAmountPaid + sub.amount,
    });
  }

  Future<void> updateSubscriptionAmount(String subId, double newAmount) async {
    await _client.patch('subscriptions/$subId', {'amount': newAmount});
  }
}
