import 'package:expense_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:expense_app/core/theme/app_colors.dart';
import 'package:expense_app/core/utils/currency_formatter.dart';
import 'package:expense_app/features/analytics/presentation/statistics/transaction_statistics.dart';
import 'package:expense_app/features/analytics/presentation/widgets/stats_charts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  StatsPeriod _selectedPeriod = StatsPeriod.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.transactions.isEmpty) {
            return _ErrorState(
              message: provider.error!,
              onRetry: provider.fetchTransactions,
            );
          }

          final statistics = TransactionStatistics.calculate(
            transactions: provider.transactions,
            period: _selectedPeriod,
            referenceDate: DateTime.now(),
          );

          return RefreshIndicator(
            onRefresh: provider.fetchTransactions,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                _PeriodSelector(
                  selectedPeriod: _selectedPeriod,
                  onChanged: (period) {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  _periodDescription(_selectedPeriod, statistics.range.start),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _SummaryCard(statistics: statistics),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Transactions',
                        value: '${statistics.expenseCount}',
                        icon: Icons.receipt_long_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: 'Average expense',
                        value: formatNpr(statistics.averageExpense),
                        icon: Icons.show_chart,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Spending trend',
                  subtitle: _trendSubtitle(_selectedPeriod),
                  child: ExpenseBarChart(
                    buckets: statistics.buckets,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Expenses by category',
                  subtitle: 'Where your money went',
                  child: statistics.categories.isEmpty
                      ? const _EmptyCategories()
                      : Column(
                          children: [
                            Center(
                              child: ExpenseDonutChart(
                                categories: statistics.categories,
                                total: statistics.totalExpenses,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (final category in statistics.categories)
                              _CategoryRow(
                                category: category,
                                total: statistics.totalExpenses,
                              ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _periodDescription(StatsPeriod period, DateTime start) {
    switch (period) {
      case StatsPeriod.week:
        return 'This week';
      case StatsPeriod.month:
        return '${_monthName(start.month)} ${start.year}';
      case StatsPeriod.year:
        return '${start.year}';
    }
  }

  String _trendSubtitle(StatsPeriod period) {
    switch (period) {
      case StatsPeriod.week:
        return 'Daily expenses';
      case StatsPeriod.month:
        return 'Weekly totals';
      case StatsPeriod.year:
        return 'Monthly totals';
    }
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
  });

  final StatsPeriod selectedPeriod;
  final ValueChanged<StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<StatsPeriod>(
      segments: const [
        ButtonSegment(value: StatsPeriod.week, label: Text('Week')),
        ButtonSegment(value: StatsPeriod.month, label: Text('Month')),
        ButtonSegment(value: StatsPeriod.year, label: Text('Year')),
      ],
      selected: {selectedPeriod},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.statistics});

  final TransactionStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL EXPENSES',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatNpr(statistics.totalExpenses),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.total,
  });

  final CategoryExpense category;
  final double total;

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0 : (category.amount / total * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(category.icon, color: category.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '$percentage%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 12),
          Text(
            formatNpr(category.amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'No expenses recorded for this period.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
