import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/debt_model.dart';
import '../../../shared/repositories/debt_repository.dart';
import '../../../shared/repositories/repository_exceptions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  final DebtRepository _repository = DebtRepository();

  late final Stream<List<DebtModel>> _debtsStream;

  @override
  void initState() {
    super.initState();
    _debtsStream = _repository.watchDebts();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ));
  }

  Future<void> _deleteDebt(DebtModel debt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Debt'),
        content: Text('Delete debt for ${debt.customerName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.deleteDebt(debt.id);
      _showMessage('Debt removed.');
    } on RepositoryException catch (e) {
      _showMessage(e.message, isError: true);
    }
  }

  void _showEditDebt(DebtModel debt) {
    final nameCtrl = TextEditingController(text: debt.customerName);
    final amountCtrl =
        TextEditingController(text: debt.originalAmount.toString());
    final noteCtrl = TextEditingController(text: debt.note ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Debt',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                CustomTextField(
                    label: 'Customer Name',
                    controller: nameCtrl,
                    validator: (v) =>
                        (v?.trim().isEmpty ?? true) ? 'Required' : null),
                const SizedBox(height: 12),
                CustomTextField(
                    label: 'Amount (YER)',
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.trim().isEmpty ?? true) return 'Required';
                      if (double.tryParse(v!) == null) return 'Must be a number';
                      return null;
                    }),
                const SizedBox(height: 12),
                CustomTextField(
                    label: 'Note (optional)', controller: noteCtrl),
                const SizedBox(height: 20),
                CustomButton(
                    label: 'Save Changes',
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      try {
                        await _repository.updateDebt(
                          id: debt.id,
                          customerName: nameCtrl.text,
                          amount: double.parse(amountCtrl.text),
                          note: noteCtrl.text.trim().isEmpty
                              ? null
                              : noteCtrl.text.trim(),
                        );
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        _showMessage('Debt updated.');
                      } on RepositoryException catch (e) {
                        if (!mounted) return;
                        _showMessage(e.message, isError: true);
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDebtDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Debt', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                CustomTextField(
                    label: 'Customer Name',
                    hint: 'Full name',
                    controller: nameCtrl,
                    validator: (v) =>
                        (v?.trim().isEmpty ?? true) ? 'Required' : null),
                const SizedBox(height: 12),
                CustomTextField(
                    label: 'Amount (YER)',
                    hint: '0',
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.trim().isEmpty ?? true) return 'Required';
                      if (double.tryParse(v!) == null) return 'Must be a number';
                      return null;
                    }),
                const SizedBox(height: 12),
                CustomTextField(
                    label: 'Note (optional)',
                    hint: 'e.g. Grocery purchase',
                    controller: noteCtrl),
                const SizedBox(height: 20),
                CustomButton(
                    label: 'Add Debt',
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      try {
                        await _repository.createDebt(
                          customerName: nameCtrl.text.trim(),
                          amount: double.parse(amountCtrl.text),
                          note: noteCtrl.text.trim().isEmpty
                              ? null
                              : noteCtrl.text.trim(),
                        );
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        _showMessage('Debt added.');
                      } on RepositoryException catch (e) {
                        if (!mounted) return;
                        _showMessage(e.message, isError: true);
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _recordPayment(DebtModel debt) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Record Payment for ${debt.customerName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Remaining: YER ${debt.remaining.toStringAsFixed(0)}'),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Payment amount (YER)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text);
              if (amount != null && amount > 0) {
                try {
                  await _repository.recordPayment(debt.id, amount);
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  _showMessage('Payment recorded.');
                } on RepositoryException catch (e) {
                  if (!mounted) return;
                  _showMessage(e.message, isError: true);
                }
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Debt Management')),
      body: StreamBuilder<List<DebtModel>>(
        stream: _debtsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading debts: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final debts = snapshot.data!;
          final totalDebt =
              debts.fold(0.0, (s, d) => s + d.remaining);

          return Column(
            children: [
              // Summary banner
              Container(
                margin: const EdgeInsets.all(AppConstants.paddingMD),
                padding: const EdgeInsets.all(AppConstants.paddingMD),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.error, Color(0xFFDC2626)],
                  ),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusLarge),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Outstanding Debt',
                            style: textTheme.bodySmall
                                ?.copyWith(color: Colors.white70)),
                        Text(
                          'YER ${totalDebt.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
                          style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        Text(
                            '${debts.where((d) => d.remaining > 0).length} customers with debt',
                            style: textTheme.bodySmall
                                ?.copyWith(color: Colors.white70)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white54, size: 48),
                  ],
                ),
              ),
              // Debt list
              Expanded(
                child: debts.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: 'No debts recorded',
                        subtitle: 'All customers are paid up.')
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMD),
                        itemCount: debts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => _DebtTile(
                          debt: debts[i],
                          onPay: () => _recordPayment(debts[i]),
                          onEdit: () => _showEditDebt(debts[i]),
                          onDelete: () => _deleteDebt(debts[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDebtDialog,
        backgroundColor: AppColors.error,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Debt', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile(
      {required this.debt, required this.onPay, this.onEdit, this.onDelete});
  final DebtModel debt;
  final VoidCallback onPay;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isPaid = debt.remaining <= 0;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    (isPaid ? AppColors.success : AppColors.error)
                        .withOpacity(0.12),
                child: Text(
                  debt.customerName.isNotEmpty
                      ? debt.customerName.substring(0, 1).toUpperCase()
                      : '?',
                  style: textTheme.titleSmall?.copyWith(
                      color: isPaid ? AppColors.success : AppColors.error),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(debt.customerName, style: textTheme.titleSmall),
                    if (debt.note != null)
                      Text(debt.note!, style: textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isPaid ? AppColors.success : AppColors.error)
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      isPaid ? 'Paid' : 'Unpaid',
                      style: textTheme.labelSmall?.copyWith(
                          color: isPaid ? AppColors.success : AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'YER ${debt.remaining.toStringAsFixed(0)}',
                    style: textTheme.titleSmall?.copyWith(
                        color: isPaid ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w700),
                  ),
                  if (onEdit != null || onDelete != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          _IconBtn(
                              icon: Icons.edit_outlined, onTap: onEdit!),
                        if (onEdit != null && onDelete != null)
                          const SizedBox(width: 4),
                        if (onDelete != null)
                          _IconBtn(
                              icon: Icons.delete_outline_rounded,
                              onTap: onDelete!,
                              color: AppColors.error),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (!isPaid) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: debt.originalAmount > 0
                  ? (debt.totalPaid / debt.originalAmount).clamp(0, 1)
                  : 0,
              backgroundColor: AppColors.error.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paid: YER ${debt.totalPaid.toStringAsFixed(0)}',
                    style: textTheme.bodySmall),
                Text('Original: YER ${debt.originalAmount.toStringAsFixed(0)}',
                    style: textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: onPay,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 36),
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Record Payment'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color ?? AppColors.primary),
      ),
    );
  }
}
