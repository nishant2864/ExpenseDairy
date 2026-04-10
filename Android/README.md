# ExpenseTracker Android (Flutter)

This is the Android version of ExpenseTracker, migrated from React Native to Flutter.

## 🚀 Getting Started

To initialize the platform-specific files (Android/iOS folders) and install dependencies, run the following commands in this directory:

```bash
# Generate platform files
flutter create .

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📂 Structure

- `lib/models/`: Data models for transactions and categories.
- `lib/providers/`: State management using Provider and SharedPreferences.
- `lib/screens/`: UI screens (Home, Transactions, Profile, etc.).
- `lib/widgets/`: Reusable components (ATMCard, TransactionRow, etc.).

## ✨ Features Replicated

- **Liquid Glass Aesthetic**: Implemented with gradients and BlurFilters (where applicable).
- **Virtual Tracking Card**: Flippable ATM card with balance and card details.
- **Persistence**: Synchronized with local storage via `shared_preferences`.
- **Search & Filters**: Fully functional search on the transactions list.
