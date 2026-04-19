import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/subscription_model.dart';

import '../auth/auth_repository.dart';
import '../layout/main_layout.dart';

import '../../features/auth/pages/welcome_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/profile/pages/profile_setup_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/organizations/pages/organizations_page.dart';
import '../../features/organizations/pages/organization_details_page.dart';
import '../../features/organizations/pages/organization_supporters_page.dart';
import '../../features/needs/pages/needs_page.dart';
import '../../features/donations/pages/donate_page.dart';
import '../../features/donations/pages/donation_confirmation_page.dart';
import '../../features/sponsorships/pages/sponsorships_page.dart';
import '../../features/sponsorships/pages/my_sponsorships_page.dart';
import '../../features/volunteering/pages/volunteer_page.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/edit_profile_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/settings/pages/change_password_page.dart';
import '../../features/settings/pages/privacy_settings_page.dart';
import '../../features/settings/pages/notification_settings_page.dart';
import '../../features/settings/pages/help_support_page.dart';
import '../../features/admin/pages/admin_dashboard_page.dart';
import '../../features/admin/pages/user_feedback_page.dart';
import '../../features/admin/pages/manage_organizations_page.dart';
import '../../features/organizations/pages/add_organization_page.dart';
import '../../features/organizations/pages/edit_organization_page.dart';
import '../../features/admin/pages/verify_donations_page.dart';
import '../../features/donations/pages/donation_history_page.dart';
import '../../features/donations/pages/leaderboard_page.dart';
import '../../features/admin/pages/add_need_page.dart';
import '../../features/admin/pages/pending_needs_page.dart';
import '../../features/sponsorships/pages/sponsor_checkout_page.dart';

 final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authModelProvider);

  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final isAuth = authState != null;
      final isSplash = state.matchedLocation == '/welcome' || 
                       state.matchedLocation == '/login' || 
                       state.matchedLocation == '/register';

      if (!isAuth && !isSplash) {
        return '/login';
      }

      if (isAuth && isSplash) {
        if (state.matchedLocation == '/register') {
          return '/profile-setup';
        }
        return '/home';
      }

      return null;
    },
    routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/add-organization',
      name: 'add-organization',
      builder: (context, state) => const AddOrganizationPage(),
    ),
    GoRoute(
      path: '/admin/manage-organizations',
      builder: (context, state) => const ManageOrganizationsPage(),
    ),
    GoRoute(
      path: '/admin/verify-donations',
      builder: (context, state) => const VerifyDonationsPage(),
    ),
    GoRoute(
      path: '/admin/add-need',
      builder: (context, state) => const AddNeedPage(),
    ),
    GoRoute(
      path: '/admin/pending-needs',
      builder: (context, state) => const PendingNeedsPage(),
    ),
    GoRoute(
      path: '/admin/feedback',
      builder: (context, state) => const UserFeedbackPage(),
    ),
    GoRoute(
      path: '/admin/edit-organization/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EditOrganizationPage(id: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: '/privacy-settings',
      builder: (context, state) => const PrivacySettingsPage(),
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsPage(),
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final name = extra?['name'] as String?;
        final phone = extra?['phone'] as String?;
        return ProfileSetupPage(initialName: name, initialPhone: phone);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/organizations',
              builder: (context, state) => const OrganizationsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/needs',
              builder: (context, state) => const NeedsPage(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/organizations/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return OrganizationDetailsPage(organizationId: id);
      },
    ),
    GoRoute(
      path: '/donate',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return DonatePage(
          preselectedOrgId: extra?['organizationId'] as String?,
          preselectedNeedTitle: extra?['needTitle'] as String?,
          preselectedNeedAmount: extra?['needAmount'] as String?,
          preselectedNeedCategory: extra?['needCategory'] as String?,
          preselectedNeedId: extra?['needId'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/donation-confirmation',
      builder: (context, state) => const DonationConfirmationPage(),
    ),
    GoRoute(
      path: '/donation-history',
      builder: (context, state) => const DonationHistoryPage(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardPage(),
    ),
    GoRoute(
      path: '/sponsorships',
      builder: (context, state) => const SponsorshipsPage(),
    ),
    GoRoute(
      path: '/my-sponsorships',
      builder: (context, state) => const MySponsorshipsPage(),
    ),
    GoRoute(
      path: '/sponsorship-checkout',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SponsorCheckoutPage(
          targetType: extra?['targetType'] as String? ?? 'org',
          targetId: extra?['targetId'] as String? ?? '',
          targetName: extra?['targetName'] as String? ?? '',
          orgId: extra?['orgId'] as String? ?? '',
          amount: (extra?['amount'] as num?)?.toDouble() ?? 1000.0,
          subscriptionToRenew: extra?['subscriptionToRenew'] as Subscription?,
        );
      },
    ),
    GoRoute(
      path: '/organizations/:id/supporters',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return OrganizationSupportersPage(orgId: id);
      },
    ),
    GoRoute(
      path: '/volunteer',
      builder: (context, state) => const VolunteerPage(),
    ),
  ],
);
});