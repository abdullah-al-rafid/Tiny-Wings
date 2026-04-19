import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/donation_model.dart';
import '../../../models/organization_model.dart';
import '../../organizations/providers/organization_providers.dart';
import '../../admin/providers/admin_providers.dart';
import '../providers/donation_providers.dart';
import '../providers/leaderboard_providers.dart';
import '../data/donation_repository.dart';
import '../../sponsorships/providers/sponsorship_providers.dart';
import '../../../core/auth/auth_repository.dart';

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
  DonationType selectedType = DonationType.money;
  Organization? selectedOrganization;
  
  // Money specific
  final _amountController = TextEditingController();
  String selectedAmount = '';
  String selectedPayment = 'bKash';
  
  // Items specific
  String? selectedCategory = 'Food';
  final _itemNameController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _quantityController = TextEditingController();
  String selectedUnit = 'pcs';
  final _notesController = TextEditingController();

  bool _isLoading = false;

  final List<String> categories = [
    'Food', 'Clothing', 'Toys', 'Books', 'Medical', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedNeedTitle != null) {
      selectedType = DonationType.items;
      _itemNameController.text = widget.preselectedNeedTitle!;
      _notesController.text = 'Donating for need: ${widget.preselectedNeedTitle}';
      
      final parts = widget.preselectedNeedAmount?.split(' ') ?? [];
      if (parts.isNotEmpty) {
        final qty = double.tryParse(parts[0]);
        if (qty != null) {
          _quantityController.text = qty.toString();
        }
        if (parts.length > 1) {
          final u = parts.sublist(1).join(' ').toLowerCase();
          if (['pcs', 'kg', 'sets', 'packs', 'units'].contains(u)) {
             selectedUnit = u;
          }
        }
      }
      
      if (widget.preselectedNeedCategory != null) {
        String mappedCat = widget.preselectedNeedCategory!;
        if (mappedCat == 'Medicine') mappedCat = 'Medical';
        if (mappedCat == 'Education') mappedCat = 'Books';
        
        if (categories.contains(mappedCat)) {
          selectedCategory = mappedCat;
        } else {
          selectedCategory = 'Other';
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _itemNameController.dispose();
    _estimatedValueController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitDonation() async {
    if (selectedOrganization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an organization')),
      );
      return;
    }

    final user = ref.read(authModelProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to donate')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final donation = Donation(
        donorId: user.uid,
        donorName: user.email.split('@').first,
        organizationId: selectedOrganization!.id,
        organizationName: selectedOrganization!.name,
        type: selectedType,
        status: selectedType == DonationType.money ? 'verified' : 'pending',
        itemName: selectedType == DonationType.items && _itemNameController.text.isNotEmpty 
            ? _itemNameController.text 
            : null,
        estimatedValue: selectedType == DonationType.items 
            ? double.tryParse(_estimatedValueController.text) 
            : null,
        amount: selectedType == DonationType.money 
            ? double.tryParse(_amountController.text.isNotEmpty ? _amountController.text : selectedAmount) 
            : null,
        paymentMethod: selectedType == DonationType.money ? selectedPayment : null,
        itemCategory: selectedType == DonationType.items ? selectedCategory : null,
        needId: selectedType == DonationType.items ? widget.preselectedNeedId : null,
        quantity: selectedType == DonationType.items 
            ? double.tryParse(_quantityController.text) 
            : null,
        unit: selectedType == DonationType.items ? selectedUnit : null,
        condition: null,
        notes: _notesController.text,
        timestamp: DateTime.now(),
      );

      await ref.read(donationRepositoryProvider).saveDonation(donation);

      // Invalidate providers to force refresh
      ref.invalidate(userDonationsProvider);
      ref.invalidate(adminStatsProvider);
      ref.invalidate(leaderboardProvider);
      ref.invalidate(orgSupportersProvider(selectedOrganization!.id));

      if (mounted) {
        context.push('/donation-confirmation');
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
    final organizationsAsync = ref.watch(organizationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Donation'),
      ),
      body: organizationsAsync.when(
        data: (organizations) {
          if (selectedOrganization == null && organizations.isNotEmpty) {
            if (widget.preselectedOrgId != null) {
              try {
                selectedOrganization = organizations.firstWhere((org) => org.id == widget.preselectedOrgId);
              } catch (_) {}
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Donation Type
                _buildSectionHeader('Donation Type'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TypeSelection(
                        title: 'Money',
                        icon: Icons.account_balance_wallet_outlined,
                        isSelected: selectedType == DonationType.money,
                        onTap: () => setState(() => selectedType = DonationType.money),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _TypeSelection(
                        title: 'Items',
                        icon: Icons.inventory_2_outlined,
                        isSelected: selectedType == DonationType.items,
                        onTap: () => setState(() => selectedType = DonationType.items),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Select Organization
                _buildSectionHeader('Select Organization'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Organization>(
                      value: selectedOrganization,
                      hint: const Text('Select an organization'),
                      isExpanded: true,
                      items: organizations.map((org) {
                        return DropdownMenuItem(
                          value: org,
                          child: Text(org.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedOrganization = val),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Conditional Section: Money or Items
                if (selectedType == DonationType.money)
                  _buildMoneySection()
                else
                  _buildItemsSection(),

                const SizedBox(height: 32),
                
                // Notes
                _buildSectionHeader('Notes (Optional)'),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Any special instructions...',
                  ),
                ),
                const SizedBox(height: 48),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  AppButton(
                    text: 'Donate Now',
                    onPressed: _submitDonation,
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading organizations: $e')),
      ),
    );
  }

  Widget _buildMoneySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Amount (BDT)'),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          onChanged: (val) => setState(() => selectedAmount = ''),
          decoration: const InputDecoration(
            hintText: 'Enter custom amount',
            prefixText: '৳ ',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['500', '1000', '2000', '5000'].map((amount) {
            return _AmountChip(
              amount: '৳$amount',
              isSelected: selectedAmount == amount,
              onTap: () {
                setState(() {
                  selectedAmount = amount;
                  _amountController.text = amount;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Payment Method'),
        const SizedBox(height: 12),
        ...['bKash', 'Nagad', 'Card', 'Bank'].map((method) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PaymentMethodItem(
              title: method,
              isSelected: selectedPayment == method,
              onTap: () => setState(() => selectedPayment = method),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Item Category'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((cat) {
            return _CategoryChip(
              label: cat,
              isSelected: selectedCategory == cat,
              onTap: () => setState(() => selectedCategory = cat),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Specific Item Details'),
        const SizedBox(height: 12),
        TextField(
          controller: _itemNameController,
          decoration: const InputDecoration(
            hintText: 'E.g. Rice, Blankets, Paracetamol',
            labelText: 'Item Name',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _estimatedValueController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Estimated Value in ৳ (Optional)',
            prefixText: '৳ ',
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Quantity & Details'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Quantity',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    items: ['pcs', 'kg', 'sets', 'packs', 'units']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedUnit = val!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 24),
      ],
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

class _TypeSelection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeSelection({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmountChip({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          amount,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary)
            else
              const Icon(Icons.circle_outlined, color: AppColors.border),
          ],
        ),
      ),
    );
  }
}