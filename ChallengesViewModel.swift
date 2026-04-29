//
//  ChallengesViewModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 16/08/25.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation


private extension ChallengesViewModel {
    static let iso8601WithFrac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    static let iso8601: ISO8601DateFormatter = ISO8601DateFormatter()

    static func parseSupabaseDate(_ s: String) -> Date? {
        if let d = iso8601WithFrac.date(from: s) { return d }                 // 2025-08-19T12:34:56.789Z / +00:00
        if let d = iso8601.date(from: s) { return d }                         // 2025-08-19T12:34:56Z
        let df = DateFormatter()
        df.calendar = .init(identifier: .gregorian)
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"                                         // plain DATE
        return df.date(from: s)
    }
}

@MainActor
final class ChallengesViewModel: ObservableObject {
    @Published var activeChallenges: [ActiveChallenge] = []
    @Published var achievements: [Achievement] = [
        Achievement(icon: "medal.fill",          label:"Money Master",               color:.yellow),
        Achievement(icon: "crown.fill",          label:"Budget Boss",                color:.gray),
        Achievement(icon: "star.fill",           label:"Saving Star",                color:.orange),
        Achievement(icon: "1.circle.fill",       label:"1st Challenge Joined",       color:.blue),
        Achievement(icon: "checkmark.seal.fill", label:"1 Challenge Completed",      color:.green),
        Achievement(icon: "10.circle.fill",      label:"10 Challenges Completed",    color:.teal),
        Achievement(icon: "50.circle.fill",      label:"50 Challenges Completed",    color:.purple),
        Achievement(icon: "trophy.fill",         label:"100 Challenges Completed",   color:.pink),
        Achievement(icon: "rosette",             label:"200 Challenges Completed",   color:.indigo),
        Achievement(icon: "star.circle.fill",    label:"300 Challenges Completed",   color:.orange),
        Achievement(icon: "medal.fill",          label:"400 Challenges Completed",   color:.cyan),
        Achievement(icon: "crown.fill",          label:"500 Challenges Completed",   color:.red)
    ]
    @Published var leaders: [Leader] = []
    @Published var newChallenges: [NewChallenge] = []
    @Published private(set) var lastChallengeRefresh: Date = .distantPast
    @Published var justUnlocked: Achievement?

    var ownerName: String = "You"
    var currentUserIsPublic: Bool = true
    
    private let defaults = UserDefaults.standard
        private let onboardedKey = "challenges.hasOnboarded"
        private var hasOnboarded: Bool {
            get { defaults.bool(forKey: onboardedKey) }
            set { defaults.set(newValue, forKey: onboardedKey) }
        }

        private func isSundayIST(_ date: Date = Date()) -> Bool {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(identifier: "Asia/Kolkata") ?? .current
            return cal.component(.weekday, from: date) == 1
        }

        private func openSlotsNow() -> Int {
            // cap simultaneous *incomplete* actives at targetActiveCount (5)
            return max(0, targetActiveCount - activeChallenges.filter { !$0.isCompleted }.count)
        }

    let milestoneCatalog: [Milestone] = [
        .init(threshold: 100, color: .teal,    icon: "flag.checkered"),
        .init(threshold: 200, color: .blue,    icon: "trophy.fill"),
        .init(threshold: 300, color: .purple,  icon: "rosette"),
        .init(threshold: 400, color: .pink,    icon: "star.circle.fill"),
        .init(threshold: 500, color: .orange,  icon: "crown.fill")
    ]

    private let targetActiveCount = 5
    var totalCompleted: Int { activeChallenges.filter { $0.isCompleted }.count }
    private var cancellable: AnyCancellable?

    init() {
        startSundayRefreshTimer()
        Task { await initialSync() }
    }

    func setCurrentUser(name: String, isPublic: Bool) {
        ownerName = name
        currentUserIsPublic = isPublic
    }

    // MARK: - First sync
    private func initialSync() async {
        _ = await SupabaseChallengesManager.shared.waitUntilAuthenticatedIfNeeded()
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { try await self.pullUserActivesAndProgress() }
                group.addTask { try await self.pullAchievements() }
                group.addTask { try await self.pullLeaderboard() }
                try await group.waitForAll()
            }
            refreshDerivedState()

