import SwiftUI

struct QuestsGamesView: View {
    @Environment(FestivalStore.self) private var store

    @State private var selectedCategory: QuestCategory = .alle
    @State private var arCodeInput = ""
    @State private var arCodeError = false

    private var filteredQuests: [Quest] {
        store.state.quests.filter { q in
            selectedCategory == .alle || q.category == selectedCategory
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    playerProfileCard
                    questsSectionCard
                    badgeShelfCard
                    bingoSectionCard
                    encorePredictionsCard
                    arScavengerCard
                    wrappedStoryCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(SunriseTheme.background)
            .navigationTitle("Quests & Spiele")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Player Profile

    private var playerProfileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Level \(store.level) · starzone Veteran")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(SunriseTheme.ink)
                    Text("\(store.state.xp) XP gesamt · \(300 - store.xpInCurrentLevel) XP bis Level \(store.level + 1)")
                        .font(.caption)
                        .foregroundStyle(SunriseTheme.muted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(store.state.coins)")
                        .font(.title2.weight(.heavy).monospacedDigit())
                        .foregroundStyle(SunriseTheme.red)
                    Text("Coins")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(SunriseTheme.subtle)
                }
            }

            ProgressView(value: store.levelProgress)
                .tint(SunriseTheme.red)

            HStack(spacing: 12) {
                statPill(label: "Badges", value: "\(store.unlockedBadgeCount)/\(store.state.badges.count)")
                statPill(label: "Bühnen", value: "\(store.state.checkedInStages.count)/\(store.state.stages.count)")
                statPill(label: "Bingo-Reihen", value: "\(store.completedBingoLines)")
            }
        }
        .sunriseTierCard()
    }

    // MARK: - Quests

    private var questsSectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aktive Quests")
                .font(.headline.weight(.bold))
                .foregroundStyle(SunriseTheme.ink)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(QuestCategory.allCases) { cat in
                        Button {
                            selectedCategory = cat
                        } label: {
                            Text(cat.rawValue)
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundStyle(selectedCategory == cat ? .white : SunriseTheme.ink)
                                .background(selectedCategory == cat ? SunriseTheme.ink : SunriseTheme.background)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            ForEach(filteredQuests) { quest in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(quest.title)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(SunriseTheme.ink)
                            Text(quest.description)
                                .font(.caption)
                                .foregroundStyle(SunriseTheme.muted)
                        }
                        Spacer()
                        SunrisePillBadge(
                            text: "+\(quest.xpReward) XP · +\(quest.coinReward) C",
                            background: quest.completed ? SunriseTheme.teal.opacity(0.14) : SunriseTheme.red.opacity(0.12),
                            foreground: quest.completed ? SunriseTheme.teal : SunriseTheme.red
                        )
                    }

                    HStack {
                        ProgressView(value: Double(quest.progress), total: Double(max(1, quest.target)))
                            .tint(quest.completed ? SunriseTheme.teal : SunriseTheme.red)
                        Text("\(quest.progress)/\(quest.target)")
                            .font(.caption2.weight(.bold).monospacedDigit())
                            .foregroundStyle(SunriseTheme.muted)
                    }

                    if !quest.completed {
                        Button {
                            store.advanceQuest(id: quest.id)
                        } label: {
                            Text(quest.progress + 1 >= quest.target ? "Quest abschließen" : "Fortschritt erfassen (+1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(SunriseTheme.red)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    } else {
                        Label("Abgeschlossen", systemImage: "checkmark.circle.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(SunriseTheme.teal)
                    }
                }
                .padding(12)
                .background(SunriseTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .sunriseCard()
    }

    // MARK: - Badge Shelf

    private var badgeShelfCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Digitales Badge-Regal")
                .font(.headline.weight(.bold))
                .foregroundStyle(SunriseTheme.ink)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(store.state.badges) { badge in
                    Button {
                        store.togglePinBadge(id: badge.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: badge.systemImage)
                                    .font(.title3)
                                    .foregroundStyle(badge.unlocked ? SunriseTheme.red : SunriseTheme.borderStrong)
                                Spacer()
                                if badge.pinned {
                                    Image(systemName: "pin.fill")
                                        .font(.caption2)
                                        .foregroundStyle(SunriseTheme.teal)
                                }
                            }
                            Text(badge.title)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(badge.unlocked ? SunriseTheme.ink : SunriseTheme.subtle)
                                .multilineTextAlignment(.leading)
                            Text(badge.rarityText)
                                .font(.caption2)
                                .foregroundStyle(SunriseTheme.subtle)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(badge.unlocked ? Color.white : SunriseTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(badge.pinned ? SunriseTheme.teal : SunriseTheme.border, lineWidth: badge.pinned ? 1.5 : 1)
                        )
                        .opacity(badge.unlocked ? 1 : 0.65)
                    }
                }
            }
        }
        .sunriseCard()
    }

    // MARK: - 3x3 Festival Bingo

    private var bingoSectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Festival-Bingo (3×3)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(SunriseTheme.ink)
                Spacer()
                SunrisePillBadge(text: "\(store.completedBingoLines) Reihen", background: SunriseTheme.teal.opacity(0.14), foreground: SunriseTheme.teal)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(store.state.bingo) { tile in
                    Button {
                        store.verifyBingoTile(id: tile.id, method: "Check-in")
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tile.completed ? "checkmark.circle.fill" : "camera.circle")
                                .font(.title3)
                                .foregroundStyle(tile.completed ? .white : SunriseTheme.red)
                            Text(tile.label)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(tile.completed ? .white : SunriseTheme.ink)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                        .frame(maxWidth: .infinity, minHeight: 88)
                        .padding(6)
                        .background(tile.completed ? SunriseTheme.teal : SunriseTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(tile.completed ? SunriseTheme.teal : SunriseTheme.border, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .sunriseCard()
    }

    // MARK: - Encore Predictions

    private var encorePredictionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Zugabe-Tippspiel")
                .font(.headline.weight(.bold))
                .foregroundStyle(SunriseTheme.ink)

            ForEach(store.state.predictions) { pred in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(pred.artist)
                            .font(.subheadline.weight(.bold))
                        Spacer()
                        Text("+\(pred.points) XP")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(SunriseTheme.red)
                    }
                    Text("\(pred.stageName) · \(pred.time)")
                        .font(.caption)
                        .foregroundStyle(SunriseTheme.muted)

                    ForEach(pred.options, id: \.self) { song in
                        let isSelected = pred.selectedOption == song
                        Button {
                            store.selectPrediction(predictionId: pred.id, option: song)
                        } label: {
                            HStack {
                                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                                    .foregroundStyle(isSelected ? SunriseTheme.red : SunriseTheme.subtle)
                                Text(song)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(SunriseTheme.ink)
                                Spacer()
                                if pred.revealedSong == song {
                                    SunrisePillBadge(text: "Gespielt!", background: SunriseTheme.teal.opacity(0.15), foreground: SunriseTheme.teal)
                                }
                            }
                            .padding(8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    if pred.revealedSong == nil {
                        Button("Live-Auflösung simulieren") {
                            store.revealPrediction(predictionId: pred.id)
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SunriseTheme.teal)
                        .padding(.top, 2)
                    }
                }
                .padding(12)
                .background(SunriseTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .sunriseCard()
    }

    // MARK: - AR Scavenger Hunt

    private var arScavengerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AR-Schnitzeljagd & Totems")
                    .font(.headline.weight(.bold))
                Spacer()
                SunrisePillBadge(text: "\(store.state.arClues.filter(\.found).count)/\(store.state.arClues.count)")
            }

            Image("festival_ar_totem")
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack(spacing: 8) {
                TextField("Codewort (z. B. LICHTUNG / BASILIKUM)", text: $arCodeInput)
                    .textInputAutocapitalization(.characters)
                    .font(.caption)
                    .padding(9)
                    .background(SunriseTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(arCodeError ? SunriseTheme.red : SunriseTheme.border))

                Button("Einlösen") {
                    let ok = store.redeemARCode(arCodeInput)
                    arCodeError = !ok
                    if ok { arCodeInput = "" }
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(SunriseTheme.red)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            ForEach(store.state.arClues) { clue in
                HStack {
                    Image(systemName: clue.found ? "checkmark.seal.fill" : "viewfinder")
                        .foregroundStyle(clue.found ? SunriseTheme.teal : SunriseTheme.red)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(clue.title)
                            .font(.caption.weight(.bold))
                        Text(clue.locationHint)
                            .font(.caption2)
                            .foregroundStyle(SunriseTheme.muted)
                    }
                    Spacer()
                    Text("+\(clue.rewardXp) XP")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(SunriseTheme.teal)
                }
            }
        }
        .sunriseCard()
    }

    // MARK: - Festival Wrapped Story Card

    private var wrappedStoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("STARZONE WRAPPED 2026")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(.white.opacity(0.85))
                    Text("Dein Festival-Rückblick")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                Image("starzone_box_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
            }

            HStack(spacing: 12) {
                wrappedMetric("Level", "\(store.level)")
                wrappedMetric("XP", "\(store.state.xp)")
                wrappedMetric("Badges", "\(store.unlockedBadgeCount)")
                wrappedMetric("Favoriten", "\(store.state.lineup.filter(\.isFavorite).count)")
            }

            ShareLink(
                item: "Mein starzone Festival Wrapped 2026: Level \(store.level), \(store.state.xp) XP, \(store.unlockedBadgeCount) Badges & \(store.completedBingoLines) Bingo-Reihen!"
            ) {
                Label("Story-Highlight teilen", systemImage: "square.and.arrow.up")
                    .font(.subheadline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .foregroundStyle(SunriseTheme.red)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [SunriseTheme.red, SunriseTheme.orange, SunriseTheme.ink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: SunriseTheme.ink.opacity(0.18), radius: 10, x: 0, y: 4)
    }

    private func statPill(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundStyle(SunriseTheme.ink)
            Text(label)
                .font(.caption2)
                .foregroundStyle(SunriseTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(SunriseTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func wrappedMetric(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.weight(.heavy).monospacedDigit())
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.white.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
