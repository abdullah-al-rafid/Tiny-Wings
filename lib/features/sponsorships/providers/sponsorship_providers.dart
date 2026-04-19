import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/subscription_model.dart';
import '../../../models/donation_model.dart';
import '../../../models/supporter_model.dart';
import '../data/sponsorship_repository.dart';
import '../../donations/data/donation_repository.dart';
import '../../../core/auth/auth_repository.dart';

import '../../profile/data/user_repository.dart';

final orgSponsorsProvider = FutureProvider.family<List<Subscription>, String>((ref, orgId) {
  return ref.watch(sponsorshipRepositoryProvider).getOrgSponsors(orgId);
});

final orgSupportersProvider = FutureProvider.family<List<Supporter>, String>((ref, orgId) async {
  final sponsorshipRepo = ref.watch(sponsorshipRepositoryProvider);
  final donationRepo = ref.watch(donationRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  final subs = await sponsorshipRepo.getOrgSponsors(orgId);
  final donations = await donationRepo.getDonationsByOrg(orgId);
  final users = await userRepo.getAllUsers();
  
  // Create name lookup map
  final Map<String, String> nameMap = {
    for (var u in users) u.uid: u.name
  };

  final Map<String, Supporter> sponsorMap = {};
  final Map<String, Supporter> donationMap = {};

  // Process Subscriptions (Sponsors)
  for (var sub in subs) {
    if (sub.status != 'active') continue;
    
    final realName = nameMap[sub.donorId] ?? sub.donorName;
    
    // Aggregate multiple subscriptions if they have them? (Usually one per org)
    if (sponsorMap.containsKey(sub.donorId)) {
      final existing = sponsorMap[sub.donorId]!;
      sponsorMap[sub.donorId] = Supporter(
        donorId: sub.donorId,
        donorName: realName,
        totalAmount: existing.totalAmount + sub.amount,
        isMonthly: true,
        lastContribution: sub.lastPaymentDate.isAfter(existing.lastContribution) ? sub.lastPaymentDate : existing.lastContribution,
      );
    } else {
      sponsorMap[sub.donorId] = Supporter(
        donorId: sub.donorId,
        donorName: realName,
        totalAmount: sub.amount,
        isMonthly: true,
        lastContribution: sub.lastPaymentDate,
      );
    }
  }

  // Process Donations (One-time)
  for (var d in donations) {
    if (d.type != DonationType.money) continue;
    final amount = d.amount ?? 0.0;
    final realName = nameMap[d.donorId] ?? d.donorName;

    if (donationMap.containsKey(d.donorId)) {
      final existing = donationMap[d.donorId]!;
      donationMap[d.donorId] = Supporter(
        donorId: d.donorId,
        donorName: realName,
        totalAmount: existing.totalAmount + amount,
        isMonthly: false,
        lastContribution: d.timestamp.isAfter(existing.lastContribution) ? d.timestamp : existing.lastContribution,
      );
    } else {
      donationMap[d.donorId] = Supporter(
        donorId: d.donorId,
        donorName: realName,
        totalAmount: amount,
        isMonthly: false,
        lastContribution: d.timestamp,
      );
    }
  }

  // Return combined but separate list
  final List<Supporter> allSupporters = [...sponsorMap.values, ...donationMap.values];
  return allSupporters..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
});

final userSubscriptionsProvider = FutureProvider<List<Subscription>>((ref) async {
  final user = ref.watch(authModelProvider);
  if (user == null) return [];
  return ref.watch(sponsorshipRepositoryProvider).getUserSubscriptions(user.uid);
});

final activeUserSubscriptionsProvider = FutureProvider<List<Subscription>>((ref) async {
  final subs = await ref.watch(userSubscriptionsProvider.future);
  return subs.where((s) => s.status == 'active').toList();
});

final allSubscriptionsProvider = FutureProvider<List<Subscription>>((ref) {
  return ref.watch(sponsorshipRepositoryProvider).getAllSubscriptions();
});
