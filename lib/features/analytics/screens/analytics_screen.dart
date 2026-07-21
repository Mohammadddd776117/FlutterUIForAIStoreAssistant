import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/stat_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  _Period _period = _Period.week;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Row(
              children: _Period.values.map((p) {
                final active = _period == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.label),
                    selected: active,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: active ? Colors.white : null),
                    onSelected: (_) => setState(() => _period = p),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // KPI cards
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(
                  label: 'Revenue',
                  value: _period == _Period.week ? 'YER 129,500' : _period == _Period.month ? 'YER 542,000' : 'YER 6.4M',
                  icon: Icons.payments_rounded,
                  color: AppColors.primary,
                  change: '14%',
                ),
                StatCard(
                  label: 'Profit',
                  value: _period == _Period.week ? 'YER 29,750' : _period == _Period.month ? 'YER 124,600' : 'YER 1.47M',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.accent,
                  change: '9%',
                ),
                StatCard(
                  label: 'Expenses',
                  value: _period == _Period.week ? 'YER 99,750' : _period == _Period.month ? 'YER 417,400' : 'YER 4.93M',
                  icon: Icons.receipt_rounded,
                  color: AppColors.error,
                  change: '3%',
                  isPositiveChange: false,
                ),
                StatCard(
                  label: 'Transactions',
                  value: _period == _Period.week ? '329' : _period == _Period.month ? '1,420' : '17,040',
                  icon: Icons.swap_horiz_rounded,
                  color: const Color(0xFF7C3AED),
                  change: '7%',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Revenue chart
            Text('Revenue vs Profit', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (v) => FlLine(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            final idx = v.toInt();
                            if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                            return Text(days[idx], style: Theme.of(context).textTheme.labelSmall);
                          },
                          reservedSize: 20,
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Revenue line
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 18500), FlSpot(1, 15200), FlSpot(2, 21000),
                          FlSpot(3, 17800), FlSpot(4, 22500), FlSpot(5, 19000), FlSpot(6, 15500),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.08),
                        ),
                      ),
                      // Profit line
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 4250), FlSpot(1, 3500), FlSpot(2, 4830),
                          FlSpot(3, 4100), FlSpot(4, 5200), FlSpot(5, 4370), FlSpot(6, 3570),
                        ],
                        isCurved: true,
                        color: AppColors.accent,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.accent.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Best sellers
            Text('Best Sellers', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            ..._bestSellers.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BestSellerRow(rank: e.key + 1, data: e.value),
                )),
            const SizedBox(height: 20),

            // Category breakdown (pie chart)
            Text('Sales by Category', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sections: _categoryData.asMap().entries.map((e) {
                          return PieChartSectionData(
                            value: e.value['pct'] as double,
                            color: AppColors.chartColors[e.key % AppColors.chartColors.length],
                            radius: 50,
                            title: '${(e.value['pct'] as double).toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                          );
                        }).toList(),
                        centerSpaceRadius: 20,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _categoryData.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.chartColors[e.key % AppColors.chartColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(child: Text(e.value['label'] as String, style: textTheme.bodySmall)),
                                Text('${(e.value['pct'] as double).toStringAsFixed(0)}%', style: textTheme.labelSmall),
                              ],
                            ),
                          )).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BestSellerRow extends StatelessWidget {
  const _BestSellerRow({required this.rank, required this.data});
  final int rank;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: rank == 1 ? const Color(0xFFFFD700).withOpacity(0.15)
                  : rank == 2 ? const Color(0xFFC0C0C0).withOpacity(0.15)
                  : rank == 3 ? const Color(0xFFCD7F32).withOpacity(0.15)
                  : AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(data['name'] as String, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(data['revenue'] as String, style: textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              Text('${data['units']} units', style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

const _bestSellers = [
  {'name': 'Cooking Oil (1L)', 'revenue': 'YER 54,000', 'units': 45},
  {'name': 'Rice (5kg)', 'revenue': 'YER 37,500', 'units': 15},
  {'name': 'Sugar (1kg)', 'revenue': 'YER 28,800', 'units': 36},
  {'name': 'Tea (250g)', 'revenue': 'YER 19,500', 'units': 30},
  {'name': 'Flour (2kg)', 'revenue': 'YER 15,400', 'units': 14},
];

const _categoryData = [
  {'label': 'Oils & Fats', 'pct': 35.0},
  {'label': 'Grains', 'pct': 25.0},
  {'label': 'Beverages', 'pct': 15.0},
  {'label': 'Canned Goods', 'pct': 12.0},
  {'label': 'Other', 'pct': 13.0},
];

enum _Period {
  week,
  month,
  year;

  String get label {
    switch (this) {
      case week: return 'This Week';
      case month: return 'This Month';
      case year: return 'This Year';
    }
  }
}
