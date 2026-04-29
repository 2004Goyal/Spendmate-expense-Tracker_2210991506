//
//  SquadListView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 30/06/25.
//

import Foundation
import SwiftUI

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}

//// MARK: - Group Card View
struct GroupCardView: View {
    var groupName: String
    var total: String
    var settled: String
    var members: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(groupName)
                    .font(.headline)
                    .foregroundColor(.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }

            HStack(spacing: -8) {
                ForEach(members, id: \.self) { icon in
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.gray))
                }
            }

            HStack {
                Text("Total: \(total)")
                    .font(.subheadline)
                    .foregroundColor(.black)

                Spacer()

                Text("Settled: \(settled)")
                    .font(.subheadline)
                    .foregroundColor(Color("CaribbeanTeal"))
            }
        }
        .padding()
        .background(Color("MistyAqua"))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
//
//// MARK: - Activity Row
struct ActivityRow: View {
    var title: String
    var amount: String
    var date: String
    var status: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.body).bold()
                Spacer()
                Text(status)
                    .font(.caption)
                    .foregroundColor(status == "Settled" ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.4))
                    .cornerRadius(8)
            }
            HStack {
                Text(amount)
                    .font(.subheadline)
                Spacer()
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color("MistyAqua"))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}


struct GroupExpensesView: View {
    @EnvironmentObject var userProfile: UserProfile

    @State private var showCreateGroup = false
    @State private var selectedGroup: GroupInfo? = nil
    @State private var isNavigating = false
    @State private var groupList: [GroupInfo] = []
    @State private var showGroupCreatedAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Text("SquadPay")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    Spacer()
                    NavigationLink(destination:
                        CreateGroupView(
                            showGroupExpenses: $showCreateGroup,
                            onGroupCreated: { newGroup in
                                groupList.insert(newGroup, at: 0)
                                showGroupCreatedAlert = true
                            }
                        )
                    ) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color("PeacockBlue"))

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Groups")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(groupList) { group in
                            Button {
                                selectedGroup = group
                                isNavigating = true
                            } label: {
                                GroupCardView(groupName: group.name, total: "₹0", settled: "₹0", members: group.members)
                            }
                        }

                        if let group = selectedGroup {
                            Text("Recent Activity")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(group.expenses.prefix(5)) { exp in
                                ActivityRow(
                                    title: exp.title,
                                    amount: "₹\(Int(exp.amount))",
                                    date: exp.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? "-",
                                    status: "Pending"
                                )
                            }
                        }
                    }
                }

                NavigationLink(
                    destination: GroupBalancesView(selectedGroup: $selectedGroup),
                    isActive: $isNavigating
                ) { EmptyView() }
            }
            .task {
                await fetchGroups()
            }
            .alert("Group created successfully.", isPresented: $showGroupCreatedAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    
    func fetchGroups() async {
        // Get current user id from Supabase (safest source)
        guard let uid = SupabaseManager.shared.client.auth.currentUser?.id else {
            print("❌ Not signed in")
            return
        }
        let myId = uid.uuidString.lowercased() // ✅ lowercased to match policy & stored members

        do {
            // Prefer typed decode via .value
            let groups: [GroupModel] = try await SupabaseManager.shared.client
                .from("groups")
                .select("*")
                .contains("members", value: [myId])     // ✅ match text[] of lowercased UUIDs
                .order("created_at", ascending: false)
                .execute()
                .value

            self.groupList = groups.map {
                GroupInfo(id: $0.id.uuidString,
                          name: $0.name,
                          type: $0.type,
                          members: $0.members)
            }
        } catch {
            print("❌ Error fetching groups:", error)
        }
    }

}
