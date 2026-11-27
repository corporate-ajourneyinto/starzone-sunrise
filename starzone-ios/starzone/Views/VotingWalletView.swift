import SwiftUI

struct VotingWalletView: View {
    @Environment(FestivalStore.self) private var store

    @State private var selectedSection = 0
    @State private var expandedWalletItem: WalletItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    cashlessBalanceCard

                    Picker("Bereich", selection: $selectedSection) {
                        Text("QR-Wallet").tag(0)
                        Text("Votings").tag(1)
                        Text("Prämien & Lose").tag(2)
                    }
                    .pickerStyle(.segmented)

                    switch selectedSection {
                    case 0:
                        walletSection
                    case 1:
                        votingSection
                    default:
                        rewardsAndRafflesSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(SunriseTheme.background)
            .navigationTitle("Lounge & Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $expandedWalletItem) { item in
                walletDetailSheet(item: item)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Cashless Balance

    private var cashlessBalanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("starzone Cashless Wallet")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SunriseTheme.muted)
                    Text(String(format: "CHF %.2f", store.state.cashlessBalance))
                        .font(.title.weight(.heavy).monospacedDigit())
                        .foregroundStyle(SunriseTheme.ink)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(store.state.coins) Coins")
                        .font(.subheadline.weight(.bold).monospacedDigit())
                        .foregroundStyle(SunriseTheme.red)
                    Text("Fastlane aktiv")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(SunriseTheme.teal)
                }
            }

            HStack(spacing: 8) {
                Button("+ CHF 25 laden") {
                    store.topUpCashless(amount: 25)
                }
                .font(.caption.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .foregroundStyle(.white)
                .background(SunriseTheme.red)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Button("+ CHF 50 laden") {
                    store.topUpCashless(amount: 50)
                }
                .font(.caption.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .foregroundStyle(SunriseTheme.ink)
                .background(SunriseTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SunriseTheme.borderStrong))
            }
        }
        .sunriseTierCard()
    }

    // MARK: - QR Wallet Passes

    private var walletSection: some View {
        VStack(spacing: 12) {
            ForEach(store.state.wallet) { item in
                Button {
                    expandedWalletItem = item
                } label: {
                    HStack(spacing: 12) {
                        NativeQRCodeView(payload: item.qrSeed, size: 72)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                SunrisePillBadge(
                                    text: item.type,
                                    background: item.redeemed ? SunriseTheme.border : SunriseTheme.red.opacity(0.12),
                                    foreground: item.redeemed ? SunriseTheme.muted : SunriseTheme.red
                                )
                                Spacer()
                                if item.redeemed {
                                    Text("Eingelöst")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(SunriseTheme.teal)
                                }
                            }
                            Text(item.title)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(SunriseTheme.ink)
                                .multilineTextAlignment(.leading)
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundStyle(SunriseTheme.muted)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Text("\(item.codeText) · \(item.validUntil)")
                                .font(.caption2.monospaced())
                                .foregroundStyle(SunriseTheme.subtle)
                        }
                    }
                    .sunriseCard(padding: 12)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Live Votings

    private var votingSection: some View {
        VStack(spacing: 14) {
            ForEach(store.state.polls) { poll in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        SunrisePillBadge(text: poll.artistOrHost, background: SunriseTheme.teal.opacity(0.14), foreground: SunriseTheme.teal)
                        Spacer()
                        Text("Bis \(poll.closesAt)")
                            .font(.caption2)
                            .foregroundStyle(SunriseTheme.subtle)
                    }
                    Text(poll.title)
                        .font(.headline.weight(.bold))
                    Text(poll.subtitle)
                        .font(.caption)
                        .foregroundStyle(SunriseTheme.muted)

                    ForEach(poll.options) { opt in
                        let pct = Int((Double(opt.votes) / Double(poll.totalVotes)) * 100)
                        let isChosen = poll.votedOptionId == opt.id

                        Button {
                            store.vote(pollId: poll.id, optionId: opt.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(opt.label)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(SunriseTheme.ink)
                                    Spacer()
                                    if poll.votedOptionId != nil {
                                        Text("\(pct)% (\(opt.votes))")
                                            .font(.caption2.weight(.bold).monospacedDigit())
                                            .foregroundStyle(isChosen ? SunriseTheme.red : SunriseTheme.muted)
                                    }
                                }
                                if poll.votedOptionId != nil {
                                    ProgressView(value: Double(opt.votes), total: Double(poll.totalVotes))
                                        .tint(isChosen ? SunriseTheme.red : SunriseTheme.teal)
                                }
                            }
                            .padding(10)
                            .background(isChosen ? SunriseTheme.red.opacity(0.08) : SunriseTheme.background)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isChosen ? SunriseTheme.red : SunriseTheme.border, lineWidth: 1)
                            )
                        }
                        .disabled(poll.votedOptionId != nil)
                    }
                }
                .sunriseCard()
            }
        }
    }

    // MARK: - Rewards & Raffles

    private var rewardsAndRafflesSection: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Coin-Prämien einlösen")
                    .font(.headline.weight(.bold))

                ForEach(FestivalSeedData.rewards) { reward in
                    let canAfford = store.state.coins >= reward.costCoins
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(reward.title)
                                .font(.subheadline.weight(.bold))
                            Spacer()
                            SunrisePillBadge(text: "\(reward.costCoins) Coins")
                        }
                        Text(reward.description)
                            .font(.caption)
                            .foregroundStyle(SunriseTheme.muted)
                        HStack {
                            Text(reward.stockLabel)
                                .font(.caption2)
                                .foregroundStyle(SunriseTheme.subtle)
                            Spacer()
                            Button(canAfford ? "Einlösen" : "Zu wenig Coins") {
                                _ = store.redeemReward(reward)
                            }
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(canAfford ? SunriseTheme.red : SunriseTheme.borderStrong)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .disabled(!canAfford)
                        }
                    }
                    .padding(12)
                    .background(SunriseTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .sunriseCard()

            VStack(alignment: .leading, spacing: 10) {
                Text("Gewinnspiele & Hospitality-Lose")
                    .font(.headline.weight(.bold))

                ForEach(store.state.raffles) { raffle in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            SunrisePillBadge(text: raffle.category, background: SunriseTheme.teal.opacity(0.14), foreground: SunriseTheme.teal)
                            Spacer()
                            Text(raffle.drawTime)
                                .font(.caption2)
                                .foregroundStyle(SunriseTheme.subtle)
                        }
                        Text(raffle.title)
                            .font(.subheadline.weight(.bold))
                        Text(raffle.prizeDescription)
                            .font(.caption)
                            .foregroundStyle(SunriseTheme.muted)

                        Button(raffle.entered ? "Teilnahme bestätigt ✓" : "Kostenlos teilnehmen (+30 XP)") {
                            store.enterRaffle(id: raffle.id)
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(raffle.entered ? SunriseTheme.teal : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(raffle.entered ? SunriseTheme.teal.opacity(0.14) : SunriseTheme.ink)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .disabled(raffle.entered)
                    }
                    .padding(12)
                    .background(SunriseTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .sunriseCard()
        }
    }

    private func walletDetailSheet(item: WalletItem) -> some View {
        VStack(spacing: 18) {
            SunrisePillBadge(text: item.type)
            Text(item.title)
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)
            Text(item.subtitle)
                .font(.caption)
                .foregroundStyle(SunriseTheme.muted)
                .multilineTextAlignment(.center)

            NativeQRCodeView(payload: item.qrSeed, size: 220)

            Text(item.codeText)
                .font(.headline.monospaced().weight(.bold))
                .foregroundStyle(SunriseTheme.ink)

            Text(item.validUntil)
                .font(.caption)
                .foregroundStyle(SunriseTheme.subtle)

            Button {
                store.toggleWalletRedeemed(id: item.id)
                expandedWalletItem = nil
            } label: {
                Text(item.redeemed ? "Als aktiv markieren" : "Als eingelöst markieren")
                    .font(.subheadline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .foregroundStyle(.white)
                    .background(SunriseTheme.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
        }
        .padding(24)
    }
}
