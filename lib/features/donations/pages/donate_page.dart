import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/models/donation_model.dart';
import '../../../core/models/organization_model.dart';
import '../../organizations/providers/organization_providers.dart';
import '../providers/donation_providers.dart';
import '../data/donation_repository.dart';
import '../../../core/auth/auth_repository.dart';
import '../../needs/providers/need_providers.dart';

class DonatePage extends ConsumerStatefulWidget {
  final String? preselectedOrgId;
  final String? preselectedNeedTitle;
  final String? preselectedNeedAmount;
  final String? preselectedNeedCategory;
  final String? preselectedNeedId;

  const DonatePage({
    super.key,
    this.preselectedOrgId,
    this.preselectedNeedTitle,
    this.preselectedNeedAmount,
    this.preselectedNeedCategory,
    this.preselectedNeedId,
  });

  @override
  ConsumerState<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends ConsumerState<DonatePage> {
  int _currentStep = 0;
  DonationType selectedType = DonationType.money;
  Organization? selectedOrganization;
  
  final _amountController = TextEditingController();
  final _bkashNumberController = TextEditingController();
  final _otpController = TextEditingController();
  String selectedAmount = '';
  bool _otpSent = false;
  
  String? selectedCategory = 'Food';
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  String selectedUnit = 'pcs';
  final _notesController = TextEditingController();

  bool _isLoading = false;

  final List<String> categories = ['Food', 'Clothing', 'Toys', 'Books', 'Medical', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedNeedTitle != null) {
      selectedType = DonationType.items;
      _itemNameController.text = widget.preselectedNeedTitle!;
      _notesController.text = 'For: ${widget.preselectedNeedTitle}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final organizationsAsync = ref.watch(organizationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: organizationsAsync.when(
        data: (organizations) {
          if (selectedOrganization == null && organizations.isNotEmpty) {
            if (widget.preselectedOrgId != null) {
              try { selectedOrganization = organizations.firstWhere((org) => org.id == widget.preselectedOrgId); } catch (_) {}
            }
          }
          return Stack(
            children: [
              _buildBackgroundDecoration(),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildStepIndicator(),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildCurrentStep(organizations),
                      ),
                    ),
                    _buildBottomBar(),
                  ],
                ),
              ),
              if (_isLoading) _buildLoadingOverlay(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFFF9FAFB),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.03),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E3A8A)),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Gift of Hope',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A), letterSpacing: -0.5),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final totalSteps = selectedType == DonationType.money ? 4 : 3;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index % 2 == 1) {
            final lineIdx = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: lineIdx < _currentStep ? const Color(0xFF1E3A8A) : Colors.grey.shade200,
              ),
            );
          }
          final stepIdx = index ~/ 2;
          final isActive = stepIdx <= _currentStep;
          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF1E3A8A) : Colors.white,
              border: Border.all(color: isActive ? const Color(0xFF1E3A8A) : Colors.grey.shade300, width: 2),
              boxShadow: isActive ? [BoxShadow(color: const Color(0xFF1E3A8A).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))] : null,
            ),
            child: Center(
              child: stepIdx < _currentStep 
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : Text('${stepIdx + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(List<Organization> organizations) {
    switch (_currentStep) {
      case 0: return _buildTypeAndTarget(organizations);
      case 1: return _buildDonationDetails();
      case 2: return selectedType == DonationType.money ? _buildPaymentProcess() : _buildFinalSummary();
      case 3: return _buildFinalSummary();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildTypeAndTarget(List<Organization> organizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose your path of impact', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('Every small act creates a ripple of change.', style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: _FancyTypeCard(title: 'Financial', sub: 'Instant Help', icon: Icons.auto_awesome_rounded, isSelected: selectedType == DonationType.money, onTap: () => setState(() => selectedType = DonationType.money))),
            const SizedBox(width: 16),
            Expanded(child: _FancyTypeCard(title: 'Essentials', sub: 'Physical Goods', icon: Icons.inventory_2_rounded, isSelected: selectedType == DonationType.items, onTap: () => setState(() => selectedType = DonationType.items))),
          ],
        ),
        const SizedBox(height: 40),
        const Text('Select Recipient', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1F2937))),
        const SizedBox(height: 12),
        _buildDropdown(organizations),
      ],
    );
  }

  Widget _buildDropdown(List<Organization> organizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Organization>(
          value: selectedOrganization,
          hint: const Text('Who will receive your help?'),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1E3A8A)),
          items: organizations.map((org) => DropdownMenuItem(value: org, child: Text(org.name, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
          onChanged: (val) => setState(() => selectedOrganization = val),
        ),
      ),
    );
  }

  Widget _buildDonationDetails() {
    if (selectedType == DonationType.money) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How much to give?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.5)),
          const SizedBox(height: 32),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
            decoration: InputDecoration(
              prefixText: '৳ ',
              hintText: '0',
              hintStyle: TextStyle(color: Colors.grey.shade300),
              filled: true,
              fillColor: const Color(0xFF1E3A8A).withValues(alpha: 0.03),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: ['500', '1000', '2500', '5000'].map((a) => ChoiceChip(
              label: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text('৳$a')),
              selected: selectedAmount == a,
              onSelected: (s) => setState(() { selectedAmount = a; _amountController.text = a; }),
              selectedColor: const Color(0xFF1E3A8A),
              labelStyle: TextStyle(color: selectedAmount == a ? Colors.white : const Color(0xFF1E3A8A), fontWeight: FontWeight.w900),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: selectedAmount == a ? const Color(0xFF1E3A8A) : Colors.grey.shade200),
            )).toList(),
          ),
          const SizedBox(height: 40),
          _buildImpactInsight(),
        ],
      );
    } else {
      return ListView(
        children: [
          const Text('Provision details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.5)),
          const SizedBox(height: 24),
          _buildFieldLabel('Item Name'),
          TextField(controller: _itemNameController, decoration: _inputDeco('e.g. Winter Blankets')),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildFieldLabel('Qty'), TextField(controller: _quantityController, keyboardType: TextInputType.number, decoration: _inputDeco('10'))])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildFieldLabel('Unit'), _buildUnitSelector()])),
            ],
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('Category'),
          Wrap(spacing: 8, runSpacing: 8, children: categories.map((c) => _MiniChip(label: c, isSelected: selectedCategory == c, onTap: () => setState(() => selectedCategory = c))).toList()),
        ],
      );
    }
  }

  Widget _buildImpactInsight() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return const SizedBox.shrink();
    String msg = "Your gift will provide ${(amount / 200).floor()} full meals for children in need.";
    if (amount >= 5000) msg = "Incredible! This covers an entire month of education and health for 2 children.";
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFD1FAE5))),
      child: Row(children: [
        const Icon(Icons.auto_awesome_rounded, color: Color(0xFF059669), size: 32),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('IMPACT PREVIEW', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(msg, style: const TextStyle(color: Color(0xFF065F46), fontSize: 14, fontWeight: FontWeight.w600, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _buildPaymentProcess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Secure Checkout', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.5)),
        const SizedBox(height: 32),
        Center(child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]), child: Image.network('https://e7.pngegg.com/pngimages/145/219/png-clipart-bkash-logo-payment-system-mobile-app-service-marketing-purple-marketing.png', height: 48))),
        const SizedBox(height: 48),
        _buildFieldLabel('bKash Number'),
        TextField(controller: _bkashNumberController, keyboardType: TextInputType.phone, enabled: !_otpSent, decoration: _inputDeco('01XXXXXXXXX', icon: Icons.phone_android_rounded)),
        if (_otpSent) ...[
          const SizedBox(height: 24),
          _buildFieldLabel('6-Digit OTP'),
          TextField(controller: _otpController, keyboardType: TextInputType.number, maxLength: 6, style: const TextStyle(letterSpacing: 12, fontSize: 24, fontWeight: FontWeight.w900), decoration: _inputDeco('XXXXXX')),
        ],
      ],
    );
  }

  Widget _buildFinalSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ready to change lives?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.5)),
        const SizedBox(height: 32),
        _buildSummaryCard(),
        const SizedBox(height: 40),
        const Text('COMMITMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF9CA3AF), letterSpacing: 2)),
        const SizedBox(height: 12),
        Text('By proceeding, your contribution will be securely transferred to ${selectedOrganization?.name}. Your impact will be recorded in the ledger for transparency.', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.6)),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final val = selectedType == DonationType.money ? '৳${_amountController.text}' : '${_quantityController.text} $selectedUnit of ${_itemNameController.text}';
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: const Color(0xFF1E3A8A).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Target', value: selectedOrganization?.name ?? ''),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white24)),
          _SummaryRow(label: 'Gift', value: val, isLarge: true),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLast = (selectedType == DonationType.money && _currentStep == 3) || (selectedType == DonationType.items && _currentStep == 2);
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(children: [
        if (_currentStep > 0) ...[
          IconButton(onPressed: () => setState(() => _currentStep--), icon: const Icon(Icons.arrow_back_rounded)),
          const SizedBox(width: 16),
        ],
        Expanded(child: AppButton(text: isLast ? 'Finalize Gift' : (_currentStep == 2 && selectedType == DonationType.money ? (_otpSent ? 'Verify OTP' : 'Send OTP') : 'Continue'), onPressed: isLast ? _submitDonation : _handleNext)),
      ]),
    );
  }

  void _handleNext() {
    if (_currentStep == 0 && selectedOrganization == null) return;
    if (_currentStep == 1 && selectedType == DonationType.money && _amountController.text.isEmpty) return;
    if (_currentStep == 2 && selectedType == DonationType.money) {
      if (!_otpSent) { setState(() => _otpSent = true); return; }
      if (_otpController.text != '123456') return;
    }
    setState(() => _currentStep++);
  }

  InputDecoration _inputDeco(String hint, {IconData? icon}) => InputDecoration(hintText: hint, prefixIcon: icon != null ? Icon(icon) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)), filled: true, fillColor: Colors.white);
  Widget _buildFieldLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF4B5563))));
  Widget _buildUnitSelector() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(20),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedUnit,
        items: ['pcs', 'kg', 'sets', 'packs'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
        onChanged: (v) => setState(() => selectedUnit = v!),
      ),
    ),
  );
  Widget _buildLoadingOverlay() => Positioned.fill(child: Container(color: Colors.white.withValues(alpha: 0.8), child: const Center(child: CircularProgressIndicator())));

  Future<void> _submitDonation() async {
    final user = ref.read(authModelProvider);
    if (user == null || selectedOrganization == null) return;
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      final donation = Donation(
        donorId: user.uid, donorName: user.email.split('@').first, organizationId: selectedOrganization!.id, organizationName: selectedOrganization!.name,
        type: selectedType, status: selectedType == DonationType.money ? 'verified' : 'pending',
        amount: selectedType == DonationType.money ? double.tryParse(_amountController.text) : null,
        itemName: selectedType == DonationType.items ? _itemNameController.text : null,
        quantity: selectedType == DonationType.items ? double.tryParse(_quantityController.text) : null,
        unit: selectedType == DonationType.items ? selectedUnit : null,
        itemCategory: selectedType == DonationType.items ? selectedCategory : null,
        timestamp: DateTime.now(), notes: _notesController.text,
      );
      await ref.read(donationRepositoryProvider).saveDonation(donation);
      if (selectedType == DonationType.items &&
          widget.preselectedNeedId != null &&
          widget.preselectedNeedId!.isNotEmpty) {
        final quantity = double.tryParse(_quantityController.text) ?? 0;
        if (quantity > 0) {
          await ref.read(needActionsProvider).updateNeedFulfillment(
                widget.preselectedNeedId!,
                quantity,
              );
        }
      }
      ref.invalidate(userDonationsProvider);
      ref.invalidate(approvedNeedsProvider);
      ref.invalidate(needsByOrgProvider(selectedOrganization!.id));
      if (mounted) context.push('/donation-confirmation');
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }
}

class _FancyTypeCard extends StatelessWidget {
  final String title, sub; final IconData icon; final bool isSelected; final VoidCallback onTap;
  const _FancyTypeCard({required this.title, required this.sub, required this.icon, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade200, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF1E3A8A).withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))] : null,
        ),
        child: Column(children: [
          Icon(icon, color: isSelected ? Colors.white : const Color(0xFF1E3A8A), size: 32),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1E3A8A), fontWeight: FontWeight.w900, fontSize: 16)),
          Text(sub, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label; final bool isSelected; final VoidCallback onTap;
  const _MiniChip({required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: isSelected ? const Color(0xFF1E3A8A) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade200)), child: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 12))),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value; final bool isLarge;
  const _SummaryRow({required this.label, required this.value, this.isLarge = false});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w600, fontSize: 13)),
      Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: isLarge ? 20 : 15)),
    ]);
  }
}

