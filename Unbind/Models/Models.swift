//
//  Models.swift
//  Unbind
//
//  Data Models for the app
//

import Foundation

// MARK: - Body Location
enum BodyLocation: String, CaseIterable, Identifiable {
    case chest = "Chest"
    case stomach = "Stomach"
    case throat = "Throat"
    case solarPlexus = "Solar Plexus"
    case shoulders = "Shoulders"
    case head = "Head"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .chest: return "heart"
        case .stomach: return "circle.grid.cross"
        case .throat: return "waveform"
        case .solarPlexus: return "sun.max"
        case .shoulders: return "figure.arms.open"
        case .head: return "brain.head.profile"
        }
    }
    
    var description: String {
        switch self {
        case .chest: return "The center of emotional weight"
        case .stomach: return "Where anxiety often settles"
        case .throat: return "Unspoken words and tension"
        case .solarPlexus: return "Core of personal power"
        case .shoulders: return "Carrying the weight of responsibility"
        case .head: return "Overthinking and mental fog"
        }
    }
}

// MARK: - Feeling Quality
enum FeelingQuality: String, CaseIterable, Identifiable {
    case tight = "Tight"
    case heavy = "Heavy"
    case hot = "Hot"
    case foggy = "Foggy"
    case restless = "Restless"
    case pressure = "Pressure"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .tight: return "Constricted, squeezed"
        case .heavy: return "Weighted down"
        case .hot: return "Burning, intense"
        case .foggy: return "Unclear, disconnected"
        case .restless: return "Can't settle"
        case .pressure: return "Pushing outward"
        }
    }
}

// MARK: - Protection Layer
enum ProtectionLayer: String, CaseIterable, Identifiable {
    case rejection = "Rejection"
    case judgment = "Judgment"
    case uncertainty = "Uncertainty"
    case failure = "Failure"
    case lossOfControl = "Loss of Control"
    case notEnough = "Not Being Enough"
    
    var id: String { rawValue }
    
    var softening: String {
        switch self {
        case .rejection:
            return "The fear of rejection is just trying to keep you safe. You don't need to push it away — just let it be here."
        case .judgment:
            return "The fear of judgment wants to protect your sense of self. It's okay. You're allowed to be imperfect."
        case .uncertainty:
            return "Not knowing is uncomfortable. But you've survived uncertainty before. You can hold this."
        case .failure:
            return "The fear of failure is just protection. It doesn't define you. Let it soften."
        case .lossOfControl:
            return "Wanting control is human. But right now, you can let go — just a little."
        case .notEnough:
            return "The feeling of 'not enough' is a story, not a truth. You are already whole."
        }
    }
}

// MARK: - Inner Weather
enum InnerWeather: String, CaseIterable, Identifiable {
    case soft = "Soft"
    case neutral = "Neutral"
    case heavy = "Heavy"
    case tight = "Tight"
    case open = "Open"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .soft: return "☁️"
        case .neutral: return "🌤"
        case .heavy: return "🌧"
        case .tight: return "⛈"
        case .open: return "☀️"
        }
    }
    
    var message: String {
        switch self {
        case .soft: return "A gentle start. Let's honor that."
        case .neutral: return "Steady ground. A good place to begin."
        case .heavy: return "Something is present. We'll meet it gently."
        case .tight: return "There's tension here. Let's soften together."
        case .open: return "Spaciousness. Beautiful. Let's expand it."
        }
    }
}

// MARK: - Release Session
struct ReleaseSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let bodyLocation: String
    let feelingQuality: String
    let protectionLayer: String
    
    init(bodyLocation: BodyLocation, feelingQuality: FeelingQuality, protectionLayer: ProtectionLayer) {
        self.id = UUID()
        self.date = Date()
        self.bodyLocation = bodyLocation.rawValue
        self.feelingQuality = feelingQuality.rawValue
        self.protectionLayer = protectionLayer.rawValue
    }
}