            // 🔒 NEW: First-time users should *not* auto-join. Show joinables only.
            if activeChallenges.isEmpty && !hasOnboarded {
                await topUpJoinables(openSlots: targetActiveCount, preserveExisting: false)
            } else {
                // Existing users: allow server to assign only on Sundays (IST)
                await serverAssignIfNeeded(onlyOnSunday: true)
                await refreshJoinablesBasedOnRules()
            }
        } catch {
            print("Challenges initial sync error:", error.localizedDescription)
        }
    }


    private func refreshDerivedState() { updateAchievementStates() }

    // MARK: - Pulls

    private func pullUserActivesAndProgress() async throws {
        let rows = try await SupabaseChallengesManager.shared.fetchUserActiveChallenges()
        self.activeChallenges = rows.map { tuple in
            let ua = tuple.ua, ch = tuple.ch
            let total = max(1, ch.total_days)
            var completion = Array(repeating: false, count: total)
            tuple.days.forEach { d in
                if d.day_index >= 0 && d.day_index < completion.count { completion[d.day_index] = d.is_done }
            }
            return ActiveChallenge(
                userActiveId: ua.id,
                dbChallengeId: ch.id,
                title: ch.title,
                totalDays: total,
                color: Color(hex: ch.color_hex ?? "#06B6D4") ?? .teal,
                startDate: ua.start_date,
                type: ChallengeType(rawValue: ch.type) ?? .dailyStreak,
                dailyCompletion: completion
            )
        }
    }

    private func pullAchievements() async throws {
        let rows = try await SupabaseChallengesManager.shared.fetchUserAchievements()
        guard !rows.isEmpty else { return }
        for i in achievements.indices {
            if let match = rows.first(where: { $0.label == achievements[i].label }) {
                achievements[i].earned = match.earned
                if let s = match.earned_at, let d = Self.parseSupabaseDate(s) {
                    achievements[i].earnedDate = d
                } else {
                    achievements[i].earnedDate = nil
                }
                achievements[i].earnedBy = match.earned_by
            }
        }
    }

    private func pullLeaderboard() async throws {
        do {
            let rows = try await SupabaseChallengesManager.shared.fetchLeaderboard()
            self.leaders = rows.enumerated().map { idx, r in
                Leader(
                    initials: r.initials ?? Self.initials(from: r.name),
                    name: r.name,
                    points: "\(r.points)",
                    rank: "#\(idx + 1)"
                )
            }
        } catch {
            let pts = computePoints(for: activeChallenges.filter { $0.isCompleted }.count)
            self.leaders = [Leader(initials: Self.initials(from: ownerName), name: ownerName, points: "\(pts)", rank: "#1")]
        }
    }

    // MARK: - Server assignment (NEW)
    /// Ask the server if we should assign challenges *now*.
    /// - onlyOnSunday: true means skip on non-Sundays.
    /// - First-time users (hasOnboarded == false) are never auto-assigned.
    private func serverAssignIfNeeded(onlyOnSunday: Bool = true) async {
        guard let uid = SupabaseChallengesManager.shared.userId else { return }

        // ❌ Never auto-assign for first-time users
        if activeChallenges.isEmpty && !hasOnboarded { return }

        if onlyOnSunday && !isSundayIST() { return }

        let slots = openSlotsNow()
        guard slots > 0 else { return }

        do {
            // Ask server for up to our current open slots
            let assignables = try await SupabaseChallengesManager.shared
                .fetchAssignableChallenges(userId: uid, target: min(targetActiveCount, slots))

            guard !assignables.isEmpty else { return }

            // Cap to the exact number of open slots
            let picked = Array(assignables.prefix(slots))
            try await SupabaseChallengesManager.shared
                .insertActiveChallenges(userId: uid, challengeIds: picked.map(\.id))

            try await pullUserActivesAndProgress()
            refreshDerivedState()

            // Remove those from local joinables if present
            let newIds = Set(picked.map(\.id))
            newChallenges.removeAll { newIds.contains($0.dbChallengeId) }

            print("[Challenges] Server assigned \(picked.count) (capped by open slots=\(slots)).")
        } catch {
            print("[Challenges] serverAssignIfNeeded error:", error.localizedDescription)
        }
    }


    // MARK: - Sunday / onboarding refresh rules (client-side offers)

    private func startSundayRefreshTimer() {
        cancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refreshJoinablesBasedOnRules() }
            }
    }
    func refreshJoinablesBasedOnRules() async {
        // 1) First-time users: never auto-assign; just show joinables up to 5
        if activeChallenges.isEmpty && !hasOnboarded {
            await topUpJoinables(openSlots: targetActiveCount, preserveExisting: true)
            return
        }

        // 2) Existing users: pull latest actives
        do { try await pullUserActivesAndProgress() }
        catch { print("[Challenges] refreshJoinables: actives pull failed:", error.localizedDescription) }

        let slots = openSlotsNow()

        if isSundayIST() {
            // protect against multiple runs the same Sunday
            let cal = Calendar.current
            let now = Date()
            if !cal.isDate(lastChallengeRefresh, inSameDayAs: now) {
                await serverAssignIfNeeded(onlyOnSunday: true)
                await topUpJoinables(openSlots: openSlotsNow(), preserveExisting: true)
                lastChallengeRefresh = now
            }
            return
        }

        // NON-SUNDAY
        if activeChallenges.isEmpty {
            await topUpJoinables(openSlots: targetActiveCount, preserveExisting: true)
        } else {
            if newChallenges.isEmpty && slots > 0 {
                await topUpJoinables(openSlots: slots, preserveExisting: true)
            }
        }
    }


    /// Build the joinable list. By default we **preserveExisting** offers and add new ones
    /// up to `openSlots`, filtering out already joined.
    private func topUpJoinables(openSlots: Int, preserveExisting: Bool = true) async {
        guard openSlots > 0 || preserveExisting else { return }

        do {
            let catalog = try await SupabaseChallengesManager.shared.fetchCatalogChallenges()

            let joinedIDs = Set(activeChallenges.map { $0.dbChallengeId })
            let existing = preserveExisting ? newChallenges : []

            let existingIDs = Set(existing.map { $0.dbChallengeId })
            let candidates = catalog.filter { !joinedIDs.contains($0.id) && !existingIDs.contains($0.id) }

            let need = max(0, openSlots - existing.count)
            let additions = Array(candidates.prefix(need)).map {
                NewChallenge(
                    dbChallengeId: $0.id,
                    icon: $0.icon ?? "target",
                    title: $0.title,
                    points: "\($0.points)"
                )
            }

            let combined = existing + additions
            if combined != newChallenges {
                self.newChallenges = combined
                print("[Challenges] Offering \(newChallenges.count) joinables (openSlots=\(openSlots), preserved=\(existing.count), added=\(additions.count)).")
            }
        } catch {
            print("[Challenges] topUpJoinables failed:", error.localizedDescription)
        }
    }

    private func computeOpenSlotsFromIncomplete() -> Int {
        let incomplete = activeChallenges.filter { !$0.isCompleted }.count
        return max(0, targetActiveCount - incomplete)
    }

    // MARK: - Join, toggle, achievements

    func joinChallenge(_ ch: NewChallenge) {
        Task { [weak self] in
            guard let self = self else { return }

            // 🚧 Respect the 5-active cap
            guard self.openSlotsNow() > 0 else {
                print("[Challenges] joinChallenge blocked: no open slots remaining.")
                return
            }

            // 1) Fetch catalog (with your existing detailed DecodingError logging)
            let catalog: [SupabaseChallengesManager.DBChallenge]
            do {
                catalog = try await SupabaseChallengesManager.shared.fetchCatalogChallenges()
            } catch let DecodingError.dataCorrupted(ctx) {
                print("DecodingError.dataCorrupted:", ctx.debugDescription, ctx.codingPath)
                return
            } catch let DecodingError.keyNotFound(key, ctx) {
                print("DecodingError.keyNotFound:", key.stringValue, ctx.debugDescription, ctx.codingPath)
                return
            } catch let DecodingError.typeMismatch(type, ctx) {
                print("DecodingError.typeMismatch:", type, ctx.debugDescription, ctx.codingPath)
                return
            } catch let DecodingError.valueNotFound(type, ctx) {
                print("DecodingError.valueNotFound:", type, ctx.debugDescription, ctx.codingPath)
                return
            } catch {
                print("[Challenges] fetchCatalogChallenges failed:", error.localizedDescription)
                return
            }

            guard let dbch = catalog.first(where: { $0.id == ch.dbChallengeId }) else {
                print("[Challenges] joinChallenge: challenge id \(ch.dbChallengeId) not found in catalog")
                return
            }

            // 2) Insert/join
            do {
                let ua = try await SupabaseChallengesManager.shared.joinChallenge(dbch, startDate: Date())

                let active = ActiveChallenge(
                    userActiveId: ua.id,
                    dbChallengeId: dbch.id,
                    title: dbch.title,
                    totalDays: max(1, dbch.total_days),
                    color: Color(hex: dbch.color_hex ?? "#3B82F6") ?? .blue,
                    startDate: ua.start_date,
                    type: ChallengeType(rawValue: dbch.type) ?? .dailyStreak,
                    dailyCompletion: Array(repeating: false, count: max(1, dbch.total_days))
                )

                self.activeChallenges.append(active)
                self.newChallenges.removeAll { $0.dbChallengeId == ch.dbChallengeId }

                // ✅ Mark that the user has onboarded (enables future Sunday server-assign)
                if !self.hasOnboarded { self.hasOnboarded = true }

                if self.activeChallenges.count == 1 {
                    try? await SupabaseChallengesManager.shared.upsertAchievement(
                        label: "1st Challenge Joined", icon: "1.circle.fill", colorHex: "#3B82F6", earnedBy: self.ownerName
                    )
                    self.markAchievement(label: "1st Challenge Joined")
                }
                self.refreshDerivedState()
            } catch let DecodingError.dataCorrupted(ctx) {
                print("DecodingError (join insert) dataCorrupted:", ctx.debugDescription, ctx.codingPath)
            } catch let DecodingError.keyNotFound(key, ctx) {
                print("DecodingError (join insert) keyNotFound:", key.stringValue, ctx.debugDescription, ctx.codingPath)
            } catch let DecodingError.typeMismatch(type, ctx) {
                print("DecodingError (join insert) typeMismatch:", type, ctx.debugDescription, ctx.codingPath)
            } catch let DecodingError.valueNotFound(type, ctx) {
                print("DecodingError (join insert) valueNotFound:", type, ctx.codingPath)
            } catch {
                print("Join challenge failed:", error.localizedDescription)
            }
        }
    }


