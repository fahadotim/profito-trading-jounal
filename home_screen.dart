import 'package:flutter/material.dart';
import '../main.dart';
import '../models/trade.dart';
import '../services/stats_service.dart';
import '../services/storage_service.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/trade_card.dart';
import 'add_edit_trade_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  List<Trade> _trades = [];
  double _startingBalance = 10.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trades = await _storage.loadTrades();
    final balance = await _storage.loadStartingBalance();
    setState(() {
      _trades = trades;
      _startingBalance = balance;
      _loading = false;
    });
  }

  Future<void> _openAddEdit({Trade? existing}) async {
    final result = await Navigator.of(context).push<TradeEditResult>(
      MaterialPageRoute(builder: (_) => AddEditTradeScreen(existing: existing)),
    );
    if (result == null) return;

    final updated = List<Trade>.from(_trades);
    if (result.delete && existing != null) {
      updated.removeWhere((t) => t.id == existing.id);
    } else if (result.trade != null) {
      final idx = updated.indexWhere((t) => t.id == result.trade!.id);
      if (idx >= 0) {
        updated[idx] = result.trade!;
      } else {
        updated.insert(0, result.trade!);
      }
    }
    updated.sort((a, b) => b.date.compareTo(a.date));
    await _storage.saveTrades(updated);
    setState(() => _trades = updated);
  }

  Future<void> _editBalance() async {
    final controller = TextEditingController(text: _startingBalance.toStringAsFixed(2));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        title: const Text('Starting balance'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(prefixText: '\$ '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              Navigator.pop(ctx, v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result >= 0) {
      await _storage.saveStartingBalance(result);
      setState(() => _startingBalance = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.neutral)));
    }

    final stats = JournalStats.compute(_trades, _startingBalance);

    return Scaffold(
      appBar: AppBar(title: const Text('Trading Journal')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEdit(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.neutral,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: DashboardSummary(
                stats: stats,
                startingBalance: _startingBalance,
                onEditBalance: _editBalance,
              ),
            ),
            if (_trades.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(onAdd: () => _openAddEdit()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => TradeCard(
                      trade: _trades[i],
                      onTap: () => _openAddEdit(existing: _trades[i]),
                    ),
                    childCount: _trades.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.show_chart, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No trades logged yet',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Log your first supply/demand trade to start tracking your win rate and R.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onAdd,
              style: FilledButton.styleFrom(backgroundColor: AppColors.neutral, foregroundColor: AppColors.bg),
              child: const Text('Log a trade'),
            ),
          ],
        ),
      ),
    );
  }
}
