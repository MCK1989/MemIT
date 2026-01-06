# 🔔 Guida alla Configurazione delle Notifiche

## ✅ Modifiche Completate

Ho risolto il problema delle notifiche implementando:

1. **Gestione completa dei permessi** in `SettingsView.swift`
2. **Delegate per notifiche in foreground** in `MemITApp.swift`
3. **Funzione di test** per verificare immediatamente il funzionamento
4. **Traduzioni complete** in `LocalizationManager.swift`

## 📝 Configurazione Necessaria in Xcode

### 1. Aggiungi la chiave nell'Info.plist

Devi aggiungere la descrizione per i permessi delle notifiche:

1. Apri il file **Info.plist** nel tuo progetto
2. Aggiungi una nuova riga cliccando sul `+`
3. Inserisci la chiave: **NSUserNotificationsUsageDescription**
4. Inserisci il valore: **MemIT usa le notifiche per ricordarti di studiare le tue flashcard ogni giorno.**

Oppure in formato XML:
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>MemIT usa le notifiche per ricordarti di studiare le tue flashcard ogni giorno.</string>
```

### 2. Verifica le Capability (opzionale ma consigliato)

1. Seleziona il target **MemIT** nel navigator di Xcode
2. Vai alla tab **Signing & Capabilities**
3. Se vuoi aggiungere badge all'icona, clicca **+ Capability** e aggiungi **Background Modes**
4. Abilita **Remote notifications** (solo se userai notifiche push in futuro)

## 🧪 Come Testare le Notifiche

### Nel Simulatore:

1. **Abilita le notifiche** in Settings → Notifications
2. Premi il **pulsante "Invia notifica di test"** (visibile solo in debug)
3. **IMPORTANTE**: Metti l'app in background premendo Cmd+Shift+H
4. Dopo 5 secondi vedrai la notifica!

### Su Dispositivo Reale:

1. Abilita il toggle delle notifiche
2. Concedi il permesso quando richiesto
3. Premi "Invia notifica di test"
4. Metti l'app in background
5. Vedrai la notifica dopo 5 secondi

## 🐛 Perché Non Vedo le Notifiche?

### Problema 1: App in Foreground
- **Causa**: Per default iOS non mostra notifiche quando l'app è aperta
- **Soluzione**: Ho aggiunto un `NotificationDelegate` che mostra notifiche anche in foreground

### Problema 2: Permessi Non Concessi
- **Causa**: L'utente ha negato i permessi
- **Soluzione**: Vai in Impostazioni → MemIT → Notifiche e abilitale manualmente

### Problema 3: Non Vedo l'App nelle Impostazioni
- **Causa**: Manca la chiave `NSUserNotificationsUsageDescription` nell'Info.plist
- **Soluzione**: Aggiungi la chiave come descritto sopra

### Problema 4: Console Dice "Scheduled" Ma Non Arriva
- **Causa**: La notifica è schedulata per l'orario impostato (potrebbe essere domani!)
- **Soluzione**: Usa il pulsante di test per ricevere una notifica dopo 5 secondi

## 📋 Verifica nella Console

Dovresti vedere questi messaggi:

```
✅ Notification permission granted
✅ Notification scheduled for 09:00
📋 Pending notifications: 1
   - dailyStudyReminder
```

Se vedi questi messaggi, le notifiche sono configurate correttamente!

## 🔍 Debug Avanzato

Per verificare lo stato dei permessi, aggiungi questo codice temporaneamente:

```swift
UNUserNotificationCenter.current().getNotificationSettings { settings in
    print("Authorization status: \(settings.authorizationStatus.rawValue)")
    print("Alert setting: \(settings.alertSetting.rawValue)")
    print("Badge setting: \(settings.badgeSetting.rawValue)")
    print("Sound setting: \(settings.soundSetting.rawValue)")
}
```

Stati possibili:
- `0` = notDetermined (mai richiesto)
- `1` = denied (negato)
- `2` = authorized (autorizzato)
- `3` = provisional (autorizzazione provvisoria)
- `4` = ephemeral (temporaneo per App Clips)

## ✨ Funzionalità Implementate

- ✅ Richiesta permessi all'attivazione del toggle
- ✅ Alert se l'utente nega i permessi con link alle impostazioni
- ✅ Schedulazione notifica giornaliera all'orario scelto
- ✅ Rischedulazione automatica quando cambi l'orario
- ✅ Cancellazione notifiche quando disabilitate
- ✅ Verifica e schedulazione all'avvio dell'app
- ✅ Notifica di test per debug (solo in build di sviluppo)
- ✅ Notifiche visibili anche con app in foreground
- ✅ Badge sull'icona dell'app

## 🎯 Prossimi Passi

1. Aggiungi la chiave nell'Info.plist
2. Compila ed esegui l'app
3. Abilita le notifiche
4. Premi "Invia notifica di test"
5. Metti l'app in background
6. Verifica che la notifica arrivi!

## 📱 Comportamento Finale

Una volta configurato, l'app:
1. Chiederà il permesso quando l'utente attiva le notifiche
2. Invierà una notifica ogni giorno all'orario impostato
3. Mostrerà un badge sull'icona
4. Permetterà all'utente di aprire l'app toccando la notifica

Buono studio! 📚✨
