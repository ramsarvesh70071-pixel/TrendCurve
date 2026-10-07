# 📈 Trend Curve

> **Track. Analyze. Grow.**  
> A production-quality, data-tracking and growth analytics Flutter application built with Material 3, Riverpod, GoRouter, and interactive charts.

---

## 🌟 Overview

**Trend Curve** allows creators, founders, professionals, students, and teams to create metrics and monitor numerical progress over time. Whether tracking monthly business revenue, expenses, website traffic, fitness goals, or study hours, Trend Curve computes momentum vectors, percentage growth, and visual trend curves.

📖 **[Full In-Depth User Guide & Feature Manual (Hinglish)](USER_GUIDE.md)** — Check this comprehensive guide explaining every screen, button, and feature step-by-step!

---

## ✨ Features

- **📊 Comprehensive Dashboard:**
  - Real-time stat cards: Total Trends, Logged Data Points, Average Growth, and Best Performer.
  - Interactive performance chart with 7D, 30D, 3M, 6M, 1Y, and All time filters.
  - Quick action buttons (Create Trend, Add Data, Compare, View Analytics).
  - Recent trends with sparklines and automated activity timeline.

- **📈 Trend Management & Full CRUD:**
  - Search with real-time filtering by category, trend direction (Positive, Negative, Stable), frequency, date range, and value limits.
  - 6 sorting modes (Recently Updated, Name, Highest Growth, Lowest Growth, Highest Value, Lowest Value).
  - Color palette selection, category tagging, unit customization (₹, $, %, kg, hrs, etc.), and frequency configuration (Daily, Weekly, Monthly, Yearly).
  - Trend duplicate, archive/restore, and safe deletion.

- **🔍 Interactive Data Analytics & Insights:**
  - Dynamic `fl_chart` line, bar, area, and multi-curve comparison widgets with custom touch tooltips and range zoom.
  - Automated mathematical insights (e.g. *"Your revenue increased by 18.4% compared with the previous period"*).
  - Detailed metrics: Starting Value, Highest Point, Lowest Point, Average Value, Total Change, Overall Growth %, and Best Period Spikes.
  - Multi-trend comparison screen (compare up to 3 metrics simultaneously on synchronized axes).

- **🔔 Activity Timeline & Notifications:**
  - Auto-logging timeline for all data updates, additions, and trend modifications.
  - Milestone alerts, goal achievements, and notification center with read/unread tracking.

- **🎨 Modern Design & Theming:**
  - Material 3 design system with curated Electric Indigo color palette.
  - Light mode, Dark mode, and System default with instant toggle and persistent storage.
  - Clean responsive layout for mobile, tablet, desktop, and web.

- **💾 Data Sovereignty (Export & Import):**
  - Instant backup export to formatted JSON and CSV.
  - JSON restore utility and sample data reset.

- **🔌 Backend-Ready Architecture:**
  - Built with Dio abstraction, API endpoints configuration, and automatic Bearer token interceptor to connect a Node.js/Express + MongoDB backend without rewriting UI code.

---

## 🛠️ Technology Stack

- **Framework:** Flutter 3.35+ (Dart 3.9+)
- **Design System:** Material 3, Google Fonts (Plus Jakarta Sans)
- **State Management:** Flutter Riverpod 3.x (`Notifier`, `AsyncNotifier`, `Provider`)
- **Routing:** GoRouter 17.x (Declarative StatefulShellRoute with auth redirects)
- **Charts:** fl_chart 1.2.0
- **Local Storage:** SharedPreferences & FlutterSecureStorage
- **Formatting:** intl 0.20+
- **HTTP Client:** Dio 5.11+

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.24 or higher)
- Android Studio / VS Code
- Android SDK (for Android build)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ramsarvesh70071-pixel/trend-curve.git
   cd trend-curve
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run unit & widget tests:**
   ```bash
   flutter test
   ```

4. **Run the application:**
   ```bash
   # Run on connected device or emulator
   flutter run

   # Run on Windows Desktop
   flutter run -d windows

   # Run on Chrome Web
   flutter run -d chrome
   ```

5. **Build release APK:**
   ```bash
   flutter build apk --release
   ```
   The generated APK will be at:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Testing

The project includes unit and widget test suites covering:
- Growth calculation formulas & zero-handling safety
- Trend direction classification & automated insight generation
- Repository CRUD operations (Create, Read, Update, Delete, Duplicate, Archive)
- Multi-criteria filtering & sorting
- Authentication flows & credential validation
- Number & date formatters
- App launch & splash screen rendering

```bash
flutter test
# All 24 tests passed
```

---

## 📄 License

This project is licensed under the MIT License.