// MARK: - User State
class UserState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }
    
    @Published var currentStreak: Int {
        didSet { UserDefaults.standard.set(currentStreak, forKey: "currentStreak") }
    }
    
    @Published var lastActiveDate: Date? {
        didSet { 
            if let date = lastActiveDate {
                UserDefaults.standard.set(date, forKey: "lastActiveDate")
            }
        }
    }
    
    @Published var totalReleaseSessions: Int {
        didSet { UserDefaults.standard.set(totalReleaseSessions, forKey: "totalReleaseSessions") }
    }
    
    @Published var morningCompletedToday: Bool = false
    @Published var eveningCompletedToday: Bool = false
    
    @Published var todaysSeedIndex: Int {
        didSet { UserDefaults.standard.set(todaysSeedIndex, forKey: "todaysSeedIndex") }
    }
    
    @Published var lastSeedDate: Date? {
        didSet {
            if let date = lastSeedDate {
                UserDefaults.standard.set(date, forKey: "lastSeedDate")
            }
        }
    }
    
    @Published var checkInHistory: [DailyCheckIn] = [] {
        didSet { saveCheckInHistory() }
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        self.lastActiveDate = UserDefaults.standard.object(forKey: "lastActiveDate") as? Date
        self.totalReleaseSessions = UserDefaults.standard.integer(forKey: "totalReleaseSessions")
        self.todaysSeedIndex = UserDefaults.standard.integer(forKey: "todaysSeedIndex")
        self.lastSeedDate = UserDefaults.standard.object(forKey: "lastSeedDate") as? Date
        
        loadCheckInHistory()
        checkAndUpdateStreak()
        checkAndUpdateDailySeed()
        loadTodaysCheckInState()
    }
    
    private func loadCheckInHistory() {
        if let data = UserDefaults.standard.data(forKey: "checkInHistory"),
           let decoded = try? JSONDecoder().decode([DailyCheckIn].self, from: data) {
            checkInHistory = decoded
        }
    }
    
    private func saveCheckInHistory() {
        if let encoded = try? JSONEncoder().encode(checkInHistory) {
            UserDefaults.standard.set(encoded, forKey: "checkInHistory")
        }
    }
    
    private func loadTodaysCheckInState() {
        let today = Calendar.current.startOfDay(for: Date())
        if let todaysCheckIn = checkInHistory.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            morningCompletedToday = todaysCheckIn.morningCompleted
            eveningCompletedToday = todaysCheckIn.eveningCompleted
        }
    }
    
    func getTodaysCheckIn() -> DailyCheckIn {
        let today = Calendar.current.startOfDay(for: Date())
        if let existing = checkInHistory.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            return checkInHistory[existing]
        }
        return DailyCheckIn(date: today)
    }
    
    func updateTodaysCheckIn(_ checkIn: DailyCheckIn) {
        let today = Calendar.current.startOfDay(for: Date())
        if let index = checkInHistory.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            checkInHistory[index] = checkIn
        } else {
            checkInHistory.append(checkIn)
        }
        // Sort by date descending
        checkInHistory.sort { $0.date > $1.date }
    }
    
    func checkAndUpdateStreak() {
        let calendar = Calendar.current
        
        guard let lastDate = lastActiveDate else {
            return
        }
        
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)
        
        let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        if daysDifference > 1 {
            // Streak broken
            currentStreak = 0
        }
        
        // Reset daily completions if it's a new day
        if daysDifference >= 1 {
            morningCompletedToday = false
            eveningCompletedToday = false
        }
    }
    
    func checkAndUpdateDailySeed() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastSeedDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            if today > lastDay {
                // New day, new seed
                todaysSeedIndex = (todaysSeedIndex + 1) % SeedContent.seeds.count
                lastSeedDate = today
            }
        } else {
            // First time
            lastSeedDate = today
        }
    }
    
    func recordActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastActiveDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysDifference > 1 {
                // Streak broken, start fresh
                currentStreak = 1
            }
            // Same day = no change to streak
        } else {
            // First activity ever
            currentStreak = 1
        }
        
        lastActiveDate = Date()
    }
    
    func completeMorning(weather: InnerWeather? = nil) {
        morningCompletedToday = true
        var checkIn = getTodaysCheckIn()
        checkIn.morningCompleted = true
        if let w = weather {
            checkIn.morningWeather = w.rawValue
        }
        updateTodaysCheckIn(checkIn)
        recordActivity()
    }
    
    func completeEvening(weather: InnerWeather? = nil) {
        eveningCompletedToday = true
        var checkIn = getTodaysCheckIn()
        checkIn.eveningCompleted = true
        if let w = weather {
            checkIn.eveningWeather = w.rawValue
        }
        updateTodaysCheckIn(checkIn)
        recordActivity()
    }
    
    func completeRelease() {
        totalReleaseSessions += 1
        recordActivity()
    }
    
    var todaysSeed: Seed {
        SeedContent.seeds[todaysSeedIndex]
    }
    
    // MARK: - Progress Helpers
    
    func getRecentCheckIns(days: Int = 7) -> [DailyCheckIn] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Create entries for all days in the range
        var result: [DailyCheckIn] = []
        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            if let existing = checkInHistory.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                result.append(existing)
            } else {
                // Create empty entry for days without check-ins
                result.append(DailyCheckIn(date: date))
            }
        }
        return result
    }
    
    var weeklyCompletionRate: Double {
        let recent = getRecentCheckIns(days: 7)
        let totalPossible = recent.count * 2 // morning + evening
        let completed = recent.reduce(0) { sum, checkIn in
            sum + (checkIn.morningCompleted ? 1 : 0) + (checkIn.eveningCompleted ? 1 : 0)
        }
        return totalPossible > 0 ? Double(completed) / Double(totalPossible) : 0
    }
    
    var averageWeeklyMood: Double {
        let recent = getRecentCheckIns(days: 7).filter { $0.morningWeather != nil || $0.eveningWeather != nil }
        guard !recent.isEmpty else { return 3.0 }
        let total = recent.reduce(0) { $0 + $1.weatherScore }
        return Double(total) / Double(recent.count)
    }
    
    var totalCheckIns: Int {
        checkInHistory.reduce(0) { sum, checkIn in
            sum + (checkIn.morningCompleted ? 1 : 0) + (checkIn.eveningCompleted ? 1 : 0)
        }
    }
}

