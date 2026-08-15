import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/volunteer_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../../profile/providers/user_providers.dart';
import '../../../core/models/user_model.dart';
import '../data/volunteer_repository.dart';
import '../data/application_repository.dart';
import '../../../core/models/application_model.dart';
import '../../../core/localization/app_localization.dart';
import 'dart:ui';

class VolunteerPage extends ConsumerWidget {
  const VolunteerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(filteredVolunteerOpportunitiesProvider);
    final user = ref.watch(userProfileProvider).value;
    final t = ref.watch(translationProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t['volunteering']!),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (user?.role == UserRole.admin || user?.role == UserRole.orphanageAdmin || user?.role == UserRole.opportunityPoster)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1E3A8A)),
              onPressed: () => context.push('/volunteer/add'),
            ),
        ],
      ),
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
          // Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox(),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header with search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                        ),
                        child: TextField(
                          onChanged: (val) => ref.read(volunteerSearchQueryProvider.notifier).state = val,
                          decoration: InputDecoration(
                            hintText: t['search_opps']!,
                            hintStyle: TextStyle(color: const Color(0xFF1E3A8A).withValues(alpha: 0.4)),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A8A)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: opportunitiesAsync.when(
                    data: (opportunities) {
                      if (opportunities.isEmpty) {
                        return Center(
                          child: Text(
                            'No opportunities found.', 
                            style: TextStyle(color: const Color(0xFF1E3A8A).withValues(alpha: 0.5))
                          )
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: opportunities.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final opp = opportunities[index];
                          return _VolunteerCard(
                            oppid: opp.id,
                            title: opp.title,
                            organization: opp.organizationName,
                            date: '${opp.date.day}/${opp.date.month}/${opp.date.year}',
                            time: opp.time,
                            location: opp.location,
                            description: opp.description,
                            isApplied: opp.appliedUserIds.contains(user?.uid),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VolunteerCard extends ConsumerWidget {
  final String oppid;
  final String title;
  final String organization;
  final String date;
  final String time;
  final String location;
  final String description;
  final bool isApplied;

  const _VolunteerCard({
    required this.oppid,
    required this.title,
    required this.organization,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    this.isApplied = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider).value;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    if (isApplied)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          ref.watch(translationProvider)['already_applied']!,
                          style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  organization,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                _InfoRow(icon: Icons.calendar_today_outlined, text: date),
                const SizedBox(height: 10),
                _InfoRow(icon: Icons.access_time_outlined, text: time),
                const SizedBox(height: 10),
                _InfoRow(icon: Icons.location_on_outlined, text: location),
                const SizedBox(height: 20),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isApplied || user == null 
                    ? null 
                    : () async {
                        try {
                           // 1. Submit formal application
                          await ref.read(applicationRepositoryProvider).submitApplication(
                            VolunteerApplication(
                              id: '', // Generated by Firebase
                              userId: user.uid,
                              userName: user.name.isNotEmpty ? user.name : 'User',
                              opportunityId: oppid,
                              opportunityTitle: title,
                              organizationName: organization,
                              status: ApplicationStatus.pending,
                              appliedAt: DateTime.now(),
                            )
                          );

                          // 2. Mark on opportunity (Existing logic)
                          await ref.read(volunteerRepositoryProvider).applyForOpportunity(oppid, user.uid);
                          
                          ref.invalidate(volunteerOpportunitiesProvider);
                          ref.invalidate(userApplicationsProvider(user.uid));

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Successfully applied! Check "My Applications" for status.')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApplied ? Colors.grey.shade200 : const Color(0xFF3B82F6),
                  foregroundColor: isApplied ? Colors.grey.shade600 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isApplied ? ref.watch(translationProvider)['already_applied']! : ref.watch(translationProvider)['apply_now']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF3B82F6).withValues(alpha: 0.7)),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
