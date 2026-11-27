import Foundation

enum MainTab: String, CaseIterable, Identifiable {
    case map = "Karte"
    case quests = "Quests"
    case community = "Community"
    case wallet = "Wallet"
    case livecam = "Live-Cam"
    case portals = "Portale"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .map: return "map.fill"
        case .quests: return "trophy.fill"
        case .community: return "person.3.fill"
        case .wallet: return "ticket.fill"
        case .livecam: return "video.fill"
        case .portals: return "globe"
        }
    }
}

enum FestivalDay: String, CaseIterable, Codable, Identifiable {
    case alle = "Alle"
    case freitag = "Freitag"
    case samstag = "Samstag"
    case sonntag = "Sonntag"

    var id: String { rawValue }
}

enum StageId: String, Codable, CaseIterable, Identifiable {
    case mainstage
    case seebuehne
    case zeltbuehne
    case waldlichtung

    var id: String { rawValue }
}

enum CrowdLevel: String, Codable {
    case ruhig = "Ruhig"
    case lebhaft = "Lebhaft"
    case sehrVoll = "Sehr voll"
}

struct Stage: Identifiable, Codable, Equatable {
    let id: StageId
    var name: String
    var subtitle: String
    var capacity: Int
    var crowdPercent: Int
    var crowdLabel: CrowdLevel
    var currentAct: String
    var nextAct: String
    var walkMinutesFromGate: Int
    var mapX: Double // 0..800
    var mapY: Double // 0..480
    var isSecret: Bool
    var accessible: Bool
    var quietZoneNearby: Bool
    var alternativeHint: String?
}

enum POIType: String, Codable, CaseIterable {
    case wc, drinks, food, wardrobe, water, firstaid, quiet, charger, lounge

    var systemImage: String {
        switch self {
        case .wc: return "figure.stand.dress.line.vertical.figure"
        case .drinks: return "wineglass.fill"
        case .food: return "fork.knife"
        case .wardrobe: return "lock.fill"
        case .water: return "drop.fill"
        case .firstaid: return "cross.case.fill"
        case .quiet: return "ear.badge.checkmark"
        case .charger: return "bolt.batteryblock.fill"
        case .lounge: return "sparkles"
        }
    }
}

struct ServicePOI: Identifiable, Codable, Equatable {
    let id: String
    var type: POIType
    var name: String
    var waitMinutes: Int
    var statusLabel: String
    var mapX: Double
    var mapY: Double
    var accessible: Bool
    var rating: Double
    var reportCount: Int
}

struct PackListItem: Identifiable, Codable, Equatable {
    let id: String
    var label: String
    var category: String
    var weatherDependent: Bool
    var packed: Bool
}

enum PersonalPinType: String, Codable {
    case auto
    case zelt

    var label: String {
        switch self {
        case .auto: return "Auto-Pin"
        case .zelt: return "Zelt-Pin"
        }
    }

    var systemImage: String {
        switch self {
        case .auto: return "car.fill"
        case .zelt: return "tent.fill"
        }
    }
}

struct PersonalPin: Identifiable, Codable, Equatable {
    var id: String { type.rawValue }
    var type: PersonalPinType
    var mapX: Double
    var mapY: Double
    var note: String
}

struct LineupAct: Identifiable, Codable, Equatable {
    let id: String
    var artist: String
    var genre: String
    var day: FestivalDay
    var startTime: String // "19:30"
    var endTime: String   // "20:45"
    var stageId: StageId
    var walkMinutes: Int
    var isFavorite: Bool
    var hasReminder: Bool
    var isNewDiscovery: Bool
    var description: String

    var startMinutes: Int {
        Self.parseMinutes(startTime)
    }

    var endMinutes: Int {
        Self.parseMinutes(endTime)
    }

    var leaveTimeLabel: String {
        let leaveMins = max(0, startMinutes - walkMinutes - 10)
        let h = leaveMins / 60
        let m = leaveMins % 60
        return String(format: "%02d:%02d losgehen · %d Min", h, m, walkMinutes)
    }

    private static func parseMinutes(_ time: String) -> Int {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return 0 }
        return parts[0] * 60 + parts[1]
    }
}

enum PushCategory: String, Codable {
    case konzert, konflikt, wetter, buehne, quest

    var systemImage: String {
        switch self {
        case .konzert: return "bell.badge.fill"
        case .konflikt: return "exclamationmark.triangle.fill"
        case .wetter: return "cloud.bolt.rain.fill"
        case .buehne: return "safari.fill"
        case .quest: return "trophy.fill"
        }
    }
}

struct PushNotificationItem: Identifiable, Equatable {
    let id: String
    let category: PushCategory
    let title: String
    let message: String
    let timestamp: String
    var stageId: StageId?
}

enum QuestCategory: String, Codable, CaseIterable, Identifiable {
    case alle = "Alle"
    case tages = "Tages-Quests"
    case crew = "Crew-Quests"
    case saison = "Saison-Pass"
    case sponsoren = "Sponsoren"

    var id: String { rawValue }
}

