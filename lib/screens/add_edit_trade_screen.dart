import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../models/trade.dart';

/// Result passed back to the home screen: either a saved trade, or a
/// delete request for the trade that was being edited.
class TradeEditResult {
  final Trade? trade;
  final bool delete;
  TradeEditResult({this.trade, this.delete = false});
}

class AddEditTradeScreen extends StatefulWidget {
  final Trade? existing;
  const AddEditTradeScreen({super.key, this.existing});

  @override
  State<AddEditTradeScreen> createState() => _AddEditTradeScreenState();
}

class _AddEditTradeScreenState extends State<AddEditTradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _pairCtrl;
  late TextEditingController _entryCtrl;
  late TextEditingController _stopCtrl;
  late TextEditingController _targetCtrl;
  late TextEditingController _lotCtrl;
  late TextEditingController _riskCtrl;
  late TextEditingController _pnlCtrl;
  late TextEditingController _notesCtrl;

  TradeDirection _direction = TradeDirection.buy;
  TradeOutcome _outcome = TradeOutcome.open;
  late DateTime _date;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _pairCtrl = TextEditingController(text: t?.pair ?? '');
    _entryCtrl = TextEditingController(text: t != null ? _fmt(t.entryPrice) : '');
    _stopCtrl = TextEditingController(text: t != null ? _fmt(t.stopLoss) : '');
    _targetCtrl = TextEditingController(text: t != null ? _fmt(t.takeProfit) : '');
    _lotCtrl = TextEditingController(text: t != null ? _fmt(t.lotSize) : '0.01');
    _riskCtrl = TextEditingController(text: t != null ? _fmt(t.riskAmount) : '');
    _pnlCtrl = TextEditingController(text: t?.pnl != null ? _fmt(t!.pnl!) : '');
    _notesCtrl = TextEditingController(text: t?.setupNotes ?? '');
    _direction = t?.direction ?? TradeDirection.buy;
    _outcome = t?.outcome ?? TradeOutcome.open;
    _date = t?.date ?? DateTime.now();
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _pairCtrl.dispose();
    _entryCtrl.dispose();
    _stopCtrl.dispose();
    _targetCtrl.dispose();
    _lotCtrl.dispose();
    _riskCtrl.dispose();
    _pnlCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.neutral,
                surface: AppColors.surfaceRaised,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final pnlText = _pnlCtrl.text.trim();
    final trade = Trade(
      id: widget.existing?.id ?? _uuid.v4(),
      date: _date,
      pair: _pairCtrl.text.trim().toUpperCase(),
      direction: _direction,
      entryPrice: double.parse(_entryCtrl.text),
      stopLoss: double.parse(_stopCtrl.text),
      takeProfit: double.parse(_targetCtrl.text),
      lotSize: double.parse(_lotCtrl.text),
      riskAmount: double.parse(_riskCtrl.text),
      outcome: _outcome,
      pnl: pnlText.isEmpty ? null : double.tryParse(pnlText),
      setupNotes: _notesCtrl.text.trim(),
    );
    Navigator.of(context).pop(TradeEditResult(trade: trade));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        title: const Text('Delete trade?'),
        content: const Text('This can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.loss)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(TradeEditResult(delete: true));
    }
  }

  String? _requiredNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (double.tryParse(v) == null) return 'Enter a number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit trade' : 'New trade'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
              color: AppColors.loss,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _pairCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Pair (e.g. EURUSD)'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date'),
                      child: Text('${_date.month}/${_date.day}/${_date.year}'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<TradeDirection>(
              segments: const [
                ButtonSegment(value: TradeDirection.buy, label: Text('Buy'), icon: Icon(Icons.arrow_upward, size: 16)),
                ButtonSegment(value: TradeDirection.sell, label: Text('Sell'), icon: Icon(Icons.arrow_downward, size: 16)),
              ],
              selected: {_direction},
              onSelectionChanged: (s) => setState(() => _direction = s.first),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _entryCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Entry price'),
                    validator: _requiredNumber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _stopCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Stop loss'),
                    validator: _requiredNumber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _targetCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Take profit'),
                    validator: _requiredNumber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _lotCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Lot size'),
                    validator: _requiredNumber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _riskCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount risked (\$)', prefixText: '\$ '),
              validator: _requiredNumber,
            ),
            const SizedBox(height: 20),
            const Text('Outcome', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TradeOutcome.values.map((o) {
                final selected = _outcome == o;
                return ChoiceChip(
                  label: Text(_outcomeLabel(o)),
                  selected: selected,
                  onSelected: (_) => setState(() => _outcome = o),
                  selectedColor: _outcomeColor(o),
                  backgroundColor: AppColors.surfaceRaised,
                  labelStyle: TextStyle(color: selected ? AppColors.bg : AppColors.textPrimary),
                  side: BorderSide(color: selected ? _outcomeColor(o) : AppColors.border),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (_outcome != TradeOutcome.open)
              TextFormField(
                controller: _pnlCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(
                  labelText: 'Realized P&L (\$, negative for a loss)',
                  prefixText: '\$ ',
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Setup notes',
                hintText: 'Why did this zone qualify? What confirmed the entry?',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.neutral,
                foregroundColor: AppColors.bg,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(_isEditing ? 'Save changes' : 'Log trade'),
            ),
          ],
        ),
      ),
    );
  }

  String _outcomeLabel(TradeOutcome o) {
    switch (o) {
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

  Color _outcomeColor(TradeOutcome o) {
    switch (o) {
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
}
