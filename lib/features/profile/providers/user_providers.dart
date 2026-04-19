import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_repository.dart';
import '../data/user_repository.dart';
import '../../../models/user_model.dart';

final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final authData = ref.watch(authModelProvider);
  if (authData == null) return null;

  final repository = ref.watch(userRepositoryProvider);
  try {
    final profile = await repository.getUserProfile(authData.uid);
    if (profile != null) return profile;
  } catch (e) {
    // If permission denied or other error, fallback to basic info
    print('Error fetching profile: $e');
  }

  // Fallback to basic info from auth
  final isAdmin = authData.email == 'admin@tinywings.com';
  return UserModel(
    uid: authData.uid,
    email: authData.email,
    name: isAdmin ? 'Admin' : '',
    phone: '',
    type: isAdmin ? 'Admin' : 'Donor',
  );
});