struct Quest: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var description: String
    var category: QuestCategory
    var xpReward: Int
    var coinReward: Int
    var progress: Int
    var target: Int
    var completed: Bool
    var badgeUnlockId: String?
    var sponsorName: String?
    var crewSizeHint: String?
}

enum BadgeCategory: String, Codable {
    case selten = "Selten"
    case nachhaltigkeit = "Nachhaltigkeit"
    case saison = "Saison"
    case crew = "Crew"
}

struct BadgeItem: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var description: String
    var category: BadgeCategory
    var year: String
    var rarityText: String
    var unlocked: Bool
    var pinned: Bool
    var systemImage: String
}

struct BingoTile: Identifiable, Codable, Equatable {
    let id: String
    var label: String
    var hint: String
    var completed: Bool
    var verifiedBy: String?
}

struct EncorePrediction: Identifiable, Codable, Equatable {
    let id: String
    var artist: String
    var stageName: String
    var time: String
    var options: [String]
    var selectedOption: String?
    var revealedSong: String?
    var points: Int
}

struct ARClue: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var locationHint: String
    var found: Bool
    var rewardXp: Int
    var rewardCoins: Int
    var codeWord: String
}

struct VibePost: Identifiable, Codable, Equatable {
    let id: String
    var author: String
    var handle: String
    var stageName: String
    var timestamp: String
    var text: String
    var likes: Int
    var likedByMe: Bool
    var assetImageName: String?
    var isFanWallMoment: Bool
}

struct SquadMember: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var role: String
    var status: String
    var stageId: String
    var mapX: Double
    var mapY: Double
    var ghostMode: Bool
    var buddyCode: String
    var favoriteActIds: [String]
}

struct MusicMatchProfile: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var service: String
    var matchPercent: Int
    var sharedArtists: [String]
    var topGenre: String
    var currentStage: String
    var invited: Bool
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: String
    var author: String
    var text: String
    var time: String
}

struct ChatChannel: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var category: String
    var archivesIn: String
    var activeUsers: Int
    var messages: [ChatMessage]
}

struct RideCampPost: Identifiable, Codable, Equatable {
    let id: String
    var type: String // "Mitfahrt" | "Zeltnachbar"
    var title: String
    var author: String
    var routeOrZone: String
    var dateInfo: String
    var spotsOpen: Int
    var joined: Bool
}

struct VotingOption: Identifiable, Codable, Equatable {
    let id: String
    var label: String
    var votes: Int
}

struct VotingPoll: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var subtitle: String
    var artistOrHost: String
    var closesAt: String
    var options: [VotingOption]
    var votedOptionId: String?

    var totalVotes: Int {
        max(1, options.reduce(0) { $0 + $1.votes })
    }
}

struct WalletItem: Identifiable, Codable, Equatable {
    let id: String
    var type: String // Ticket | Coupon | Zugang | Nachhaltigkeit
    var title: String
    var subtitle: String
    var validUntil: String
    var qrSeed: String
    var codeText: String
    var redeemed: Bool
}

struct RewardItem: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var description: String
    var costCoins: Int
    var type: String
    var stockLabel: String
}

struct LiveCamBroadcast: Identifiable, Codable, Equatable {
    let id: String
    var author: String
    var stageName: String
    var caption: String
    var timestamp: String
    var cheers: Int
    var assetImageName: String?
}

struct NewsItem: Identifiable, Codable, Equatable {
    let id: String
    var category: String
    var title: String
    var summary: String
    var author: String
    var timestamp: String
    var tag: String
}

struct RaffleItem: Identifiable, Codable, Equatable {
    let id: String
    var category: String
    var title: String
    var prizeDescription: String
    var drawTime: String
    var entered: Bool
}

struct TicketAlertPrefs: Codable, Equatable {
    var enabled: Bool
    var geofencingEnabled: Bool
    var email: String
    var genres: [String]
    var regions: [String]
    var eventTypes: [String]
}

struct PersistedFestivalState: Codable {
    var xp: Int
    var coins: Int
    var cashlessBalance: Double
    var chargerReserved: Bool
    var secretUnlocked: Bool
    var myGhostMode: Bool
    var weatherAlertActive: Bool
    var checkedInStages: [StageId]
    var stages: [Stage]
    var pois: [ServicePOI]
    var packList: [PackListItem]
    var personalPins: [PersonalPin]
    var lineup: [LineupAct]
    var quests: [Quest]
    var badges: [BadgeItem]
    var bingo: [BingoTile]
    var predictions: [EncorePrediction]
    var arClues: [ARClue]
    var vibePosts: [VibePost]
    var squad: [SquadMember]
    var musicMatches: [MusicMatchProfile]
    var channels: [ChatChannel]
    var rideCampPosts: [RideCampPost]
    var polls: [VotingPoll]
    var wallet: [WalletItem]
    var broadcasts: [LiveCamBroadcast]
    var newsItems: [NewsItem]
    var raffles: [RaffleItem]
    var ticketPrefs: TicketAlertPrefs
}
