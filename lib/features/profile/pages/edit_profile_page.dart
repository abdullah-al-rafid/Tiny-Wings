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
import '../../../core/localization/app_localization.dart';

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
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _professionController = TextEditingController();
    _skillsController = TextEditingController();
    _addressController = TextEditingController();
    _emergencyContactController = TextEditingController();
    
    // Defer initialization to after the first frame to safely use ref.read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final user = ref.read(userProfileProvider).value;
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _bioController.text = user.bio ?? '';
        _professionController.text = user.profession ?? '';
        _skillsController.text = user.skills ?? '';
        _addressController.text = user.address ?? '';
        _emergencyContactController.text = user.emergencyPhone ?? '';
        _selectedBloodGroup = user.bloodGroup ?? 'O+';
        _profilePictureUrl = user.profilePictureUrl;
      });
    }
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
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, // Reasonable size for profile pic
      imageQuality: 80, // Good compression
    );
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
          SnackBar(content: Text(ref.watch(translationProvider)['successful_update']!)),
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
    final t = ref.watch(translationProvider);
    final userAsync = ref.watch(userProfileProvider);

    // If data arrives after initial build, populate controllers
    userAsync.whenData((user) {
      if (user != null && _nameController.text.isEmpty && _emailController.text.isEmpty) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _bioController.text = user.bio ?? '';
        _professionController.text = user.profession ?? '';
        _skillsController.text = user.skills ?? '';
        _addressController.text = user.address ?? '';
        _emergencyContactController.text = user.emergencyPhone ?? '';
        _selectedBloodGroup = user.bloodGroup ?? 'O+';
        _profilePictureUrl = user.profilePictureUrl;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(t['edit_profile']!),
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
              _buildSectionHeader(t['basic_information']!),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(t['full_name']!, Icons.person_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration(t['email_address']!, Icons.email_outlined).copyWith(
                  helperText: 'Email cannot be changed here for security',
                ),
                readOnly: true,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration(t['phone_number']!, Icons.phone_outlined),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: _inputDecoration(t['bio']!, Icons.info_outline),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              // --- Section: Professional & Skills ---
              _buildSectionHeader(t['professional_skills']!),
              const SizedBox(height: 16),
              TextFormField(
                controller: _professionController,
                decoration: _inputDecoration(t['profession']!, Icons.work_outline),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skillsController,
                decoration: _inputDecoration(
                  t['v_skills']!, 
                  Icons.star_outline,
                  'e.g. Teaching, First Aid, Event Planning',
                ),
              ),
              const SizedBox(height: 32),
              
              // --- Section: Location & Safety ---
              _buildSectionHeader(t['location_safety']!),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration(t['address']!, Icons.location_on_outlined),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      decoration: _inputDecoration(t['blood_group']!, Icons.bloodtype_outlined),
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
                      decoration: _inputDecoration(t['emergency_phone']!, Icons.emergency_outlined),
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
                  text: t['save_changes']!,
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
