//
//  GroupSettlementViewModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 04/08/25.
//

import Foundation
import Supabase

@MainActor
class GroupSettlementViewModel: ObservableObject {
    @Published var isSettling: Bool = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client

    func settleUp(groupID: UUID, payerName: String, payeeName: String, amount: Double, completion: @escaping (Bool) -> Void) {
        let settlement = GroupSettlement(
            group_id: groupID,
            payer: payerName,
            payee: payeeName,
            amount: amount
        )

        Task {
            do {
                isSettling = true
                _ = try await client
                    .from("group_settlements")
                    .insert(settlement)
                    .execute()
                isSettling = false
                completion(true)
            } catch {
                print("❌ Error inserting settlement:", error)
                errorMessage = error.localizedDescription
                isSettling = false
                completion(false)
            }
        }
    }
}




