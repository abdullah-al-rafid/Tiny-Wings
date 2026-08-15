import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_model.dart';
import '../auth/auth_repository.dart';
import '../layout/main_layout.dart';

import '../../features/auth/pages/welcome_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/profile/pages/profile_setup_page.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/home/pages/home.dart';
import '../../features/organizations/pages/organizations_page.dart';
import '../../features/organizations/pages/organization_details_page.dart';
import '../../features/organizations/pages/organization_supporters_page.dart';
import '../../features/needs/pages/needs_page.dart';
import '../../features/donations/pages/donate_page.dart';
import '../../features/donations/pages/donation_confirmation_page.dart';
import '../../features/donations/pages/impact_ledger_page.dart';
import '../../features/sponsorships/pages/sponsorships_page.dart';
import '../../features/sponsorships/pages/my_sponsorships_page.dart';
import '../../features/volunteering/pages/volunteer_page.dart';
import '../../features/volunteering/pages/opportunity_board_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/edit_profile_page.dart';
import '../../features/profile/pages/my_applications_page.dart';
import '../../features/profile/pages/suspended_page.dart';
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
import '../../features/profile/pages/impact_certificate_page.dart';
import '../../features/volunteering/pages/add_opportunity_page.dart';
import '../../features/admin/pages/manage_applications_page.dart';
import '../../features/admin/pages/admin_control_center_page.dart';

import '../../features/sponsorships/pages/add_child_sponsorship_page.dart';
import '../../features/sponsorships/pages/edit_child_sponsorship_page.dart';
import '../../features/volunteering/pages/add_life_opportunity_page.dart';
import '../../features/volunteering/pages/edit_life_opportunity_page.dart';
import '../models/child_sponsorship_model.dart';
import '../models/opportunity_model.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authModelProvider);

  return GoRouter(
    initialLocation: '/welcome',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuth = authState != null;
      final path = state.matchedLocation;
      
      final isPublicRoute = path == '/welcome' || 
                             path == '/login' || 
                             path == '/register';

      if (!isAuth && !isPublicRoute) {
        return '/login';
      }

      if (isAuth && isPublicRoute) {
        if (path == '/register') {
          return '/profile-setup';
        }
        return '/home';
      }

      // We handle suspension and roles inside the pages or via specific guards
      // to avoid complex redirect logic that can cause infinite loops.
      
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/welcome'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/welcome',
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
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
          return ProfileSetupPage(
            initialName: extra?['name'] as String?,
            initialPhone: extra?['phone'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/suspended',
        builder: (context, state) => const SuspendedPage(),
      ),
      
      // Main Application Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const Home(),
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

      // Profile Related
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/my-applications',
        builder: (context, state) => const MyApplicationsPage(),
      ),
      GoRoute(
        path: '/impact-certificate',
        builder: (context, state) => const ImpactCertificatePage(),
      ),

      // Organization Details (Full Screen)
      GoRoute(
        path: '/organizations/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrganizationDetailsPage(organizationId: id);
        },
      ),
      GoRoute(
        path: '/organizations/:id/supporters',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrganizationSupportersPage(orgId: id);
        },
      ),

      // Donation & Impact
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
        path: '/impact-ledger',
        builder: (context, state) => const ImpactLedgerPage(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardPage(),
      ),

      // Sponsorships
      GoRoute(
        path: '/sponsorships',
        builder: (context, state) => const SponsorshipsPage(),
      ),
      GoRoute(
        path: '/my-sponsorships',
        builder: (context, state) => const MySponsorshipsPage(),
      ),
      GoRoute(
        path: '/sponsorships/add-child',
        builder: (context, state) => const AddChildSponsorshipPage(),
      ),
      GoRoute(
        path: '/sponsorships/edit-child',
        builder: (context, state) {
          final child = state.extra as ChildSponsorship;
          return EditChildSponsorshipPage(child: child);
        },
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

      // Volunteering
      GoRoute(
        path: '/volunteer',
        builder: (context, state) => const VolunteerPage(),
      ),
      GoRoute(
        path: '/volunteer/add',
        builder: (context, state) => const AddOpportunityPage(),
      ),
      GoRoute(
        path: '/opportunity-board',
        builder: (context, state) => const OpportunityBoardPage(),
      ),
      GoRoute(
        path: '/opportunity-board/add',
        builder: (context, state) => const AddLifeOpportunityPage(),
      ),
      GoRoute(
        path: '/opportunity-board/edit',
        builder: (context, state) {
          final opp = state.extra as Opportunity;
          return EditLifeOpportunityPage(opp: opp);
        },
      ),

      // Settings
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

      // Admin Area
      GoRoute(
        path: '/admin/dashboard', // Changed from /admin-dashboard for consistency
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/control-center',
        builder: (context, state) => const AdminControlCenterPage(),
      ),
      GoRoute(
        path: '/admin/add-organization',
        builder: (context, state) => const AddOrganizationPage(),
      ),
      GoRoute(
        path: '/admin/manage-organizations',
        builder: (context, state) => const ManageOrganizationsPage(),
      ),
      GoRoute(
        path: '/admin/edit-organization/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditOrganizationPage(id: id);
        },
      ),
      GoRoute(
        path: '/admin/verify-organizations',
        builder: (context, state) => const ManageApplicationsPage(),
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
    ],
  );
});

