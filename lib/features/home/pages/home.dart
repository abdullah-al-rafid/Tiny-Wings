import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_page.dart'; // Import for DashboardView and HomeBackground
import '../widgets/post_card.dart';
import '../widgets/create_post_dialog.dart';
import '../providers/post_providers.dart';
import '../../profile/providers/user_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    final isAdmin = userProfile?.isAdmin ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: isAdmin 
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90), // Nudge up above nav bar
              child: FloatingActionButton.extended(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => const CreatePostDialog(),
                ),
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('Post Update'),
                backgroundColor: AppColors.primary,
              ),
            )
          : null,
      body: Stack(
        children: [
          // Premium Unified Background
          const HomeBackground(),
          
          RefreshIndicator(
            onRefresh: () => ref.refresh(postsProvider.future),
            child: CustomScrollView(
              slivers: [
                // Dashbord Section (Teammate's content)
                SliverSafeArea(
                  bottom: false,
                  sliver: SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing, 
                      vertical: AppTheme.padding,
                    ),
                    sliver: const SliverToBoxAdapter(
                      child: DashboardView(),
                    ),
                  ),
                ),

                // Social Feed Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Impact Updates',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            if (!isAdmin)
                              Icon(Icons.feed_rounded, color: const Color(0xFF1E3A8A).withValues(alpha: 0.3)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'See how your contributions are making a difference.',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF1E3A8A).withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Social Feed Content
                postsAsync.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.bubble_chart_outlined, size: 60, color: Colors.blue.withValues(alpha: 0.2)),
                                const SizedBox(height: 12),
                                Text(
                                  'Be the first to share an update!',
                                  style: TextStyle(color: Colors.blue.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => PostCard(post: posts[index]),
                          childCount: posts.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Text('Error loading feed: $e')),
                  ),
                ),

                // Bottom Spacing for FAB/Nav
                const SliverToBoxAdapter(
                  child: SizedBox(height: 160), // Increased for more clearance
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
