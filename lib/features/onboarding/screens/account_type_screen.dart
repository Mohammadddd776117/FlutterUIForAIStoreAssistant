import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';

class _AccountOption {
  final String role;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;

  const _AccountOption({
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
  });
}

const _options = [
  _AccountOption(
    role: AppConstants.roleMerchant,
    title: AppStrings.merchant,
    description: AppStrings.merchantDesc,
    icon: Icons.store_rounded,
    color: AppColors.primary,
    features: ['Full analytics & reports', 'Manage all branches', 'View profits & expenses', 'AI business insights'],
  ),
  _AccountOption(
    role: AppConstants.roleWorker,
    title: AppStrings.worker,
    description: AppStrings.workerDesc,
    icon: Icons.badge_rounded,
    color: Color(0xFF059669),
    features: ['Scan & add products', 'Register sales', 'Update stock levels', 'No access to private data'],
  ),
  _AccountOption(
    role: AppConstants.roleCustomer,
    title: AppStrings.customer,
    description: AppStrings.customerDesc,
    icon: Icons.person_rounded,
    color: Color(0xFF7C3AED),
    features: ['Search by text, image, voice', 'View product prices', 'Check availability', 'AI product assistant'],
  ),
];

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                AppStrings.selectAccountType,
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the account type that fits your role in the store.',
                style: textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 32),
              ...List.generate(_options.length, (i) {
                final opt = _options[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _AccountCard(option: opt),
                );
              }),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.option});
  final _AccountOption option;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      onTap: () =>
          context.go('/register', extra: {'role': option.role, 'color': option.color.value}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: option.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Icon(option.icon, color: option.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.title, style: textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: option.features
                .map((f) => _FeatureChip(label: f, color: option.color))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
