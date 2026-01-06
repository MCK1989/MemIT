# Changelog - MemIT App

## 2026-01-05 - Statistiche Globali e Fix Impostazioni

### 🐛 Bug Fixes

1. **Fix StudyViewModel - Corretto uso di maxReviewCards**
   - Prima: usava solo `dailyNewCards` come limite totale
   - Ora: usa `maxReviewCards` come limite totale e `dailyNewCards` per le carte nuove
   - Le carte dovute hanno priorità assoluta
   - Le carte nuove riempiono gli spazi rimanenti

### ⚙️ Impostazioni di Default

2. **Aggiornati valori di default per le impostazioni**
   - `dailyNewCards`: 20 carte (invariato)
   - `maxReviewCards`: 80 carte (ridotto da 100)
   - Rapporto: 80/20 = 4 (sostenibile a lungo termine)

### 📊 Statistiche Globali Persistenti

3. **Implementato sistema di statistiche globali**
   - Nuovo struct `GlobalStats` con persistenza in UserDefaults
   - Traccia statistiche totali:
     - Carte totali studiate
     - Nuove carte vs Review
     - Conteggio per rating (Again/Hard/Good/Easy)
     - Sessioni di studio totali
     - Data ultima sessione
   - Statistiche giornaliere con reset automatico:
     - `todayCardsStudied`
     - `todayNewCards`
     - `todayReviews`
   - Le statistiche vengono salvate quando si chiude una sessione
   - Le statistiche vengono caricate all'avvio dell'app

4. **Integrazione in StudyViewModel**
   - `endSession()` ora chiama `appState.updateGlobalStats(with: todayStats)`
   - Salvataggio automatico delle statistiche dopo ogni sessione

5. **UI Updates**
   - HomeView ora mostra statistiche giornaliere reali
   - StatsView mostra nuova sezione "All Time Statistics" con:
     - Carte totali studiate
     - Sessioni totali
     - Nuove carte e review
     - Accuracy globale
     - Breakdown dei rating
     - Data ultima sessione

### 🔄 Comportamento

**Logica della coda di studio:**
```
maxReviewCards = 80 (limite totale)
dailyNewCards = 20 (limite nuove)

Se hai 10 carte dovute:
- ✅ 10 carte dovute
- ✅ 20 carte nuove (min(20, 80-10) = 20)
- Totale: 30 carte

Se hai 70 carte dovute:
- ✅ 70 carte dovute
- ✅ 10 carte nuove (min(20, 80-70) = 10)
- Totale: 80 carte

Se hai 90 carte dovute:
- ✅ 80 carte dovute (limite massimo)
- ❌ 0 carte nuove
- Totale: 80 carte
```

### 📁 Files Modificati

- `AppState.swift`: Aggiunto `GlobalStats` struct e metodo `updateGlobalStats()`
- `StudyViewModel.swift`: Fix `prepareStudyQueue()` e aggiornato `endSession()`
- `HomeView.swift`: Integrato `appState.globalStats` nelle card statistiche
- `StatsView.swift`: Aggiunta sezione `globalStatsOverview`

### 🚀 Testing Checklist

- [ ] Verificare che le statistiche si salvano dopo una sessione
- [ ] Verificare che le statistiche persistono dopo chiusura/apertura app
- [ ] Verificare che le statistiche giornaliere si resettano ogni giorno
- [ ] Verificare che maxReviewCards limita correttamente il totale
- [ ] Verificare che dailyNewCards limita correttamente le nuove carte
- [ ] Verificare priorità delle carte dovute su quelle nuove

