//
//  DBChallengeModels.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 13/08/25.
//

import Foundation
import Supabase
import PostgREST

// MARK: - Helpers on the manager
extension SupabaseChallengesManager {
    /// Wait up to `timeout` seconds for a signed-in session (RLS: authenticated).
    @discardableResult
    func waitUntilAuthenticatedIfNeeded(timeout: TimeInterval = 5.0) async -> Bool {
        if client.auth.currentUser != nil { return true }
        let start = Date()
        while client.auth.currentUser == nil,
              Date().timeIntervalSince(start) < timeout {
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
        }
        return client.auth.currentUser != nil
    }
}

final class SupabaseChallengesManager {
    static let shared = SupabaseChallengesManager()

    // 🔧 Your project keys
    private let url = URL(string: "https://rpxjmgltnazchqjvzlqk.supabase.co")!
    private let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJweGptZ2x0bmF6Y2hxanZ6bHFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5OTk1OTgsImV4cCI6MjA2NzU3NTU5OH0.zBWw-0S_41g-SlPvkZcUppl-BQQU1l10Wn-uX1rpuX8"

    let client: SupabaseClient
    private init() {
        client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
    }

    var userId: UUID? { client.auth.currentUser?.id }

    // MARK: - DB models (read)
    struct DBChallenge: Decodable, Identifiable {
        let id: UUID
        let icon: String?
        let title: String
        let points: Int
        let total_days: Int
        let color_hex: String?
        let type: String // "dailyStreak" | "oneTimeTarget"
        let is_active: Bool?
        let starts_on: String? // "YYYY-MM-DD"
    }

    struct DBAchievementsRow: Decodable {
        let id: UUID
        let user_id: UUID
        let label: String
        let icon: String?
        let color_hex: String?
        let earned: Bool
        let earned_at: String?
        let earned_by: String?
    }

    struct DBUserActive: Decodable, Identifiable {
        let id: UUID
        let user_id: UUID
        let challenge_id: UUID
        let start_date: Date
    }

    struct DBDaily: Decodable {
        let id: UUID
        let user_active_id: UUID
        let day_index: Int
        let is_done: Bool
    }

    struct DBLeaderboardRow: Decodable {
        let user_id: UUID
        let name: String
        let initials: String?
        let completed_count: Int
        let points: Int
        let rnk: Int
    }

    // MARK: - Encodable payloads (write)
    private struct InsertUserActive: Encodable {
        let user_id: UUID
        let challenge_id: UUID
        let start_date: Date
    }
    private struct UpsertDaily: Encodable {
        let user_active_id: UUID
        let day_index: Int
        let is_done: Bool
    }
    private struct UpsertAchievement: Encodable {
        let user_id: UUID
        let label: String
        let icon: String
        let color_hex: String
        let earned: Bool
        let earned_at: Date
        let earned_by: String?
    }

    // MARK: - Queries

    /// Catalog of active challenges whose `starts_on` is null or <= today.
    func fetchCatalogChallenges() async throws -> [DBChallenge] {
        let df = DateFormatter()
        df.calendar = .init(identifier: .gregorian)
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"
        let today = df.string(from: Date())

        let rows: [DBChallenge] = try await client.database
            .from("challenges")
            .select()
            .eq("is_active", value: true)
            .or("starts_on.is.null,starts_on.lte.\(today)")
            .order("starts_on", ascending: true)
            .limit(50)
            .execute()
            .value

        return rows
    }

