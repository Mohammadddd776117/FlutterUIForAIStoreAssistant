import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/loading_overlay.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Low Stock'),
            Tab(text: 'Out of Stock'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMD),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _InventoryList(filter: 'all', query: _query),
                _InventoryList(filter: 'low', query: _query),
                _InventoryList(filter: 'out', query: _query),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scanner'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _InventoryList extends StatelessWidget {
  const _InventoryList({required this.filter, required this.query});
  final String filter;
  final String query;

  @override
  Widget build(BuildContext context) {
    final all = _demoInventory;
    final filtered = all.where((p) {
      final matchesQuery = query.isEmpty ||
          p['name']!.toLowerCase().contains(query.toLowerCase()) ||
          p['category']!.toLowerCase().contains(query.toLowerCase());
      final matchesFilter = filter == 'all' ||
          (filter == 'low' && p['status'] == 'Low Stock') ||
          (filter == 'out' && p['status'] == 'Out of Stock');
      return matchesQuery && matchesFilter;
    }).toList();

    if (filtered.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No products found',
        subtitle: filter == 'low'
            ? 'No products are running low.'
            : filter == 'out'
                ? 'No out-of-stock products.'
                : 'Add your first product to get started.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _ProductRow(product: filtered[i]),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});
  final Map<String, String> product;

  Color get _statusColor {
    switch (product['status']) {
      case 'Out of Stock': return AppColors.error;
      case 'Low Stock': return AppColors.warning;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: AppConstants.thumbnailSize,
            height: AppConstants.thumbnailSize,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name']!, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(product['category']!, style: textTheme.bodySmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _InfoBadge(label: 'Qty: ${product['qty']}', color: _statusColor),
                    const SizedBox(width: 6),
                    _InfoBadge(label: product['status']!, color: _statusColor),
                  ],
                ),
              ],
            ),
          ),
          // Price + actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(product['price']!, style: textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconBtn(icon: Icons.edit_outlined, onTap: () {}),
                  const SizedBox(width: 4),
                  _IconBtn(icon: Icons.delete_outline_rounded, onTap: () {}, color: AppColors.error),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
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

const _demoInventory = [
  {'name': 'Rice (5kg)', 'category': 'Grains', 'qty': '8', 'price': 'YER 2,500', 'status': 'Low Stock'},
  {'name': 'Cooking Oil (1L)', 'category': 'Oils', 'qty': '45', 'price': 'YER 1,200', 'status': 'In Stock'},
  {'name': 'Sugar (1kg)', 'category': 'Sweeteners', 'qty': '6', 'price': 'YER 800', 'status': 'Low Stock'},
  {'name': 'Tea (250g)', 'category': 'Beverages', 'qty': '30', 'price': 'YER 650', 'status': 'In Stock'},
  {'name': 'Flour (2kg)', 'category': 'Grains', 'qty': '0', 'price': 'YER 1,100', 'status': 'Out of Stock'},
  {'name': 'Tomato Paste', 'category': 'Canned Goods', 'qty': '0', 'price': 'YER 350', 'status': 'Out of Stock'},
  {'name': 'Lentils (1kg)', 'category': 'Legumes', 'qty': '22', 'price': 'YER 900', 'status': 'In Stock'},
  {'name': 'Salt (1kg)', 'category': 'Spices', 'qty': '60', 'price': 'YER 200', 'status': 'In Stock'},
  {'name': 'Canned Sardines', 'category': 'Canned Goods', 'qty': '14', 'price': 'YER 450', 'status': 'In Stock'},
  {'name': 'Biscuits Assorted', 'category': 'Snacks', 'qty': '7', 'price': 'YER 280', 'status': 'Low Stock'},
];
