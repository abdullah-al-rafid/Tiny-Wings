import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/models/need_model.dart';
import '../../needs/providers/need_providers.dart';
import '../../organizations/providers/organization_providers.dart';
import '../../notifications/data/notification_repository.dart';
import '../../notifications/providers/notification_providers.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/auth/auth_repository.dart';

class AddNeedPage extends ConsumerStatefulWidget {
  const AddNeedPage({super.key});

  @override
  ConsumerState<AddNeedPage> createState() => _AddNeedPageState();
}

class _AddNeedPageState extends ConsumerState<AddNeedPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedOrgId;
  String? _selectedCategory;
  String _priority = 'Normal';
  
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _targetQuantityController = TextEditingController();
  final _deadlineController = TextEditingController();
  final List<String> _units = ['pcs', 'kg', 'sets', 'packs', 'units', 'box'];
  String _unit = 'pcs';

  final List<String> _categories = ['Food', 'Clothing', 'Medicine', 'Education', 'Other'];

  bool _isLoading = false;

  Future<void> _submitNeed() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOrgId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an organization')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orgs = ref.read(organizationsProvider).value ?? [];
      final selectedOrg = orgs.firstWhere((o) => o.id == _selectedOrgId);

      final newNeed = Need(
        id: '', // Empty means new
        organizationId: _selectedOrgId!,
        organizationName: selectedOrg.name,
        title: _titleController.text,
        category: _selectedCategory!,
        priority: _priority,
        subtitle: _subtitleController.text,
        quantityOrAmount: '${_targetQuantityController.text} $_unit',
        targetQuantity: double.tryParse(_targetQuantityController.text) ?? 1.0,
        fulfilledQuantity: 0.0,
        unit: _unit,
        deadline: _deadlineController.text,
        status: 'approved', // Admin creating it, so default is approved
        createdAt: DateTime.now(),
      );

      await ref.read(needActionsProvider).saveNeed(newNeed);

      // Trigger notification if urgent
      if (_priority == 'Urgent') {
        final authData = ref.read(authModelProvider);
        if (authData != null) {
          final notification = AppNotification(
            id: '', 
            userId: authData.uid, // In a real app, this would be broadcast to followers
            title: 'Urgent Need Posted',
            message: 'A new urgent need for "${newNeed.title}" has been posted by ${newNeed.organizationName}.',
            type: NotificationType.need,
            timestamp: DateTime.now(),
            relatedId: newNeed.id,
          );
          await ref.read(notificationRepositoryProvider).sendNotification(notification);
          ref.invalidate(notificationsProvider);
        }
      }
      
      // Refresh providers
      ref.invalidate(approvedNeedsProvider);
      ref.invalidate(needsByOrgProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Need added successfully!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding need: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _targetQuantityController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orgsAsync = ref.watch(organizationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Need')),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    orgsAsync.when(
                      data: (orgs) {
                        return DropdownButtonFormField<String>(
                          value: _selectedOrgId,
                          decoration: const InputDecoration(labelText: 'Organization'),
                          items: orgs.map((org) => DropdownMenuItem(
                            value: org.id,
                            child: Text(org.name),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedOrgId = val),
                          validator: (val) => val == null ? 'Required' : null,
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error loading orgs: $e'),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Need Title (e.g. Winter Clothing)'),
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _subtitleController,
                      decoration: const InputDecoration(labelText: 'Short Description/Subtitle'),
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: ['Normal', 'Urgent'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (val) => setState(() => _priority = val!),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _targetQuantityController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Target Quantity (e.g. 50)'),
                            validator: (val) => val!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _unit,
                            decoration: const InputDecoration(labelText: 'Unit'),
                            items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (val) => setState(() => _unit = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _deadlineController,
                      decoration: const InputDecoration(labelText: 'Deadline (e.g. Deadline: Dec 20, 2026)'),
                    ),
                    const SizedBox(height: 32),

                    AppButton(
                      style: AppButtonStyle.cta,
                      text: 'Submit Need',
                      onPressed: _submitNeed,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

