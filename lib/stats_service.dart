import '../models/trade.dart';

class JournalStats {
  final int totalTrades;
  final int wins;
  final int losses;
  final int breakevens;
  final int open;
  final double winRate; // 0-100, based on closed trades only
  final double totalR;
  final double totalPnl;
  final double currentBalance;
  final List<double> equityCurve; // running balance after each closed trade, starting balance first

  JournalStats({
    required this.totalTrades,
    required this.wins,
    required this.losses,
    required this.breakevens,
    required this.open,
    required this.winRate,
    required this.totalR,
    required this.totalPnl,
    required this.currentBalance,
    required this.equityCurve,
  });

  factory JournalStats.compute(List<Trade> trades, double startingBalance) {
    final closed = trades
        .where((t) => t.outcome != TradeOutcome.open)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    int wins = 0, losses = 0, breakevens = 0;
    double totalR = 0;
    double totalPnl = 0;
    final equity = <double>[startingBalance];
    double running = startingBalance;

    for (final t in closed) {
      if (t.outcome == TradeOutcome.win) wins++;
      if (t.outcome == TradeOutcome.loss) losses++;
      if (t.outcome == TradeOutcome.breakeven) breakevens++;
      final r = t.realizedR;
      if (r != null) totalR += r;
      final p = t.pnl ?? 0;
      totalPnl += p;
      running += p;
      equity.add(running);
    }

    final openCount = trades.length - closed.length;
    final decidedCount = wins + losses; // breakevens excluded from win-rate denominator
    final winRate = decidedCount == 0 ? 0.0 : (wins / decidedCount) * 100;

    return JournalStats(
      totalTrades: trades.length,
      wins: wins,
      losses: losses,
      breakevens: breakevens,
      open: openCount,
      winRate: winRate,
      totalR: totalR,
      totalPnl: totalPnl,
      currentBalance: running,
      equityCurve: equity,
    );
  }
}
