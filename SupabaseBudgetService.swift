//
//  SupabaseBudgetService.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 16/07/25.
//

import Foundation
import SwiftUI
import Supabase

final class SupabaseBudgetService {
    static let shared = SupabaseBudgetService()
    private init() {}

    func fetchBudget(for userId: UUID, month: String) async throws -> [String: Double] {
        try await ExpensesService.shared.fetchBudget(for: userId, month: month)
    }

    func fetchExpenses(for userId: UUID, month: String) async throws -> [String: Double] {
        try await ExpensesService.shared.fetchExpenses(for: userId, month: month)
    }

    func addExpense(userId: UUID, category: String, amount: Double, notes: String? = nil) async throws {
        try await ExpensesService.shared.addExpense(userId: userId, category: category, amount: amount, notes: notes)
    }
}
