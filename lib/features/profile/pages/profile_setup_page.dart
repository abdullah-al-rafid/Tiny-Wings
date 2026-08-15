import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_repository.dart';
import '../data/user_repository.dart';
import '../../../core/models/user_model.dart';
import '../../profile/providers/user_providers.dart';

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
  UserRole _selectedRole = UserRole.donor; // Default role
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Retrieve data passed from the Registration step
    final profileData = ref.read(profileSetupDataProvider);
    _nameController.text = profileData?['name'] ?? widget.initialName ?? '';
    _phoneController.text = profileData?['phone'] ?? widget.initialPhone ?? '';
  }

  /// This method bridges the gap between Firebase Authentication (Identity)
  /// and our Realtime Database (Application Profile). 
  /// It creates a UserModel and saves it to the 'users' node in RTDB.
  Future<void> _handleCompleteSetup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authData = ref.read(authModelProvider);
        if (authData == null) throw 'Authentication session not found';

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
          role: _selectedRole, // Role chosen by the user
          status: 'active',
          createdAt: DateTime.now(),
        );

        // PERSISTENCE: Save to database via the Repository
        await ref.read(userRepositoryProvider).saveUserProfile(user);
        
        // Refresh the profile provider to reflect the new data throughout the app
        ref.invalidate(userProfileProvider);

        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
        automaticallyImplyLeading: false, 
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tell us a little bit more about yourself.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    readOnly: true, 
                    decoration: _inputDecoration('Full Name').copyWith(
                      fillColor: const Color(0xFFF3F4F6), 
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    readOnly: true, 
                    decoration: _inputDecoration('Phone Number').copyWith(
                      fillColor: const Color(0xFFF3F4F6), 
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _districtController,
                    decoration: _inputDecoration('District / City'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration('Full Address'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Gender'),
                          value: _selectedGender,
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                            DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
                          ],
                          onChanged: (value) => setState(() => _selectedGender = value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _dobController,
                          keyboardType: TextInputType.datetime,
                          decoration: _inputDecoration('Date of Birth (YYYY-MM-DD)'),
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
                  const SizedBox(height: 32),
                  const Text('I am primarily interested in:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          icon: Icons.favorite_rounded,
                          title: 'Donating',
                          isSelected: _selectedRole == UserRole.donor,
                          onTap: () => setState(() => _selectedRole = UserRole.donor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildRoleCard(
                          icon: Icons.volunteer_activism_rounded,
                          title: 'Volunteering',
                          isSelected: _selectedRole == UserRole.volunteer,
                          onTap: () => setState(() => _selectedRole = UserRole.volunteer),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _handleCompleteSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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

  Widget _buildRoleCard({required IconData icon, required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB), width: 2),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : const Color(0xFF3B82F6), size: 32),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1F2937), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
