# AVIS Donation Management

🌐 Available languages:
-  [🇮🇹 Italiano](README.md)

[![Build and Test](https://github.com/Durigon-Diego/Gestione-Donazione-Avis/actions/workflows/flutter_test_and_badge.yml/badge.svg)](https://github.com/Durigon-Diego/Gestione-Donazione-Avis/actions/workflows/flutter_test_and_badge.yml)
[![Coverage](https://durigon-diego.github.io/Gestione-Donazione-Avis/coverage/20250430-111203-8176.svg)](https://durigon-diego.github.io/Gestione-Donazione-Avis/coverage/20250430-111203-8176/index.html) <!-- badge::coverage -->

**AVIS Donation Management** is a cross-platform Flutter app designed to simplify and digitize the workflow of AVIS donor days.  
The app allows operators to securely log in, manage each operational step in real-time, and access essential data in an efficient and organized way.

## ✨ Key Features

- Operator authentication via Supabase
- Italian UI with localization support
- Management of operational steps:
  - Reception
  - Acceptance
  - Medical Check-up
  - Donation
- Admin interface for:
  - Operator management
  - Donation day management
- Real-time data synchronization
- Supports Android, iOS, and Web platforms

## 🚀 Technologies Used

- [Flutter](https://flutter.dev/) 3.24+
- [Supabase](https://supabase.com/) – for authentication, database and RLS policies
- [`supabase_flutter`](https://pub.dev/packages/supabase_flutter) – Flutter integration
- `go_router` – for page navigation
- `flutter_localizations` + `intl` – for Italian language support
- `flutter_dotenv` – for secure environment variable handling
- `shared_preferences` – for local persistence
- `dart:developer` – for logging
- `flutter_test` – built-in testing framework
- `mocktail` – for unit testing
- `lints` – to maintain code quality

## ⚙️ Project Setup

1. **Clone the repository**
   ```bash
   git clone git@github.com:Durigon-Diego/Gestione-Donazione-Avis.git avis_donation_management
   cd avis_donation_management
   ```

2. **Install the local hook**
   ```bash
   bash setup.sh
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Configure environment variables**

   Copy the `.env_template` file and fill in your credentials:

   ```bash
   cp .env_template .env
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

| Folder                | Description                                             |
|-----------------------|---------------------------------------------------------|
| `lib/`                | Main application code                                   |
| `lib/pages/`          | Screens for each app section                            |
| `lib/components/`     | Themes, scaffolds and reusable components                  |
| `lib/helpers/`        | Support classes and logging                             |
| `assets/fonts/`       | Custom fonts                                            |
| `test/`               | Unit tests                                              |
| `test/fake_components`| Stubs for unit testing                                  |
| `SQL/`                | Database creation/update scripts                        |
| `tool/`               | General tools                                           |

## 🧪 Running Tests

```bash
flutter test
```

To generate a coverage report:
```bash
dart run tool/generate_coverage_helper.dart
flutter test
genhtml coverage/lcov.info --output-directory coverage/report/
```

## 📜 License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.  
This means that anyone using, modifying, or distributing the software—including via network services—must also share their modified source code under the same license terms.

Learn more: [https://www.gnu.org/licenses/agpl-3.0.html](https://www.gnu.org/licenses/agpl-3.0.html)

---

> A project developed to support the operational efficiency of AVIS blood donation days.
