import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../data/organization_repository.dart';
import '../../../core/models/organization_model.dart';
import '../providers/organization_providers.dart';
import '../../profile/providers/user_providers.dart';
import '../../../core/models/user_model.dart';

class AddOrganizationPage extends ConsumerStatefulWidget {
  const AddOrganizationPage({super.key});

  @override
  ConsumerState<AddOrganizationPage> createState() => _AddOrganizationPageState();
}

class _AddOrganizationPageState extends ConsumerState<AddOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _aboutController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _totalChildrenController = TextEditingController();
  
  Uint8List? _imageBytes;
  String? _imageExtension;
  bool _isVerified = false;
  bool _isFeatured = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _aboutController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _totalChildrenController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageExtension = pickedFile.name.split('.').last;
      });
    }
  }

  Future<void> _submit() async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final id = _nameController.text.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');
      
      // 1. Upload Cover Image (Optional)
      String imageUrl = '';
      if (_imageBytes != null) {
        imageUrl = await ref.read(organizationRepositoryProvider).uploadOrganizationCover(
          id, 
          _imageBytes!, 
          _imageExtension ?? 'jpg',
        );
      }

      // 2. Create Organization object
      final organization = Organization(
        id: id,
        name: _nameController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        about: _aboutController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        imageUrl: imageUrl,
        status: user.role == UserRole.admin 
            ? (_isVerified ? VerificationStatus.verified : VerificationStatus.pending)
            : VerificationStatus.pending,
        isFeatured: user.role == UserRole.admin ? _isFeatured : false,
        totalChildren: int.tryParse(_totalChildrenController.text) ?? 0,
        submittedBy: user.uid,
        submittedAt: DateTime.now(),
      );

      // 3. Save to Database
      await ref.read(organizationRepositoryProvider).saveOrganization(organization);
      
      ref.invalidate(organizationsProvider);

      if (mounted) {
        final message = user.role == UserRole.admin 
            ? 'Organization added successfully!' 
            : 'Submission received! It will be reviewed by an admin.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.role == UserRole.admin ? 'Add Organization' : 'Submit Orphanage'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader('Basic Information'),
                  const SizedBox(height: 16),
                  
                  // Cover Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        image: _imageBytes != null 
                          ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                          : null,
                      ),
                      child: _imageBytes == null 
                        ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 40, color: Color(0xFF9CA3AF)),
                            SizedBox(height: 8),
                            Text('Upload Cover Photo', style: TextStyle(color: Color(0xFF6B7280))),
                          ],
                        ) 
                        : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Organization Name'),
                    validator: (v) => v!.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location (e.g., Dhaka)'),
                    validator: (v) => v!.isEmpty ? 'Location is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _totalChildrenController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total Children Supported'),
                    validator: (v) => v!.isEmpty ? 'Please enter a number' : null,
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Contact Details'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number (Optional)'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email Address (Optional)'),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Details'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Short Description'),
                    validator: (v) => v!.isEmpty ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _aboutController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'About / Mission'),
                  ),
                  const SizedBox(height: 16),
                  
                  if (user?.role == UserRole.admin) ...[
                    SwitchListTile(
                      title: const Text('Official / Verified'),
                      subtitle: const Text('Admin bypass for instant verification'),
                      value: _isVerified,
                      onChanged: (val) => setState(() => _isVerified = val),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Featured on Home Page'),
                      value: _isFeatured,
                      onChanged: (val) => setState(() => _isFeatured = val),
                    ),
                  ],

                  const SizedBox(height: 32),

                  AppButton(
                    text: user?.role == UserRole.admin ? 'Save Organization' : 'Submit for Verification',
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