//    func toggleDay(for clientId: UUID, day: Int) {
//        guard let idx = activeChallenges.firstIndex(where: { $0.id == clientId }),
//              day >= 0, day < activeChallenges[idx].dailyCompletion.count else { return }
//
//        let prevCompleted = activeChallenges[idx].isCompleted
//        activeChallenges[idx].dailyCompletion[day].toggle()
//        let newValue = activeChallenges[idx].dailyCompletion[day]
//        let nowCompleted = activeChallenges[idx].isCompleted
//        let uaId = activeChallenges[idx].userActiveId
//
//        Task {
//            do {
//                try await SupabaseChallengesManager.shared
//                    .upsertDailyToggle(userActiveId: uaId, dayIndex: day, newValue: newValue)
//
//                if !prevCompleted && nowCompleted {
//                    markCompletionMilestones()
//                    let completed = activeChallenges.filter { $0.isCompleted }.count
//                    let unlocks: [(Int, String, String)] = [
//                        (1,"1 Challenge Completed","checkmark.seal.fill"),
//                        (10,"10 Challenges Completed","10.circle.fill"),
//                        (50,"50 Challenges Completed","50.circle.fill"),
//                        (100,"100 Challenges Completed","trophy.fill"),
//                        (200,"200 Challenges Completed","rosette"),
//                        (300,"300 Challenges Completed","star.circle.fill"),
//                        (400,"400 Challenges Completed","medal.fill"),
//                        (500,"500 Challenges Completed","crown.fill")
//                    ]
//                    for (threshold, label, icon) in unlocks where completed >= threshold {
//                        try? await SupabaseChallengesManager.shared.upsertAchievement(
//                            label: label, icon: icon, colorHex: "#06B6D4", earnedBy: ownerName
//                        )
//                    }
//                }
//            } catch {
//                print("Toggle day failed:", error.localizedDescription)
//                activeChallenges[idx].dailyCompletion[day].toggle() // revert
//            }
//            refreshDerivedState()
//        }
//    }

    // MARK: - Achievements logic

    private struct AchievementRule { let targetCompleted: Int?; let description: String }
    private let specialRules: [String: AchievementRule] = [
        "Money Master": .init(targetCompleted: 15, description: "Complete 15 challenges overall (roughly 1,500 points). Mix streaks and savings challenges."),
        "Budget Boss":  .init(targetCompleted: 30, description: "Complete 30 challenges in total. Stay consistent over multiple weeks."),
        "Saving Star":  .init(targetCompleted: 5,  description: "Complete 5 savings-focused challenges (or any 5 challenges)."),
        "1st Challenge Joined": .init(targetCompleted: nil, description: "Join your first challenge from the “Join New Challenge” section.")
    ]

    private func numericTarget(from label: String) -> Int? {
        if let first = label.split(separator: " ").first { return Int(first) }
        return nil
    }

    func targetForAchievement(_ a: Achievement) -> Int? {
        if let t = specialRules[a.label]?.targetCompleted { return t }
        if let n = numericTarget(from: a.label) { return n }
        switch a.label {
        case "1 Challenge Completed": return 1
        case "10 Challenges Completed": return 10
        case "50 Challenges Completed": return 50
        case "100 Challenges Completed": return 100
        case "200 Challenges Completed": return 200
        case "300 Challenges Completed": return 300
        case "400 Challenges Completed": return 400
        case "500 Challenges Completed": return 500
        default: return nil
        }
    }

    func remainingForAchievement(_ a: Achievement) -> Int? {
        guard let target = targetForAchievement(a) else { return nil }
        return max(0, target - totalCompleted)
    }

    func progressTowards(_ a: Achievement) -> Double {
        guard let target = targetForAchievement(a), target > 0 else { return a.earned ? 1.0 : 0.0 }
        return min(1.0, Double(totalCompleted) / Double(target))
    }

    func howToEarnText(for a: Achievement) -> String {
        if let rule = specialRules[a.label] { return rule.description }
        if let t = targetForAchievement(a) { return "Complete \(t) challenges in total to unlock this award." }
        return "Keep finishing challenges and maintaining streaks to unlock this award."
    }

