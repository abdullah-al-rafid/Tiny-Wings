import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/need_providers.dart';

class NeedsPage extends ConsumerWidget {
  const NeedsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsAsync = ref.watch(approvedNeedsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedPriority = ref.watch(selectedPriorityProvider);

    return Scaffold(
      extendBody: true,
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

          // Decorative Blobs
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF93C5FD).withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC4B5FD).withValues(alpha: 0.3),
              ),
            ),
          ),

          // Blur layer
          Positioned.fill(
            child: RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: const SizedBox(),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header + Filters (frosted)
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        border: Border(
                          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Needs',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Browse and fulfill community needs',
                            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 16),

                          // Priority filter row
                          _buildFilterLabel('Priority'),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: 'All',
                                  isSelected: selectedPriority == 'All',
                                  color: const Color(0xFF6B7280),
                                  onTap: () => ref.read(selectedPriorityProvider.notifier).state = 'All',
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: '🔴 Urgent',
                                  isSelected: selectedPriority == 'Urgent',
                                  color: const Color(0xFFDC2626),
                                  onTap: () => ref.read(selectedPriorityProvider.notifier).state = 'Urgent',
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: '🟡 Normal',
                                  isSelected: selectedPriority == 'Normal',
                                  color: const Color(0xFFD97706),
                                  onTap: () => ref.read(selectedPriorityProvider.notifier).state = 'Normal',
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: '🟢 Low',
                                  isSelected: selectedPriority == 'Low',
                                  color: const Color(0xFF059669),
                                  onTap: () => ref.read(selectedPriorityProvider.notifier).state = 'Low',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Category filter row
                          _buildFilterLabel('Category'),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: 'All',
                                  isSelected: selectedCategory == 'All',
                                  color: const Color(0xFF3B82F6),
                                  onTap: () => ref.read(selectedCategoryProvider.notifier).state = 'All',
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: '🍚 Food',
                                  isSelected: selectedCategory == 'Food',
                                  color: const Color(0xFFF59E0B),
                                  onTap: () => ref.read(selectedCategoryProvider.notifier).state = 'Food',
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: '👕 Clothing',
                                  isSelected: selectedCategory == 'Clothing',
                                  color: const Color(0xFF8B5CF6),
                                  onTap: () => ref.read(selectedCategoryProvider.notifier).state = 'Clothing',
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: '💊 Medicine',
                                  isSelected: selectedCategory == 'Medicine',
                                  color: const Color(0xFFEC4899),
                                  onTap: () => ref.read(selectedCategoryProvider.notifier).state = 'Medicine',
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: '📚 Education',
                                  isSelected: selectedCategory == 'Education',
                                  color: const Color(0xFF0EA5E9),
                                  onTap: () => ref.read(selectedCategoryProvider.notifier).state = 'Education',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Need cards list
                Expanded(
                  child: RepaintBoundary(
                    child: needsAsync.when(
                      data: (needs) {
                        final activeNeeds = needs.where((n) => n.status != 'fulfilled').toList();
                        final filteredByCategory = selectedCategory == 'All'
                            ? activeNeeds
                            : activeNeeds.where((n) => _matchesCategory(n.category, selectedCategory)).toList();
                        final filteredNeeds = selectedPriority == 'All'
                            ? filteredByCategory
                            : filteredByCategory.where((n) => _matchesPriority(n.priority, selectedPriority)).toList();

                        if (filteredNeeds.isEmpty) {
                          return _buildEmptyState();
                        }

                        return RefreshIndicator(
                          onRefresh: () => ref.refresh(approvedNeedsProvider.future),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                            itemCount: filteredNeeds.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final need = filteredNeeds[index];
                              return _NeedCard(
                                title: need.title,
                                priority: need.priority,
                                organization: need.organizationName ?? 'Unknown Organization',
                                quantityOrAmount: need.quantityOrAmount,
                                targetQuantity: need.targetQuantity,
                                fulfilledQuantity: need.fulfilledQuantity,
                                unit: need.unit,
                                deadline: need.deadline,
                                category: need.category,
                                onDonatePressed: () {
                                  context.push('/donate', extra: {
                                    'organizationId': need.organizationId,
                                    'needTitle': need.title,
                                    'needAmount': need.targetQuantity > 0
                                        ? '${need.targetQuantity} ${need.unit}'
                                        : need.quantityOrAmount,
                                    'needCategory': need.category,
                                    'needId': need.id,
                                  });
                                },
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3A8A),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.inbox_rounded, size: 60, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No needs found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
        ],
      ),
    );
  }

  bool _matchesCategory(String actualCategory, String selectedCategory) {
    final normalized = actualCategory.toLowerCase();
    return switch (selectedCategory) {
      'Medicine' => normalized == 'medicine' || normalized == 'medical' || normalized == 'health',
      _ => normalized == selectedCategory.toLowerCase(),
    };
  }

  bool _matchesPriority(String actualPriority, String selectedPriority) {
    final normalized = actualPriority.toLowerCase();
    return switch (selectedPriority) {
      'Urgent' => normalized == 'urgent' || normalized == 'critical' || normalized == 'high',
      'Normal' => normalized == 'normal' || normalized == 'medium',
      'Low' => normalized == 'low',
      _ => normalized == selectedPriority.toLowerCase(),
    };
  }
}

// ─── Filter Chip ────────────────────────────────────────────────────────────

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.color
                    : (_isHovered
                        ? widget.color.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.color
                      : (_isHovered ? widget.color.withValues(alpha: 0.4) : Colors.white),
                ),
                boxShadow: (widget.isSelected || _isHovered)
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: widget.isSelected ? 0.3 : 0.12),
                          blurRadius: _isHovered ? 12 : 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: widget.isSelected
                      ? Colors.white
                      : (_isHovered ? widget.color : const Color(0xFF4B5563)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Need Card ───────────────────────────────────────────────────────────────

class _NeedCard extends StatefulWidget {
  final String title;
  final String priority;
  final String organization;
  final String quantityOrAmount;
  final double targetQuantity;
  final double fulfilledQuantity;
  final String unit;
  final String deadline;
  final String category;
  final VoidCallback onDonatePressed;

  const _NeedCard({
    required this.title,
    required this.priority,
    required this.organization,
    required this.quantityOrAmount,
    required this.targetQuantity,
    required this.fulfilledQuantity,
    required this.unit,
    required this.deadline,
    required this.category,
    required this.onDonatePressed,
  });

  @override
  State<_NeedCard> createState() => _NeedCardState();
}

class _NeedCardState extends State<_NeedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isUrgent = widget.priority.toLowerCase() == 'urgent';
    final bool isNormal = widget.priority.toLowerCase() == 'normal';

    final Color priorityColor = isUrgent
        ? const Color(0xFFDC2626)
        : (isNormal ? const Color(0xFFD97706) : const Color(0xFF059669));
    final Color priorityBg = isUrgent
        ? const Color(0xFFFEE2E2)
        : (isNormal ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5));

    // Progress
    final double progress = widget.targetQuantity > 0
        ? (widget.fulfilledQuantity / widget.targetQuantity).clamp(0.0, 1.0)
        : 0.0;

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.012 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.white.withValues(alpha: 0.78)
                      : Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered
                        ? priorityColor.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? priorityColor.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title row + priority badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isHovered
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.priority,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: priorityColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Organization
                    Row(
                      children: [
                        const Icon(Icons.business_rounded, size: 14, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 5),
                        Text(
                          widget.organization,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Progress bar (if applicable)
                    if (widget.targetQuantity > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.fulfilledQuantity.toStringAsFixed(0)} / ${widget.targetQuantity.toStringAsFixed(0)} ${widget.unit} fulfilled',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: priorityColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: priorityBg,
                          valueColor: AlwaysStoppedAnimation<Color>(priorityColor),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else if (widget.quantityOrAmount.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 14, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 5),
                          Text(
                            widget.quantityOrAmount,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Deadline
                    if (widget.deadline.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 5),
                          Text(
                            'Due: ${widget.deadline}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ] else
                      const SizedBox(height: 4),

                    // Donate button
                    _DonateButton(onTap: widget.onDonatePressed),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Donate Button ───────────────────────────────────────────────────────────

class _DonateButton extends StatefulWidget {
  final VoidCallback onTap;
  const _DonateButton({required this.onTap});

  @override
  State<_DonateButton> createState() => _DonateButtonState();
}

class _DonateButtonState extends State<_DonateButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isHovered
                      ? [const Color(0xFF2563EB), const Color(0xFF1D4ED8)]
                      : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: _isHovered ? 0.45 : 0.25),
                    blurRadius: _isHovered ? 18 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volunteer_activism_rounded, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Donate Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
