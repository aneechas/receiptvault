import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'Last 3 Months', 'This Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods
                .map((period) => PopupMenuItem(
                      value: period,
                      child: Text(period),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<Map<String, double>>(
            future: provider.getCategoryTotals(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final categoryTotals = snapshot.data!;

              if (categoryTotals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No data to display',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start adding expenses to see analytics',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TotalSpendingCard(categoryTotals: categoryTotals),
                    const SizedBox(height: 24),
                    _CategoryPieChart(categoryTotals: categoryTotals),
                    const SizedBox(height: 24),
                    _CategoryBreakdownList(categoryTotals: categoryTotals),
                    const SizedBox(height: 24),
                    _SpendingTrendChart(expenses: provider.expenses),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TotalSpendingCard extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const _TotalSpendingCard({required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    final total = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
    final settings = Provider.of<SettingsProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Spending',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${settings.getCurrencySymbol()}${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatColumn(
                  label: 'Categories',
                  value: categoryTotals.length.toString(),
                  color: AppTheme.secondaryColor,
                ),
                _StatColumn(
                  label: 'Avg/Category',
                  value: '${settings.getCurrencySymbol()}${(total / categoryTotals.length).toStringAsFixed(0)}',
                  color: AppTheme.accentColor,
                ),
                _StatColumn(
                  label: 'Highest',
                  value: '${settings.getCurrencySymbol()}${categoryTotals.values.reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}',
                  color: AppTheme.errorColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const _CategoryPieChart({required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = categoryTotals.values.fold(0.0, (sum, value) => sum + value);

    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
      Colors.lime,
      Colors.deepOrange,
      Colors.cyan,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sortedCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final percentage = (category.value / total) * 100;

                    return PieChartSectionData(
                      value: category.value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      color: colors[index % colors.length],
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdownList extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const _CategoryBreakdownList({required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
    final settings = Provider.of<SettingsProvider>(context);

    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
      Colors.lime,
      Colors.deepOrange,
      Colors.cyan,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Category Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ...sortedCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final percentage = (category.value / total);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              category.key,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Text(
                          '${settings.getCurrencySymbol()}${category.value.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors[index % colors.length],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SpendingTrendChart extends StatelessWidget {
  final List expenses;

  const _SpendingTrendChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    final last7Days = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });

    final dailyTotals = last7Days.map((date) {
      final dayTotal = expenses
          .where((expense) =>
              expense.date.year == date.year &&
              expense.date.month == date.month &&
              expense.date.day == date.day)
          .fold(0.0, (sum, expense) => sum + expense.amount);
      return dayTotal;
    }).toList();

    final maxY = dailyTotals.isEmpty
        ? 100.0
        : dailyTotals.reduce((a, b) => a > b ? a : b) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last 7 Days Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 5,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${settings.getCurrencySymbol()}${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                            final date = last7Days[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('E').format(date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyTotals
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                          .toList(),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}