//
//  AddGroupExpenseViewModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 04/08/25.
//

import Foundation
import Supabase

@MainActor
final class AddGroupExpenseViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var amount: String = ""
    @Published var splitType: String = "Split Equally"   // "Split Equally" | "Custom Split"
    @Published var sharedWith: [String] = []             // member UUID strings

    @Published var isLoading: Bool = false
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false

    private let client = SupabaseManager.shared.client

    // Payload that matches your Supabase schema
    private struct ExpenseInsert: Codable {
        let title: String
        let amount: Double
        let paid_by: UUID
        let split_type: String
        let shared_with: [String]
        let group_id: UUID
    }

    func addExpense(groupID: UUID, completion: @escaping (Bool) -> Void) {
        guard let paidByUUID = client.auth.currentUser?.id else {
            alert("Not signed in", success: false, completion)
            return
        }
        guard let amountDouble = Double(amount), amountDouble > 0 else {
            alert("Invalid amount entered", success: false, completion)
            return
        }

        let payload = ExpenseInsert(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amountDouble,
            paid_by: paidByUUID,
            split_type: splitType,
            shared_with: sharedWith,     // make sure you set this from the selected group's members
            group_id: groupID
        )

        Task {
            do {
                isLoading = true
                _ = try await client
                    .from("Expenses")     // 🔁 keep this consistent everywhere in your app
                    .insert(payload)
                    .execute()
                isLoading = false
                alert("Expense added successfully 🎉", success: true, completion)
            } catch {
                isLoading = false
                alert("Failed to add expense: \(error.localizedDescription)", success: false, completion)
                print("❌ Supabase insert error:", error)
            }
        }
    }

    private func alert(_ message: String, success: Bool, _ completion: (Bool) -> Void) {
        alertMessage = message
        showAlert = true
        completion(success)
    }
}
