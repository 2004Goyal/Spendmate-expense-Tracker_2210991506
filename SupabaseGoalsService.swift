//
//  SupabaseGoalsService.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 17/07/25.
//

import Foundation
import SwiftUI
import AnyCodable
import Supabase

// MARK: - Data Transfer Objects
struct GoalAdditionDTO: Codable {
    var amount: Double
    var date: String     // RFC3339
}

struct SupabaseGoalRowDTO: Codable, Identifiable {
    let id: UUID
    var name: String
    var target_amount: Double
    var saved_amount: Double
    var target_date: String         // RFC3339
    var additions: [GoalAdditionDTO]
    var created_at: String?         // RFC3339 from DB
}

struct SupabaseGoalInsertDTO: Codable {
    let id: UUID
    var name: String
    var target_amount: Double
    var saved_amount: Double
    var target_date: String
    var additions: [GoalAdditionDTO]
}

struct SupabaseGoalUpdateDTO: Codable {
    var name: String
    var target_amount: Double
    var saved_amount: Double
    var target_date: String
    var additions: [GoalAdditionDTO]
}

// MARK: - Supabase Goals Service
final class SupabaseGoalsService {
    static let shared = SupabaseGoalsService()
    private let client = SupabaseManager.shared.client

    private init() {}

    @discardableResult
    private func ensureSignedIn() async throws -> Session {
        try await client.auth.session
    }

    func saveGoal(_ goal: Goal) async throws {
        _ = try await ensureSignedIn()

        let insert = SupabaseGoalInsertDTO(
            id: goal.id,
            name: goal.name,
            target_amount: goal.targetAmount,
            saved_amount: goal.savedAmount,
            target_date: goal.targetDate.rfc3339String,
            additions: goal.additions.map {
                GoalAdditionDTO(amount: $0.amount, date: $0.date.rfc3339String)
            }
        )

        try await client
            .from("user_goals")
            .insert(insert) // omit user_id; DB default = auth.uid()
            .execute()
    }

    func updateGoal(_ goal: Goal) async throws {
        _ = try await ensureSignedIn()

        let update = SupabaseGoalUpdateDTO(
            name: goal.name,
            target_amount: goal.targetAmount,
            saved_amount: goal.savedAmount,
            target_date: goal.targetDate.rfc3339String,
            additions: goal.additions.map {
                GoalAdditionDTO(amount: $0.amount, date: $0.date.rfc3339String)
            }
        )

        try await client
            .from("user_goals")
            .update(update)
            .eq("id", value: goal.id.uuidString)
            .execute()
    }

    func loadGoals() async throws -> [Goal] {
        _ = try await ensureSignedIn()

        let rows: [SupabaseGoalRowDTO] = try await client
            .from("user_goals")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value

        return rows.compactMap { row in
            guard let target = parseRFC3339(row.target_date) else { return nil }
            let created = row.created_at.flatMap(parseRFC3339) ?? Date()

            let g = Goal(
                id: row.id,
                createdAt: created,
                name: row.name,
                targetAmount: row.target_amount,
                savedAmount: row.saved_amount,
                targetDate: target
            )

            g.additions = row.additions.compactMap { dto in
                guard let d = parseRFC3339(dto.date) else { return nil }
                return (dto.amount, d)
            }
            return g
        }
    }
}

// MARK: - Enhanced SupabaseGoalsService Extensions
extension SupabaseGoalsService {
    /// Enhanced save with retry logic
    func saveGoalWithRetry(_ goal: Goal, maxRetries: Int = 3) async throws {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                try await saveGoal(goal)
                return // Success
            } catch {
                lastError = error
                print("❌ Save attempt \(attempt) failed: \(error)")
                
                if attempt < maxRetries {
                    // Wait before retry (exponential backoff)
                    try await Task.sleep(nanoseconds: UInt64(attempt * 1_000_000_000))
                }
            }
        }
        
        // All retries failed
        throw lastError ?? NSError(domain: "SaveFailed", code: -1)
    }
    
    /// Check if goal exists in database
    func goalExists(id: UUID) async -> Bool {
        do {
            _ = try await ensureSignedIn()
            let rows: [SupabaseGoalRowDTO] = try await client
                .from("user_goals")
                .select()
                .eq("id", value: id.uuidString)
                .limit(1)
                .execute()
                .value
            return !rows.isEmpty
        } catch {
            print("❌ Error checking goal existence:", error)
            return false
        }
    }
}
