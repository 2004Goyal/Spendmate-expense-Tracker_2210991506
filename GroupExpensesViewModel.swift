//
//  GroupExpensesViewModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 04/08/25.
//

import Foundation
import Supabase

class GroupExpensesViewModel: ObservableObject {
    @Published var groups: [GroupModel] = []

    private let client = SupabaseManager.shared.client

    func fetchGroups(currentUserID: String) {
        Task {
            do {
                let groupList: [GroupModel] = try await client
                    .from("groups")
                    .select()
                    .contains("members", value: [currentUserID])
                    .execute()
                    .value

                DispatchQueue.main.async {
                    self.groups = groupList
                }
            } catch {
                print("❌ Error fetching groups:", error)
            }
        }
    }
}
