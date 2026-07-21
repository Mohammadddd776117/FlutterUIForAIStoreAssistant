# AI Store Assistant — Flutter Mobile Application

> An AI-powered retail management platform for grocery stores and small businesses in Yemen and beyond.

---

## Overview

**AI Store Assistant** is a production-ready Flutter application foundation that empowers small shops and grocery stores with:

- 📦 **Smart Inventory Management** — track products, get low-stock alerts, and scan items with barcode or image recognition
- 🤖 **AI Business Assistant** — ChatGPT-style interface powered by Gemini API (interface prepared, ready for API key)
- 💰 **Fast Sales & Checkout** — select products, calculate totals, and record sales instantly
- 📊 **Analytics & Reports** — revenue, profit, expenses, and best-seller charts
- 👥 **Role-Based Access** — Merchant, Worker, and Customer roles with appropriate permissions
- 🏪 **Branch Management** — manage multiple store locations
- 📣 **Marketing Tools** — create promotions and send customer messages
- 🧾 **Debt Tracking** — customer debt records with payment history

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   └── app_strings.dart           # All UI strings (i18n-ready)
│   ├── routing/
│   │   └── app_router.dart            # GoRouter navigation
│   ├── security/
│   │   └── auth_guard.dart            # Route guards & RBAC
│   ├── theme/
│   │   ├── app_colors.dart            # Color palette
│   │   └── app_theme.dart             # Light & dark themes
│   └── utilities/
│       ├── app_date_utils.dart        # Date/number formatting
│       └── app_validators.dart        # Input validators
├── features/
│   ├── onboarding/                    # Splash, Welcome, Account Type
│   ├── authentication/                # Login, Register
│   ├── merchant/                      # Merchant Dashboard
│   ├── worker/                        # Worker Panel
│   ├── customer/                      # Customer Search
│   ├── inventory/                     # Inventory Management
│   ├── product_scanner/               # Barcode & Image Scanner
│   ├── sales/                         # Fast Sales Screen
│   ├── debts/                         # Debt Management
│   ├── analytics/                     # Revenue & Profit Charts
│   ├── branches/                      # Branch Management
│   ├── marketing/                     # Promotions & Messages
│   ├── ai_assistant/                  # AI Chat (Gemini-ready)
│   └── settings/                      # Theme, Language, Account
└── shared/
    ├── models/                         # Data models (User, Product, Sale, Debt)
    ├── services/                       # Auth, API, Storage services
    └── widgets/                        # Reusable UI components
```

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.2.0
- Dart ≥ 3.2.0
- Android Studio / Xcode for device builds

### Install Dependencies

```bash
flutter pub get
```

### Run on Android

```bash
flutter run -d android
```

### Run on iOS

```bash
flutter run -d ios
```

### Build Release APK

```bash
flutter build apk --release
```

### Build iOS Archive

```bash
flutter build ipa
```

---

## Architecture

This project follows **Clean Architecture** principles:

- **Core** — app-wide infrastructure (theme, routing, constants, security)
- **Features** — screen modules, each containing `screens/`, `services/`, and `models/` as needed
- **Shared** — cross-feature widgets, models, and services

### State Management

The project is structured for **Provider** (already in `pubspec.yaml`). Each feature is ready to wrap with `ChangeNotifierProvider` as business logic grows.

### Navigation

Uses **GoRouter** for declarative navigation with deep-link support and route protection via `AuthGuard`.

---

## Design System

| Token | Light | Dark |
|-------|-------|------|
| Background | `#F8FBFF` | `#0A0E1A` |
| Surface | `#FFFFFF` | `#141928` |
| Card | `#F1F5F9` | `#1E2539` |
| Primary | `#1A73E8` | `#1A73E8` |
| Accent | `#00C853` | `#00C853` |

**Typography:** Inter (Google Fonts)  
**Icons:** Material Symbols Rounded  
**Charts:** fl_chart  

**Theme switching:** automatic based on device time (dark after 20:00, light after 07:00) with manual override in Settings.

---

## AI Integration (Gemini)

The AI service layer is fully prepared in `lib/features/ai_assistant/services/ai_service.dart`.

To connect:
1. Obtain a Gemini API key from [Google AI Studio](https://aistudio.google.com/)
2. **Never commit the key** — supply it via `--dart-define`:
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_key_here
   ```
3. Uncomment and implement the `sendMessage` body in `AiService`
4. Add `http` or `dio` to `pubspec.yaml` for HTTP transport

### Planned AI Features

- Natural language store queries ("How much profit did I make today?")
- Product image recognition via Gemini Vision
- Restock recommendations based on sales history
- AI-generated promotion copy

---

## Security

- **Secure storage** — sensitive tokens go through `SecureStorageService` (wired to `flutter_secure_storage`)
- **Role-based access** — `AuthGuard` enforces merchant/worker/customer permissions at the router level
- **No secrets in source** — API keys loaded via `--dart-define` or a backend proxy
- **Input validation** — `AppValidators` covers all user inputs
- **HTTPS enforced** — all API calls use HTTPS; HTTP is rejected at config level

---

## Roadmap

- [ ] Connect backend API (replace stub implementations in `ApiService`)
- [ ] Integrate Gemini API for AI features
- [ ] Add real barcode scanning (`mobile_scanner` package)
- [ ] Implement real camera-based product image recognition
- [ ] Add offline mode with local SQLite (`drift` package)
- [ ] Push notifications (FCM)
- [ ] Multi-currency support
- [ ] Export reports to PDF / Excel
- [ ] Complete Arabic RTL layout testing

---

## License

Proprietary — All rights reserved.
