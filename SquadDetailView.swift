//
//  SquadDetailView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 30/06/25.
//

import SwiftUI

struct GroupInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let type: String
    let members: [String]
    var expenses: [ExpenseInfo] = []
}

struct ExpenseInfo: Identifiable, Hashable {
    let id: UUID
    let title: String
    let amount: Double
    let paidBy: String
    let splitType: String
    let sharedWith: [String]
    let groupId: String
    let createdAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        paidBy: String,
        splitType: String,
        sharedWith: [String],
        groupId: String,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.paidBy = paidBy
        self.splitType = splitType
        self.sharedWith = sharedWith
        self.groupId = groupId
        self.createdAt = createdAt
    }
}

struct Expense: Decodable {
    let id: String
    let title: String
    let amount: Double
    let paid_by: String
    let split_type: String
    let shared_with: [String]
    let group_id: String
    let created_at: String
}

struct GroupBalancesView: View {
    @Binding var selectedGroup: GroupInfo?
    @EnvironmentObject var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab = "Balances"
    @State private var groupExpenses: [ExpenseInfo] = []

    // NEW: navigation to Add Expense (now via floating button)
    @State private var showAddExpenseView = false
    
    // NEW: navigation to Edit Group
    @State private var showEditGroupView = false

    // Settlement state
    @State private var selectedPayee: String = ""
    @State private var selectedAmount: Double = 0.0

    let tabs = ["Balances", "Totals", "Settle Up"]

    var body: some View {
        ZStack {
            if let group = selectedGroup {
                VStack(spacing: 0) {
                    topBar(group)

                    // Hidden nav push to Add Expense
                    NavigationLink(
                        destination: AddGroupExpenseView(selectedGroup: $selectedGroup),
                        isActive: $showAddExpenseView
                    ) { EmptyView() }
                    
                    // Hidden nav push to Edit Group
                    NavigationLink(
                        destination: EditGroupView(selectedGroup: $selectedGroup),
                        isActive: $showEditGroupView
                    ) { EmptyView() }

                    Spacer().frame(height: 12)
                    tabSwitcher
                    Spacer().frame(height: 12)
                    summaryCard
                    contentSection
                    Spacer(minLength: 8)
                }
                
                // Floating Action Button for Add Expense
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showAddExpenseView = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color("PeacockBlue"))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
                
            } else {
                Text("❌ No group selected").foregroundColor(.red)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .task(id: selectedGroup?.id) {
            if let group = selectedGroup {
                fetchExpenses(for: group.id) { self.groupExpenses = $0 }
            }
        }
        // Refresh after returning from Add Expense
        .onChange(of: showAddExpenseView) { isOpen in
            if !isOpen, let g = selectedGroup {
                fetchExpenses(for: g.id) { self.groupExpenses = $0 }
            }
        }
        // Refresh after returning from Edit Group
        .onChange(of: showEditGroupView) { isOpen in
            if !isOpen, let g = selectedGroup {
                // Optionally refresh group data or handle updates
                fetchExpenses(for: g.id) { self.groupExpenses = $0 }
            }
        }
    }

    // MARK: - Top Bar (with pencil button for editing)
    func topBar(_ group: GroupInfo) -> some View {
        VStack(spacing: 4) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                }
                Spacer()
                VStack(spacing: 2) {
                    Text(group.name).font(.headline).foregroundColor(.white)
                    Text("Created \(Date(), format: .dateTime.month().year())")
                        .font(.caption).foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                // NEW: pencil button to edit group
                Button {
                    showEditGroupView = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color("PeacockBlue"))
    }

    // MARK: - Segmented Control
    var tabSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(selectedTab == tab ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == tab ? Color(hex: "#0097A7") : Color.clear)
                        .cornerRadius(10)
                }
            }
        }
        .padding(6)
        .background(Color("MistyAqua"))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Summary card (Group Total + Your Balance)
    var summaryCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Group Total").font(.subheadline).foregroundColor(.gray)
                Text("₹\(Int(totalSpending))").font(.headline)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Your Balance").font(.subheadline).foregroundColor(.gray)
                Text(signedAmount(yourBalance))
                    .font(.headline)
                    .foregroundColor(yourBalance >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Per-tab content
    @ViewBuilder
    var contentSection: some View {
        let currentUser = userProfile.fullName.isEmpty ? "You" : userProfile.fullName

        switch selectedTab {
        case "Balances":
            WhoOwesWhomView(
                expenses: groupExpenses,
                currentUser: currentUser,
                selectedPayee: $selectedPayee,
                selectedAmount: $selectedAmount,
                showSettleUp: .constant(false) // we'll navigate into the tab below
            )
            .onChange(of: selectedAmount) { _ in
                // When user taps "Settle Up" on a balance row, jump to the Settle Up tab
                if selectedAmount > 0 { selectedTab = "Settle Up" }
            }
            .padding(.top, 6)

        case "Totals":
            GroupSummaryView(expenses: groupExpenses, currentUser: currentUser)
                .padding(.top, 6)

        case "Settle Up":
            if selectedPayee.isEmpty || selectedAmount <= 0 {
                Text("Select a balance from the Balances tab to settle.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // Embed SettleUpView UI directly like screenshot 2
                SettleUpView(
                    groupID: selectedGroup?.id ?? "",
                    payeeName: selectedPayee,
                    amountOwed: selectedAmount
                )
                .environmentObject(userProfile)
            }

        default:
            EmptyView()
        }
    }

    // MARK: - Metrics
    var totalSpending: Double {
        groupExpenses.reduce(0) { $0 + $1.amount }
    }
    var yourContribution: Double {
        let me = userProfile.fullName.isEmpty ? "You" : userProfile.fullName
        return groupExpenses.filter { $0.paidBy == me }.reduce(0) { $0 + $1.amount }
    }
    var yourShare: Double {
        let me = userProfile.fullName.isEmpty ? "You" : userProfile.fullName
        return groupExpenses
            .filter { $0.sharedWith.contains(me) }
            .reduce(0) { $0 + ($1.amount / Double(max($1.sharedWith.count, 1))) }
    }
    var yourBalance: Double { yourContribution - yourShare }

    func signedAmount(_ v: Double) -> String {
        let n = Int(v.rounded())
        return (v >= 0 ? "+" : "") + "₹\(n)"
    }

    // MARK: - Fetch
    func fetchExpenses(for groupId: String, completion: @escaping ([ExpenseInfo]) -> Void) {
        Task {
            do {
                let rows: [Expense] = try await SupabaseManager.shared.client
                    .from("Expenses")
                    .select("*")
                    .eq("group_id", value: groupId)
                    .order("created_at", ascending: false)
                    .execute()
                    .value

                let converted: [ExpenseInfo] = rows.compactMap { exp in
                    guard let uuid = UUID(uuidString: exp.id) else { return nil }
                    let formatter = ISO8601DateFormatter()
                    return ExpenseInfo(
                        id: uuid,
                        title: exp.title,
                        amount: exp.amount,
                        paidBy: exp.paid_by,
                        splitType: exp.split_type,
                        sharedWith: exp.shared_with,
                        groupId: exp.group_id,
                        createdAt: formatter.date(from: exp.created_at)
                    )
                }

                DispatchQueue.main.async { completion(converted) }
            } catch {
                print("❌ Error fetching expenses: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }
    }
}
