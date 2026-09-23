enum TradeDirection { buy, sell }

enum TradeOutcome { win, loss, breakeven, open }

class Trade {
  final String id;
  final DateTime date;
  final String pair;
  final TradeDirection direction;
  final double entryPrice;
  final double stopLoss;
  final double takeProfit;
  final double lotSize;
  final double riskAmount; // dollars risked on this trade
  final TradeOutcome outcome;
  final double? pnl; // realized profit/loss in dollars, null if open
  final String setupNotes; // why this zone qualified as supply/demand
  final String? screenshotPath;

  Trade({
    required this.id,
    required this.date,
    required this.pair,
    required this.direction,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.lotSize,
    required this.riskAmount,
    required this.outcome,
    this.pnl,
    this.setupNotes = '',
    this.screenshotPath,
  });

  /// Reward-to-risk ratio based on entry/stop/target, regardless of outcome.
  double get plannedRR {
    final risk = (entryPrice - stopLoss).abs();
    final reward = (takeProfit - entryPrice).abs();
    if (risk == 0) return 0;
    return reward / risk;
  }

  /// Realized R-multiple: how many "R" (risk units) this trade actually made or lost.
  double? get realizedR {
    if (pnl == null || riskAmount == 0) return null;
    return pnl! / riskAmount;
  }

  Trade copyWith({
    String? id,
    DateTime? date,
    String? pair,
    TradeDirection? direction,
    double? entryPrice,
    double? stopLoss,
    double? takeProfit,
    double? lotSize,
    double? riskAmount,
    TradeOutcome? outcome,
    double? pnl,
    String? setupNotes,
    String? screenshotPath,
  }) {
    return Trade(
      id: id ?? this.id,
      date: date ?? this.date,
      pair: pair ?? this.pair,
      direction: direction ?? this.direction,
      entryPrice: entryPrice ?? this.entryPrice,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
      lotSize: lotSize ?? this.lotSize,
      riskAmount: riskAmount ?? this.riskAmount,
      outcome: outcome ?? this.outcome,
      pnl: pnl ?? this.pnl,
      setupNotes: setupNotes ?? this.setupNotes,
      screenshotPath: screenshotPath ?? this.screenshotPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'pair': pair,
        'direction': direction.name,
        'entryPrice': entryPrice,
        'stopLoss': stopLoss,
        'takeProfit': takeProfit,
        'lotSize': lotSize,
        'riskAmount': riskAmount,
        'outcome': outcome.name,
        'pnl': pnl,
        'setupNotes': setupNotes,
        'screenshotPath': screenshotPath,
      };

  factory Trade.fromJson(Map<String, dynamic> json) => Trade(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        pair: json['pair'] as String,
        direction: TradeDirection.values.byName(json['direction'] as String),
        entryPrice: (json['entryPrice'] as num).toDouble(),
        stopLoss: (json['stopLoss'] as num).toDouble(),
        takeProfit: (json['takeProfit'] as num).toDouble(),
        lotSize: (json['lotSize'] as num).toDouble(),
        riskAmount: (json['riskAmount'] as num).toDouble(),
        outcome: TradeOutcome.values.byName(json['outcome'] as String),
        pnl: json['pnl'] == null ? null : (json['pnl'] as num).toDouble(),
        setupNotes: json['setupNotes'] as String? ?? '',
        screenshotPath: json['screenshotPath'] as String?,
      );
}
