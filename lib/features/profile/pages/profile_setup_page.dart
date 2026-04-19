import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_repository.dart';
import '../data/user_repository.dart';
import '../../../models/user_model.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  final String? initialName;
  final String? initialPhone;

  const ProfileSetupPage({
    super.key,
    this.initialName,
    this.initialPhone,
  });

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _bioController = TextEditingController();
  
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profileData = ref.read(profileSetupDataProvider);
    _nameController.text = profileData?['name'] ?? widget.initialName ?? '';
    _phoneController.text = profileData?['phone'] ?? widget.initialPhone ?? '';
  }

  @override
  void didUpdateWidget(covariant ProfileSetupPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialName != oldWidget.initialName) {
      _nameController.text = widget.initialName ?? '';
    }
    if (widget.initialPhone != oldWidget.initialPhone) {
      _phoneController.text = widget.initialPhone ?? '';
    }
  }

  Future<void> _handleCompleteSetup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authData = ref.read(authModelProvider);
        if (authData == null) throw 'Authentication data not found';

        final user = UserModel(
          uid: authData.uid,
          email: authData.email,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          district: _districtController.text.trim(),
          address: _addressController.text.trim(),
          gender: _selectedGender,
          dob: _dobController.text.trim(),
          bio: _bioController.text.trim(),
        );

        await ref.read(userRepositoryProvider).saveUserProfile(user);
        
        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Complete Profile', style: TextStyle(color: Color(0xFF1F2937))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent going back to register
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text(
              'Skip',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Almost there...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tell us a little bit more about yourself.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    readOnly: true, // Not editable
                    decoration: _inputDecoration('Full Name').copyWith(
                      fillColor: const Color(0xFFF3F4F6), // slightly darker background to indicate readOnly
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    readOnly: true, // Not editable
                    decoration: _inputDecoration('Phone Number').copyWith(
                      fillColor: const Color(0xFFF3F4F6), 
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _districtController,
                    decoration: _inputDecoration('District / City'),
                    validator: (value) => null, // Optional
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration('Full Address'),
                    validator: (value) => null, // Optional
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Gender'),
                          initialValue: _selectedGender,
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                            DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          validator: (value) => null, // Optional
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _dobController,
                          keyboardType: TextInputType.datetime,
                          decoration: _inputDecoration('Date of Birth (YYYY-MM-DD)'),
                          validator: (value) => null, // Optional
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: _inputDecoration('Short Bio (Optional)'),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _handleCompleteSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Finish & Enter App',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
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
