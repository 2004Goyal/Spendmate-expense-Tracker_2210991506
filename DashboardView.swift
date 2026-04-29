//
//  DashboardView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI

//struct NotificationsView: View {
//    var body: some View {
//        NavigationStack {
//            List { Label("No notifications yet", systemImage: "bell.slash") }
//                .navigationTitle("Notifications")
//                .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//struct DashboardView: View {
//    @State private var showMica = false
//    @EnvironmentObject var spendingModel: SpendingModel     // expenses (spent)
//    @EnvironmentObject var budgetModel: BudgetModel         // 🔹 limits from Planner
//    @EnvironmentObject var userProfile: UserProfile
//
//    @State private var showNotifications = false
//    @State private var hasUnreadNotifications = false
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                VStack(spacing: 0) {
//                    // Top Bar
//                    HStack {
//                        Text("Hi, \(userProfile.fullName)")
//                            .font(.title2.bold())
//                            .foregroundColor(.white)
//                        Spacer()
//                        HStack(spacing: 16) {
//                            Button {
//                                showNotifications = true
//                                hasUnreadNotifications = false
//                            } label: {
//                                ZStack(alignment: .topTrailing) {
//                                    Image(systemName: "bell")
//                                        .foregroundColor(.white)
//                                        .imageScale(.large)
//                                    if hasUnreadNotifications {
//                                        Circle().fill(Color.red).frame(width: 8, height: 8).offset(x: 6, y: -6)
//                                    }
//                                }
//                            }
//                            .accessibilityLabel("Notifications")
//
//                            NavigationLink(destination: ProfileView()) {
//                                Image(systemName: "person.crop.circle")
//                                    .resizable().frame(width: 28, height: 28)
//                                    .foregroundColor(.white)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color("PeacockBlue"))
//
//                    Spacer().frame(height: 16)
//
//                    ScrollView {
//                        VStack(alignment: .leading, spacing: 24) {
//                            // Days Left & Daily Limit
//                            let calendar = Calendar.current
//                            let today = Date()
//                            let totalDays = calendar.range(of: .day, in: .month, for: today)?.count ?? 30
//                            let currentDay = calendar.component(.day, from: today)
//                            let daysLeft = max(totalDays - currentDay, 0)
//
//                            // 🔹 Limits from Planner (BudgetModel), Spent from SpendingModel
//                            let totalSpendingLimit =
//                                budgetModel.food +
//                                budgetModel.travel +
//                                budgetModel.entertainment +
//                                budgetModel.shopping +
//                                budgetModel.misc
//
//                            let totalSpent =
//                                spendingModel.foodSpent +
//                                spendingModel.travelSpent +
//                                spendingModel.entertainmentSpent +
//                                spendingModel.shoppingSpent +
//                                spendingModel.miscSpent
//
//                            let dailyLimit = daysLeft > 0 ? Int(totalSpendingLimit / Double(daysLeft)) : 0
//
//                            // Info Cards
//                            HStack(spacing: 10) {
//                                InfoCard(title: "Total Expense This Month", value: "₹\(Int(totalSpent))")
//                                InfoCard(title: "Days Left / Daily Limit", value: "\(daysLeft) Days / ₹\(dailyLimit)")
//                            }
//
//                            // Category Spend
//                            VStack(alignment: .leading, spacing: 16) {
//                                Text("Category Spend")
//                                    .font(.headline)
//                                    .foregroundColor(Color("Charcoal"))
//
//                                VStack(spacing: 18) {
//                                    SpendBar(category: "Food",          amount: Int(spendingModel.foodSpent),          limit: Int(budgetModel.food),          color: Color("CaribbeanTeal"))
//                                    SpendBar(category: "Travel",        amount: Int(spendingModel.travelSpent),        limit: Int(budgetModel.travel),        color: Color("PeacockBlue"))
//                                    SpendBar(category: "Entertainment", amount: Int(spendingModel.entertainmentSpent), limit: Int(budgetModel.entertainment), color: Color("SeaGreen"))
//                                    SpendBar(category: "Shopping",      amount: Int(spendingModel.shoppingSpent),      limit: Int(budgetModel.shopping),      color: Color("Orange"))
//                                    SpendBar(category: "Misc",          amount: Int(spendingModel.miscSpent),          limit: Int(budgetModel.misc),          color: Color("DeepTeal"))
//
//                                    // Overspending warnings (compare Spent vs Planner limits)
//                                    if spendingModel.foodSpent          >= budgetModel.food ||
//                                       spendingModel.travelSpent        >= budgetModel.travel ||
//                                       spendingModel.entertainmentSpent >= budgetModel.entertainment ||
//                                       spendingModel.shoppingSpent      >= budgetModel.shopping ||
//                                       spendingModel.miscSpent          >= budgetModel.misc {
//                                        Text("⚠️ You're overspending in one or more categories!")
//                                            .font(.footnote).foregroundColor(.red).padding(.top, 8)
//                                    }
//
//                                    if totalSpent > totalSpendingLimit {
//                                        Text("🚨 You're spending more than your total budget!")
//                                            .font(.footnote).foregroundColor(.red).padding(.top, 4)
//                                    }
//                                }
//                            }
//
//                            // Buttons
//                            VStack(spacing: 18) {
//                                NavigationLink(
//                                    destination: AddExpenseView { category, amount in
//                                        if let userIdStr = userProfile.id,
//                                           let userUUID = UUID(uuidString: userIdStr) {
//                                            Task {
//                                                await spendingModel.addExpense(userId: userUUID,
//                                                                               category: category,
//                                                                               amount: Double(amount))
//                                                await budgetModel.loadData(userId: userUUID)
//                                                await spendingModel.loadRecentExpenses(userId: userUUID) // ⬅️ refresh recents
//                                            }
//                                        }
//                                    }
//                                ) {
//                                    DashboardButton(title: "Add Expense", icon: "plus")
//                                }
//
//                                NavigationLink(destination: MonthlyReportView()) {
//                                    DashboardButton(title: "View Reports", icon: "doc.text")
//                                }
//
//                                NavigationLink(destination: ChallengesView()) {
//                                    DashboardButton(title: "Challenges", icon: "trophy")
//                                }
//                            }
//                            .padding(.top, 12)
//
//                            // -----------------------------------------
//                            // HISTORY (Below the Challenges button)
//                            // -----------------------------------------
//                            VStack(alignment: .leading, spacing: 10) {
//                                HStack {
//                                    Text("History")
//                                        .font(.headline)
//                                        .foregroundColor(Color("Charcoal"))
//                                    Spacer()
//                                    NavigationLink(destination: ExpensesHistoryView()) {
//                                        Text("See All")
//                                            .font(.subheadline.weight(.semibold))
//                                            .foregroundColor(Color("PeacockBlue"))
//                                    }
//                                }
//
//                                if spendingModel.recentExpenses.isEmpty {
//                                    Text("No expenses yet. Start by adding one!")
//                                        .font(.footnote)
//                                        .foregroundColor(.secondary)
//                                } else {
//                                    VStack(spacing: 10) {
//                                        ForEach(spendingModel.recentExpenses.prefix(3)) { row in
//                                            ExpenseRowView(row: row)
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.top, 8)
//                        }
//                        .padding(.horizontal, 24)
//                        .padding(.bottom, 80)
//                    }
//                }
//
//                // MICA Floating Button
//                VStack {
//                    Spacer()
//                    HStack {
//                        Spacer()
//                        Button(action: { showMica = true }) {
//                            ZStack {
//                                Circle().fill(Color.white.opacity(0.95)).frame(width: 64, height: 64)
//                                    .shadow(color: .gray.opacity(0.3), radius: 6, x: 0, y: 3)
//                                Image(systemName: "message.circle.fill")
//                                    .resizable().frame(width: 40, height: 40)
//                                    .foregroundColor(Color("CaribbeanTeal"))
//                                    .scaleEffect(1.1)
//                                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: UUID())
//                            }
//                        }
//                        .padding(.trailing, 24)
//                        .padding(.bottom, 24)
//                        .sheet(isPresented: $showMica) { MicaChatView() }
//                    }
//                    .onAppear {
//                        if let userIdStr = userProfile.id,
//                           let userUUID = UUID(uuidString: userIdStr) {
//                            Task {
//                                await userProfile.load(for: userIdStr)
//                                await budgetModel.loadData(userId: userUUID)
//                                await spendingModel.loadData(userId: userUUID)          // totals
//                                await spendingModel.loadRecentExpenses(userId: userUUID) // ⬅️ recents for History
//                            }
//                        }
//                    }
//                }
//            }
//            .sheet(isPresented: $showNotifications) { NotificationsView() }
//        }
//    }
//}
//
//
//
//@MainActor
//final class SpendingModel: ObservableObject {
//    // Totals (used by Dashboard meters)
//    @Published var foodSpent: Double = 0
//    @Published var travelSpent: Double = 0
//    @Published var entertainmentSpent: Double = 0
//    @Published var shoppingSpent: Double = 0
//    @Published var miscSpent: Double = 0
//
//    // NEW: Recent + full history
//    @Published var recentExpenses: [ExpenseListItem] = []
//    @Published var history: [ExpenseListItem] = []
//
//    private let service = ExpensesService.shared
//    
//
//    /// Load *totals* for the month; Planner (BudgetModel) owns limits.
//    func loadData(userId: UUID, for date: Date = .now) async {
//        let month = DateFormatter.yyyyMM.string(from: date)
//        do {
//            let totals = try await service.fetchExpenses(for: userId, month: month)
//            self.foodSpent          = totals["Food"] ?? 0
//            self.travelSpent        = totals["Travel"] ?? 0
//            self.entertainmentSpent = totals["Entertainment"] ?? 0
//            self.shoppingSpent      = totals["Shopping"] ?? 0
//            self.miscSpent          = totals["Misc"] ?? 0
//        } catch {
//            print("⚠️ SpendingModel.loadData error:", error)
//        }
//    }
//
//    func loadRecentExpenses(userId: UUID, limit: Int = 3) async {
//        do { self.recentExpenses = try await service.fetchRecentExpenses(for: userId, limit: limit) }
//        catch { print("⚠️ SpendingModel.loadRecentExpenses error:", error) }
//    }
//
//    func loadHistory(userId: UUID) async {
//        do { self.history = try await service.fetchHistory(for: userId) }
//        catch { print("⚠️ SpendingModel.loadHistory error:", error) }
//    }
//
//
//    func addExpense(userId: UUID, category: String, amount: Double, notes: String? = nil) async {
//        do {
//            try await service.addExpense(userId: userId, category: category, amount: amount, notes: notes)
//            // Refresh both totals and recents; history will refresh when user opens it
//            await loadData(userId: userId)
//            await loadRecentExpenses(userId: userId)
//        } catch {
//            print("⚠️ SpendingModel.addExpense error:", error)
//        }
//    }
//}
///////// UI-friendly item just for the History & Recents lists.
///////// Maps Supabase rows and tolerates either `description` or `notes` fields.
//struct ExpenseListItem: Identifiable, Decodable {
//    let id: UUID
//    let user_id: String?
//    let category: String
//    let amount: Double
//    let note: String?
//    let created_at: String?  // RFC3339 from Supabase
//
//    var createdAtDate: Date {
//        guard let s = created_at else { return Date() }
//        // RFC3339/ISO8601 parsing
//        let f = ISO8601DateFormatter()
//        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        return f.date(from: s) ?? ISO8601DateFormatter().date(from: s) ?? Date()
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case id, user_id, category, amount, description, notes, created_at
//    }
//
//    init(from decoder: Decoder) throws {
//        let c = try decoder.container(keyedBy: CodingKeys.self)
//        id         = try c.decode(UUID.self, forKey: .id)
//        user_id    = try c.decodeIfPresent(String.self, forKey: .user_id)
//        category   = try c.decode(String.self, forKey: .category)
//        amount     = try c.decode(Double.self, forKey: .amount)
//        // accept either "description" or "notes"
//        note       = try c.decodeIfPresent(String.self, forKey: .description)
//                   ?? c.decodeIfPresent(String.self, forKey: .notes)
//        created_at = try c.decodeIfPresent(String.self, forKey: .created_at)
//    }
//}
////
////
////// MARK: - Compact row used in Dashboard History and full History
//struct ExpenseRowView: View {
//    let row: ExpenseListItem
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            Image(systemName: icon(for: row.category))
//                .frame(width: 28, height: 28)
//                .foregroundColor(Color("CaribbeanTeal"))
//
//            VStack(alignment: .leading, spacing: 4) {
//                HStack {
//                    Text(row.category)
//                        .font(.subheadline.weight(.semibold))
//                        .foregroundColor(Color("Charcoal"))
//                    Spacer()
//                    Text("₹\(Int(row.amount))")
//                        .font(.subheadline.weight(.semibold))
//                        .foregroundColor(Color("Charcoal"))
//                }
//                Text(DateFormatter.history.string(from: row.createdAtDate))
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                if let note = row.note, !note.isEmpty {
//                    Text(note)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .lineLimit(2)
//                }
//            }
//        }
//        .padding(12)
//        .background(Color("MistyAqua").opacity(0.6))
//        .cornerRadius(12)
//    }
//
//    private func icon(for category: String) -> String {
//        switch category.lowercased() {
//        case "food": return "fork.knife"
//        case "travel": return "airplane"
//        case "entertainment": return "ticket"
//        case "shopping": return "bag"
//        case "misc": return "ellipsis.circle"
//        default: return "creditcard"
//        }
//    }
//}
//extension DateFormatter {
//    static let history: DateFormatter = {
//        let f = DateFormatter()
//        f.dateStyle = .medium
//        f.timeStyle = .short
//        return f
//    }()
//}
////
////
////// MARK: - Full history screen
//struct ExpensesHistoryView: View {
//    @EnvironmentObject var spendingModel: SpendingModel
//    @EnvironmentObject var userProfile: UserProfile
//
//    var body: some View {
//        List {
//            if spendingModel.history.isEmpty {
//                Text("No transactions yet.")
//                    .foregroundColor(.secondary)
//            } else {
//                ForEach(spendingModel.history) { row in
//                    ExpenseRowView(row: row)
//                        .listRowSeparator(.hidden)
//                        .listRowInsets(EdgeInsets())
//                        .padding(.vertical, 4)
//                }
//            }
//        }
//        .listStyle(.plain)
//        .navigationTitle("Transaction History")
//        .onAppear {
//            if let idStr = userProfile.id, let uuid = UUID(uuidString: idStr) {
//                Task { await spendingModel.loadHistory(userId: uuid) }
//            }
//        }
//    }
//}
struct NotificationsView: View {
    var body: some View {
        NavigationStack {
            List { Label("No notifications yet", systemImage: "bell.slash") }
                .navigationTitle("Notifications")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DashboardView: View {
    @State private var showMica = false
    @State private var showMicaAlert = false // NEW: Alert state for locked MICA
    @EnvironmentObject var spendingModel: SpendingModel     // expenses (spent)
    @EnvironmentObject var budgetModel: BudgetModel         // 🔹 limits from Planner
    @EnvironmentObject var userProfile: UserProfile

    @State private var showNotifications = false
    @State private var hasUnreadNotifications = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        Text("Hi, \(userProfile.fullName)")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Spacer()
                        HStack(spacing: 16) {
                            Button {
                                showNotifications = true
                                hasUnreadNotifications = false
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell")
                                        .foregroundColor(.white)
                                        .imageScale(.large)
                                    if hasUnreadNotifications {
                                        Circle().fill(Color.red).frame(width: 8, height: 8).offset(x: 6, y: -6)
                                    }
                                }
                            }
                            .accessibilityLabel("Notifications")

                            NavigationLink(destination: ProfileView()) {
                                Image(systemName: "person.crop.circle")
                                    .resizable().frame(width: 28, height: 28)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color("PeacockBlue"))

                    Spacer().frame(height: 16)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Days Left & Daily Limit
                            let calendar = Calendar.current
                            let today = Date()
                            let totalDays = calendar.range(of: .day, in: .month, for: today)?.count ?? 30
                            let currentDay = calendar.component(.day, from: today)
                            let daysLeft = max(totalDays - currentDay, 0)

                            // 🔹 Limits from Planner (BudgetModel), Spent from SpendingModel
                            let totalSpendingLimit =
                                budgetModel.food +
                                budgetModel.travel +
                                budgetModel.entertainment +
                                budgetModel.shopping +
                                budgetModel.misc

                            let totalSpent =
                                spendingModel.foodSpent +
                                spendingModel.travelSpent +
                                spendingModel.entertainmentSpent +
                                spendingModel.shoppingSpent +
                                spendingModel.miscSpent

                            let dailyLimit = daysLeft > 0 ? Int(totalSpendingLimit / Double(daysLeft)) : 0

                            // Info Cards
                            HStack(spacing: 10) {
                                InfoCard(title: "Total Expense This Month", value: "₹\(Int(totalSpent))")
                                InfoCard(title: "Days Left / Daily Limit", value: "\(daysLeft) Days / ₹\(dailyLimit)")
                            }

                            // Category Spend
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Category Spend")
                                    .font(.headline)
                                    .foregroundColor(Color("Charcoal"))

                                VStack(spacing: 18) {
                                    SpendBar(category: "Food",          amount: Int(spendingModel.foodSpent),          limit: Int(budgetModel.food),          color: Color("CaribbeanTeal"))
                                    SpendBar(category: "Travel",        amount: Int(spendingModel.travelSpent),        limit: Int(budgetModel.travel),        color: Color("PeacockBlue"))
                                    SpendBar(category: "Entertainment", amount: Int(spendingModel.entertainmentSpent), limit: Int(budgetModel.entertainment), color: Color("SeaGreen"))
                                    SpendBar(category: "Shopping",      amount: Int(spendingModel.shoppingSpent),      limit: Int(budgetModel.shopping),      color: Color("Orange"))
                                    SpendBar(category: "Misc",          amount: Int(spendingModel.miscSpent),          limit: Int(budgetModel.misc),          color: Color("DeepTeal"))

                                    // Overspending warnings (compare Spent vs Planner limits)
                                    if spendingModel.foodSpent          >= budgetModel.food ||
                                       spendingModel.travelSpent        >= budgetModel.travel ||
                                       spendingModel.entertainmentSpent >= budgetModel.entertainment ||
                                       spendingModel.shoppingSpent      >= budgetModel.shopping ||
                                       spendingModel.miscSpent          >= budgetModel.misc {
                                        Text("⚠️ You're overspending in one or more categories!")
                                            .font(.footnote).foregroundColor(.red).padding(.top, 8)
                                    }

                                    if totalSpent > totalSpendingLimit {
                                        Text("🚨 You're spending more than your total budget!")
                                            .font(.footnote).foregroundColor(.red).padding(.top, 4)
                                    }
                                }
                            }

                            // Buttons
                            VStack(spacing: 18) {
                                NavigationLink(
                                    destination: AddExpenseView { category, amount in
                                        if let userIdStr = userProfile.id,
                                           let userUUID = UUID(uuidString: userIdStr) {
                                            Task {
                                                await spendingModel.addExpense(userId: userUUID,
                                                                               category: category,
                                                                               amount: Double(amount))
                                                await budgetModel.loadData(userId: userUUID)
                                                await spendingModel.loadRecentExpenses(userId: userUUID) // ⬅️ refresh recents
                                            }
                                        }
                                    }
                                ) {
                                    DashboardButton(title: "Add Expense", icon: "plus")
                                }

                                NavigationLink(destination: MonthlyReportView()) {
                                    DashboardButton(title: "View Reports", icon: "doc.text")
                                }

                                NavigationLink(destination: ChallengesView()) {
                                    DashboardButton(title: "Challenges", icon: "trophy")
                                }
                            }
                            .padding(.top, 12)

                            // -----------------------------------------
                            // HISTORY (Below the Challenges button)
                            // -----------------------------------------
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("History")
                                        .font(.headline)
                                        .foregroundColor(Color("Charcoal"))
                                    Spacer()
                                    NavigationLink(destination: ExpensesHistoryView()) {
                                        Text("See All")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(Color("PeacockBlue"))
                                    }
                                }

                                if spendingModel.recentExpenses.isEmpty {
                                    Text("No expenses yet. Start by adding one!")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                } else {
                                    VStack(spacing: 10) {
                                        ForEach(spendingModel.recentExpenses.prefix(3)) { row in
                                            ExpenseRowView(row: row)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 80)
                    }
                }

                // MICA Floating Button (LOCKED with Alert)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Show alert instead of opening MICA
                            showMicaAlert = true
                        }) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.95)).frame(width: 64, height: 64)
                                    .shadow(color: .gray.opacity(0.3), radius: 6, x: 0, y: 3)
                                
                                // Add a subtle overlay to indicate it's locked
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 64, height: 64)
                                
                                VStack(spacing: 2) {
                                    Image(systemName: "message.circle.fill")
                                        .resizable().frame(width: 32, height: 32)
                                        .foregroundColor(Color("CaribbeanTeal"))
                                    
                                    // Small "coming soon" indicator
                                    Text("Soon")
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundColor(Color("CaribbeanTeal").opacity(0.8))
                                }
                            }
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                        // Removed the sheet for MicaChatView since it's locked
                    }
                    .onAppear {
                        if let userIdStr = userProfile.id,
                           let userUUID = UUID(uuidString: userIdStr) {
                            Task {
                                await userProfile.load(for: userIdStr)
                                await budgetModel.loadData(userId: userUUID)
                                await spendingModel.loadData(userId: userUUID)          // totals
                                await spendingModel.loadRecentExpenses(userId: userUUID) // ⬅️ recents for History
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showNotifications) { NotificationsView() }
            // NEW: Alert for locked MICA feature
            .alert("MICA AI Assistant Coming Soon", isPresented: $showMicaAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("We're working on bringing you an intelligent AI assistant to help manage your expenses and provide insights. Stay tuned for future updates!")
            }
        }
    }
}

