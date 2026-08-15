import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/models/child_sponsorship_model.dart';
import '../../../core/models/organization_model.dart';
import '../../organizations/providers/organization_providers.dart';
import '../data/sponsorship_repository.dart';
import '../providers/sponsorship_providers.dart';
import '../../profile/providers/user_providers.dart';
import '../../../core/models/user_model.dart';

class EditChildSponsorshipPage extends ConsumerStatefulWidget {
  final ChildSponsorship child;
  const EditChildSponsorshipPage({super.key, required this.child});

  @override
  ConsumerState<EditChildSponsorshipPage> createState() => _EditChildSponsorshipPageState();
}

class _EditChildSponsorshipPageState extends ConsumerState<EditChildSponsorshipPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _storyController;
  late TextEditingController _amountController;
  
  Uint8List? _imageBytes;
  String? _imageExtension;
  Organization? _selectedOrg;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.childName);
    _ageController = TextEditingController(text: widget.child.age.toString());
    _storyController = TextEditingController(text: widget.child.story);
    _amountController = TextEditingController(text: widget.child.monthlyNeeded.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _storyController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageExtension = pickedFile.name.split('.').last;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOrg == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an organization')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String imageUrl = widget.child.imageUrl;
      if (_imageBytes != null) {
        imageUrl = await ref.read(sponsorshipRepositoryProvider).uploadChildImage(
          widget.child.id!, 
          _imageBytes!, 
          _imageExtension ?? 'jpg',
        );
      }

      final updatedChild = ChildSponsorship(
        id: widget.child.id,
        organizationId: _selectedOrg!.id,
        organizationName: _selectedOrg!.name,
        childName: _nameController.text,
        age: int.tryParse(_ageController.text) ?? 0,
        story: _storyController.text,
        imageUrl: imageUrl,
        monthlyNeeded: double.tryParse(_amountController.text) ?? 0.0,
        currentSponsorId: widget.child.currentSponsorId,
      );

      await ref.read(childSponsorshipActionsProvider).saveChildSponsorship(updatedChild);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Child profile updated!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgsAsync = ref.watch(organizationsProvider);
    final user = ref.watch(userProfileProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Child Profile')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                        image: _imageBytes != null 
                          ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                          : (widget.child.imageUrl.isNotEmpty 
                              ? DecorationImage(image: getAppImageProvider(widget.child.imageUrl), fit: BoxFit.cover)
                              : null),
                      ),
                      child: _imageBytes == null && widget.child.imageUrl.isEmpty
                        ? const Center(child: Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey))
                        : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Child Name', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Monthly Need (৳)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  orgsAsync.when(
                    data: (orgs) {
                      final filteredOrgs = (user != null && user.role == UserRole.orphanageAdmin)
                          ? orgs.where((o) => o.id == user.assignedOrphanageId).toList()
                          : orgs;
                      
                      if (_selectedOrg == null) {
                        try {
                          _selectedOrg = orgs.firstWhere((o) => o.id == widget.child.organizationId);
                        } catch (_) {}
                      }

                      return DropdownButtonFormField<Organization>(
                        value: _selectedOrg,
                        decoration: const InputDecoration(labelText: 'Organization', border: OutlineInputBorder()),
                        items: filteredOrgs.map((o) => DropdownMenuItem(value: o, child: Text(o.name))).toList(),
                        onChanged: (v) => setState(() => _selectedOrg = v),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error loading organizations: $e'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _storyController,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Child\'s Story', border: OutlineInputBorder(), alignLabelWithHint: true),
                    validator: (v) => v!.isEmpty ? 'Story required' : null,
                  ),
                  const SizedBox(height: 32),
                  AppButton(text: 'Update Profile', onPressed: _submit),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _handleDelete(),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete Profile'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete ${widget.child.childName}\'s sponsorship profile?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      await ref.read(childSponsorshipActionsProvider).deleteChildSponsorship(widget.child.id!);
      if (mounted) context.pop();
    }
  }
}

