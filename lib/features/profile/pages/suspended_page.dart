import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class SuspendedPage extends ConsumerWidget {
  const SuspendedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.block, size: 64, color: Colors.red),
            ),
            const SizedBox(height: 32),
            const Text(
              'Account Disabled',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your access to the TinyWings platform has been suspended by an administrator due to a violation of our community guidelines or pending verification.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 48),
            AppButton(
              text: 'Log Out',
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Potential link to support
              },
              child: const Text('Contact Support', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
