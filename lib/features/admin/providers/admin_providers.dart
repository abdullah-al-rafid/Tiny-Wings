import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../donations/data/donation_repository.dart';
import '../../profile/data/user_repository.dart';
import '../../../models/donation_model.dart';
import '../../../models/user_model.dart';

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getAllUsers();
});

final allDonationsProvider = FutureProvider<List<Donation>>((ref) async {
  final repository = ref.watch(donationRepositoryProvider);
  return repository.getAllDonations();
});

class AdminStats {
  final int totalUsers;
  final double totalMoney;
  final double itemsWorth;
  final double totalImpact;
  final List<Donation> allDonations;

  AdminStats({
    required this.totalUsers,
    required this.totalMoney,
    required this.itemsWorth,
    required this.totalImpact,
    required this.allDonations,
  });
}

final adminStatsProvider = Provider<AsyncValue<AdminStats>>((ref) {
  final usersAsync = ref.watch(allUsersProvider);
  final donationsAsync = ref.watch(allDonationsProvider);

  return usersAsync.when(
    data: (users) => donationsAsync.when(
      data: (donations) {
        final totalMoney = donations
            .where((d) => d.type == DonationType.money && d.status == 'verified')
            .fold(0.0, (sum, d) => sum + (d.amount ?? 0.0));
            
        final itemsWorth = donations
            .where((d) => d.type == DonationType.items && d.status == 'verified')
            .fold(0.0, (sum, d) => sum + (d.approvedValue ?? 0.0));
            
        final totalImpact = totalMoney + itemsWorth;
        
        return AsyncValue.data(AdminStats(
          totalUsers: users.length,
          totalMoney: totalMoney,
          itemsWorth: itemsWorth,
          totalImpact: totalImpact,
          allDonations: donations,
        ));
      },
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'Food');
