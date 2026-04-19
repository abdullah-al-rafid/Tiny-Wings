import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/widgets/app_button.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/user_providers.dart';
import '../data/user_repository.dart';
import '../../../core/widgets/app_image.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _professionController;
  late TextEditingController _skillsController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  
  String? _selectedBloodGroup;
  String? _profilePictureUrl;
  bool _isLoading = false;
  Uint8List? _selectedImageBytes;
  String? _imageExtension;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider).value;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _professionController = TextEditingController(text: user?.profession ?? '');
    _skillsController = TextEditingController(text: user?.skills ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _emergencyContactController = TextEditingController(text: user?.emergencyPhone ?? '');
    _selectedBloodGroup = user?.bloodGroup ?? 'O+';
    _profilePictureUrl = user?.profilePictureUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _professionController.dispose();
    _skillsController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _imageExtension = pickedFile.name.split('.').last;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(userProfileProvider).value;
      if (user == null) return;

      String? photoUrl = _profilePictureUrl;
      if (_selectedImageBytes != null) {
        photoUrl = await ref.read(userRepositoryProvider).uploadProfilePicture(
          user.uid, 
          _selectedImageBytes!, 
          _imageExtension ?? 'jpg'
        );
      }

      final updatedUser = user.copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
        bio: _bioController.text,
        profession: _professionController.text,
        skills: _skillsController.text,
        address: _addressController.text,
        bloodGroup: _selectedBloodGroup,
        emergencyPhone: _emergencyContactController.text,
        profilePictureUrl: photoUrl,
      );

      await ref.read(userRepositoryProvider).saveUserProfile(updatedUser);
      
      // Update phone mapping if changed
      if (user.phone != _phoneController.text) {
        await ref.read(userRepositoryProvider).setUserPhoneMapping(_phoneController.text, user.email);
      }

      ref.invalidate(userProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                          image: _selectedImageBytes != null
                              ? DecorationImage(image: MemoryImage(_selectedImageBytes!), fit: BoxFit.cover)
                              : (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
                                  ? DecorationImage(image: getAppImageProvider(_profilePictureUrl!), fit: BoxFit.cover)
                                  : null),
                        ),
                        child: _selectedImageBytes == null && (_profilePictureUrl == null || _profilePictureUrl!.isEmpty)
                            ? const Icon(Icons.person_outline, size: 50, color: AppColors.textSecondary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: AppColors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // --- Section: Basic Information ---
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Full Name', Icons.person_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('Email Address', Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration('Phone Number', Icons.phone_outlined),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: _inputDecoration('Bio', Icons.info_outline),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // --- Section: Professional & Skills ---
              _buildSectionHeader('Professional & Skills'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _professionController,
                decoration: _inputDecoration('Profession', Icons.work_outline),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skillsController,
                decoration: _inputDecoration(
                  'Volunteering Skills', 
                  Icons.star_outline,
                  'e.g. Teaching, First Aid, Event Planning',
                ),
              ),
              const SizedBox(height: 32),

              // --- Section: Location & Safety ---
              _buildSectionHeader('Location & Safety'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration('Full Address', Icons.location_on_outlined),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      decoration: _inputDecoration('Blood Group', Icons.bloodtype_outlined),
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                          .map((group) => DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedBloodGroup = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emergencyContactController,
                      decoration: _inputDecoration('Emergency Phone', Icons.emergency_outlined),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                AppButton(
                  text: 'Save Changes',
                  onPressed: _saveProfile,
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, [IconData? icon, String? hintText]) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.textSecondary, size: 20) : null,
    );
  }
}
