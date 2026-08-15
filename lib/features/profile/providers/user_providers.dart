import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_repository.dart';
import '../data/user_repository.dart';
import '../../../core/models/user_model.dart';

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final authData = ref.watch(authModelProvider);
  if (authData == null) return Stream.value(null);

  final repository = ref.watch(userRepositoryProvider);
  return repository.watchUserProfile(authData.uid).map((profile) {
    if (profile != null) {
      if (profile.status == 'suspended') {
        throw Exception('ACCOUNT_SUSPENDED');
      }
      return profile;
    }

    // Fallback to basic info from auth
    final isAdmin = authData.email == 'admin@gmail.com';
    return UserModel(
      uid: authData.uid,
      email: authData.email,
      name: isAdmin ? 'Admin' : '',
      phone: '',
      role: isAdmin ? UserRole.admin : UserRole.donor,
    );
  });
});