    /// All actives + daily progress for current user
    func fetchUserActiveChallenges() async throws
    -> [(ua: DBUserActive, ch: DBChallenge, days: [DBDaily])] {
        guard let uid = userId else { return [] }

        let actives: [DBUserActive] = try await client.database
            .from("user_active_challenges")
            .select()
            .eq("user_id", value: uid)
            .order("start_date", ascending: false)
            .limit(60)
            .execute()
            .value

        if actives.isEmpty { return [] }

        let challenges: [DBChallenge] = try await client.database
            .from("challenges")
            .select()
            .in("id", value: actives.map(\.challenge_id))
            .execute()
            .value

        let allDaily: [DBDaily] = try await client.database
            .from("user_daily_progress")
            .select()
            .in("user_active_id", value: actives.map(\.id))
            .order("day_index", ascending: true)
            .execute()
            .value

        let chMap = Dictionary(uniqueKeysWithValues: challenges.map { ($0.id, $0) })
        let dailyGrouped = Dictionary(grouping: allDaily, by: { $0.user_active_id })

        return actives.compactMap { ua in
            guard let ch = chMap[ua.challenge_id] else { return nil }
            return (ua, ch, dailyGrouped[ua.id] ?? [])
        }
    }

    /// Join a challenge
    func joinChallenge(_ challenge: DBChallenge, startDate: Date = Date()) async throws -> DBUserActive {
        guard let uid = userId else { throw NSError(domain: "auth", code: 401) }
        let payload = InsertUserActive(user_id: uid, challenge_id: challenge.id, start_date: startDate)
        let row: DBUserActive = try await client.database
            .from("user_active_challenges")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
        return row
    }

    /// Toggle a day (upsert unique (user_active_id, day_index))
    func upsertDailyToggle(userActiveId: UUID, dayIndex: Int, newValue: Bool) async throws {
        let payload = UpsertDaily(user_active_id: userActiveId, day_index: dayIndex, is_done: newValue)
        _ = try await client.database
            .from("user_daily_progress")
            .upsert(payload)
            .execute()
    }

    /// User achievements (read)
    func fetchUserAchievements() async throws -> [DBAchievementsRow] {
        guard let uid = userId else { return [] }
        let rows: [DBAchievementsRow] = try await client.database
            .from("user_achievements")
            .select()
            .eq("user_id", value: uid)
            .execute()
            .value
        return rows
    }

    /// Upsert earned achievement
    func upsertAchievement(label: String, icon: String, colorHex: String, earnedBy: String?) async throws {
        guard let uid = userId else { return }
        let payload = UpsertAchievement(
            user_id: uid, label: label, icon: icon, color_hex: colorHex,
            earned: true, earned_at: Date(), earned_by: earnedBy ?? "You"
        )
        _ = try await client.database
            .from("user_achievements")
            .upsert(payload, onConflict: "user_id,label")
            .execute()
    }

    /// Leaderboard (e.g., from a SQL view)
    func fetchLeaderboard(limit: Int = 20) async throws -> [DBLeaderboardRow] {
        let rows: [DBLeaderboardRow] = try await client.database
            .from("leaderboard_view")
            .select()
            .order("points", ascending: false)
            .limit(limit)
            .execute()
            .value
        return rows
    }

    // MARK: - Server-side weekly assignment (RPC)

    /// RPC params as a single Encodable to avoid mixed-type dictionary issues.
    private struct GetAssignableParams: Encodable {
        let p_user: String
        let p_target: Int
    }

    /// Fetch challenges the server says to assign now (0..target).
    func fetchAssignableChallenges(userId: UUID, target: Int = 5) async throws -> [DBChallenge] {
        let params = GetAssignableParams(p_user: userId.uuidString, p_target: target)

        // Make the execute() generic so the response isn't Void
        let resp: PostgrestResponse<[DBChallenge]> = try await client
            .rpc("get_assignable_challenges", params: params)
            .execute()

        return resp.value   // [] if the function returns no rows
    }

    /// Insert N active challenges for the user in one go.
    func insertActiveChallenges(userId: UUID, challengeIds: [UUID], startDate: Date = Date()) async throws {
        guard !challengeIds.isEmpty else { return }
        let payloads = challengeIds.map { InsertUserActive(user_id: userId, challenge_id: $0, start_date: startDate) }
        _ = try await client.database
            .from("user_active_challenges")
            .insert(payloads)
            .execute()
    }
}
