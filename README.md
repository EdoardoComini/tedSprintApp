# 🚀 tedSprintApp

Benvenuto nella repository ufficiale di **tedSprintApp**, l'applicazione Flutter dedicata alla gestione e presentazione dei progetti in stile TEDx. Il progetto include un'architettura frontend robusta in Flutter e un'integrazione backend serverless basata su AWS Lambda.

---

## 📂 Struttura del Progetto

Il progetto è strutturato in modo da separare nettamente la logica di business del backend e l'interfaccia utente del frontend:

```text
tedSprintApp/
├── backend/                  # Codice e configurazioni delle funzioni AWS Lambda
└── frontend/
    └── lib/
        ├── models/           # Modelli dati e strato Domain (Flutter)
        ├── providers/        # [Pronto per Antonio] Gestione dello stato globale
        └── screens/          # [Pronto per Antonio] Interfacce e schermate della UI
💡 Nota per i Collaboratori: Le cartelle providers e screens sono attualmente configurate con la struttura ufficiale pronta all'uso. I file specifici per queste sezioni verranno caricati direttamente dai rispettivi proprietari.

🛠️ Tecnologie Utilizzate
Frontend: Flutter & Dart (Struttura MVC/Provider)

Backend: Node.js / Python (AWS Lambda Functions)

Database / API: AWS Gateway & Servizi integrati

💻 Come Iniziare
Prerequisiti
Assicurati di avere installato sul tuo computer:

Flutter SDK (versione stabile)

VS Code (con estensioni Flutter/Dart) o Android Studio

Configurazione Locale
Clona la repository:

Bash
git clone [https://github.com/EdoardoComini/tedSprintApp.git](https://github.com/EdoardoComini/tedSprintApp.git)
cd tedSprintApp
Installa le dipendenze del Frontend:

Bash
cd frontend
flutter pub get
Avvia l'applicazione:
Connetti un emulatore o un dispositivo fisico e lancia:

Bash
flutter run
👤 Autori e Contributi
Edoardo Comini (e.comini1@studenti.unibg.it) — Setup iniziale, Modelli dati e Struttura Backend Lambda

Antonio — Sviluppo UI Screens e Stato Globale (Providers)