@MainActor
final class SpendingModel: ObservableObject {
    // Totals (used by Dashboard meters)
    @Published var foodSpent: Double = 0
    @Published var travelSpent: Double = 0
    @Published var entertainmentSpent: Double = 0
    @Published var shoppingSpent: Double = 0
    @Published var miscSpent: Double = 0

    // NEW: Recent + full history
    @Published var recentExpenses: [ExpenseListItem] = []
    @Published var history: [ExpenseListItem] = []

    private let service = ExpensesService.shared
    

    /// Load *totals* for the month; Planner (BudgetModel) owns limits.
    func loadData(userId: UUID, for date: Date = .now) async {
        let month = DateFormatter.yyyyMM.string(from: date)
        do {
            let totals = try await service.fetchExpenses(for: userId, month: month)
            self.foodSpent          = totals["Food"] ?? 0
            self.travelSpent        = totals["Travel"] ?? 0
            self.entertainmentSpent = totals["Entertainment"] ?? 0
            self.shoppingSpent      = totals["Shopping"] ?? 0
            self.miscSpent          = totals["Misc"] ?? 0
        } catch {
            print("⚠️ SpendingModel.loadData error:", error)
        }
    }

    func loadRecentExpenses(userId: UUID, limit: Int = 3) async {
        do { self.recentExpenses = try await service.fetchRecentExpenses(for: userId, limit: limit) }
        catch { print("⚠️ SpendingModel.loadRecentExpenses error:", error) }
    }

