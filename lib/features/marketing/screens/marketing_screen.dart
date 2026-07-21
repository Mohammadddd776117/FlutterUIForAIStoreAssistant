import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_overlay.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key});

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketing'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Promotions'),
            Tab(text: 'Customer Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PromotionsTab(),
          _MessagesTab(),
        ],
      ),
    );
  }
}

class _PromotionsTab extends StatefulWidget {
  const _PromotionsTab();

  @override
  State<_PromotionsTab> createState() => _PromotionsTabState();
}

class _PromotionsTabState extends State<_PromotionsTab> {
  final List<_Promotion> _promotions = List.from(_demoPromotions);

  void _showCreatePromotion() {
    final titleCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
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
            Text('Create Promotion', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Promotion Title', hintText: 'e.g. Weekend Special')),
            const SizedBox(height: 12),
            TextField(controller: discountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount %', hintText: '10')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _promotions.insert(0, _Promotion(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleCtrl.text.trim(),
                      discount: '${discountCtrl.text.trim()}%',
                      isActive: true,
                      expiresAt: DateTime.now().add(const Duration(days: 7)),
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text('Create Promotion'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _promotions.isEmpty
          ? EmptyState(
              icon: Icons.local_offer_outlined,
              title: 'No promotions yet',
              subtitle: 'Create your first promotion to attract more customers.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingMD),
              itemCount: _promotions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _PromotionCard(
                promo: _promotions[i],
                onToggle: () => setState(() => _promotions[i] = _promotions[i].toggle()),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePromotion,
        backgroundColor: AppColors.accentOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Create Promotion', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({required this.promo, required this.onToggle});
  final _Promotion promo;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Text(
              promo.discount,
              style: textTheme.titleMedium?.copyWith(color: AppColors.accentOrange, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.title, style: textTheme.titleSmall),
                Text(
                  'Expires ${_fmtDate(promo.expiresAt)}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(value: promo.isActive, onChanged: (_) => onToggle(), activeColor: AppColors.primary),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _MessagesTab extends StatefulWidget {
  const _MessagesTab();

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _sending = false; _msgCtrl.clear(); });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message sent to all customers!'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Broadcast Message', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Send a message to all your customers', style: textTheme.bodySmall),
                const SizedBox(height: 12),
                TextField(
                  controller: _msgCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Type your message here... (e.g. Weekend sale: 20% off all beverages!)'),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: _sending ? 'Sending...' : 'Send to All Customers',
                  onPressed: _sending ? null : _sendMessage,
                  isLoading: _sending,
                  leading: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Message Templates', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          ..._templates.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  onTap: () => setState(() => _msgCtrl.text = t['body']!),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['title']!, style: textTheme.titleSmall),
                            const SizedBox(height: 2),
                            Text(t['body']!, style: textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _Promotion {
  final String id;
  final String title;
  final String discount;
  final bool isActive;
  final DateTime expiresAt;

  const _Promotion({required this.id, required this.title, required this.discount, required this.isActive, required this.expiresAt});
  _Promotion toggle() => _Promotion(id: id, title: title, discount: discount, isActive: !isActive, expiresAt: expiresAt);
}

final _demoPromotions = [
  _Promotion(id: '1', title: 'Weekend Special', discount: '15%', isActive: true, expiresAt: DateTime.now().add(const Duration(days: 2))),
  _Promotion(id: '2', title: 'Bulk Buy Deal', discount: '10%', isActive: true, expiresAt: DateTime.now().add(const Duration(days: 14))),
  _Promotion(id: '3', title: 'Ramadan Offer', discount: '20%', isActive: false, expiresAt: DateTime.now().subtract(const Duration(days: 30))),
];

const _templates = [
  {
    'title': 'Weekend Sale',
    'body': '🎉 Weekend Special! Get 15% off on all beverages and snacks this Friday and Saturday. Visit us now!',
  },
  {
    'title': 'New Stock Arrival',
    'body': '📦 New stock just arrived! Fresh products, great prices. Come visit your favorite store today.',
  },
  {
    'title': 'Loyalty Appreciation',
    'body': '❤️ Thank you for being a loyal customer! Enjoy an exclusive 10% discount on your next purchase.',
  },
];
