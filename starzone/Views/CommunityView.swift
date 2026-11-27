import SwiftUI

struct CommunityView: View {
    @Environment(FestivalStore.self) private var store

    @State private var selectedSection = 0
    @State private var newPostText = ""
    @State private var newPostStage = "Nordstern Hauptbühne"
    @State private var selectedChannelId = "ch-main"
    @State private var chatDraft = ""
    @State private var showBuddyQR = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Bereich", selection: $selectedSection) {
                        Text("Social Wall").tag(0)
                        Text("Squad & Match").tag(1)
                        Text("Act-Chats").tag(2)
                        Text("News & Ride").tag(3)
                    }
                    .pickerStyle(.segmented)

                    switch selectedSection {
                    case 0:
                        vibeWallSection
                    case 1:
                        squadAndMatchingSection
                    case 2:
                        actChatsSection
                    default:
                        newsAndRideSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(SunriseTheme.background)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                StarzoneBrandHeader(sectionTitle: "Community") {
                    StarzoneHeaderIconButton(
                        systemImage: "qrcode",
                        tint: SunriseTheme.ink,
                        accessibilityLabel: "Mein Buddy-QR"
                    ) {
                        showBuddyQR = true
                    }
                }
            }
            .sheet(isPresented: $showBuddyQR) {
                VStack(spacing: 16) {
                    Text("Dein starzone Buddy-QR")
                        .font(.headline.weight(.bold))
                    Text("Freunde scannen diesen Code, um deiner Festival-Crew beizutreten.")
                        .font(.caption)
                        .foregroundStyle(SunriseTheme.muted)
                        .multilineTextAlignment(.center)
                    NativeQRCodeView(payload: "STARZONE-BUDDY-2026-MEMBER", size: 200)
                    Text("STZ-CREW-2026")
                        .font(.caption.weight(.bold).monospaced())
                        .foregroundStyle(SunriseTheme.red)
                }
                .padding(24)
                .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Vibe Wall

    private var vibeWallSection: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Vibe-Check teilen (+35 XP)")
                    .font(.headline.weight(.bold))
                Picker("Bühne", selection: $newPostStage) {
                    ForEach(store.state.stages) { stage in
                        Text(stage.name).tag(stage.name)
                    }
                }
                .pickerStyle(.menu)

                TextField("Wie ist die Stimmung gerade vor der Bühne?", text: $newPostText, axis: .vertical)
                    .lineLimit(2...4)
                    .font(.subheadline)
                    .padding(10)
                    .background(SunriseTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Button {
                    store.addVibePost(stageName: newPostStage, text: newPostText)
                    newPostText = ""
                } label: {
                    Text("Auf Social Wall posten")
                        .font(.subheadline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(.white)
                        .background(newPostText.trimmingCharacters(in: .whitespaces).isEmpty ? SunriseTheme.borderStrong : SunriseTheme.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(newPostText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .sunriseCard()

            let visiblePosts = store.state.vibePosts.filter { post in
                !store.state.reportedPostIds.contains(post.id) &&
                !store.state.blockedAuthors.contains(post.author)
            }

            ForEach(visiblePosts) { post in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(post.author)
                                .font(.subheadline.weight(.bold))
                            Text("\(post.handle) · \(post.stageName)")
                                .font(.caption2)
                                .foregroundStyle(SunriseTheme.muted)
                        }
                        Spacer()
                        Text(post.timestamp)
                            .font(.caption2)
                            .foregroundStyle(SunriseTheme.subtle)

                        if post.author != "Du (starzone Member)" {
                            Menu {
                                Button(role: .destructive) {
                                    store.reportPost(id: post.id)
                                } label: {
                                    Label("Beitrag melden", systemImage: "flag")
                                }
                                Button(role: .destructive) {
                                    store.blockAuthor(post.author)
                                } label: {
                                    Label("\(post.author) blockieren", systemImage: "hand.raised")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(SunriseTheme.subtle)
                                    .padding(6)
                            }
                            .accessibilityLabel("Beitrags-Optionen")
                        }
                    }

                    if let img = post.assetImageName {
                        Image(img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Text(post.text)
                        .font(.subheadline)
                        .foregroundStyle(SunriseTheme.ink)

                    HStack {
                        Button {
                            store.toggleLike(postId: post.id)
                        } label: {
                            Label("\(post.likes)", systemImage: post.likedByMe ? "heart.fill" : "heart")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(post.likedByMe ? SunriseTheme.red : SunriseTheme.muted)
                        }
                        Spacer()
                        if post.isFanWallMoment {
                            SunrisePillBadge(text: "Fan-Wall", background: SunriseTheme.teal.opacity(0.12), foreground: SunriseTheme.teal)
                        }
                    }
                }
                .sunriseCard()
            }

            Text("Community-Richtlinien: Respektvoller Umgang ist Pflicht. Unangemessene Beiträge können jederzeit über das Menü (•••) gemeldet oder Nutzer blockiert werden.")
                .font(.caption2)
                .foregroundStyle(SunriseTheme.subtle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }

    // MARK: - Squad & Matching

    private var squadAndMatchingSection: some View {
        @Bindable var bindableStore = store

        return VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Deine Festival-Crew")
                        .font(.headline.weight(.bold))
                    Spacer()
                    Toggle("Ghost-Modus", isOn: $bindableStore.state.myGhostMode)
                        .labelsHidden()
                    Text("Ghost")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SunriseTheme.muted)
                }

                ForEach(store.state.squad) { member in
                    HStack {
                        Circle()
                            .fill(member.ghostMode ? SunriseTheme.subtle : SunriseTheme.teal)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text(String(member.name.prefix(1)))
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.white)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.name)
                                .font(.subheadline.weight(.bold))
                            Text("\(member.role) · \(member.status)")
                                .font(.caption)
                                .foregroundStyle(SunriseTheme.muted)
                        }
                        Spacer()
                        Text(member.buddyCode)
                            .font(.caption2.monospaced())
                            .foregroundStyle(SunriseTheme.subtle)
                    }
                    .padding(10)
                    .background(SunriseTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .sunriseCard()

            VStack(alignment: .leading, spacing: 10) {
                Text("Music-Matching (Spotify & Apple Music)")
                    .font(.headline.weight(.bold))

                ForEach(store.state.musicMatches) { profile in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(profile.name)
                                .font(.subheadline.weight(.bold))
                            SunrisePillBadge(text: "\(profile.matchPercent)% Match", background: SunriseTheme.teal.opacity(0.14), foreground: SunriseTheme.teal)
                            Spacer()
                            Text(profile.service)
                                .font(.caption2)
                                .foregroundStyle(SunriseTheme.subtle)
                        }
                        Text("Gemeinsam: \(profile.sharedArtists.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundStyle(SunriseTheme.muted)
                        HStack {
                            Label(profile.currentStage, systemImage: "mappin")
                                .font(.caption2)
                                .foregroundStyle(SunriseTheme.subtle)
                            Spacer()
                            Button(profile.invited ? "Eingeladen ✓" : "Zur Crew einladen") {
                                store.toggleInviteMatch(id: profile.id)
                            }
                            .font(.caption.weight(.bold))
                            .foregroundStyle(profile.invited ? SunriseTheme.teal : .white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(profile.invited ? SunriseTheme.teal.opacity(0.14) : SunriseTheme.red)
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
    }

    // MARK: - Act Chats

    private var actChatsSection: some View {
        let activeChannel = store.state.channels.first(where: { $0.id == selectedChannelId }) ?? store.state.channels[0]

        return VStack(spacing: 14) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(store.state.channels) { ch in
                        Button {
                            selectedChannelId = ch.id
                        } label: {
                            Text(ch.name)
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .foregroundStyle(ch.id == activeChannel.id ? .white : SunriseTheme.ink)
                                .background(ch.id == activeChannel.id ? SunriseTheme.ink : Color.white)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(SunriseTheme.border))
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(activeChannel.name)
                            .font(.headline.weight(.bold))
                        Text("\(activeChannel.activeUsers) aktiv · \(activeChannel.archivesIn)")
                            .font(.caption2)
                            .foregroundStyle(SunriseTheme.muted)
                    }
                    Spacer()
                }

                let visibleMessages = activeChannel.messages.filter { msg in
                    !store.state.reportedPostIds.contains(msg.id) &&
                    !store.state.blockedAuthors.contains(msg.author)
                }

                ForEach(visibleMessages) { msg in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(msg.author)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(msg.author == "Du" ? SunriseTheme.red : SunriseTheme.ink)
                            Spacer()
                            Text(msg.time)
                                .font(.caption2)
                                .foregroundStyle(SunriseTheme.subtle)

                            if msg.author != "Du" {
                                Menu {
                                    Button(role: .destructive) {
                                        store.reportPost(id: msg.id)
                                    } label: {
                                        Label("Nachricht melden", systemImage: "flag")
                                    }
                                    Button(role: .destructive) {
                                        store.blockAuthor(msg.author)
                                    } label: {
                                        Label("\(msg.author) blockieren", systemImage: "hand.raised")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(SunriseTheme.subtle)
                                        .padding(4)
                                }
                            }
                        }
                        Text(msg.text)
                            .font(.subheadline)
                    }
                    .padding(10)
                    .background(SunriseTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                HStack(spacing: 8) {
                    TextField("Nachricht senden…", text: $chatDraft)
                        .font(.subheadline)
                        .padding(9)
                        .background(SunriseTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Button {
                        store.sendChatMessage(channelId: activeChannel.id, text: chatDraft)
                        chatDraft = ""
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(SunriseTheme.red)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .sunriseCard()
        }
    }

    // MARK: - News & Ride/Camp

    private var newsAndRideSection: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text("starzone News & Reporter")
                    .font(.headline.weight(.bold))

                ForEach(store.state.newsItems) { item in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            SunrisePillBadge(text: item.category)
                            Spacer()
                            Text(item.timestamp)
                                .font(.caption2)
                                .foregroundStyle(SunriseTheme.subtle)
                        }
                        Text(item.title)
                            .font(.subheadline.weight(.bold))
                        Text(item.summary)
                            .font(.caption)
                            .foregroundStyle(SunriseTheme.muted)
                    }
                    .padding(12)
                    .background(SunriseTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .sunriseCard()

            VStack(alignment: .leading, spacing: 10) {
                Text("Mitfahrgelegenheiten & Zeltnachbarn")
                    .font(.headline.weight(.bold))

                ForEach(store.state.rideCampPosts) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            SunrisePillBadge(text: item.type, background: SunriseTheme.teal.opacity(0.14), foreground: SunriseTheme.teal)
                            Spacer()
                            Text("\(max(0, item.spotsOpen)) Plätze frei")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(SunriseTheme.muted)
                        }
                        Text(item.title)
                            .font(.subheadline.weight(.bold))
                        Text("\(item.author) · \(item.routeOrZone) · \(item.dateInfo)")
                            .font(.caption)
                            .foregroundStyle(SunriseTheme.muted)

                        Button(item.joined ? "Platz reserviert ✓" : "Anschließen") {
                            store.toggleJoinRideCamp(id: item.id)
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(item.joined ? SunriseTheme.teal : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(item.joined ? SunriseTheme.teal.opacity(0.14) : SunriseTheme.ink)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(12)
                    .background(SunriseTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .sunriseCard()
        }
    }
}
