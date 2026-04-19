import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/firebase_client.dart';
import '../../../models/donation_model.dart';

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  final client = ref.watch(firebaseClientProvider);
  return DonationRepository(client);
});

class DonationRepository {
  final FirebaseClient _client;

  DonationRepository(this._client);

  Future<void> saveDonation(Donation donation) async {
    // Generate a unique ID if not present (RTDB will assign one if we use post)
    await _client.post('donations', donation.toJson());
  }

  Future<void> updateDonation(String id, Map<String, dynamic> updates) async {
    await _client.patch('donations/$id', updates);
  }

  Future<List<Donation>> getAllDonations() async {
    final response = await _client.get('donations');
    
    if (response.body == 'null') return [];

    final Map<String, dynamic> data = json.decode(response.body);
    final List<Donation> donations = [];

    data.forEach((id, donationData) {
      donations.add(Donation.fromJson(id, donationData));
    });

    return donations;
  }

  Future<List<Donation>> getDonationsByUser(String uid) async {
    final donations = await getAllDonations();
    return donations.where((d) => d.donorId == uid).toList();
  }

  Future<List<Donation>> getDonationsByOrg(String orgId) async {
    final donations = await getAllDonations();
    return donations.where((d) => d.organizationId == orgId).toList();
  }
}