    func loadHistory(userId: UUID) async {
        do { self.history = try await service.fetchHistory(for: userId) }
        catch { print("⚠️ SpendingModel.loadHistory error:", error) }
    }


    func addExpense(userId: UUID, category: String, amount: Double, notes: String? = nil) async {
        do {
            try await service.addExpense(userId: userId, category: category, amount: amount, notes: notes)
            // Refresh both totals and recents; history will refresh when user opens it
            await loadData(userId: userId)
            await loadRecentExpenses(userId: userId)
        } catch {
            print("⚠️ SpendingModel.addExpense error:", error)
        }
    }
}

/////// UI-friendly item just for the History & Recents lists.
/////// Maps Supabase rows and tolerates either `description` or `notes` fields.
struct ExpenseListItem: Identifiable, Decodable {
    let id: UUID
    let user_id: String?
    let category: String
    let amount: Double
    let note: String?
    let created_at: String?  // RFC3339 from Supabase

    var createdAtDate: Date {
        guard let s = created_at else { return Date() }
        // RFC3339/ISO8601 parsing
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.date(from: s) ?? ISO8601DateFormatter().date(from: s) ?? Date()
    }

    enum CodingKeys: String, CodingKey {
        case id, user_id, category, amount, description, notes, created_at
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id         = try c.decode(UUID.self, forKey: .id)
        user_id    = try c.decodeIfPresent(String.self, forKey: .user_id)
        category   = try c.decode(String.self, forKey: .category)
        amount     = try c.decode(Double.self, forKey: .amount)
        // accept either "description" or "notes"
        note       = try c.decodeIfPresent(String.self, forKey: .description)
                   ?? c.decodeIfPresent(String.self, forKey: .notes)
        created_at = try c.decodeIfPresent(String.self, forKey: .created_at)
    }
}

