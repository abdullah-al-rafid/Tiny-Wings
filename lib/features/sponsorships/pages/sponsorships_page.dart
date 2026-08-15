import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image.dart';
import '../../organizations/providers/organization_providers.dart';
import '../providers/sponsorship_providers.dart';
import '../../profile/providers/user_providers.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/child_sponsorship_model.dart';
import '../../../core/localization/app_localization.dart';
import 'dart:ui';

class SponsorshipsPage extends ConsumerStatefulWidget {
  const SponsorshipsPage({super.key});

  @override
  ConsumerState<SponsorshipsPage> createState() => _SponsorshipsPageState();
}

class _SponsorshipsPageState extends ConsumerState<SponsorshipsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationProvider);
    final user = ref.watch(userProfileProvider).value;
    final isAdmin = user?.role == UserRole.admin || user?.role == UserRole.orphanageAdmin;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t['impact_sponsorships']!),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: t['institutions'] ?? 'Institutions'),
            Tab(text: t['children'] ?? 'Children'),
          ],
          indicatorColor: const Color(0xFF1E3A8A),
          labelColor: const Color(0xFF1E3A8A),
          unselectedLabelColor: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF3E8FF), Color(0xFFE0E7FF), Color(0xFFFAE8FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox(),
            ),
          ),
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrgsTab(),
                _buildChildrenTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            context.push('/admin/add-organization');
          } else {
            context.push('/sponsorships/add-child');
          }
        },
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(_tabController.index == 0 ? 'Add Institution' : 'Add Child', style: const TextStyle(color: Colors.white)),
      ) : null,
    );
  }

  Widget _buildOrgsTab() {
    final orgsAsync = ref.watch(organizationsProvider);
    final t = ref.watch(translationProvider);

    return orgsAsync.when(
      data: (orgs) {
        if (orgs.isEmpty) return Center(child: Text('No institutions available.', style: TextStyle(color: const Color(0xFF1E3A8A).withValues(alpha: 0.5))));

        return ListView.builder(
          padding: EdgeInsets.all(AppTheme.spacing),
          itemCount: orgs.length,
          itemBuilder: (context, index) {
            final org = orgs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SponsorshipCard(
                title: org.name,
                subtitle: org.location,
                imageUrl: org.imageUrl,
                tag: '${t['supports_over']!} ${org.impactChildCount ?? "50+"} ${t['children']!}',
                onTap: () => context.push('/sponsorship-checkout', extra: {
                  'targetType': 'org',
                  'targetId': org.id,
                  'targetName': org.name,
                  'orgId': org.id,
                  'amount': 1000.0,
                }),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildChildrenTab() {
    final childrenAsync = ref.watch(childSponsorshipsProvider);
    final user = ref.watch(userProfileProvider).value;
    final isAdmin = user?.role == UserRole.admin || user?.role == UserRole.orphanageAdmin;

    return childrenAsync.when(
      data: (children) {
        if (children.isEmpty) return Center(child: Text('No sponsorship posts yet.', style: TextStyle(color: const Color(0xFF1E3A8A).withValues(alpha: 0.5))));

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) {
            final child = children[index];
            return _ChildSponsorshipCard(
              child: child, 
              isAdmin: isAdmin,
              onSponsor: () => context.push('/sponsorship-checkout', extra: {
                'targetType': 'child',
                'targetId': child.id,
                'targetName': child.childName,
                'orgId': child.organizationId,
                'amount': child.monthlyNeeded,
              }),
              onEdit: () => context.push('/sponsorships/edit-child', extra: child),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _SponsorshipCard extends StatelessWidget {
  final String title, subtitle, imageUrl, tag;
  final VoidCallback onTap;

  const _SponsorshipCard({required this.title, required this.subtitle, required this.imageUrl, required this.tag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(color: const Color(0xFF3B82F6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                  child: imageUrl.isNotEmpty
                    ? ClipRRect(borderRadius: BorderRadius.circular(16), child: AppImage(imageUrl: imageUrl, fit: BoxFit.cover))
                    : const Icon(Icons.business_rounded, color: Color(0xFF3B82F6), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E3A8A))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 4),
                          Text(subtitle, style: TextStyle(color: const Color(0xFF1E3A8A).withValues(alpha: 0.5), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF3B82F6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF1E3A8A), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildSponsorshipCard extends StatelessWidget {
  final ChildSponsorship child;
  final bool isAdmin;
  final VoidCallback onSponsor;
  final VoidCallback onEdit;

  const _ChildSponsorshipCard({required this.child, required this.isAdmin, required this.onSponsor, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: AppImage(imageUrl: child.imageUrl, fit: BoxFit.cover)),
                if (isAdmin) Positioned(
                  top: 8, right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(icon: const Icon(Icons.edit, size: 18, color: Color(0xFF1E3A8A)), onPressed: onEdit),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    ),
                    child: Text(
                      '${child.childName}, ${child.age}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.organizationName,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('৳${child.monthlyNeeded.toInt()}/mo', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A))),
                    InkWell(
                      onTap: onSponsor,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(12)),
                        child: const Text('SPONSOR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

