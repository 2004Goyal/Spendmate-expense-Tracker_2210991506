//
//  BudgetModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 07/07/25.
//

import Foundation
import SwiftUI
import Combine

final class ExpensesService {
    static let shared = ExpensesService()
    private init() {}
    let client = SupabaseManager.shared.client

    // ✅ Scoped models (no global collisions)
    struct Row: Codable, Identifiable {
        let id: UUID
        let userId: UUID
        let category: String
        let amount: Double
        let date: String      // "yyyy-MM-dd"
        let notes: String?

        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case category, amount, date, notes
        }
    }

    struct Insert: Encodable {
        let user_id: String
        let category: String
        let amount: Double
        let date: String      // "yyyy-MM-dd"
        let notes: String?
    }

    // MARK: - API

    /// Budget fetch that tolerates 0 or multiple rows (no `.single()`).
    /// Returns zeros if no row exists for (user_id, month).
    func fetchBudget(for userId: UUID, month: String) async throws -> [String: Double] {
        let resp = try await client
            .from("budgets")                   // change if your table is named differently
            .select()                          // returns an array
            .eq("user_id", value: userId.uuidString)
            .eq("month", value: month)         // "yyyy-MM"
            .limit(1)                          // avoid PGRST116
            .execute()

        guard
            let arr = try JSONSerialization.jsonObject(with: resp.data) as? [[String: Any]],
            let json = arr.first
        else {
            return zeroBudget()
        }

        // Be lenient with number types
        func num(_ key: String) -> Double {
            if let d = json[key] as? Double { return d }
            if let n = json[key] as? NSNumber { return n.doubleValue }
            if let s = json[key] as? String, let d = Double(s) { return d }
            return 0
        }

        // Some projects used "others" earlier → map to misc
        let misc = max(num("misc"), num("others"))

        return [
            "food": num("food"),
            "travel": num("travel"),
            "entertainment": num("entertainment"),
            "shopping": num("shopping"),
            "misc": misc
        ]
    }

    /// Category totals for a month ("yyyy-MM"), normalized to canonical keys:
    /// Food, Travel, Entertainment, Shopping, Misc
    func fetchExpenses(for userId: UUID, month: String) async throws -> [String: Double] {
        let from = "\(month)-01"
        let to   = "\(month)-31"

        let rows: [Row] = try await client
            .from("expenses")
            .select()
            .eq("user_id", value: userId.uuidString)
            .gte("date", value: from)
            .lte("date", value: to)
            .order("date", ascending: false)
            .execute()
            .value

        var totals: [String: Double] = [:]
        for row in rows {
            let key = canonicalCategory(row.category)
            totals[key, default: 0] += row.amount
        }
        return totals
    }

    func addExpense(userId: UUID, category: String, amount: Double, notes: String? = nil) async throws {
        let payload = Insert(
            user_id: userId.uuidString,
            category: canonicalCategory(category),
            amount: amount,
            date: DateFormatter.yyyyMMdd.string(from: Date()),
            notes: notes
        )

        try await client
            .from("expenses")
            .insert(payload)
            .execute()
    }

    // MARK: - Helpers

    /// Map whatever comes from UI/DB to canonical dashboard keys.
    internal func canonicalCategory(_ raw: String) -> String {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch s {
        case "food": return "Food"
        case "travel", "transport", "commute": return "Travel"
        case "entertainment", "movies", "fun": return "Entertainment"
        case "shopping": return "Shopping"
        case "misc", "others", "other", "miscellaneous": return "Misc"
        default: return "Misc"
        }
    }

    private func zeroBudget() -> [String: Double] {
        ["food": 0, "travel": 0, "entertainment": 0, "shopping": 0, "misc": 0]
    }
}

// MARK: - Shared formatters (ensure you have this extension only once in the project)
extension DateFormatter {
    static let yyyyMM: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()

    static let yyyyMMdd: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
}