//    private func markAchievement(label: String) {
//        if let i = achievements.firstIndex(where: { $0.label == label }), achievements[i].earned == false {
//            achievements[i].earned = true
//            achievements[i].earnedDate = Date()
//            achievements[i].earnedBy = ownerName
//            justUnlocked = achievements[i]
//        }
//    }

    private func markCompletionMilestones() {
        let completed = activeChallenges.filter { $0.isCompleted }.count
        let milestones: [(Int, String)] = [
            (1,"1 Challenge Completed"), (10,"10 Challenges Completed"),
            (50,"50 Challenges Completed"), (100,"100 Challenges Completed"),
            (200,"200 Challenges Completed"), (300,"300 Challenges Completed"),
            (400,"400 Challenges Completed"), (500,"500 Challenges Completed")
        ]
        for (m,label) in milestones where completed >= m { markAchievement(label: label) }
    }

    private func updateAchievementStates() {
        if activeChallenges.count >= 1 { markAchievement(label: "1st Challenge Joined") }
        markCompletionMilestones()
    }

    // Helpers
    private func computePoints(for completed: Int) -> Int { completed * 100 }

}




// MARK: - ChallengesViewModel Extensions

extension ChallengesViewModel {
    var currentUserLeaderboardInfo: (rank: Int, points: Int)? {
        let userPoints = computePoints(for: totalCompleted)
        let currentUserName = ownerName
        
        // Check if user is already in leaders list
        if let existingUser = leaders.first(where: { $0.name == currentUserName }) {
            let rank = Int(existingUser.rank.replacingOccurrences(of: "#", with: "")) ?? 1
            return (rank: rank, points: userPoints)
        }
        
        // Calculate rank based on points compared to other users
        let usersAbove = leaders.filter {
            guard let otherPoints = Int($0.points) else { return false }
            return otherPoints > userPoints
        }.count
        
        return (rank: usersAbove + 1, points: userPoints)
    }
    
