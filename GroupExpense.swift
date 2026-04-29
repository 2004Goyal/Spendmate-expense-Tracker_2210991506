//
//  GroupExpense.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 04/08/25.
//

import Foundation

// Expense row as stored in Supabase "Expenses"
struct ExpenseRow: Codable, Identifiable {
    let id: UUID
    let title: String
    let amount: Double
    let paid_by: UUID
    let split_type: String         // "Split Equally" | "Custom Split"
    let shared_with: [String]      // array of member IDs (as String)
    let group_id: UUID
    let created_at: Date?
}

// Payload for insert
struct NewExpense: Encodable {
    let title: String
    let amount: Double
    let paid_by: UUID
    let split_type: String
    let shared_with: [String]
    let group_id: UUID
}
