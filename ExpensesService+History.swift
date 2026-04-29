//
//  ExpensesService+History.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 16/08/25.
//

import Foundation
import SwiftUI
import Supabase

private let jsonDecoder = JSONDecoder()

extension ExpensesService {
    func fetchRecentExpenses(for userId: UUID, limit: Int = 3) async throws -> [ExpenseListItem] {
        let resp = try await SupabaseManager.shared.client
            .from("expenses")                         // change to "Expenses" if your table is capitalized
            .select("*")
            .eq("user_id", value: userId.uuidString)  // keep the `value:` label
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()

        return try jsonDecoder.decode([ExpenseListItem].self, from: resp.data)
    }

    func fetchHistory(for userId: UUID) async throws -> [ExpenseListItem] {
        let resp = try await SupabaseManager.shared.client
            .from("expenses")
            .select("*")
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()

        return try jsonDecoder.decode([ExpenseListItem].self, from: resp.data)
    }
}