    func computeUserPoints(for completed: Int) -> Int {
        return computePoints(for: completed)
    }
    
//    func markDayCompleted(for clientId: UUID, day: Int) {
//            guard let idx = activeChallenges.firstIndex(where: { $0.id == clientId }),
//                  day >= 0, day < activeChallenges[idx].dailyCompletion.count else {
//                print("❌ Invalid challenge or day index")
//                return
//            }
//            
//            // Update the state regardless of current value
//            let prevCompleted = activeChallenges[idx].isCompleted
//            activeChallenges[idx].dailyCompletion[day] = true
//            let nowCompleted = activeChallenges[idx].isCompleted
//            let uaId = activeChallenges[idx].userActiveId
//            
//            // Add haptic feedback
//            Haptics.success()
//            
//            Task {
//                do {
//                    try await SupabaseChallengesManager.shared
//                        .upsertDailyToggle(userActiveId: uaId, dayIndex: day, newValue: true)
//                    
//                    print("✅ Day \(day + 1) marked as completed")
//                    
//                    // Check for challenge completion achievements
//                    if !prevCompleted && nowCompleted {
//                        await markCompletionMilestones()
//                        let completed = activeChallenges.filter { $0.isCompleted }.count
//                        let unlocks: [(Int, String, String)] = [
//                            (1,"1 Challenge Completed","checkmark.seal.fill"),
//                            (10,"10 Challenges Completed","10.circle.fill"),
//                            (50,"50 Challenges Completed","50.circle.fill"),
//                            (100,"100 Challenges Completed","trophy.fill"),
//                            (200,"200 Challenges Completed","rosette"),
//                            (300,"300 Challenges Completed","star.circle.fill"),
//                            (400,"400 Challenges Completed","medal.fill"),
//                            (500,"500 Challenges Completed","crown.fill")
//                        ]
//                        for (threshold, label, icon) in unlocks where completed >= threshold {
//                            try? await SupabaseChallengesManager.shared.upsertAchievement(
//                                label: label, icon: icon, colorHex: "#06B6D4", earnedBy: ownerName
//                            )
//                        }
//                    }
//                    
//                    await MainActor.run {
//                        refreshDerivedState()
//                    }
//                } catch {
//                    print("❌ Mark day completed failed: \(error.localizedDescription)")
//                    // Revert the change on error
//                    await MainActor.run {
//                        activeChallenges[idx].dailyCompletion[day] = false
//                    }
//                }
//            }
//        }
//        
//        /// Mark a specific day as missed (No button)
//        func markDayMissed(for clientId: UUID, day: Int) {
//            guard let idx = activeChallenges.firstIndex(where: { $0.id == clientId }),
//                  day >= 0, day < activeChallenges[idx].dailyCompletion.count else {
//                print("❌ Invalid challenge or day index")
//                return
//            }
//            
//            // Update the state regardless of current value
//            activeChallenges[idx].dailyCompletion[day] = false
//            let uaId = activeChallenges[idx].userActiveId
//            
//            // Add haptic feedback
//            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
//            impactFeedback.impactOccurred()
//            
//            Task {
//                do {
//                    try await SupabaseChallengesManager.shared
//                        .upsertDailyToggle(userActiveId: uaId, dayIndex: day, newValue: false)
//                    
//                    print("✅ Day \(day + 1) marked as missed")
//                    
//                    await MainActor.run {
//                        refreshDerivedState()
//                    }
//                } catch {
//                    print("❌ Mark day missed failed: \(error.localizedDescription)")
//                    // Revert the change on error
//                    await MainActor.run {
//                        activeChallenges[idx].dailyCompletion[day] = true
//                    }
//                }
//            }
//        }
//        
//        // Make markCompletionMilestones async and accessible
//        func markCompletionMilestones() async {
//            let completed = activeChallenges.filter { $0.isCompleted }.count
//            let milestones: [(Int, String)] = [
//                (1,"1 Challenge Completed"), (10,"10 Challenges Completed"),
//                (50,"50 Challenges Completed"), (100,"100 Challenges Completed"),
//                (200,"200 Challenges Completed"), (300,"300 Challenges Completed"),
//                (400,"400 Challenges Completed"), (500,"500 Challenges Completed")
//            ]
//            
//            for (m, label) in milestones where completed >= m {
//                await MainActor.run {
//                    markAchievement(label: label)
//                }
//            }
//        }
//        
//        // Keep the existing toggleDay method for backward compatibility, but mark it as deprecated
//        @available(*, deprecated, message: "Use markDayCompleted or markDayMissed instead")
//        func toggleDay(for clientId: UUID, day: Int) {
//            guard let idx = activeChallenges.firstIndex(where: { $0.id == clientId }),
//                  day >= 0, day < activeChallenges[idx].dailyCompletion.count else { return }
//
//            let prevCompleted = activeChallenges[idx].isCompleted
//            activeChallenges[idx].dailyCompletion[day].toggle()
//            let newValue = activeChallenges[idx].dailyCompletion[day]
//            let nowCompleted = activeChallenges[idx].isCompleted
//            let uaId = activeChallenges[idx].userActiveId
//
//            Task {
//                do {
//                    try await SupabaseChallengesManager.shared
//                        .upsertDailyToggle(userActiveId: uaId, dayIndex: day, newValue: newValue)
//
//                    if !prevCompleted && nowCompleted {
//                        await markCompletionMilestones()
//                        let completed = activeChallenges.filter { $0.isCompleted }.count
//                        let unlocks: [(Int, String, String)] = [
//                            (1,"1 Challenge Completed","checkmark.seal.fill"),
//                            (10,"10 Challenges Completed","10.circle.fill"),
//                            (50,"50 Challenges Completed","50.circle.fill"),
//                            (100,"100 Challenges Completed","trophy.fill"),
//                            (200,"200 Challenges Completed","rosette"),
//                            (300,"300 Challenges Completed","star.circle.fill"),
//                            (400,"400 Challenges Completed","medal.fill"),
//                            (500,"500 Challenges Completed","crown.fill")
//                        ]
//                        for (threshold, label, icon) in unlocks where completed >= threshold {
//                            try? await SupabaseChallengesManager.shared.upsertAchievement(
//                                label: label, icon: icon, colorHex: "#06B6D4", earnedBy: ownerName
//                            )
//                        }
//                    }
//                    
//                    await MainActor.run {
//                        refreshDerivedState()
//                    }
//                } catch {
//                    print("Toggle day failed:", error.localizedDescription)
//                    activeChallenges[idx].dailyCompletion[day].toggle() // revert
//                }
//            }
//        }
    func markDayCompleted(for clientId: UUID, day: Int) {
            print("🔵 markDayCompleted called for challenge \(clientId), day \(day)")
            
            guard let idx = activeChallenges.firstIndex(where: { $0.id == clientId }),
                  day >= 0, day < activeChallenges[idx].dailyCompletion.count else {
                print("❌ Invalid challenge or day index")
                return
            }
            
            // Update the state immediately for UI responsiveness
            let prevCompleted = activeChallenges[idx].isCompleted
            activeChallenges[idx].dailyCompletion[day] = true
            let nowCompleted = activeChallenges[idx].isCompleted
            let uaId = activeChallenges[idx].userActiveId
            
            print("✅ UI updated - Day \(day + 1) marked as completed")
            
            // Add haptic feedback
            SoftSound.play()
            
            Task {
                do {
                    try await SupabaseManager.shared.client.auth.session
                    
                    try await SupabaseChallengesManager.shared
                        .upsertDailyToggle(userActiveId: uaId, dayIndex: day, newValue: true)
                    
                    print("✅ Database updated - Day \(day + 1) marked as completed")
                    
                    // Check for challenge completion achievements
                    if !prevCompleted && nowCompleted {
                        await markCompletionMilestones()
                        let completed = activeChallenges.filter { $0.isCompleted }.count
                        
                        // Achievement unlocks
                        let unlocks: [(Int, String, String)] = [
                            (1,"1 Challenge Completed","checkmark.seal.fill"),
                            (10,"10 Challenges Completed","10.circle.fill"),
                            (50,"50 Challenges Completed","50.circle.fill"),
                            (100,"100 Challenges Completed","trophy.fill"),
                            (200,"200 Challenges Completed","rosette"),
                            (300,"300 Challenges Completed","star.circle.fill"),
                            (400,"400 Challenges Completed","medal.fill"),
                            (500,"500 Challenges Completed","crown.fill")
                        ]
                        
                        for (threshold, label, icon) in unlocks where completed >= threshold {
                            try? await SupabaseChallengesManager.shared.upsertAchievement(
                                label: label, icon: icon, colorHex: "#06B6D4", earnedBy: ownerName
                            )
                        }
                    }
                    
                    await MainActor.run {
                        self.refreshDerivedState()
                    }
                } catch {
                    print("❌ Database update failed: \(error.localizedDescription)")
                    // Revert the change on error
                    await MainActor.run {
                        self.activeChallenges[idx].dailyCompletion[day] = false
                    }
                }
            }
        }
        
