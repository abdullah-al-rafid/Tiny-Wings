import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/providers/user_providers.dart';
import '../data/volunteer_repository.dart';
import '../../../core/models/opportunity_model.dart';
import '../providers/volunteer_providers.dart';
import '../../../core/localization/app_localization.dart';

class AddLifeOpportunityPage extends ConsumerStatefulWidget {
  const AddLifeOpportunityPage({super.key});

  @override
  ConsumerState<AddLifeOpportunityPage> createState() => _AddLifeOpportunityPageState();
}

class _AddLifeOpportunityPageState extends ConsumerState<AddLifeOpportunityPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _eligibilityController = TextEditingController();
  final _contactMethodController = TextEditingController();
  
  OpportunityCategory _selectedCategory = OpportunityCategory.jobs;
  DateTime? _selectedDeadline;
  bool _isSaving = false;

  Future<void> _saveOpportunity() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    setState(() => _isSaving = true);

    final opp = Opportunity(
      id: '', // Backend assigns
      title: _titleController.text,
      category: _selectedCategory,
      description: _descriptionController.text,
      eligibility: _eligibilityController.text,
      deadline: _selectedDeadline,
      location: _locationController.text,
      contactMethod: _contactMethodController.text,
      postedBy: user.uid,
      organizationId: user.organizationId,
      status: OpportunityStatus.approved, // Direct approval for trusted posters
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(volunteerRepositoryProvider).addLifeOpportunity(opp);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.watch(translationProvider)['opp_posted']!)),
        );
        ref.invalidate(lifeOpportunitiesProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.coral),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t['post_opp']!),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E3A8A)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTextField(
                                label: 'Title',
                                controller: _titleController,
                                hint: 'e.g. IT Training Scholarship',
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 20),
                              _buildCategoryDropdown(t),
                              const SizedBox(height: 20),
                              _buildDeadlineField(t),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'Location',
                                controller: _locationController,
                                hint: 'e.g. Dhaka, Remote, etc.',
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'Eligibility',
                                controller: _eligibilityController,
                                hint: 'e.g. Students aged 15-18',
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'Contact/Apply Method',
                                controller: _contactMethodController,
                                hint: 'e.g. Email us at apply@org.com',
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'Description',
                                controller: _descriptionController,
                                hint: 'Full details of this opportunity...',
                                maxLines: 4,
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: _isSaving ? null : _saveOpportunity,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: _isSaving
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(t['post_opp']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFF1E3A8A).withValues(alpha: 0.35), fontSize: 13),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(Map<String, String> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
        const SizedBox(height: 8),
        DropdownButtonFormField<OpportunityCategory>(
          value: _selectedCategory,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          items: OpportunityCategory.values.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(t[cat.name] ?? cat.name, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
        ),
      ],
    );
  }

  Widget _buildDeadlineField(Map<String, String> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t['deadline']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 7)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (date != null) setState(() => _selectedDeadline = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDeadline == null 
                      ? 'No Deadline' 
                      : '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}',
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF1E3A8A)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

