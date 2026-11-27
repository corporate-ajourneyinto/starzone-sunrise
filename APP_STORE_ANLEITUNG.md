# starzone iOS-App direkt über GitHub Actions in den Apple App Store laden

Diese Anleitung führt dich **komplett ohne Mac (direkt über GitHub Actions)** in **App Store Connect / TestFlight** und den **Apple App Store**.

---

## Schritt 1: App Store Connect vorbereiten

Voraussetzung: Aktives **Apple Developer Program** ([developer.apple.com](https://developer.apple.com)).

1. **Team ID notieren:**
   - Öffne [developer.apple.com/account](https://developer.apple.com/account) → **Membership details** → **Team ID** (10-stellig, z. B. `AB12CD34EF`).
2. **Bundle-ID registrieren:**
   - Öffne [developer.apple.com/account/resources/identifiers/list](https://developer.apple.com/account/resources/identifiers/list)
   - Klicke **+** → **App IDs** → **App**
   - **Bundle ID (Explicit):** z. B. `ch.starzone.festivalapp` *(falls bereits vergeben, wähle eine eigene eindeutige ID wie `ch.deinname.starzone`)*.
3. **Neue App anlegen:**
   - Öffne [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Meine Apps → + → Neue App**
   - Plattform: **iOS**, Sprache: **Deutsch**, Bundle-ID aus Schritt 1.2 wählen.
4. **App Store Connect API-Key erstellen (für Cloud-Signierung ohne Mac):**
   - In App Store Connect: **Benutzer und Zugriffe → Integrationen → App Store Connect-API → +**
   - Name: `GitHub Actions`, Zugriff: **Admin** *(oder **App-Manager** mit Berechtigung für Cloud-verwaltete Verteilungszertifikate)*.
   - **`.p8`-Datei herunterladen** (nur 1× möglich!) und **Issuer ID** + **Key ID** notieren.

---

## Schritt 2: GitHub Secrets im Repository hinterlegen

Öffne in deinem Repository `corporate-ajourneyinto/starzone-sunrise`:
**Settings → Secrets and variables → Actions → New repository secret**

Lege diese **4 Secrets** an:

| Secret-Name | Wert |
|---|---|
| `APPLE_TEAM_ID` | Deine 10-stellige Apple Developer **Team ID** |
| `APP_STORE_CONNECT_ISSUER_ID` | **Issuer ID** (UUID) aus App Store Connect |
| `APP_STORE_CONNECT_KEY_ID` | **Key ID** (10-stellig) des API-Keys |
| `APP_STORE_CONNECT_API_KEY` | Kompletter Inhalt der `AuthKey_XXXX.p8`-Datei *(Klartext inkl. `-----BEGIN PRIVATE KEY-----` oder Base64)* |

*(Optional: Falls deine Bundle-ID von `ch.starzone.festivalapp` abweicht, lege unter **Variables** eine Variable `APP_BUNDLE_ID` mit deiner Bundle-ID an.)*

---

## Schritt 3: Build & Upload zu App Store Connect starten

1. Öffne im GitHub-Repository den Tab **Actions**.
2. Wähle links den Workflow **App Store Connect Upload (iOS)**.
3. Klicke auf **Run workflow** → optional Bundle-ID / Version prüfen → **Run workflow** starten.
   *(Alternativ startet der Upload automatisch, sobald du ein Git-Tag wie `v1.0.0` pushst.)*

GitHub Actions baut die App auf einem `macos-15`-Runner mit Xcode, signiert sie über **Apple Cloud Signing** und lädt sie direkt in **App Store Connect → TestFlight** hoch!

---

## Schritt 4: Testen & im App Store veröffentlichen

1. Nach ca. 10–15 Minuten erscheint der Build in App Store Connect unter **TestFlight** — installiere ihn per **TestFlight-App** auf deinem iPhone.
2. Fülle in App Store Connect unter **App Store** die Pflichtfelder aus:
   - Screenshots, Beschreibung, Support-URL, **Datenschutzerklärungs-URL** & Altersfreigabe.
3. Wähle den Build aus und klicke **Zur Prüfung hinzufügen** (App Review dauert meist 24–48 Std.).

> **Wichtiger Marken-Hinweis:** Falls du die App öffentlich unter dem Namen/Logo **starzone / Sunrise** im App Store veröffentlichst, verlangt Apple ggf. einen Nachweis über die Markenrechte (oder die Einreichung über das offizielle Sunrise-/starzone-Developer-Konto). Für interne Tests über **TestFlight** ist das zunächst unkritisch.
