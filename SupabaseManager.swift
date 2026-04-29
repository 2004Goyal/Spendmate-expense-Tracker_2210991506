//
//  SupabaseManager.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 09/07/25.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://rpxjmgltnazchqjvzlqk.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJweGptZ2x0bmF6Y2hxanZ6bHFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5OTk1OTgsImV4cCI6MjA2NzU3NTU5OH0.zBWw-0S_41g-SlPvkZcUppl-BQQU1l10Wn-uX1rpuX8"
        )
    }
}
extension SupabaseManager {
    struct LeaderboardRow: Decodable {
        let user_id: UUID
        let full_name: String
        let initials: String
        let completed_count: Int
        let points: Int
        let rnk: Int
    }
}

// MARK: - API Calls used by Challenges screen

extension SupabaseManager {
    /// Calls your SQL function: get_leaderboard(limit_count int)
    func fetchLeaderboard(limit: Int = 50) async throws -> [LeaderboardRow] {
        let rows: [LeaderboardRow] = try await client
            .rpc("get_leaderboard", params: ["limit_count": limit])
            .execute()
            .value
        return rows
    }
}