// MARK: - Seed
struct Seed: Identifiable {
    let id = UUID()
    let text: String
    let category: SeedCategory
}

enum SeedCategory: String {
    case letting = "Letting Go"
    case presence = "Presence"
    case acceptance = "Acceptance"
    case truth = "Truth"
    case softness = "Softness"
    case freedom = "Freedom"
}

// MARK: - Daily Check-In Record
struct DailyCheckIn: Codable, Identifiable {
    var id: String { dateString }
    let dateString: String
    let date: Date
    var morningWeather: String?
    var eveningWeather: String?
    var morningCompleted: Bool
    var eveningCompleted: Bool
    
    init(date: Date, morningWeather: String? = nil, eveningWeather: String? = nil, morningCompleted: Bool = false, eveningCompleted: Bool = false) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.dateString = formatter.string(from: date)
        self.date = Calendar.current.startOfDay(for: date)
        self.morningWeather = morningWeather
        self.eveningWeather = eveningWeather
        self.morningCompleted = morningCompleted
        self.eveningCompleted = eveningCompleted
    }
    
    var completionScore: Double {
        var score = 0.0
        if morningCompleted { score += 0.5 }
        if eveningCompleted { score += 0.5 }
        return score
    }
    
    var weatherScore: Int {
        // Convert weather to a 1-5 score for progress tracking
        func weatherToScore(_ weather: String?) -> Int? {
            guard let w = weather else { return nil }
            switch w {
            case "Open": return 5
            case "Soft": return 4
            case "Neutral": return 3
            case "Heavy": return 2
            case "Tight": return 1
            default: return nil
            }
        }
        
        let morning = weatherToScore(morningWeather)
        let evening = weatherToScore(eveningWeather)
        
        if let m = morning, let e = evening {
            return (m + e) / 2
        } else if let m = morning {
            return m
        } else if let e = evening {
            return e
        }
        return 3 // Default neutral
    }
}

