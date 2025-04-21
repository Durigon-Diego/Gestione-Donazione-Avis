# Gestione Donazione AVIS

![Flutter CI](https://github.com/Durigon-Diego/Gestione-Donazione-Avis/actions/workflows/flutter.yml/badge.svg)
![Coverage](https://durigon-diego.github.io/Gestione-Donazione-Avis/coverage/20250421-135928-27924.svg) <!-- badge::coverage -->

**Gestione Donazione AVIS** è un'app Flutter multipiattaforma pensata per semplificare e digitalizzare la gestione dei donatori AVIS durante le giornate di donazione.  
L'app consente agli operatori di accedere con autenticazione sicura, gestire in tempo reale le fasi operative, e visualizzare dati essenziali in modo efficiente e organizzato.

## ✨ Funzionalità principali

- Autenticazione operatori tramite Supabase
- Interfaccia in italiano con localizzazione
- Gestione delle fasi operative:
  - Ingresso
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
- [Supabase](https://supabase.com/) (Auth, Database, Policies)
- `flutter_dotenv` per la gestione sicura delle variabili ambiente
- `shared_preferences` per la persistenza locale
- Logging con `dart:developer`

## ⚙️ Setup del progetto

1. **Clona il repository**  
   ```bash
   git clone git@github.com:TUO_USERNAME/avis-donor-app.git
   cd avis-donor-app
   ```

2. **Installa le dipendenze**
   ```bash
   flutter pub get
   ```

3. **Configura le variabili ambiente**

   Copia il file `.env_template` e compilalo con i dati richiesti:

   ```bash
   cp .env_template .env
   ```

4. **Avvia l'app**
   ```bash
   flutter run
   ```

## 📁 Struttura del progetto

| Cartella           | Contenuto                                       |
|--------------------|-------------------------------------------------|
| `lib/`             | Codice principale dell'app                      |
| `lib/pages/`       | Schermate per ciascuna sezione dell'app         |
| `lib/helpers/`     | Temi, scaffolds, logging e componenti riutili   |
| `assets/fonts/`    | Font personalizzati                             |

## 🧪 Esecuzione dei test

```bash
flutter test
```

## 📝 Licenza

Questo progetto è distribuito sotto licenza **GNU Affero General Public License v3.0 (AGPL-3.0)**.
Ciò significa che chiunque utilizzi, modifichi o distribuisca il software, anche tramite rete (es. come servizio), è tenuto a rendere disponibile il codice sorgente modificato secondo i termini della licenza.

Per maggiori informazioni: [https://www.gnu.org/licenses/agpl-3.0.html](https://www.gnu.org/licenses/agpl-3.0.html)

---

> Progetto sviluppato per supportare l’efficienza operativa delle giornate di donazione AVIS.
