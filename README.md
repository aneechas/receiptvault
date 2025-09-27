# ReceiptVault

AI-Powered Receipt Scanner & Expense Tracker for iOS

## Overview

ReceiptVault is a commercial-grade iOS application built with Flutter that helps individuals and small businesses manage their expenses through AI-powered receipt scanning and smart categorisation.

## Features

### Phase 1: Core Infrastructure (Current)
- ✅ Project structure with Flutter
- ✅ SQLite database with expense management
- ✅ Google ML Kit OCR integration
- ✅ Receipt parsing algorithms
- ✅ Material 3 theme with dark/light mode
- ✅ Provider state management
- ⏳ Camera integration (In Progress)

### Phase 2: Professional UI/UX (Planned)
- Animated dashboard with spending overview
- Receipt review and editing interface
- Custom theme system
- Smooth transitions and animations

### Phase 3: Advanced Features (Planned)
- Firebase authentication and cloud sync
- AI insights powered by Gemini API
- Interactive analytics dashboard
- Budget tracking

### Phase 4: Monetisation (Planned)
- Three-tier subscription system (Free/Premium/Business)
- CSV/PDF export functionality
- Multi-currency support
- Professional reporting

### Phase 5: App Store Launch (Planned)
- Performance optimisation
- Testing and quality assurance
- App Store preparation
- GDPR compliance

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **OCR**: Google ML Kit Text Recognition
- **AI**: Google Gemini API
- **Backend**: Firebase (Auth, Firestore)
- **Charts**: fl_chart, Syncfusion Charts

## Project Structure

```
lib/
├── main.dart
├── config/          # Theme, routes, constants
├── models/          # Data models (Expense, Category, Receipt, User)
├── services/        # Database, OCR, AI services
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable components
└── utils/           # Utilities and helpers
```

## Development

### Prerequisites
- Flutter SDK 3.0+
- Xcode (for iOS development)
- CocoaPods

### Setup
```bash
# Install dependencies
flutter pub get

# Run on iOS simulator
flutter run

# Build for iOS
flutter build ios --release
```

### Testing
```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## Monetisation Model

### Free Tier
- Up to 20 receipts per month
- Basic expense tracking
- Manual categorisation

### Premium Tier (£4.99/month)
- Up to 500 receipts per month
- AI-powered insights
- Cloud sync
- CSV export

### Business Tier (£9.99/month)
- Unlimited receipts
- Priority support
- PDF reports
- Multi-currency
- Team features

## Development Timeline

- **Days 1-3**: Phase 1 - Core Infrastructure ✅
- **Days 3-5**: Phase 2 - Professional UI/UX
- **Days 5-7**: Phase 3 - Advanced Features & AI
- **Days 7-8**: Phase 4 - Monetisation
- **Days 8-10**: Phase 5 - App Store Launch

## License

Proprietary - All Rights Reserved

## Author

Developed as part of the MasterClaude framework side project initiative.

## Support

For issues and feature requests, please use GitHub Issues.

---

**Status**: Phase 1 In Progress | **Target**: Commercial iOS App | **Quality**: Production-Ready