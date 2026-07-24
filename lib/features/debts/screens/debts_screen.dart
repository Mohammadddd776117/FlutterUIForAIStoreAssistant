import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/debt_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/repositories/customer_repository.dart';
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
  final CustomerRepository _customerRepository = CustomerRepository();

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

  // ── Customer picker ──────────────────────────────────────────────────────────

  /// Opens the customer picker bottom sheet and returns the selected customer,
  /// or null if the user dismissed without a selection.
  Future<UserModel?> _pickCustomer(BuildContext sheetContext) {
    return showModalBottomSheet<UserModel>(
      context: sheetContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CustomerPickerSheet(repository: _customerRepository),
    );
  }

  // ── Add debt ─────────────────────────────────────────────────────────────────

  void _showAddDebtDialog() {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    UserModel? selectedCustomer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Debt',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),

                  // Customer picker — required for new debts
                  _CustomerSelectorField(
                    selected: selectedCustomer,
                    onTap: () async {
                      final customer = await _pickCustomer(ctx);
                      if (customer != null) {
                        setSheetState(() => selectedCustomer = customer);
                      }
                    },
                    onClear: () =>
                        setSheetState(() => selectedCustomer = null),
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                      label: 'Amount (YER)',
                      hint: '0',
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.trim().isEmpty ?? true) return 'Required';
                        if (double.tryParse(v!) == null) {
                          return 'Must be a number';
                        }
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
                        if (selectedCustomer == null) {
                          _showMessage('Please select a customer.',
                              isError: true);
                          return;
                        }
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        try {
                          await _repository.createDebt(
                            customerId: selectedCustomer!.id,
                            customerName: selectedCustomer!.fullName,
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
      ),
    );
  }

  // ── Edit debt ─────────────────────────────────────────────────────────────────

  void _showEditDebt(DebtModel debt) {
    // Pre-fill name from the existing record.
    final nameCtrl = TextEditingController(text: debt.customerName);
    final amountCtrl =
        TextEditingController(text: debt.originalAmount.toString());
    final noteCtrl = TextEditingController(text: debt.note ?? '');
    final formKey = GlobalKey<FormState>();
    // If the debt is already linked to a customer, we track any change.
    UserModel? selectedCustomer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
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

                  // Customer picker — optional when editing; if a customer is
                  // selected their name is written into the name field below.
                  _CustomerSelectorField(
                    selected: selectedCustomer,
                    hint: debt.customerId.isNotEmpty
                        ? 'Linked — tap to change'
                        : 'Tap to link a customer',
                    onTap: () async {
                      final customer = await _pickCustomer(ctx);
                      if (customer != null) {
                        setSheetState(() {
                          selectedCustomer = customer;
                          nameCtrl.text = customer.fullName;
                        });
                      }
                    },
                    onClear: () => setSheetState(() => selectedCustomer = null),
                  ),
                  const SizedBox(height: 12),

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
                        if (double.tryParse(v!) == null) {
                          return 'Must be a number';
                        }
                        return null;
                      }),
                  const SizedBox(height: 12),
                  CustomTextField(
                      label: 'Note (optional)', controller: noteCtrl),
                  const SizedBox(height: 20),
                  CustomButton(
                      label: 'Save Changes',
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        try {
                          await _repository.updateDebt(
                            id: debt.id,
                            // Pass the new customerId if a customer was selected
                            // from the picker; otherwise leave the existing link.
                            customerId: selectedCustomer?.id,
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
      ),
    );
  }

  // ── Delete debt ───────────────────────────────────────────────────────────────

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

  // ── Record payment ────────────────────────────────────────────────────────────

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

  // ── Build ─────────────────────────────────────────────────────────────────────

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
          final totalDebt = debts.fold(0.0, (s, d) => s + d.remaining);

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
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
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
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
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
        label:
            const Text('Add Debt', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ── Customer selector field ──────────────────────────────────────────────────

/// Tappable field that shows the selected customer or a placeholder.
/// Used inside StatefulBuilder sheets so state is managed by the caller.
class _CustomerSelectorField extends StatelessWidget {
  const _CustomerSelectorField({
    required this.selected,
    required this.onTap,
    required this.onClear,
    this.hint,
  });

  final UserModel? selected;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasSelection = selected != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasSelection ? AppColors.primary : colorScheme.outline,
            width: hasSelection ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              hasSelection
                  ? Icons.person_rounded
                  : Icons.person_search_rounded,
              color: hasSelection ? AppColors.primary : colorScheme.outline,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer',
                    style:
                        textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                  ),
                  Text(
                    hasSelection
                        ? selected!.fullName
                        : (hint ?? 'Tap to select customer...'),
                    style: textTheme.bodyMedium?.copyWith(
                      color: hasSelection ? null : colorScheme.outline,
                    ),
                  ),
                  if (hasSelection && selected!.phone.isNotEmpty)
                    Text(selected!.phone,
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.outline)),
                ],
              ),
            ),
            if (hasSelection)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    size: 18, color: colorScheme.outline),
              )
            else
              Icon(Icons.arrow_drop_down_rounded, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

// ── Customer picker sheet ────────────────────────────────────────────────────

class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet({required this.repository});
  final CustomerRepository repository;

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<UserModel> _customers = [];
  String _query = '';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final customers = await widget.repository.getCustomers();
      setState(() => _customers = customers);
    } on RepositoryException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<UserModel> get _filtered => _query.isEmpty
      ? _customers
      : _customers
          .where((c) =>
              c.fullName.toLowerCase().contains(_query.toLowerCase()) ||
              c.phone.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Text('Select Customer', style: textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() {
                          _searchCtrl.clear();
                          _query = '';
                        }),
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // Customer list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(color: AppColors.error)))
                    : _filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_off_outlined,
                                    size: 48, color: colorScheme.outline),
                                const SizedBox(height: 12),
                                Text(
                                  _query.isEmpty
                                      ? 'No customers yet'
                                      : 'No matches found',
                                  style: textTheme.bodyLarge,
                                ),
                                if (_query.isEmpty) ...[
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40),
                                    child: Text(
                                      'Add customers first via the Customers screen.',
                                      style: textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollCtrl,
                            padding:
                                const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (ctx, i) {
                              final c = _filtered[i];
                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  child: Text(
                                    c.initials,
                                    style: textTheme.labelMedium
                                        ?.copyWith(color: AppColors.primary),
                                  ),
                                ),
                                title: Text(c.fullName,
                                    style: textTheme.titleSmall),
                                subtitle: c.phone.isNotEmpty
                                    ? Text(c.phone,
                                        style: textTheme.bodySmall)
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.radiusMedium),
                                ),
                                tileColor: Theme.of(context).cardTheme.color,
                                onTap: () => Navigator.pop(ctx, c),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Debt tile ──────────────────────────────────────────────────────────────────

class _DebtTile extends StatelessWidget {
  const _DebtTile({
    required this.debt,
    required this.onPay,
    this.onEdit,
    this.onDelete,
  });
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
                        .withValues(alpha: 0.12),
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
                    // Linked badge — shown when debt has a DB customer FK.
                    if (debt.customerId.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.link_rounded,
                              size: 11,
                              color:
                                  AppColors.primary.withValues(alpha: 0.7)),
                          const SizedBox(width: 2),
                          Text(
                            'Linked to customer',
                            style: textTheme.labelSmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isPaid ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      isPaid ? 'Paid' : 'Unpaid',
                      style: textTheme.labelSmall?.copyWith(
                          color: isPaid
                              ? AppColors.success
                              : AppColors.error),
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
              backgroundColor: AppColors.error.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paid: YER ${debt.totalPaid.toStringAsFixed(0)}',
                    style: textTheme.bodySmall),
                Text(
                    'Original: YER ${debt.originalAmount.toStringAsFixed(0)}',
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
          color: (color ?? AppColors.primary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color ?? AppColors.primary),
      ),
    );
  }
}
