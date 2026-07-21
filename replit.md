# AI Store Assistant — Flutter Mobile Application

## Project Overview

A complete Flutter mobile application foundation for an AI-powered retail management platform targeting grocery stores and small businesses in Yemen.

Originally imported as a Figma Make React/Vite prototype, this project has been fully converted into a production-ready Flutter application.

## Tech Stack

- **Framework:** Flutter 3.32.0
- **Language:** Dart 3.8.0
- **Navigation:** go_router
- **State Management:** Provider (wired, not yet populated with business logic)
- **Charts:** fl_chart
- **Typography:** Google Fonts (Inter)
- **Storage:** shared_preferences + flutter_secure_storage interface
- **Localization:** flutter_localizations (English + Arabic RTL)

## Running the Project

Since this is a Flutter mobile app, it cannot be previewed directly in Replit's web preview. To build and run:

```bash
flutter pub get
flutter build apk --debug   # Android APK
flutter build ios            # iOS (requires macOS + Xcode)
flutter analyze              # Static analysis
```

## Project Structure

```
lib/
├── main.dart                   — App entry point, theme + localization setup
├── core/
│   ├── constants/              — AppConstants, AppStrings
│   ├── routing/                — AppRouter (GoRouter)
│   ├── security/               — AuthGuard (RBAC)
│   ├── theme/                  — AppTheme, AppColors
│   └── utilities/              — Validators, DateUtils
├── features/
│   ├── onboarding/             — Splash, Welcome, AccountType screens
│   ├── authentication/         — Login, Register screens
│   ├── merchant/               — Merchant Dashboard
│   ├── worker/                 — Worker Panel (restricted permissions)
│   ├── customer/               — Customer Product Search
│   ├── inventory/              — Inventory Management
│   ├── product_scanner/        — Barcode + Image Scanner
│   ├── sales/                  — Fast Sales Screen
│   ├── debts/                  — Debt Management
│   ├── analytics/              — Charts (fl_chart: line + pie)
│   ├── branches/               — Branch Management
│   ├── marketing/              — Promotions + Customer Messages
│   ├── ai_assistant/           — AI Chat (Gemini interface ready)
│   └── settings/               — Theme, Language, Account, Subscription
└── shared/
    ├── models/                 — User, Product, Sale, Debt models
    ├── services/               — AuthService, ApiService, StorageService
    └── widgets/                — CustomButton, CustomTextField, AppCard, StatCard, LoadingOverlay
```

## Key Design Decisions

- **Theme:** Auto dark/light based on device time (dark after 20:00); manual override in Settings
- **RBAC:** Worker accounts cannot see profit, analytics, or private merchant data
- **AI:** Full service interface prepared for Gemini API — no fake API keys committed
- **Security:** Sensitive tokens go through SecureStorageService (flutter_secure_storage); API keys loaded via --dart-define
- **RTL:** Arabic locale registered; full RTL testing needed

## User Preferences

- Keep Flutter project structure clean — one screen per file
- Never commit secrets or API keys
- Stub implementations should be clearly marked with `// TODO: Replace with real API call`