        /// Mark a specific day as missed (No button)
        func markDayMissed(for clientId: UUID, day: Int) {
            print("🔴 markDayMissed called for challenge \(clientId), day \(day)")
            
            guard let idx = activeChallenges.firstIndex(where: { $0.id == clientId }),
                  day >= 0, day < activeChallenges[idx].dailyCompletion.count else {
                print("❌ Invalid challenge or day index")
                return
            }
            
            // Update the state immediately for UI responsiveness
            activeChallenges[idx].dailyCompletion[day] = false
            let uaId = activeChallenges[idx].userActiveId
            
            print("✅ UI updated - Day \(day + 1) marked as missed")
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            Task {
                do {
                    try await SupabaseManager.shared.client.auth.session
                    
                    try await SupabaseChallengesManager.shared
                        .upsertDailyToggle(userActiveId: uaId, dayIndex: day, newValue: false)
                    
                    print("✅ Database updated - Day \(day + 1) marked as missed")
                    
                    await MainActor.run {
                        self.refreshDerivedState()
                    }
                } catch {
                    print("❌ Database update failed: \(error.localizedDescription)")
                    // Revert the change on error
                    await MainActor.run {
                        self.activeChallenges[idx].dailyCompletion[day] = true
                    }
                }
            }
        }
        
        // Make markCompletionMilestones public and async
        func markCompletionMilestones() async {
            let completed = activeChallenges.filter { $0.isCompleted }.count
            let milestones: [(Int, String)] = [
                (1,"1 Challenge Completed"), (10,"10 Challenges Completed"),
                (50,"50 Challenges Completed"), (100,"100 Challenges Completed"),
                (200,"200 Challenges Completed"), (300,"300 Challenges Completed"),
                (400,"400 Challenges Completed"), (500,"500 Challenges Completed")
            ]
            
            for (m, label) in milestones where completed >= m {
                await MainActor.run {
                    self.markAchievement(label: label)
                }
            }
        }
        
        // Make markAchievement accessible if needed
        private func markAchievement(label: String) {
            if let i = achievements.firstIndex(where: { $0.label == label }), achievements[i].earned == false {
                achievements[i].earned = true
                achievements[i].earnedDate = Date()
                achievements[i].earnedBy = ownerName
                justUnlocked = achievements[i]
            }
        }
}

// MARK: - Updated ChallengesView
