import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/trade.dart';

class TradeCard extends StatelessWidget {
  final Trade trade;
  final VoidCallback onTap;

  const TradeCard({super.key, required this.trade, required this.onTap});

  Color get _outcomeColor {
    switch (trade.outcome) {
      case TradeOutcome.win:
        return AppColors.win;
      case TradeOutcome.loss:
        return AppColors.loss;
      case TradeOutcome.breakeven:
        return AppColors.neutral;
      case TradeOutcome.open:
        return AppColors.open;
    }
  }

  String get _outcomeLabel {
    switch (trade.outcome) {
      case TradeOutcome.win:
        return 'Win';
      case TradeOutcome.loss:
        return 'Loss';
      case TradeOutcome.breakeven:
        return 'Breakeven';
      case TradeOutcome.open:
        return 'Open';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, y').format(trade.date);
    final r = trade.realizedR;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _outcomeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          trade.pair,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          trade.direction == TradeDirection.buy
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(dateStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _outcomeLabel,
                    style: TextStyle(color: _outcomeColor, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  if (r != null)
                    Text(
                      '${r >= 0 ? '+' : ''}${r.toStringAsFixed(1)}R',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    )
                  else
                    Text(
                      'target ${trade.plannedRR.toStringAsFixed(1)}R',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
