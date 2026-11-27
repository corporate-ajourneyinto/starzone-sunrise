import SwiftUI

struct MapLineupView: View {
    @Environment(FestivalStore.self) private var store
    @Binding var selectedStageId: StageId

    @State private var showHeatmap = true
    @State private var showAccessibleRoute = false
    @State private var showFriendFinder = true
    @State private var showPersonalPins = true
    @State private var secretCodeInput = ""
    @State private var secretError = false

    @State private var selectedDay: FestivalDay = .alle
    @State private var onlyMySchedule = false
    @State private var searchText = ""
    @State private var selectedPOI: ServicePOI?

    private var selectedStage: Stage {
        store.state.stages.first(where: { $0.id == selectedStageId }) ?? store.state.stages[0]
    }

    private var filteredActs: [LineupAct] {
        store.state.lineup.filter { act in
            if act.stageId == .waldlichtung && !store.state.secretUnlocked { return false }
            if selectedDay != .alle && act.day != selectedDay { return false }
            if onlyMySchedule && !act.isFavorite { return false }
            if !searchText.isEmpty {
                let q = searchText.lowercased()
                return act.artist.lowercased().contains(q) || act.genre.lowercased().contains(q)
            }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    heroHeaderCard
                    interactiveMapCard
                    selectedStageDetailCard
                    servicePOIsCard
                    lineupSectionCard
                    packListCard
                    ticketAlarmCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(SunriseTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("starzone_header_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.triggerWeatherAlert()
                    } label: {
                        Image(systemName: store.state.weatherAlertActive ? "cloud.bolt.rain.fill" : "cloud.sun.fill")
                            .foregroundStyle(store.state.weatherAlertActive ? SunriseTheme.orange : SunriseTheme.ink)
                    }
                    .accessibilityLabel("Wetter-Alert umschalten")
                }
            }
            .sheet(item: $selectedPOI) { poi in
                poiReportSheet(poi: poi)
                    .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Hero Header

    private var heroHeaderCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image("festival_mainstage")
                .resizable()
                .scaledToFill()
                .frame(height: 170)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.15), .black.opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    SunrisePillBadge(text: "LIVE · FESTIVAL 2026", background: SunriseTheme.red, foreground: .white)
                    SunrisePillBadge(text: "Lv. \(store.level) · \(store.state.coins) Coins", background: .white.opacity(0.92), foreground: SunriseTheme.ink)
                }
                Text("starzone Festival Companion")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text("Live-Auslastung, Crowd-Heatmap, My Schedule & Crew-Navigation")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.88))
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: SunriseTheme.ink.opacity(0.14), radius: 10, x: 0, y: 4)
    }

    // MARK: - Interactive Festival Map

    private var interactiveMapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Interaktive Geländekarte")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(SunriseTheme.ink)
                    Text("Tippe auf Bühnen oder Service-POIs für Live-Daten")
                        .font(.caption)
                        .foregroundStyle(SunriseTheme.muted)
                }
                Spacer()
                SunrisePillBadge(text: "Offline-fähig", background: SunriseTheme.teal.opacity(0.12), foreground: SunriseTheme.teal)
            }

            // Layer toggles
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    layerChip("Heatmap", icon: "flame.fill", isOn: $showHeatmap)
                    layerChip("Barrierefrei", icon: "figure.roll", isOn: $showAccessibleRoute)
                    layerChip("Friend Finder", icon: "person.2.fill", isOn: $showFriendFinder)
                    layerChip("Auto & Zelt", icon: "tent.fill", isOn: $showPersonalPins)
                }
            }

            // Interactive Canvas Map
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    // Ground & Lake
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: 0xEFECE7))

                    // Decorative Lake (Seebühne West)
                    Ellipse()
                        .fill(SunriseTheme.teal.opacity(0.16))
                        .frame(width: w * 0.42, height: h * 0.34)
                        .position(x: w * 0.72, y: h * 0.25)

                    // Pine Forest (Waldlichtung)
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.green.opacity(0.10))
                        .frame(width: w * 0.32, height: h * 0.36)
                        .position(x: w * 0.82, y: h * 0.75)

                    // Accessible Route Path
                    if showAccessibleRoute {
                        Path { path in
                            path.move(to: CGPoint(x: w * 0.16, y: h * 0.82))
                            path.addLine(to: CGPoint(x: w * 0.26, y: h * 0.35))
                            path.addLine(to: CGPoint(x: w * 0.54, y: h * 0.65))
                            path.addLine(to: CGPoint(x: w * 0.69, y: h * 0.28))
                        }
                        .stroke(SunriseTheme.teal, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 5]))
                    }

                    // Heatmap blobs
                    if showHeatmap {
                        ForEach(store.state.stages) { stage in
                            if !stage.isSecret || store.state.secretUnlocked {
                                Circle()
                                    .fill(crowdColor(stage.crowdPercent).opacity(0.24))
                                    .frame(width: CGFloat(stage.crowdPercent) * 0.95, height: CGFloat(stage.crowdPercent) * 0.95)
                                    .blur(radius: 10)
                                    .position(x: w * (stage.mapX / 800.0), y: h * (stage.mapY / 480.0))
                            }
                        }
                    }

                    // Personal Auto & Zelt Pins
                    if showPersonalPins {
                        ForEach(store.state.personalPins) { pin in
                            Image(systemName: pin.type.systemImage)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(SunriseTheme.ink)
                                .clipShape(Circle())
                                .position(x: w * (pin.mapX / 800.0), y: h * (pin.mapY / 480.0))
                        }
                    }

                    // Squad Members (Friend Finder)
                    if showFriendFinder {
                        ForEach(store.state.squad.filter { !$0.ghostMode }) { member in
                            VStack(spacing: 2) {
                                Text(String(member.name.prefix(1)))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 22, height: 22)
                                    .background(SunriseTheme.teal)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                                Text(member.name.split(separator: " ").first.map(String.init) ?? member.name)
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 4)
                                    .background(.white.opacity(0.9))
                                    .clipShape(Capsule())
                            }
                            .position(x: w * (member.mapX / 800.0), y: h * (member.mapY / 480.0))
                        }
                    }

                    // Service POIs
                    ForEach(store.state.pois) { poi in
                        Button {
                            selectedPOI = poi
                        } label: {
                            Image(systemName: poi.type.systemImage)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(poi.type == .lounge ? .white : SunriseTheme.ink)
                                .frame(width: 22, height: 22)
                                .background(poi.type == .lounge ? SunriseTheme.red : .white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        .position(x: w * (poi.mapX / 800.0), y: h * (poi.mapY / 480.0))
                    }

                    // Stages
                    ForEach(store.state.stages) { stage in
                        if !stage.isSecret || store.state.secretUnlocked {
                            let isSelected = stage.id == selectedStageId
                            Button {
                                selectedStageId = stage.id
                            } label: {
                                VStack(spacing: 2) {
                                    HStack(spacing: 4) {
                                        Image(systemName: stage.isSecret ? "sparkles" : "music.mic")
                                            .font(.caption2.weight(.bold))
                                        Text("\(stage.crowdPercent)%")
                                            .font(.caption2.weight(.bold).monospacedDigit())
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(isSelected ? SunriseTheme.red : crowdColor(stage.crowdPercent))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(.white, lineWidth: isSelected ? 2.5 : 1.5)
                                    )
                                    .shadow(radius: isSelected ? 5 : 2)

                                    Text(stage.name.split(separator: " ").first.map(String.init) ?? stage.name)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(SunriseTheme.ink)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1)
                                        .background(.white.opacity(0.92))
                                        .clipShape(Capsule())
                                }
                            }
                            .position(x: w * (stage.mapX / 800.0), y: h * (stage.mapY / 480.0))
                        }
                    }

                    // User Geo Pin
                    VStack(spacing: 1) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                        Text("DU")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundStyle(.blue)
                    }
                    .position(x: w * 0.36, y: h * 0.56)
                }
            }
            .frame(height: 245)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(SunriseTheme.border, lineWidth: 1)
            )

            // Secret Stage Unlock Bar
            if !store.state.secretUnlocked {
                HStack(spacing: 8) {
                    TextField("Secret-Stage-Code (z. B. STARZONE26)", text: $secretCodeInput)
                        .textInputAutocapitalization(.characters)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(SunriseTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(secretError ? SunriseTheme.red : SunriseTheme.border, lineWidth: 1)
                        )

                    Button("Freischalten") {
                        let ok = store.unlockSecretStage(code: secretCodeInput)
                        secretError = !ok
                        if ok {
                            secretCodeInput = ""
                            selectedStageId = .waldlichtung
                        }
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(SunriseTheme.red)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .sunriseCard()
    }

    // MARK: - Selected Stage Details

    private var selectedStageDetailCard: some View {
        let stage = selectedStage
        let checkedIn = store.state.checkedInStages.contains(stage.id)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(stage.name)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(SunriseTheme.ink)
                    Text(stage.subtitle)
                        .font(.caption)
                        .foregroundStyle(SunriseTheme.muted)
                }
                Spacer()
                SunrisePillBadge(
                    text: "\(stage.crowdLabel.rawValue) · \(stage.crowdPercent)%",
                    background: crowdColor(stage.crowdPercent).opacity(0.14),
                    foreground: crowdColor(stage.crowdPercent)
                )
            }

            // Crowd Meter Progress
            ProgressView(value: Double(stage.crowdPercent), total: 100)
                .tint(crowdColor(stage.crowdPercent))

            HStack(spacing: 16) {
                Label("Jetzt: \(stage.currentAct)", systemImage: "music.note")
                Spacer()
                Label("\(stage.walkMinutesFromGate) Min", systemImage: "figure.walk")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(SunriseTheme.ink)

            Text("Danach: \(stage.nextAct)")
                .font(.caption)
                .foregroundStyle(SunriseTheme.muted)

            if let hint = stage.alternativeHint {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(SunriseTheme.orange)
                    Text(hint)
                        .font(.caption)
                        .foregroundStyle(SunriseTheme.ink)
                }
                .padding(10)
                .background(SunriseTheme.sand.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Button {
                store.checkInStage(stage.id)
            } label: {
                HStack {
                    Image(systemName: checkedIn ? "checkmark.seal.fill" : "mappin.and.ellipse")
                    Text(checkedIn ? "Stempel gesammelt" : "An Bühne einchecken (+60 XP)")
                }
                .font(.subheadline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(checkedIn ? SunriseTheme.teal : .white)
                .background(checkedIn ? SunriseTheme.teal.opacity(0.12) : SunriseTheme.red)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .sunriseTierCard()
    }

    // MARK: - Service POIs

    private var servicePOIsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Service-Stationen & Wartezeiten")
                .font(.headline.weight(.bold))
                .foregroundStyle(SunriseTheme.ink)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(store.state.pois) { poi in
                        Button {
                            selectedPOI = poi
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: poi.type.systemImage)
                                        .foregroundStyle(SunriseTheme.red)
                                    Spacer()
                                    Text("\(poi.waitMinutes) Min")
                                        .font(.caption.weight(.bold).monospacedDigit())
                                        .foregroundStyle(poi.waitMinutes <= 3 ? SunriseTheme.teal : SunriseTheme.ink)
                                }
                                Text(poi.name)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(SunriseTheme.ink)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                Text("★ \(String(format: "%.1f", poi.rating)) · \(poi.reportCount) Meldungen")
                                    .font(.caption2)
                                    .foregroundStyle(SunriseTheme.subtle)
                            }
                            .frame(width: 155, alignment: .leading)
                            .padding(12)
                            .background(SunriseTheme.background)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(SunriseTheme.border, lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
        .sunriseCard()
    }

    // MARK: - Line-up & My Schedule

    private var lineupSectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Line-up & My Schedule")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(SunriseTheme.ink)
                Spacer()
                Toggle("My Schedule", isOn: $onlyMySchedule)
                    .labelsHidden()
                Text("Favoriten")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SunriseTheme.muted)
            }

            Picker("Tag", selection: $selectedDay) {
                ForEach(FestivalDay.allCases) { day in
                    Text(day.rawValue).tag(day)
                }
            }
            .pickerStyle(.segmented)

            TextField("Act oder Genre suchen…", text: $searchText)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(SunriseTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            ForEach(filteredActs) { act in
                let actConflicts = store.conflicts(for: act)
                let stageName = store.state.stages.first(where: { $0.id == act.stageId })?.name ?? ""

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(act.artist)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(SunriseTheme.ink)
                                if act.isNewDiscovery {
                                    SunrisePillBadge(text: "Neu", background: SunriseTheme.teal.opacity(0.14), foreground: SunriseTheme.teal)
                                }
                            }
                            Text("\(act.day.rawValue) · \(act.startTime)–\(act.endTime) · \(stageName)")
                                .font(.caption)
                                .foregroundStyle(SunriseTheme.muted)
                        }
                        Spacer()
                        HStack(spacing: 10) {
                            Button {
                                store.toggleReminder(actId: act.id)
                            } label: {
                                Image(systemName: act.hasReminder ? "bell.fill" : "bell")
                                    .foregroundStyle(act.hasReminder ? SunriseTheme.orange : SunriseTheme.subtle)
                            }
                            Button {
                                store.toggleFavorite(actId: act.id)
                            } label: {
                                Image(systemName: act.isFavorite ? "heart.fill" : "heart")
                                    .foregroundStyle(act.isFavorite ? SunriseTheme.red : SunriseTheme.subtle)
                            }
                        }
                    }

                    Text(act.description)
                        .font(.caption)
                        .foregroundStyle(SunriseTheme.muted)

                    HStack {
                        Label(act.leaveTimeLabel, systemImage: "figure.walk")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(SunriseTheme.teal)
                        Spacer()
                        Text(act.genre)
                            .font(.caption2)
                            .foregroundStyle(SunriseTheme.subtle)
                    }

                    if !actConflicts.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(SunriseTheme.orange)
                            Text("Überschneidung mit \(actConflicts.map(\.artist).joined(separator: ", "))")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(SunriseTheme.ink)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(SunriseTheme.sand.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .padding(12)
                .background(SunriseTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .sunriseCard()
    }

    // MARK: - Packlist & Ticketalarm

    private var packListCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Wetter-Packliste")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(SunriseTheme.ink)
                Spacer()
                Text("\(store.state.packList.filter(\.packed).count)/\(store.state.packList.count) eingepackt")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SunriseTheme.teal)
            }

            ForEach(store.state.packList) { item in
                Button {
                    store.togglePackItem(id: item.id)
                } label: {
                    HStack {
                        Image(systemName: item.packed ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(item.packed ? SunriseTheme.teal : SunriseTheme.borderStrong)
                        Text(item.label)
                            .font(.subheadline)
                            .strikethrough(item.packed)
                            .foregroundStyle(item.packed ? SunriseTheme.subtle : SunriseTheme.ink)
                        Spacer()
                        if item.weatherDependent && store.state.weatherAlertActive {
                            SunrisePillBadge(text: "Wichtig!", background: SunriseTheme.orange.opacity(0.18), foreground: SunriseTheme.orange)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .sunriseCard()
    }

    private var ticketAlarmCard: some View {
        @Bindable var bindableStore = store

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("My Starzone · Ticketalarm", systemImage: "bell.badge.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(SunriseTheme.ink)
                Spacer()
                Toggle("", isOn: $bindableStore.state.ticketPrefs.enabled)
                    .labelsHidden()
            }

            Text("Priorisierte Vorverkaufs-Alerts für Zürich, St. Gallen & deine Lieblingsgenres.")
                .font(.caption)
                .foregroundStyle(SunriseTheme.muted)

            Toggle("Gelände-Geofencing aktivieren", isOn: $bindableStore.state.ticketPrefs.geofencingEnabled)
                .font(.subheadline)

            Button {
                store.pushToast(
                    category: .konzert,
                    title: "Priority-Ticketalarm!",
                    message: "Muse · Hallenstadion Zürich — Vorverkauf startet morgen um 10:00 Uhr."
                )
            } label: {
                Text("Test-Vorverkaufs-Alert auslösen")
                    .font(.caption.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .foregroundStyle(SunriseTheme.red)
                    .background(SunriseTheme.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .sunriseCard()
    }

    // MARK: - Helpers

    private func layerChip(_ title: String, icon: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            Label(title, systemImage: icon)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .foregroundStyle(isOn.wrappedValue ? .white : SunriseTheme.ink)
                .background(isOn.wrappedValue ? SunriseTheme.ink : SunriseTheme.background)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(SunriseTheme.border, lineWidth: 1))
        }
    }

    private func crowdColor(_ percent: Int) -> Color {
        if percent >= 75 { return SunriseTheme.red }
        if percent >= 50 { return SunriseTheme.orange }
        return SunriseTheme.teal
    }

    private func poiReportSheet(poi: ServicePOI) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: poi.type.systemImage)
                    .font(.title2)
                    .foregroundStyle(SunriseTheme.red)
                VStack(alignment: .leading) {
                    Text(poi.name)
                        .font(.headline.weight(.bold))
                    Text("Aktuelle Wartezeit: \(poi.waitMinutes) Min (\(poi.statusLabel))")
                        .font(.caption)
                        .foregroundStyle(SunriseTheme.muted)
                }
                Spacer()
            }

            Text("Aktuelle Wartezeit melden (+15 XP)")
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 10) {
                waitReportButton(poiId: poi.id, label: "Frei (1 Min)", minutes: 1, status: "Frei", color: SunriseTheme.teal)
                waitReportButton(poiId: poi.id, label: "Mittel (7 Min)", minutes: 7, status: "Mittel", color: SunriseTheme.orange)
                waitReportButton(poiId: poi.id, label: "Voll (14 Min)", minutes: 14, status: "Voll", color: SunriseTheme.red)
            }

            Spacer()
        }
        .padding(20)
    }

    private func waitReportButton(poiId: String, label: String, minutes: Int, status: String, color: Color) -> some View {
        Button {
            store.reportPOIWait(poiId: poiId, waitMinutes: minutes, label: status)
            selectedPOI = nil
        } label: {
            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
