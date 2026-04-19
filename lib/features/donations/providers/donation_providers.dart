import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/donation_repository.dart';
import '../../../models/donation_model.dart';
import '../../../core/auth/auth_repository.dart';

final userDonationsProvider = FutureProvider<List<Donation>>((ref) async {
  final authData = ref.watch(authModelProvider);
  if (authData == null) return [];
  
  final repository = ref.watch(donationRepositoryProvider);
  final donations = await repository.getDonationsByUser(authData.uid);
  
  // Sort by newest first
  donations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return donations;
});
