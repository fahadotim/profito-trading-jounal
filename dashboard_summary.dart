import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/stats_service.dart';

class DashboardSummary extends StatelessWidget {
  final JournalStats stats;
  final double startingBalance;
  final VoidCallback onEditBalance;

  const DashboardSummary({
    super.key,
    required this.stats,
    required this.startingBalance,
    required this.onEditBalance,
  });

  @override
  Widget build(BuildContext context) {
    final pnlColor = stats.totalPnl >= 0 ? AppColors.win : AppColors.loss;
    final pctChange = startingBalance == 0
        ? 0.0
        : ((stats.currentBalance - startingBalance) / startingBalance) * 100;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onEditBalance,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '\$${stats.currentBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${pctChange >= 0 ? '+' : ''}${pctChange.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: pctChange >= 0 ? AppColors.win : AppColors.loss,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: onEditBalance,
            child: Text(
              'started at \$${startingBalance.toStringAsFixed(2)} · tap to edit',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          if (stats.equityCurve.length > 1) _EquityChart(points: stats.equityCurve),
          if (stats.equityCurve.length > 1) const SizedBox(height: 20),
          Row(
            children: [
              _StatTile(label: 'Win rate', value: '${stats.winRate.toStringAsFixed(0)}%'),
              _StatTile(
                label: 'Total R',
                value: '${stats.totalR >= 0 ? '+' : ''}${stats.totalR.toStringAsFixed(1)}R',
                valueColor: stats.totalR >= 0 ? AppColors.win : AppColors.loss,
              ),
              _StatTile(
                label: 'Net P&L',
                value: '${stats.totalPnl >= 0 ? '+' : ''}\$${stats.totalPnl.toStringAsFixed(2)}',
                valueColor: pnlColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatTile(label: 'Trades', value: '${stats.totalTrades}'),
              _StatTile(label: 'W / L / BE', value: '${stats.wins} / ${stats.losses} / ${stats.breakevens}'),
              _StatTile(label: 'Open', value: '${stats.open}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _EquityChart extends StatelessWidget {
  final List<double> points;

  const _EquityChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (int i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i])
    ];
    final minY = points.reduce((a, b) => a < b ? a : b);
    final maxY = points.reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY).abs() * 0.15).clamp(0.05, double.infinity);
    final rising = points.last >= points.first;

    return SizedBox(
      height: 100,
      child: LineChart(
        LineChartData(
          minY: minY - pad,
          maxY: maxY + pad,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: rising ? AppColors.win : AppColors.loss,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: (rising ? AppColors.win : AppColors.loss).withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
