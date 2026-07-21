import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/loading_overlay.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  final List<_Branch> _branches = List.from(_demoBranches);

  void _showAddBranch() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Branch', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Branch Name', hintText: 'e.g. Downtown Branch')),
            const SizedBox(height: 12),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address', hintText: 'Full address')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _branches.add(_Branch(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                      isActive: true,
                      dailySales: 0,
                      workerCount: 0,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text('Add Branch'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Branch Management')),
      body: _branches.isEmpty
          ? EmptyState(
              icon: Icons.store_outlined,
              title: 'No branches yet',
              subtitle: 'Add your first store branch to get started.',
              action: ElevatedButton.icon(
                onPressed: _showAddBranch,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Branch'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingMD),
              itemCount: _branches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _BranchCard(
                branch: _branches[i],
                onToggle: () => setState(() => _branches[i] = _branches[i].toggle()),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBranch,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Branch', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch, required this.onToggle});
  final _Branch branch;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (branch.isActive ? AppColors.primary : AppColors.lightTextHint).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(
                  Icons.store_rounded,
                  color: branch.isActive ? AppColors.primary : AppColors.lightTextHint,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(branch.name, style: textTheme.titleMedium),
                    if (branch.address.isNotEmpty)
                      Text(branch.address, style: textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Switch(value: branch.isActive, onChanged: (_) => onToggle(), activeColor: AppColors.primary),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _BranchStat(label: "Today's Sales", value: 'YER ${branch.dailySales.toStringAsFixed(0)}'),
              const SizedBox(width: 12),
              _BranchStat(label: 'Workers', value: '${branch.workerCount}'),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (branch.isActive ? AppColors.success : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  branch.isActive ? 'Active' : 'Inactive',
                  style: textTheme.labelSmall?.copyWith(color: branch.isActive ? AppColors.success : AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BranchStat extends StatelessWidget {
  const _BranchStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}

class _Branch {
  final String id;
  final String name;
  final String address;
  final bool isActive;
  final double dailySales;
  final int workerCount;

  const _Branch({
    required this.id, required this.name, required this.address,
    required this.isActive, required this.dailySales, required this.workerCount,
  });

  _Branch toggle() => _Branch(id: id, name: name, address: address, isActive: !isActive, dailySales: dailySales, workerCount: workerCount);
}

final _demoBranches = [
  const _Branch(id: '1', name: 'Main Branch', address: 'Tahrir Square, Sana\'a', isActive: true, dailySales: 18500, workerCount: 4),
  const _Branch(id: '2', name: 'Al-Hasaba Branch', address: 'Al-Hasaba District, Sana\'a', isActive: true, dailySales: 12300, workerCount: 2),
  const _Branch(id: '3', name: 'Aden Warehouse', address: 'Al-Ma\'alla, Aden', isActive: false, dailySales: 0, workerCount: 0),
];
