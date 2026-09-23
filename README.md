# Trading Journal (Flutter)

A personal trading journal for logging supply & demand trades, tracking win rate, R-multiple, and equity over time. All data is stored **locally on your device** — no account, no server.

## Setup

1. Install Flutter if you haven't: https://docs.flutter.dev/get-started/install
2. Unzip this project, then from the project folder run:
   ```
   flutter pub get
   flutter run
   ```
   Pick a connected device/emulator, or run `flutter run -d chrome` to try it in a browser first.

## What's included

- **Dashboard** — current balance, % change from your starting balance, an equity curve, win rate, total R, net P&L, and trade counts.
- **Trade log** — every trade, newest first, color-coded by outcome.
- **Add/edit trade** — pair, direction, entry/stop/target, lot size, $ risked, outcome, realized P&L, and setup notes (why the zone qualified).
- Tap the balance at the top of the dashboard to edit your starting balance (defaults to $10).

## Project structure

```
lib/
  main.dart                     — app entry point, theme
  models/trade.dart             — Trade data model (incl. R-multiple math)
  services/storage_service.dart — on-device persistence (SharedPreferences)
  services/stats_service.dart   — win rate / R / equity curve calculations
  screens/home_screen.dart      — dashboard + trade list
  screens/add_edit_trade_screen.dart — trade form
  widgets/dashboard_summary.dart — stats + equity chart
  widgets/trade_card.dart       — trade list item
```

## Notes on the $10 account math

- **Amount risked ($)** is what you enter per trade — this is what "R" is measured against. If your broker's minimum lot size forces you to risk more than 1-2%, that's expected on a $10 account; just be consistent trade to trade so your R numbers stay comparable.
- **Realized P&L** is what you actually made/lost on a closed trade. The app divides this by your risked amount to get your realized R (e.g. risked $1, made $2 → +2R).
- Win rate is based on closed trades only (wins ÷ (wins + losses)); breakevens are tracked separately and don't count against you.

## Ideas for later

- Add screenshot attachments per trade (entry chart)
- Filter/sort the trade list by pair, outcome, or date range
- Export trades to CSV