// MARK: - Compact row used in Dashboard History and full History
struct ExpenseRowView: View {
    let row: ExpenseListItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon(for: row.category))
                .frame(width: 28, height: 28)
                .foregroundColor(Color("CaribbeanTeal"))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(row.category)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color("Charcoal"))
                    Spacer()
                    Text("₹\(Int(row.amount))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color("Charcoal"))
                }
                Text(DateFormatter.history.string(from: row.createdAtDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let note = row.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(12)
        .background(Color("MistyAqua").opacity(0.6))
        .cornerRadius(12)
    }

    private func icon(for category: String) -> String {
        switch category.lowercased() {
        case "food": return "fork.knife"
        case "travel": return "airplane"
        case "entertainment": return "ticket"
        case "shopping": return "bag"
        case "misc": return "ellipsis.circle"
        default: return "creditcard"
        }
    }
}

extension DateFormatter {
    static let history: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()
}

// MARK: - Full history screen
struct ExpensesHistoryView: View {
    @EnvironmentObject var spendingModel: SpendingModel
    @EnvironmentObject var userProfile: UserProfile

    var body: some View {
        List {
            if spendingModel.history.isEmpty {
                Text("No transactions yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(spendingModel.history) { row in
                    ExpenseRowView(row: row)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Transaction History")
        .onAppear {
            if let idStr = userProfile.id, let uuid = UUID(uuidString: idStr) {
                Task { await spendingModel.loadHistory(userId: uuid) }
            }
        }
    }
}
