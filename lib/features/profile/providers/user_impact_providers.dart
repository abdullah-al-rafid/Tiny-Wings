import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../donations/providers/donation_providers.dart';
import '../../organizations/providers/organization_providers.dart';
import '../../sponsorships/providers/sponsorship_providers.dart';


class UserImpact {
  final double totalContributed;
  final int childrenSupported;
  final int activeCampaigns;

  UserImpact({
    required this.totalContributed,
    required this.childrenSupported,
    required this.activeCampaigns,
  });
}

final userImpactProvider = Provider<AsyncValue<UserImpact>>((ref) {
  final donationsAsync = ref.watch(userDonationsProvider);
  final organizationsAsync = ref.watch(organizationsProvider);
  final subscriptionsAsync = ref.watch(userSubscriptionsProvider);

  return donationsAsync.when(
    data: (donations) => organizationsAsync.when(
      data: (organizations) => subscriptionsAsync.when(
        data: (subscriptions) {
          // Total Donated (verified donations)
          final totalDonated = donations
              .where((d) => d.status == 'verified')
              .fold(0.0, (sum, d) => sum + (d.approvedValue ?? d.amount ?? 0.0));

          // Total Sponsored (all-time paid across active/completed sponsorships)
          final totalSponsored = subscriptions
              .fold(0.0, (sum, s) => sum + s.totalAmountPaid);

          final totalContributed = totalDonated + totalSponsored;

          // Get unique organization IDs supported
          final supportedOrgIds = donations.map((d) => d.organizationId).toSet();

          // Total Children Supported
          final childrenSupported = organizations
              .where((org) => supportedOrgIds.contains(org.id))
              .fold(0, (sum, org) => sum + org.totalChildren);

          return AsyncValue.data(UserImpact(
            totalContributed: totalContributed,
            childrenSupported: childrenSupported,
            activeCampaigns: supportedOrgIds.length,
          ));
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      ),
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
