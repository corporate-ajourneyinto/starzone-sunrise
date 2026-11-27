import Foundation

enum FestivalSeedData {
    static let rewards: [RewardItem] = [
        RewardItem(
            id: "rew-1",
            title: "Getränkegutschein (0,5 l nach Wahl)",
            description: "Sofort als QR-Coupon in der starzone Lounge & an jeder Bar einlösbar.",
            costCoins: 80,
            type: "Coupon",
            stockLabel: "Sofort verfügbar"
        ),
        RewardItem(
            id: "rew-2",
            title: "25 % Festival-Rabatt & Merch-Voucher",
            description: "Gilt für T-Shirts, Hoodies und Partner-Festival-Extras.",
            costCoins: 120,
            type: "Coupon",
            stockLabel: "Noch 48 Codes"
        ),
        RewardItem(
            id: "rew-3",
            title: "starzone Lounge Upgrade (Fastlane & Terrasse)",
            description: "Zugang zur überdachten Lounge mit direktem Bühnenblick & Fast-Charger.",
            costCoins: 160,
            type: "Zugang",
            stockLabel: "Ziehung Samstag 15:00"
        ),
    ]

    static func defaultState() -> PersistedFestivalState {
        PersistedFestivalState(
            xp: 1420,
            coins: 195,
            cashlessBalance: 64.50,
            chargerReserved: false,
            secretUnlocked: false,
            myGhostMode: false,
            weatherAlertActive: false,
            checkedInStages: [.mainstage, .seebuehne],
            stages: [
                Stage(
                    id: .mainstage,
                    name: "Nordstern Hauptbühne",
                    subtitle: "Open-Air Arena · Headliner & Indie",
                    capacity: 18000,
                    crowdPercent: 86,
                    crowdLabel: .sehrVoll,
                    currentAct: "Kraftklub Kollektiv",
                    nextAct: "Mira Vance (21:30)",
                    walkMinutesFromGate: 6,
                    mapX: 210,
                    mapY: 165,
                    isSecret: false,
                    accessible: true,
                    quietZoneNearby: false,
                    alternativeHint: "Hohe Auslastung — rechte Tribüne oder Seebühne mit 42 % Auslastung nutzen."
                ),
                Stage(
                    id: .seebuehne,
                    name: "Seebühne West",
                    subtitle: "Uferterrasse · Electronic & Ambient",
                    capacity: 6500,
                    crowdPercent: 42,
                    crowdLabel: .ruhig,
                    currentAct: "Klara & The Waves",
                    nextAct: "Nachtfrequenz (20:45)",
                    walkMinutesFromGate: 9,
                    mapX: 555,
                    mapY: 135,
                    isSecret: false,
                    accessible: true,
                    quietZoneNearby: true,
                    alternativeHint: nil
                ),
                Stage(
                    id: .zeltbuehne,
                    name: "Zirkuszelt Ost",
                    subtitle: "Überdacht · Hip-Hop, Brass & Funk",
                    capacity: 4800,
                    crowdPercent: 68,
                    crowdLabel: .lebhaft,
                    currentAct: "Betonpoeten Live",
                    nextAct: "Tarek Echo (21:00)",
                    walkMinutesFromGate: 5,
                    mapX: 430,
                    mapY: 315,
                    isSecret: false,
                    accessible: true,
                    quietZoneNearby: false,
                    alternativeHint: nil
                ),
                Stage(
                    id: .waldlichtung,
                    name: "Waldlichtung (Secret Stage)",
                    subtitle: "Versteckt im Kiefernwald · Intime Sets",
                    capacity: 900,
                    crowdPercent: 54,
                    crowdLabel: .lebhaft,
                    currentAct: "??? Surprise DJ Set",
                    nextAct: "Solis Acoustic (22:15)",
                    walkMinutesFromGate: 12,
                    mapX: 680,
                    mapY: 345,
                    isSecret: true,
                    accessible: false,
                    quietZoneNearby: true,
                    alternativeHint: nil
                ),
            ],
            pois: [
                ServicePOI(id: "wc-1", type: .wc, name: "Sanitär Nord (Barrierefrei)", waitMinutes: 4, statusLabel: "Kurz", mapX: 135, mapY: 265, accessible: true, rating: 4.3, reportCount: 28),
                ServicePOI(id: "drinks-1", type: .drinks, name: "Getränkebar Hauptplatz", waitMinutes: 9, statusLabel: "Mittel", mapX: 310, mapY: 220, accessible: true, rating: 4.1, reportCount: 41),
                ServicePOI(id: "food-1", type: .food, name: "Foodtruck-Platz", waitMinutes: 11, statusLabel: "Belebt", mapX: 355, mapY: 390, accessible: true, rating: 4.6, reportCount: 53),
                ServicePOI(id: "wardrobe-1", type: .wardrobe, name: "Garderobe & Schließfächer", waitMinutes: 2, statusLabel: "Frei", mapX: 145, mapY: 395, accessible: true, rating: 4.7, reportCount: 19),
                ServicePOI(id: "water-1", type: .water, name: "Trinkwasser-Station See", waitMinutes: 1, statusLabel: "Sofort", mapX: 495, mapY: 205, accessible: true, rating: 4.8, reportCount: 64),
                ServicePOI(id: "charger-1", type: .charger, name: "starzone Fast-Charger Station", waitMinutes: 3, statusLabel: "Frei", mapX: 245, mapY: 270, accessible: true, rating: 4.9, reportCount: 37),
                ServicePOI(id: "lounge-1", type: .lounge, name: "starzone Hospitality Lounge", waitMinutes: 2, statusLabel: "Fastlane", mapX: 185, mapY: 225, accessible: true, rating: 4.9, reportCount: 49),
                ServicePOI(id: "firstaid-1", type: .firstaid, name: "Erste Hilfe & Sanitäter", waitMinutes: 0, statusLabel: "Bereit", mapX: 270, mapY: 345, accessible: true, rating: 5.0, reportCount: 12),
                ServicePOI(id: "quiet-1", type: .quiet, name: "Ruhige Zone & Ohrschutz", waitMinutes: 0, statusLabel: "Ruhig", mapX: 615, mapY: 225, accessible: true, rating: 4.8, reportCount: 22),
            ],
            packList: [
                PackListItem(id: "pk-1", label: "Regenponcho / Windbreaker", category: "Wetter", weatherDependent: true, packed: false),
                PackListItem(id: "pk-2", label: "Powerbank & Ladekabel", category: "Technik", weatherDependent: false, packed: true),
                PackListItem(id: "pk-3", label: "Ohrschutz (Musikfilter)", category: "Gesundheit", weatherDependent: false, packed: true),
                PackListItem(id: "pk-4", label: "Faltbare Trinkflasche (Wasserstation)", category: "Nachhaltigkeit", weatherDependent: false, packed: false),
                PackListItem(id: "pk-5", label: "Sonnenschutz & Kopfbedeckung", category: "Wetter", weatherDependent: false, packed: true),
            ],
            personalPins: [
                PersonalPin(type: .auto, mapX: 85, mapY: 365, note: "Parkplatz P2 · Reihe D"),
                PersonalPin(type: .zelt, mapX: 125, mapY: 120, note: "Camping Sektor B · Blaues Zelt"),
            ],
            lineup: [
                LineupAct(id: "act-1", artist: "Kraftklub Kollektiv", genre: "Indie-Rock", day: .freitag, startTime: "19:30", endTime: "20:45", stageId: .mainstage, walkMinutes: 6, isFavorite: true, hasReminder: true, isNewDiscovery: false, description: "Energiegeladener Festival-Auftakt mit Bläser-Sektion."),
                LineupAct(id: "act-2", artist: "Klara & The Waves", genre: "Dream-Pop", day: .freitag, startTime: "19:45", endTime: "20:50", stageId: .seebuehne, walkMinutes: 9, isFavorite: true, hasReminder: false, isNewDiscovery: true, description: "Schwebende Synthesizer direkt am Ufer bei Sonnenuntergang."),
                LineupAct(id: "act-3", artist: "Betonpoeten Live", genre: "Hip-Hop", day: .freitag, startTime: "20:15", endTime: "21:15", stageId: .zeltbuehne, walkMinutes: 5, isFavorite: false, hasReminder: false, isNewDiscovery: false, description: "Live-Band-Rap aus Hamburg mit treibenden Brass-Hooks."),
                LineupAct(id: "act-4", artist: "Mira Vance", genre: "Electro-Pop", day: .freitag, startTime: "21:30", endTime: "23:00", stageId: .mainstage, walkMinutes: 6, isFavorite: true, hasReminder: true, isNewDiscovery: false, description: "Headliner-Show mit synchronisierter Licht- und Leinwand-Regie."),
                LineupAct(id: "act-5", artist: "Nachtfrequenz", genre: "Melodic Techno", day: .samstag, startTime: "20:45", endTime: "22:15", stageId: .seebuehne, walkMinutes: 9, isFavorite: false, hasReminder: false, isNewDiscovery: true, description: "Analoges Live-Modular-Set mit visueller Wasserprojektion."),
                LineupAct(id: "act-6", artist: "Tarek Echo", genre: "Soul & Funk", day: .samstag, startTime: "21:00", endTime: "22:15", stageId: .zeltbuehne, walkMinutes: 5, isFavorite: true, hasReminder: false, isNewDiscovery: false, description: "Siebenköpfige Funk-Formation — perfekter Crowd-Vibe im Zelt."),
                LineupAct(id: "act-7", artist: "Solis Acoustic (Secret)", genre: "Indie-Folk", day: .samstag, startTime: "22:15", endTime: "23:30", stageId: .waldlichtung, walkMinutes: 12, isFavorite: false, hasReminder: false, isNewDiscovery: true, description: "Unangekündigtes Akustik-Set unter Kiefern mit Lampions."),
                LineupAct(id: "act-8", artist: "Veloce & Orchester", genre: "Neo-Klassik / Electro", day: .sonntag, startTime: "20:00", endTime: "21:45", stageId: .mainstage, walkMinutes: 6, isFavorite: true, hasReminder: false, isNewDiscovery: false, description: "Festivalfinale mit Streicherensemble und Subbass."),
            ],
            quests: [
                Quest(id: "q-stages", title: "Besuche 3 verschiedene Bühnen", description: "Checke per Karte an drei unterschiedlichen Bühnen ein und sammle Stempel.", category: .tages, xpReward: 150, coinReward: 40, progress: 2, target: 3, completed: false, badgeUnlockId: "b-explorer", sponsorName: nil, crewSizeHint: nil),
                Quest(id: "q-new-act", title: "Entdecke einen unbekannten Act", description: "Speichere einen als Neuentdeckung markierten Act in deinem Zeitplan.", category: .tages, xpReward: 120, coinReward: 30, progress: 0, target: 1, completed: false, badgeUnlockId: nil, sponsorName: nil, crewSizeHint: nil),
                Quest(id: "q-food-qr", title: "Versteckten QR-Code am Foodtruck-Platz finden", description: "Scanne den geheimen Hinweis-Code am Foodtruck-Platz oder gib das Codewort „BASILIKUM“ ein.", category: .tages, xpReward: 200, coinReward: 60, progress: 0, target: 1, completed: false, badgeUnlockId: "b-secret", sponsorName: nil, crewSizeHint: nil),
                Quest(id: "q-crew-sync", title: "Crew-Check-in vor der Hauptbühne", description: "Mit 3 bis 6 Squad-Mitgliedern gleichzeitig ein gemeinsames Konzert besuchen.", category: .crew, xpReward: 300, coinReward: 90, progress: 2, target: 3, completed: false, badgeUnlockId: "b-crew", sponsorName: nil, crewSizeHint: "3–6 Freunde"),
                Quest(id: "q-crew-eco", title: "Gemeinsame ÖV- & Becher-Challenge", description: "Bringt als Gruppe 4 Mehrwegbecher zurück und reist mit dem Shuttle oder Zug an.", category: .crew, xpReward: 240, coinReward: 75, progress: 3, target: 4, completed: false, badgeUnlockId: "b-eco", sponsorName: nil, crewSizeHint: "3–6 Freunde"),
                Quest(id: "q-season-vet", title: "starzone Festival-Pass 2024–2026", description: "Sammle Festival-Meilensteine über drei Ausgaben hinweg für den Veteran-Status.", category: .saison, xpReward: 450, coinReward: 120, progress: 1, target: 1, completed: true, badgeUnlockId: "b-veteran", sponsorName: nil, crewSizeHint: nil),
                Quest(id: "q-sponsor-fritz", title: "starzone Lounge Foto-Spot am See", description: "Mache einen Vibe-Check an der starzone Lounge und erhalte sofort einen 2-für-1 Getränkecoupon.", category: .sponsoren, xpReward: 140, coinReward: 50, progress: 0, target: 1, completed: false, badgeUnlockId: nil, sponsorName: "starzone Lounge", crewSizeHint: nil),
                Quest(id: "q-lights-on", title: "Stars sparkling: „Lights on“ mitmachen", description: "Aktiviere im Bereich Live-Kamera die synchronisierte Lightstick-Show vor der Bühne.", category: .tages, xpReward: 140, coinReward: 35, progress: 0, target: 1, completed: false, badgeUnlockId: "b-lightstick", sponsorName: nil, crewSizeHint: nil),
                Quest(id: "q-see-me", title: "See me! Auf Stage-Wings oder Lounge-Screen", description: "Sende dein Selfie-Video auf die Stage-Wings oder den Lounge-Screen und speichere es auf der Social Wall.", category: .tages, xpReward: 160, coinReward: 45, progress: 0, target: 1, completed: false, badgeUnlockId: "b-livecam", sponsorName: nil, crewSizeHint: nil),
            ],
            badges: [
                BadgeItem(id: "b-veteran", title: "Veteran seit 2024", description: "Dritte starzone Festival-Ausgabe in Folge besucht.", category: .saison, year: "2024–2026", rarityText: "Saison-Pass · 14 % der Gäste", unlocked: true, pinned: true, systemImage: "rosette"),
                BadgeItem(id: "b-early", title: "Früher Vogel", description: "Fastlane-Check-in innerhalb der ersten 30 Minuten nach Einlass.", category: .selten, year: "2026", rarityText: "Selten · 6 % der Gäste", unlocked: true, pinned: true, systemImage: "sparkles"),
                BadgeItem(id: "b-explorer", title: "Bühnen-Nomade", description: "Mindestens 3 verschiedene Bühnen an einem Tag besucht.", category: .selten, year: "2026", rarityText: "Entdecker · Quest-Belohnung", unlocked: false, pinned: false, systemImage: "safari.fill"),
                BadgeItem(id: "b-crew", title: "Unzertrennliche Crew", description: "Gemeinsame Crew-Quest mit 3–6 Freunden abgeschlossen.", category: .crew, year: "2026", rarityText: "Team-Badge", unlocked: false, pinned: false, systemImage: "person.3.fill"),
                BadgeItem(id: "b-eco", title: "Grüner Fußabdruck", description: "ÖV-Anreise & Mehrwegbecher-Challenge gemeistert.", category: .nachhaltigkeit, year: "2026", rarityText: "Nachhaltigkeit", unlocked: false, pinned: false, systemImage: "leaf.fill"),
                BadgeItem(id: "b-secret", title: "Waldlichtung-Scout", description: "Versteckte Secret Stage oder geheimen QR-Code entdeckt.", category: .selten, year: "2026", rarityText: "Sehr selten · 3 % der Gäste", unlocked: false, pinned: false, systemImage: "flame.fill"),
                BadgeItem(id: "b-livecam", title: "See me! Leinwand-Moment", description: "Live-Clip auf Stage-Wings oder Lounge-Screen gestreamt.", category: .selten, year: "2026", rarityText: "See me! · ~10 % der Gäste", unlocked: false, pinned: false, systemImage: "video.fill"),
                BadgeItem(id: "b-lightstick", title: "Emotionaler Lightstick", description: "Bei Stars sparkling („Lights on“) in der Crowd mitgeleuchtet.", category: .selten, year: "2026", rarityText: "Lights on · ~40 % der Gäste", unlocked: false, pinned: false, systemImage: "wand.and.stars"),
            ],
            bingo: [
                BingoTile(id: "bg-1", label: "Becher fliegt in die Luft", hint: "Beim Drop auf der Hauptbühne", completed: true, verifiedBy: "Check-in"),
                BingoTile(id: "bg-2", label: "Laute Zugabe-Rufe", hint: "Mind. 20 Sekunden Chor", completed: true, verifiedBy: "Foto"),
                BingoTile(id: "bg-3", label: "Sonnenuntergangs-Chor", hint: "Alle singen den Refrain mit", completed: false, verifiedBy: nil),
                BingoTile(id: "bg-4", label: "Fantasie-Kostüm gesichtet", hint: "Leuchtende Flügel oder Dino", completed: false, verifiedBy: nil),
                BingoTile(id: "bg-5", label: "High-Five mit Fremden", hint: "Vibe-Check an der Seebühne", completed: true, verifiedBy: "Check-in"),
                BingoTile(id: "bg-6", label: "Crowdsurfing-Moment", hint: "Live im vorderen Bereich", completed: false, verifiedBy: nil),
                BingoTile(id: "bg-7", label: "Wasserstation genutzt", hint: "Flasche kostenlos aufgefüllt", completed: false, verifiedBy: nil),
                BingoTile(id: "bg-8", label: "Secret Stage gefunden", hint: "Im Kiefernwald eingecheckt", completed: false, verifiedBy: nil),
                BingoTile(id: "bg-9", label: "Akustik-Gänsehaut", hint: "Handylampen im Zirkuszelt", completed: false, verifiedBy: nil),
            ],
            predictions: [
                EncorePrediction(id: "pred-1", artist: "Mira Vance", stageName: "Nordstern Hauptbühne", time: "Heute · 22:45", options: ["Neonregen", "Mitternachtszug", "Alles auf Anfang", "Puls 128"], selectedOption: nil, revealedSong: nil, points: 120),
                EncorePrediction(id: "pred-2", artist: "Kraftklub Kollektiv", stageName: "Nordstern Hauptbühne", time: "Heute · 20:35", options: ["Kein Schlaf für Chemnitz", "Schüsse in die Luft", "Fahr mit mir"], selectedOption: "Schüsse in die Luft", revealedSong: nil, points: 100),
            ],
            arClues: [
                ARClue(id: "ar-1", title: "starzone Totem Nord", locationHint: "Zwischen Hauptbühne und Trinkwasser-Station", found: true, rewardXp: 80, rewardCoins: 25, codeWord: "STARLIGHT"),
                ARClue(id: "ar-2", title: "Leuchtender Kiefern-Marker", locationHint: "Am schmalen Waldpfad östlich der Seebühne", found: false, rewardXp: 110, rewardCoins: 35, codeWord: "LICHTUNG"),
                ARClue(id: "ar-3", title: "Foodtruck-Mural", locationHint: "Rückseite des Taco-Wagens", found: false, rewardXp: 90, rewardCoins: 30, codeWord: "BASILIKUM"),
            ],
            vibePosts: [
                VibePost(id: "vp-1", author: "Lina Bergmann", handle: "@lina_b", stageName: "Nordstern Hauptbühne", timestamp: "Vor 4 Min", text: "Der Soundcheck bei Mira Vance drückt jetzt schon ordentlich. Rechts am Technikturm ist noch richtig viel Platz!", likes: 34, likedByMe: false, assetImageName: "festival_mainstage", isFanWallMoment: true),
                VibePost(id: "vp-2", author: "Matteo Kurz", handle: "@matteo_k", stageName: "Seebühne West", timestamp: "Vor 11 Min", text: "Klara & The Waves spielen gerade ihr erstes Akustik-Intro am Wasser. Perfekte Abendsonne und keine Schlange an der Bar.", likes: 52, likedByMe: true, assetImageName: "festival_fan_wall", isFanWallMoment: true),
                VibePost(id: "vp-3", author: "Svenja T.", handle: "@svenja_t", stageName: "Zirkuszelt Ost", timestamp: "Vor 19 Min", text: "Hat jemand eine Picknickdecke nahe Erste-Hilfe-Punkt gesehen? Unsere Crew sammelt sich dort für Tarek Echo.", likes: 12, likedByMe: false, assetImageName: nil, isFanWallMoment: false),
            ],
            squad: [
                SquadMember(id: "sq-1", name: "Maja Weber", role: "Crew-Lead", status: "Vor der Hauptbühne", stageId: "mainstage", mapX: 240, mapY: 190, ghostMode: false, buddyCode: "STZ-MAJA-42", favoriteActIds: ["act-1", "act-4", "act-6"]),
                SquadMember(id: "sq-2", name: "Jonas Richter", role: "Sound-Scout", status: "An der Seebühne", stageId: "seebuehne", mapX: 530, mapY: 155, ghostMode: false, buddyCode: "STZ-JONAS-19", favoriteActIds: ["act-2", "act-4", "act-5"]),
                SquadMember(id: "sq-3", name: "Tariq Al-Mansoor", role: "Zelt-Nachbar", status: "Ghost-Modus aktiv", stageId: "zeltbuehne", mapX: 410, mapY: 300, ghostMode: true, buddyCode: "STZ-TARIQ-88", favoriteActIds: ["act-3", "act-6"]),
            ],
            musicMatches: [
                MusicMatchProfile(id: "mm-1", name: "Elena Voss", service: "Spotify", matchPercent: 94, sharedArtists: ["Mira Vance", "Kraftklub Kollektiv", "Nachtfrequenz"], topGenre: "Indie & Melodic Techno", currentStage: "Seebühne West", invited: false),
                MusicMatchProfile(id: "mm-2", name: "Pauline Becker", service: "Apple Music", matchPercent: 87, sharedArtists: ["Klara & The Waves", "Veloce & Orchester"], topGenre: "Dream-Pop & Neo-Klassik", currentStage: "Foodtruck-Platz", invited: false),
                MusicMatchProfile(id: "mm-3", name: "David Sommer", service: "Spotify", matchPercent: 81, sharedArtists: ["Tarek Echo", "Betonpoeten Live"], topGenre: "Soul, Funk & Brass", currentStage: "Zirkuszelt Ost", invited: true),
            ],
            channels: [
                ChatChannel(id: "ch-main", name: "Hauptbühne Live-Talk", category: "Bühnen-Chat", archivesIn: "Archivierung in 42 Std.", activeUsers: 418, messages: [
                    ChatMessage(id: "m-1", author: "Felix", text: "Rechts am Wellenbrecher ist der Fastlane-Einlass super flüssig.", time: "19:42"),
                    ChatMessage(id: "m-2", author: "Hannah", text: "Wisst ihr, ob Mira Vance heute mit Live-Drums spielt?", time: "19:44"),
                ]),
                ChatChannel(id: "ch-wald", name: "Waldlichtung Spotting", category: "Secret Stage", archivesIn: "Archivierung in 42 Std.", activeUsers: 134, messages: [
                    ChatMessage(id: "m-3", author: "Nico", text: "Hinter den Kiefern beim Holzsteg brennen schon die Lampions!", time: "19:30"),
                ]),
                ChatChannel(id: "ch-electro", name: "Electronic & Techno Crew", category: "Genre-Gruppe", archivesIn: "Archivierung in 42 Std.", activeUsers: 267, messages: [
                    ChatMessage(id: "m-4", author: "Mara", text: "Nachtfrequenz ab 20:45 an der Seebühne — wer kommt mit?", time: "19:38"),
                ]),
            ],
            rideCampPosts: [
                RideCampPost(id: "rc-1", type: "Mitfahrt", title: "Rückfahrt Sonntag 14:00 nach Zürich HB", author: "Lukas M.", routeOrZone: "Parkplatz P2 → Zürich", dateInfo: "Sonntag · 2 Plätze frei", spotsOpen: 2, joined: false),
                RideCampPost(id: "rc-2", type: "Zeltnachbar", title: "Ruhiges Sonnen-Camp im Sektor B (Pavillon vorhanden)", author: "Kira & Tom", routeOrZone: "Camping Sektor B · Nähe Duschen", dateInfo: "Noch Platz für 2 Zweimannzelte", spotsOpen: 2, joined: false),
                RideCampPost(id: "rc-3", type: "Mitfahrt", title: "Shuttle-Gruppe ab Bahnhof St. Gallen", author: "Sina R.", routeOrZone: "Bahnhof → Nord-Tor", dateInfo: "Morgen 11:30 · Gemeinsames Gruppenticket", spotsOpen: 3, joined: false),
            ],
            polls: [
                VotingPoll(id: "poll-1", title: "Welchen Song soll Mira Vance als Überraschung spielen?", subtitle: "Direktes Artist-Voting · Ergebnis wird um 21:15 an die Regie übermittelt", artistOrHost: "Mira Vance (Hauptbühne)", closesAt: "21:10 Uhr", options: [
                    VotingOption(id: "o-1", label: "Nordlichter (Akustik-Version)", votes: 612),
                    VotingOption(id: "o-2", label: "Glashaus (Extended Club Mix)", votes: 845),
                    VotingOption(id: "o-3", label: "Sommer 2022 (Unveröffentlicht)", votes: 491),
                ], votedOptionId: nil),
                VotingPoll(id: "poll-2", title: "Welche Bühne bekommt das Mitternachts-Feuerwerk-Sync?", subtitle: "Community-Entscheidung für das heutige Finale", artistOrHost: "starzone Festivalleitung", closesAt: "23:00 Uhr", options: [
                    VotingOption(id: "o-4", label: "Nordstern Hauptbühne", votes: 1140),
                    VotingOption(id: "o-5", label: "Seebühne West (Wasserspiegelung)", votes: 1380),
                ], votedOptionId: nil),
            ],
            wallet: [
                WalletItem(id: "wal-ticket", type: "Ticket", title: "starzone 3-Tage-Festival-Pass + Fastlane", subtitle: "Sektor B · Separater Fastlane-Einlass Nord & Süd gültig", validUntil: "Bis Montag, 12:00 Uhr", qrSeed: "STARZONE-2026-PASS-89412", codeText: "STZ-26-89412", redeemed: false),
                WalletItem(id: "wal-drink", type: "Coupon", title: "1x Signature-Drink-Gutschein (starzone Lounge)", subtitle: "Hospitality-Vorteil — direkt an der starzone Bar scannen", validUntil: "Einmalig einlösbar", qrSeed: "STARZONE-SIGNATURE-DRINK-26", codeText: "STZ-DRINK-26", redeemed: false),
                WalletItem(id: "wal-backstage", type: "Zugang", title: "starzone Lounge & Backstage-Los #0419", subtitle: "Ziehung heute um 21:00 Uhr für Mira Vance inkl. Fast-Charger", validUntil: "Heute · 21:00 Uhr", qrSeed: "STARZONE-RAFFLE-0419", codeText: "STZ-VIP-0419", redeemed: false),
            ],
            broadcasts: [
                LiveCamBroadcast(id: "cam-1", author: "Maja Weber", stageName: "Nordstern Hauptbühne", caption: "Vorfreude auf Mira Vance — beste Stimmung rechts am Turm!", timestamp: "Gerade eben", cheers: 142, assetImageName: "festival_mainstage"),
                LiveCamBroadcast(id: "cam-2", author: "Jonas Richter", stageName: "Waldlichtung (Secret Stage)", caption: "Die Lichter gehen gerade im Kiefernwald an.", timestamp: "Vor 8 Min", cheers: 89, assetImageName: "festival_secret_stage"),
            ],
            newsItems: [
                NewsItem(id: "news-1", category: "Festival-Reporter", title: "Live-Bericht von der Nordstern Hauptbühne: Soundcheck & Crowd-Stimmung", summary: "Unser starzone Festival-Reporter begleitet Mira Vance vor dem Headliner-Set. Um 21:25 Uhr startet der gemeinsame „Stars sparkling“ Countdown auf allen Screens.", author: "starzone Redaktion", timestamp: "Vor 14 Min", tag: "Live-Reportage"),
                NewsItem(id: "news-2", category: "Musik-News", title: "Ticketalarm: Muse & Roger Waters — Vorverkauf-Start für Schweizer Hallenkonzerte", summary: "Aktiviere deinen personalisierten Ticketalarm für Zürich & St. Gallen und erhalte Priority-Alerts vor dem offiziellen Verkaufsstart.", author: "starzone Musik-News", timestamp: "Vor 1 Std.", tag: "Hallenstadion · Ticketalarm"),
                NewsItem(id: "news-3", category: "Social", title: "Best of See me! & Social Wall: Eure schönsten Crowd-Momente vom Greenfield & OASG-Warm-up", summary: "Über 1.400 Fans haben heute Selfie-Videos auf die Stage-Wings gesendet. Alle Highlights aus der starzone Hospitality-Zone findest du in der Social Wall.", author: "@starzone_ch", timestamp: "Vor 2 Std.", tag: "Social Highlights"),
            ],
            raffles: [
                RaffleItem(id: "raf-1", category: "Hospitality", title: "starzone Hospitality-Zugang für 2 Personen", prizeDescription: "Zutritt zur überdachten Lounge-Terrasse inkl. Signature-Drinks und Fastlane.", drawTime: "Heute · 20:30 Uhr", entered: false),
                RaffleItem(id: "raf-2", category: "Backstage", title: "Exklusive Backstage-Tour vor dem Headliner", prizeDescription: "Geführter Blick hinter die Nordstern Hauptbühne inkl. Regie- & Technik-Spot.", drawTime: "Morgen · 16:00 Uhr", entered: false),
                RaffleItem(id: "raf-3", category: "Tickets", title: "2x VIP-Festivaltickets Saison 2027 (Openair St. Gallen / Greenfield)", prizeDescription: "Voller Festival-Pass für die nächste Saison inkl. Sunrise Moments Special.", drawTime: "Sonntag · 19:00 Uhr", entered: false),
            ],
            ticketPrefs: TicketAlertPrefs(
                enabled: true,
                geofencingEnabled: true,
                email: "fan@starzone-member.ch",
                genres: ["Indie-Rock", "Electronic"],
                regions: ["Zürich", "St. Gallen"],
                eventTypes: ["Festival", "Hallenkonzert"]
            )
        )
    }
}
