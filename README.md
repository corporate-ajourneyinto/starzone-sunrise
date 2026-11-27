# starzone — Native SwiftUI iOS-App (iOS 17+)

Vollständige native **SwiftUI iOS-App** für **starzone presented by Sunrise — Festival Companion 2026**, ohne externe Third-Party-Abhängigkeiten (reine Apple-Frameworks: `SwiftUI`, `Observation`, `CoreImage`, `AVFoundation`, `WebKit`, `SafariServices`, `UIKit`).

## Enthaltene Module

1. **Karte (`MapLineupView.swift`)**: Interaktive Geländekarte mit Crowd-Heatmap, barrierefreier Wegführung, Friend Finder, Auto-/Zelt-Pins, Secret Stage (`STARZONE26` / `WALD`), Service-POIs inkl. Wartezeiten-Meldung, Line-up mit *My Schedule* & Konfliktwarnung, Wetter-Packliste und Ticketalarm.
2. **Quests (`QuestsGamesView.swift`)**: Level-/XP-/Coins-Profil, Quests nach Kategorie, digitales Badge-Regal mit Pin-Funktion, 3×3 Festival-Bingo, Zugabe-Tippspiel, AR-Schnitzeljagd (`LICHTUNG`, `BASILIKUM`) und Festival-Wrapped mit nativem iOS `ShareLink`.
3. **Community (`CommunityView.swift`)**: Social Wall / Vibe-Check Composer, Festival-Crew mit Ghost-Modus & nativem Buddy-QR-Sheet, Music-Matching, Act-Chats, starzone News und Mitfahr-/Zeltnachbar-Börse.
4. **Wallet (`VotingWalletView.swift`)**: Cashless-Guthaben (+CHF 25 / +CHF 50), native CoreImage QR-Tickets & Coupons (Vollbild-Scan-Sheet), Live-Votings, Coin-Prämien-Shop und Gewinnspiele.
5. **Live-Cam (`LiveCamBackstageView.swift`)**: Native `AVFoundation`-Kamera-Vorschau (mit Simulator-Fallback), „See me!“ Stage-Screen-Stream & Cheers sowie Vollbild-Lightstick-Show („Stars sparkling · Lights on“) mit automatischer Display-Helligkeit.
6. **Portale (`PortalsView.swift`)**: `WKWebView` + `SFSafariViewController` für `starzone.ch/de` und `sunrise.ch/de/rewards`.

## In Xcode öffnen & starten

1. Öffne `starzone.xcodeproj` mit **Xcode 15.4+** (oder Xcode 16+) auf einem Mac.
2. Wähle das Target **starzone** → **Signing & Capabilities** → wähle dein **Team** (Apple ID / Developer Account) und passe bei Bedarf die Bundle ID (`ch.starzone.festivalapp`) an.
3. Wähle oben ein **iPhone-Simulationsgerät** (z. B. *iPhone 15 Pro*) oder dein per Kabel verbundenes iPhone und drücke **⌘R (Run)**.
4. Für **TestFlight / App Store**: `Product → Archive` → *Distribute App*.

*(Optional: Falls du das Projekt neu generieren möchtest, liegt zusätzlich `project.yml` für `xcodegen generate` bei.)*
