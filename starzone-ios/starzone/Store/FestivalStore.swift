import Foundation
import Observation
import UIKit

@Observable
final class FestivalStore {
    private static let storageKey = "starzone_2026_ios_state_v1"

    var state: PersistedFestivalState {
        didSet { save() }
    }

    var activeTab: MainTab = .map
    var toasts: [PushNotificationItem] = []

    var level: Int {
        max(1, (state.xp / 300) + 1)
    }

    var xpInCurrentLevel: Int {
        state.xp % 300
    }

    var levelProgress: Double {
        Double(xpInCurrentLevel) / 300.0
    }

    var unlockedBadgeCount: Int {
        state.badges.filter(\.unlocked).count
    }

    var completedBingoLines: Int {
        let b = state.bingo.map(\.completed)
        guard b.count == 9 else { return 0 }
        let lines = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6],
        ]
        return lines.filter { $0.allSatisfy { idx in b[idx] } }.count
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(PersistedFestivalState.self, from: data) {
            self.state = decoded
        } else {
            self.state = FestivalSeedData.defaultState()
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }

    func resetDemoData() {
        state = FestivalSeedData.defaultState()
        pushToast(category: .quest, title: "Demo zurückgesetzt", message: "Alle Festivaldaten wurden auf den Ausgangszustand gesetzt.")
    }

    // MARK: - Haptics & Toasts

    private func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func pushToast(category: PushCategory, title: String, message: String, stageId: StageId? = nil) {
        let item = PushNotificationItem(
            id: UUID().uuidString,
            category: category,
            title: title,
            message: message,
            timestamp: "Jetzt",
            stageId: stageId
        )
        toasts.insert(item, at: 0)
        if toasts.count > 3 {
            toasts = Array(toasts.prefix(3))
        }
        haptic(.medium)

        let id = item.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { [weak self] in
            self?.dismissToast(id: id)
        }
    }

    func dismissToast(id: String) {
        toasts.removeAll { $0.id == id }
    }

    // MARK: - Map & Line-up Actions

    func checkInStage(_ stageId: StageId) {
        guard !state.checkedInStages.contains(stageId) else {
            pushToast(category: .buehne, title: "Bereits eingecheckt", message: "Du hast diesen Bühnen-Stempel schon gesammelt.", stageId: stageId)
            return
        }
        state.checkedInStages.append(stageId)
        state.xp += 60
        state.coins += 15
        if let stage = state.stages.first(where: { $0.id == stageId }) {
            pushToast(category: .buehne, title: "Bühnen-Check-in!", message: "\(stage.name) besucht (+60 XP, +15 Coins).", stageId: stageId)
        }
        syncStageQuest()
    }

    func unlockSecretStage(code: String) -> Bool {
        let cleaned = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard cleaned == "STARZONE26" || cleaned == "WALD" else { return false }
        if !state.secretUnlocked {
            state.secretUnlocked = true
            state.xp += 120
            state.coins += 35
            unlockBadge(id: "b-secret")
            pushToast(category: .buehne, title: "Secret Stage freigeschaltet!", message: "Waldlichtung ist jetzt auf deiner Karte sichtbar (+120 XP, +35 Coins).", stageId: .waldlichtung)
        }
        return true
    }

    func reportPOIWait(poiId: String, waitMinutes: Int, label: String) {
        guard let idx = state.pois.firstIndex(where: { $0.id == poiId }) else { return }
        state.pois[idx].waitMinutes = waitMinutes
        state.pois[idx].statusLabel = label
        state.pois[idx].reportCount += 1
        state.xp += 15
        pushToast(category: .buehne, title: "Wartezeit gemeldet", message: "\(state.pois[idx].name): \(waitMinutes) Min (+15 XP).")
    }

    func toggleFavorite(actId: String) {
        guard let idx = state.lineup.firstIndex(where: { $0.id == actId }) else { return }
        state.lineup[idx].isFavorite.toggle()
        let act = state.lineup[idx]
        if act.isFavorite && act.isNewDiscovery {
            completeQuest(id: "q-new-act")
        }
        haptic(.light)
    }

    func toggleReminder(actId: String) {
        guard let idx = state.lineup.firstIndex(where: { $0.id == actId }) else { return }
        state.lineup[idx].hasReminder.toggle()
        let act = state.lineup[idx]
        if act.hasReminder {
            pushToast(category: .konzert, title: "15-Min-Erinnerung aktiv", message: "Wir erinnern dich rechtzeitig vor \(act.artist) (\(act.startTime)).", stageId: act.stageId)
        }
    }

    func conflicts(for act: LineupAct) -> [LineupAct] {
        guard act.isFavorite else { return [] }
        return state.lineup.filter { other in
            other.id != act.id &&
            other.isFavorite &&
            other.day == act.day &&
            act.startMinutes < other.endMinutes &&
            other.startMinutes < act.endMinutes
        }
    }

    func togglePackItem(id: String) {
        guard let idx = state.packList.firstIndex(where: { $0.id == id }) else { return }
        state.packList[idx].packed.toggle()
        haptic(.light)
    }

    func updatePersonalPin(type: PersonalPinType, note: String) {
        guard let idx = state.personalPins.firstIndex(where: { $0.type == type }) else { return }
        state.personalPins[idx].note = note
    }

    func triggerWeatherAlert() {
        state.weatherAlertActive.toggle()
        if state.weatherAlertActive {
            pushToast(category: .wetter, title: "Wetter- & Sicherheitshinweis", message: "Leichter Regenschauer ab 22:00 Uhr erwartet. Zirkuszelt Ost & starzone Lounge bieten Schutz.")
        }
    }

    // MARK: - Quests, Badges, Bingo, Predictions, AR

    private func syncStageQuest() {
        guard let idx = state.quests.firstIndex(where: { $0.id == "q-stages" }) else { return }
        state.quests[idx].progress = min(state.quests[idx].target, state.checkedInStages.count)
        if state.quests[idx].progress >= state.quests[idx].target && !state.quests[idx].completed {
            completeQuest(id: "q-stages")
        }
    }

    func advanceQuest(id: String) {
        guard let idx = state.quests.firstIndex(where: { $0.id == id }), !state.quests[idx].completed else { return }
        state.quests[idx].progress = min(state.quests[idx].target, state.quests[idx].progress + 1)
        if state.quests[idx].progress >= state.quests[idx].target {
            completeQuest(id: id)
        } else {
            state.xp += 25
            haptic(.light)
        }
    }

    func completeQuest(id: String) {
        guard let idx = state.quests.firstIndex(where: { $0.id == id }), !state.quests[idx].completed else { return }
        state.quests[idx].progress = state.quests[idx].target
        state.quests[idx].completed = true
        let q = state.quests[idx]
        state.xp += q.xpReward
        state.coins += q.coinReward
        if let badgeId = q.badgeUnlockId {
            unlockBadge(id: badgeId)
        }
        if q.id == "q-sponsor-fritz" {
            let coupon = WalletItem(
                id: "wal-sponsor-\(UUID().uuidString.prefix(5))",
                type: "Coupon",
                title: "2-für-1 Getränkecoupon (starzone Lounge)",
                subtitle: "Freigeschaltet durch starzone Lounge Foto-Spot Quest",
                validUntil: "Heute · 23:59 Uhr",
                qrSeed: "STARZONE-2FOR1-LOUNGE",
                codeText: "STZ-2FOR1-26",
                redeemed: false
            )
            state.wallet.insert(coupon, at: 0)
        }
        pushToast(category: .quest, title: "Quest abgeschlossen!", message: "\(q.title) (+\(q.xpReward) XP, +\(q.coinReward) Coins).")
    }

    func unlockBadge(id: String) {
        guard let idx = state.badges.firstIndex(where: { $0.id == id }) else { return }
        state.badges[idx].unlocked = true
    }

    func togglePinBadge(id: String) {
        guard let idx = state.badges.firstIndex(where: { $0.id == id }), state.badges[idx].unlocked else { return }
        state.badges[idx].pinned.toggle()
        haptic(.light)
    }

    func verifyBingoTile(id: String, method: String) {
        guard let idx = state.bingo.firstIndex(where: { $0.id == id }), !state.bingo[idx].completed else { return }
        state.bingo[idx].completed = true
        state.bingo[idx].verifiedBy = method
        state.xp += 45
        state.coins += 15
        pushToast(category: .quest, title: "Bingo-Feld bestätigt!", message: "\(state.bingo[idx].label) per \(method) (+45 XP, +15 Coins).")
    }

    func selectPrediction(predictionId: String, option: String) {
        guard let idx = state.predictions.firstIndex(where: { $0.id == predictionId }) else { return }
        state.predictions[idx].selectedOption = option
        haptic(.light)
    }

    func revealPrediction(predictionId: String) {
        guard let idx = state.predictions.firstIndex(where: { $0.id == predictionId }),
              state.predictions[idx].revealedSong == nil else { return }
        let winner = state.predictions[idx].selectedOption ?? state.predictions[idx].options.first ?? ""
        state.predictions[idx].revealedSong = winner
        if state.predictions[idx].selectedOption == winner {
            let pts = state.predictions[idx].points
            state.xp += pts
            state.coins += 30
            pushToast(category: .quest, title: "Zugabe richtig getippt!", message: "\(winner) war der Treffer (+\(pts) XP, +30 Coins).")
        }
    }

    func redeemARCode(_ rawCode: String) -> Bool {
        let code = rawCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard let idx = state.arClues.firstIndex(where: { $0.codeWord.uppercased() == code }) else { return false }
        if !state.arClues[idx].found {
            state.arClues[idx].found = true
            state.xp += state.arClues[idx].rewardXp
            state.coins += state.arClues[idx].rewardCoins
            if code == "BASILIKUM" {
                completeQuest(id: "q-food-qr")
            }
            pushToast(category: .quest, title: "AR-Hinweis gelöst!", message: "\(state.arClues[idx].title) entdeckt (+\(state.arClues[idx].rewardXp) XP).")
        }
        return true
    }

    // MARK: - Community

    func toggleLike(postId: String) {
        guard let idx = state.vibePosts.firstIndex(where: { $0.id == postId }) else { return }
        state.vibePosts[idx].likedByMe.toggle()
        state.vibePosts[idx].likes += state.vibePosts[idx].likedByMe ? 1 : -1
        haptic(.light)
    }

    func addVibePost(stageName: String, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let post = VibePost(
            id: UUID().uuidString,
            author: "Du (starzone Member)",
            handle: "@starzone_fan",
            stageName: stageName,
            timestamp: "Gerade eben",
            text: trimmed,
            likes: 1,
            likedByMe: true,
            assetImageName: nil,
            isFanWallMoment: true
        )
        state.vibePosts.insert(post, at: 0)
        state.xp += 35
        pushToast(category: .quest, title: "Vibe-Check geteilt", message: "Dein Beitrag ist jetzt auf der Social Wall (+35 XP).")
    }

    func sendChatMessage(channelId: String, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let idx = state.channels.firstIndex(where: { $0.id == channelId }) else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let msg = ChatMessage(id: UUID().uuidString, author: "Du", text: trimmed, time: formatter.string(from: Date()))
        state.channels[idx].messages.append(msg)
        haptic(.light)
    }

    func toggleInviteMatch(id: String) {
        guard let idx = state.musicMatches.firstIndex(where: { $0.id == id }) else { return }
        state.musicMatches[idx].invited.toggle()
        if state.musicMatches[idx].invited {
            pushToast(category: .quest, title: "Einladung gesendet", message: "\(state.musicMatches[idx].name) wurde zu deiner Crew eingeladen.")
        }
    }

    func toggleJoinRideCamp(id: String) {
        guard let idx = state.rideCampPosts.firstIndex(where: { $0.id == id }) else { return }
        state.rideCampPosts[idx].joined.toggle()
        state.rideCampPosts[idx].spotsOpen += state.rideCampPosts[idx].joined ? -1 : 1
        haptic(.light)
    }

    // MARK: - Wallet, Voting, Raffles, Rewards

    func topUpCashless(amount: Double) {
        state.cashlessBalance += amount
        pushToast(category: .quest, title: "Cashless aufgeladen", message: String(format: "+CHF %.2f gutgeschrieben. Neues Guthaben: CHF %.2f", amount, state.cashlessBalance))
    }

    func vote(pollId: String, optionId: String) {
        guard let pIdx = state.polls.firstIndex(where: { $0.id == pollId }),
              state.polls[pIdx].votedOptionId == nil,
              let oIdx = state.polls[pIdx].options.firstIndex(where: { $0.id == optionId }) else { return }
        state.polls[pIdx].options[oIdx].votes += 1
        state.polls[pIdx].votedOptionId = optionId
        state.xp += 40
        state.coins += 10
        pushToast(category: .quest, title: "Stimme abgegeben!", message: "Danke fürs Abstimmen (+40 XP, +10 Coins).")
    }

    func enterRaffle(id: String) {
        guard let idx = state.raffles.firstIndex(where: { $0.id == id }), !state.raffles[idx].entered else { return }
        state.raffles[idx].entered = true
        state.xp += 30
        pushToast(category: .quest, title: "Im Lostopf!", message: "Du nimmst jetzt an „\(state.raffles[idx].title)“ teil (+30 XP).")
    }

    func redeemReward(_ reward: RewardItem) -> Bool {
        guard state.coins >= reward.costCoins else { return false }
        state.coins -= reward.costCoins
        let newItem = WalletItem(
            id: "wal-\(UUID().uuidString.prefix(6))",
            type: reward.type,
            title: reward.title,
            subtitle: reward.description,
            validUntil: "Gültig bis Festivalende",
            qrSeed: "STARZONE-REWARD-\(UUID().uuidString.prefix(8))",
            codeText: "STZ-\(Int.random(in: 1000...9999))",
            redeemed: false
        )
        state.wallet.insert(newItem, at: 0)
        pushToast(category: .quest, title: "Prämie im Wallet!", message: "\(reward.title) wurde freigeschaltet.")
        return true
    }

    func toggleWalletRedeemed(id: String) {
        guard let idx = state.wallet.firstIndex(where: { $0.id == id }) else { return }
        state.wallet[idx].redeemed.toggle()
        haptic(.medium)
    }

    // MARK: - Live-Cam & Lightstick

    func publishBroadcast(stageName: String, caption: String) {
        let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let clip = LiveCamBroadcast(
            id: UUID().uuidString,
            author: "Du (starzone Member)",
            stageName: stageName,
            caption: trimmed,
            timestamp: "Gerade eben",
            cheers: 1,
            assetImageName: "festival_mainstage"
        )
        state.broadcasts.insert(clip, at: 0)
        completeQuest(id: "q-see-me")
    }

    func cheerBroadcast(id: String) {
        guard let idx = state.broadcasts.firstIndex(where: { $0.id == id }) else { return }
        state.broadcasts[idx].cheers += 1
        haptic(.light)
    }

    func activateLightstickQuest() {
        completeQuest(id: "q-lights-on")
    }
}
