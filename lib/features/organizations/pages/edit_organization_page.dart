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
import '../../../core/widgets/app_image.dart';

class EditOrganizationPage extends ConsumerStatefulWidget {
  final String id;
  const EditOrganizationPage({super.key, required this.id});

  @override
  ConsumerState<EditOrganizationPage> createState() => _EditOrganizationPageState();
}

class _EditOrganizationPageState extends ConsumerState<EditOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _aboutController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _childrenController;
  
  bool _isVerified = false;
  bool _isFeatured = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  
  Uint8List? _imageBytes;
  String? _imageExtension;
  String _currentImageUrl = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _aboutController = TextEditingController();
    _locationController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _childrenController = TextEditingController();
  }

  void _initialize(Organization org) {
    if (_isInitialized) return;
    _nameController.text = org.name;
    _descriptionController.text = org.description;
    _aboutController.text = org.about;
    _locationController.text = org.location;
    _phoneController.text = org.phone;
    _emailController.text = org.email;
    _childrenController.text = org.totalChildren.toString();
    _isVerified = org.isVerified;
    _isFeatured = org.isFeatured;
    _currentImageUrl = org.imageUrl;
    _isInitialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _aboutController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _childrenController.dispose();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String imageUrl = _currentImageUrl;
      if (_imageBytes != null) {
        imageUrl = await ref.read(organizationRepositoryProvider).uploadOrganizationCover(
          widget.id, 
          _imageBytes!, 
          _imageExtension ?? 'jpg',
        );
      }

      final organization = Organization(
        id: widget.id,
        name: _nameController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        about: _aboutController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        imageUrl: imageUrl,
        status: _isVerified ? VerificationStatus.verified : VerificationStatus.pending,
        isFeatured: _isFeatured,
        totalChildren: int.tryParse(_childrenController.text) ?? 0,
      );

      await ref.read(organizationRepositoryProvider).saveOrganization(organization);
      ref.invalidate(organizationsProvider);
      ref.invalidate(organizationDetailsProvider(widget.id));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization updated successfully!')),
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
    final orgAsync = ref.watch(organizationDetailsProvider(widget.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Organization')),
      body: orgAsync.when(
        data: (org) {
          if (org == null) return const Center(child: Text('Organization not found'));
          _initialize(org);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          image: _imageBytes != null 
                              ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                              : (_currentImageUrl.isNotEmpty 
                                  ? DecorationImage(image: getAppImageProvider(_currentImageUrl), fit: BoxFit.cover)
                                  : null),
                        ),
                        child: _imageBytes == null && _currentImageUrl.isEmpty
                            ? const Center(child: Icon(Icons.add_a_photo, size: 50, color: AppColors.textSecondary))
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Organization Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Short Description'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _aboutController,
                    decoration: const InputDecoration(labelText: 'Full About Section'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _childrenController,
                          decoration: const InputDecoration(labelText: 'Total Children'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Verified'),
                    value: _isVerified,
                    onChanged: (val) => setState(() => _isVerified = val),
                    activeThumbColor: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Featured on Home Page'),
                    value: _isFeatured,
                    onChanged: (val) => setState(() => _isFeatured = val),
                    activeThumbColor: AppColors.primary,
                  ),
                  const SizedBox(height: 24),

                  const SizedBox(height: 24),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    AppButton(
                      text: 'Save Changes',
                      onPressed: _submit,
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

}

