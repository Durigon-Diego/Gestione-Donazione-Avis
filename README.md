# Gestione Donazione AVIS

🌐 Lingue disponibili:
- [en English](README.en.md)

[![Build and Test](https://github.com/Durigon-Diego/Gestione-Donazione-Avis/actions/workflows/flutter_test_and_badge.yml/badge.svg)](https://github.com/Durigon-Diego/Gestione-Donazione-Avis/actions/workflows/flutter_test_and_badge.yml)
[![Coverage](https://durigon-diego.github.io/Gestione-Donazione-Avis/coverage/20250430-111203-13482.svg)](https://durigon-diego.github.io/Gestione-Donazione-Avis/coverage/20250430-111203-13482/index.html) <!-- badge::coverage -->


**Gestione Donazione AVIS** è un'app Flutter multi-piattaforma pensata per semplificare e digitalizzare la gestione dei donatori AVIS durante le giornate di donazione.
L'app consente agli operatori di accedere con autenticazione sicura, gestire in tempo reale le fasi operative, e visualizzare dati essenziali in modo efficiente e organizzato.

## ✨ Funzionalità principali

- Autenticazione operatori tramite Supabase
- Interfaccia in italiano con localizzazione
- Gestione delle fasi operative:
  - Accoglienza
  - Accettazione
  - Visita Medica
  - Donazione
- Interfaccia amministratore:
  - Gestione operatori
  - Gestione giornate di donazione
- Sincronizzazione in tempo reale
- Supporto per Android, iOS e Web

## 🚀 Tecnologie utilizzate

- [Flutter](https://flutter.dev/) 3.24+
- [Supabase](https://supabase.com/) – per autenticazione, database e RLS policies
- [`supabase_flutter`](https://pub.dev/packages/supabase_flutter) – integrazione con Flutter
- `go_router` – per la navigazione tra pagine
- `flutter_localizations` + `intl` – per il supporto alla lingua italiana
- `flutter_dotenv` – per la gestione sicura delle variabili ambiente
- `shared_preferences` – per la persistenza locale
- `dart:developer` – per il logging
- `flutter_test` – framework di test incluso
- `mocktail` – per i test unitari
- `lints` – per mantenere la qualità del codice

## ⚙️ Setup del progetto

1. **Clona il repository**
   ```bash
   git clone git@github.com:Durigon-Diego/Gestione-Donazione-Avis.git avis_donation_management
   cd avis_donation_management
   ```

2. **Installa l'hook locale**
   ```bash
   bash setup.sh
   ```

3. **Installa le dipendenze**
   ```bash
   flutter pub get
   ```

4. **Configura le variabili ambiente**

   Copia il file `.env_template` e compilalo con i dati richiesti:

   ```bash
   cp .env_template .env
   ```

5. **Avvia l'app**
   ```bash
   flutter run
   ```

## 📁 Struttura del progetto

| Cartella               | Contenuto                                       |
|------------------------|-------------------------------------------------|
| `lib/`                 | Codice principale dell'app                      |
| `lib/pages/`           | Schermate per ciascuna sezione dell'app         |
| `lib/components/`      | Temi, scaffolds e componenti riutilizzabili     |
| `lib/helpers/`         | Classi di supporto e logging                    |
| `assets/fonts/`        | Font personalizzati                             |
| `test/`                | Test unitari                                    |
| `test/fake_components` | Stub per test unitari                           |
| `SQL/`                 | Script per creazione/aggiornamento del database |
| `tool/`                | Tools generici                                  |

## 🧪 Esecuzione dei test

```bash
flutter test
```

Per generare il report di coverage
```bash
dart run tool/generate_coverage_helper.dart
flutter test
genhtml coverage/lcov.info --output-directory coverage/report/
```

## 📝 Licenza

Questo progetto è distribuito sotto licenza **GNU Affero General Public License v3.0 (AGPL-3.0)**.
Ciò significa che chiunque utilizzi, modifichi o distribuisca il software, anche tramite rete (es. come servizio), è tenuto a rendere disponibile il codice sorgente modificato secondo i termini della licenza.

Per maggiori informazioni: [https://www.gnu.org/licenses/agpl-3.0.html](https://www.gnu.org/licenses/agpl-3.0.html)

---

> Progetto sviluppato per supportare l’efficienza operativa delle giornate di donazione AVIS.

