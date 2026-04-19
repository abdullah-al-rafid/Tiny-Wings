import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../../models/donation_model.dart';
import '../../profile/data/user_repository.dart';
import '../data/donation_repository.dart';
import '../../sponsorships/data/sponsorship_repository.dart';
import '../../../models/subscription_model.dart';
import '../../../core/auth/auth_repository.dart';

enum LeaderboardFilter { allTime, twoDays, fiveDays }
enum LeaderboardType { total, sponsor, donation }

final leaderboardFilterProvider = StateProvider<LeaderboardFilter>((ref) => LeaderboardFilter.allTime);
final leaderboardTypeProvider = StateProvider<LeaderboardType>((ref) => LeaderboardType.total);

class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? profilePictureUrl;
  final double totalAmount;
  final double donationAmount;
  final double sponsorshipAmount;
  final int paymentCount;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.profilePictureUrl,
    required this.totalAmount,
    required this.donationAmount,
    required this.sponsorshipAmount,
    required this.paymentCount,
  });
}

class LeaderboardData {
  final List<LeaderboardEntry> allTime;
  final Map<String, List<LeaderboardEntry>> byOrganization;

  LeaderboardData({required this.allTime, required this.byOrganization});
}

final leaderboardProvider = FutureProvider<LeaderboardData>((ref) async {
  final userRepo = ref.watch(userRepositoryProvider);
  final donationRepo = ref.watch(donationRepositoryProvider);
  final sponsorRepo = ref.watch(sponsorshipRepositoryProvider);
  final filter = ref.watch(leaderboardFilterProvider);
  final typeFilter = ref.watch(leaderboardTypeProvider);

  final users = await userRepo.getAllUsers();
  final allDonations = await donationRepo.getAllDonations();
  final allSubs = await sponsorRepo.getAllSubscriptions();

  // Apply Time Filter
  final now = DateTime.now();
  
  bool isWithinFilter(DateTime timestamp) {
    if (filter == LeaderboardFilter.allTime) return true;
    final days = filter == LeaderboardFilter.twoDays ? 2 : 5;
    return now.difference(timestamp).inDays < days;
  }

  final filteredDonations = allDonations.where((d) => isWithinFilter(d.timestamp)).toList();
  final filteredSubs = allSubs.where((s) => isWithinFilter(s.lastPaymentDate)).toList();

  // Helper to aggregate donations and subscriptions
  List<LeaderboardEntry> aggregate(List<Donation> donationList, List<Subscription> subList) {
    final Map<String, double> donationTotals = {};
    final Map<String, double> sponsorshipTotals = {};
    final Map<String, int> paymentTotals = {};
    
    final Set<String> userIds = {};

    // Process Donations
    for (var d in donationList) {
      if (d.status == 'verified') {
        final val = d.approvedValue ?? d.amount ?? 0.0;
        donationTotals[d.donorId] = (donationTotals[d.donorId] ?? 0.0) + val;
        paymentTotals[d.donorId] = (paymentTotals[d.donorId] ?? 0) + 1;
        userIds.add(d.donorId);
      }
    }

    // Process Subscriptions (Sponsorships)
    for (var s in subList) {
      sponsorshipTotals[s.donorId] = (sponsorshipTotals[s.donorId] ?? 0.0) + s.totalAmountPaid;
      paymentTotals[s.donorId] = (paymentTotals[s.donorId] ?? 0) + s.totalPayments;
      userIds.add(s.donorId);
    }

    List<LeaderboardEntry> entries = [];
    final currentUserId = ref.read(authModelProvider)?.uid;
    int anonymousCount = 0;

    for (var uid in userIds) {
      final donAmount = donationTotals[uid] ?? 0.0;
      final sponAmount = sponsorshipTotals[uid] ?? 0.0;
      final total = donAmount + sponAmount;

      if (total > 0) {
        final user = users.firstWhere(
          (u) => u.uid == uid,
          orElse: () => UserModel(uid: uid, email: '', name: 'Unknown Donor', phone: ''),
        );
        
        final payments = paymentTotals[uid] ?? 0;
        
        String displayName = user.name;
        String? displayPic = user.profilePictureUrl;

        // Mask name if user is anonymous and NOT the current user viewing
        if (user.isAnonymous && uid != currentUserId) {
          anonymousCount++;
          displayName = 'Anonymous Donor $anonymousCount';
          displayPic = null;
        }

        entries.add(LeaderboardEntry(
          userId: uid,
          userName: displayName,
          profilePictureUrl: displayPic,
          totalAmount: total,
          donationAmount: donAmount,
          sponsorshipAmount: sponAmount,
          paymentCount: payments,
        ));
      }
    }

    // Sort based on type filter
    if (typeFilter == LeaderboardType.sponsor) {
      entries = entries.where((e) => e.sponsorshipAmount > 0).toList();
      entries.sort((a, b) => b.sponsorshipAmount.compareTo(a.sponsorshipAmount));
    } else if (typeFilter == LeaderboardType.donation) {
      entries = entries.where((e) => e.donationAmount > 0).toList();
      entries.sort((a, b) => b.donationAmount.compareTo(a.donationAmount));
    } else {
      entries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    }
    
    return entries;
  }

  final allTimeEntries = aggregate(filteredDonations, filteredSubs);

  // By Organization
  final Map<String, List<Donation>> orgDonations = {};
  for (var d in filteredDonations) {
    if (d.organizationName.isNotEmpty) {
      orgDonations.putIfAbsent(d.organizationName, () => []).add(d);
    }
  }

  final Map<String, List<LeaderboardEntry>> byOrganization = {};
  orgDonations.forEach((orgName, list) {
    final orgId = list.first.organizationId;
    final orgSubs = filteredSubs.where((s) => s.orgId == orgId || (s.targetType == 'org' && s.targetId == orgId)).toList();
    
    final aggregated = aggregate(list, orgSubs);
    if (aggregated.isNotEmpty) {
      byOrganization[orgName] = aggregated;
    }
  });

  return LeaderboardData(allTime: allTimeEntries, byOrganization: byOrganization);
});
