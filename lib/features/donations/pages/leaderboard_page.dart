import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_repository.dart';
import '../providers/leaderboard_providers.dart';
import '../widgets/premium_leaderboard_card.dart';
import '../../../core/localization/app_localization.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> with SingleTickerProviderStateMixin {
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
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final authData = ref.watch(authModelProvider);
    final t = ref.watch(translationProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
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
          
          // Abstract Decorative Blobs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF93C5FD).withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC4B5FD).withValues(alpha: 0.4),
              ),
            ),
          ),
          
          // Blur Layer
          Positioned.fill(
            child: RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: const SizedBox(),
              ),
            ),
          ),

          // Main Content
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: Text(t['top_contributors']!, style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.white.withValues(alpha: 0.6),
                  foregroundColor: const Color(0xFF1E3A8A),
                  elevation: 0,
                  pinned: true,
                  floating: true,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF1E3A8A),
                    unselectedLabelColor: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                    indicatorColor: const Color(0xFF3B82F6),
                    indicatorWeight: 3,
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) return const Color(0xFF3B82F6).withValues(alpha: 0.1);
                      if (states.contains(WidgetState.pressed)) return const Color(0xFF3B82F6).withValues(alpha: 0.2);
                      return null;
                    }),
                    tabs: [
                      Tab(text: t['all_time']!),
                      Tab(text: t['by_org']!),
                    ],
                  ),
                ),
              ];
            },
            body: RepaintBoundary(
              child: leaderboardAsync.when(
                data: (data) => TabBarView(
                  controller: _tabController,
                  children: [
                    Column(
                      children: [
                        const _TimeFilterHeader(),
                        const _CategoryFilterHeader(),
                        Expanded(child: _LeaderboardList(entries: data.allTime, currentUserId: authData?.uid)),
                      ],
                    ),
                    _OrganizationLeaderboardTab(
                      byOrganization: data.byOrganization, 
                      currentUserId: authData?.uid,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String? currentUserId;

  const _LeaderboardList({required this.entries, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No data available yet.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final double topAmount = entries.first.totalAmount;

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final bool isCurrentUser = entry.userId == currentUserId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PremiumLeaderboardCard(
            entry: entry,
            rank: index + 1,
            topAmount: topAmount,
            isCurrentUser: isCurrentUser,
          ),
        );
      },
    );
  }
}

class _OrganizationLeaderboardTab extends ConsumerStatefulWidget {
  final Map<String, List<LeaderboardEntry>> byOrganization;
  final String? currentUserId;

  const _OrganizationLeaderboardTab({
    required this.byOrganization,
    this.currentUserId,
  });

  @override
  ConsumerState<_OrganizationLeaderboardTab> createState() => _OrganizationLeaderboardTabState();
}

class _OrganizationLeaderboardTabState extends ConsumerState<_OrganizationLeaderboardTab> {
  String? selectedOrg;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    if (widget.byOrganization.isNotEmpty) {
      final keys = widget.byOrganization.keys.toList()..sort();
      selectedOrg = keys.first;
    }
  }

  @override
  void didUpdateWidget(_OrganizationLeaderboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.byOrganization.isNotEmpty) {
      if (selectedOrg == null || !widget.byOrganization.containsKey(selectedOrg!)) {
        final keys = widget.byOrganization.keys.toList()..sort();
        selectedOrg = keys.first;
      }
    } else {
      selectedOrg = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.byOrganization.isEmpty) {
      return const Center(
        child: Text(
          'No organization data available.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final orgNames = widget.byOrganization.keys.toList()..sort();
    final entries = selectedOrg != null ? widget.byOrganization[selectedOrg!] ?? [] : <LeaderboardEntry>[];

    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: _isHovered ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.4),
              border: const Border(bottom: BorderSide(color: Colors.white24)),
              boxShadow: _isHovered ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: DropdownButtonFormField<String>(
              value: selectedOrg,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: ref.watch(translationProvider)['select_org']!,
                filled: true,
                fillColor: _isHovered ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              dropdownColor: Colors.white,
              items: orgNames.map((org) {
                return DropdownMenuItem(
                  value: org,
                  child: Text(
                    org,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedOrg = val;
                });
              },
            ),
          ),
        ),
        Expanded(
          child: _LeaderboardList(entries: entries, currentUserId: widget.currentUserId),
        ),
      ],
    );
  }
}

class _CategoryFilterHeader extends ConsumerWidget {
  const _CategoryFilterHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(leaderboardTypeProvider);
    final t = ref.watch(translationProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        border: const Border(bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterButton(
              label: t['total']!,
              icon: Icons.star_border,
              isSelected: selectedType == LeaderboardType.total,
              onTap: () => ref.read(leaderboardTypeProvider.notifier).state = LeaderboardType.total,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterButton(
              label: t['sponsors']!,
              icon: Icons.favorite_border,
              isSelected: selectedType == LeaderboardType.sponsor,
              onTap: () => ref.read(leaderboardTypeProvider.notifier).state = LeaderboardType.sponsor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterButton(
              label: t['donors']!,
              icon: Icons.volunteer_activism_outlined,
              isSelected: selectedType == LeaderboardType.donation,
              onTap: () => ref.read(leaderboardTypeProvider.notifier).state = LeaderboardType.donation,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? const Color(0xFF3B82F6) 
                    : (_isHovered ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isSelected ? const Color(0xFF2563EB) : Colors.white,
                ),
                boxShadow: widget.isSelected || _isHovered ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: widget.isSelected ? 0.3 : 0.15),
                    blurRadius: _isHovered ? 12 : 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 18,
                    color: widget.isSelected 
                        ? Colors.white 
                        : const Color(0xFF1E3A8A).withValues(alpha: _isHovered ? 1.0 : 0.7),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.isSelected 
                          ? Colors.white 
                          : const Color(0xFF1E3A8A).withValues(alpha: _isHovered ? 1.0 : 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeFilterHeader extends ConsumerWidget {
  const _TimeFilterHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(leaderboardFilterProvider);
    final t = ref.watch(translationProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        border: const Border(bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 20, color: Color(0xFF1E3A8A)),
          const SizedBox(width: 8),
          Text('${t['period']!}: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<LeaderboardFilter>(
                  value: selectedFilter,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: LeaderboardFilter.allTime, child: Text('All Time')),
                    DropdownMenuItem(value: LeaderboardFilter.twoDays, child: Text('Last 2 Days (Test)')),
                    DropdownMenuItem(value: LeaderboardFilter.fiveDays, child: Text('Last 5 Days (Test)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(leaderboardFilterProvider.notifier).state = val;
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
