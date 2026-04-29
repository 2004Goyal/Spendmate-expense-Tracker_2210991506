//
//  PocketPlannerView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI
import UIKit
import Combine

struct PlannerView: View {
    @EnvironmentObject var budgetModel: BudgetModel
    @EnvironmentObject var userProfile: UserProfile

    @State private var pocketMoneyInput = ""
    @State private var autoBoost = false
    @State private var showSavePopup = false
    @State private var isLoading = true
    @State private var loadError: String?

    private var pocketMoney: Double { Double(pocketMoneyInput) ?? 0 }

    var body: some View {
        VStack(spacing: 0) {
            TopBarTitleOnlyView(title: "Planner")

            if isLoading {
                // Loading state
                ProgressView("Loading your budget...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Show error if data loading failed
                        if let error = loadError {
                            errorBanner(error)
                        }

                        // Pocket Money Section
                        pocketMoneySection

                        Divider()

                        // AI Split Section
                        budgetSplitSection

                        // Auto Boost Toggle
                        autoBoostToggle

                        // Save Button
                        saveButton
                    }
                    .padding()
                }
            }
        }
        .background(Color.white)
        .onAppear {
            setupUserProfile()
            Task {
                await loadBudgetData()
            }
        }
        .refreshable {
            Task {
                await loadBudgetData()
            }
        }
    }
    
    // MARK: - View Components
    
    private var pocketMoneySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pocket Money for \(DateFormatter.monthDisplayFormatter.string(from: .now))")
                .font(.title3)
                .foregroundColor(Color("Charcoal"))

            TextField("Enter amount", text: $pocketMoneyInput)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .onChange(of: pocketMoneyInput) { newValue in
                    // Update budget model when user types
                    budgetModel.pocketMoney = Double(newValue) ?? 0
                }

            if pocketMoney > 0 {
                Text("₹\(Int(pocketMoney))")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color("Charcoal"))
            }
        }
    }
    
    private var budgetSplitSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("AI-Suggested Budget Split")
                .font(.headline)
                .foregroundColor(Color("Charcoal"))

            BudgetSlider(title: "Food", income: pocketMoney, binding: $budgetModel.food)
            BudgetSlider(title: "Travel", income: pocketMoney, binding: $budgetModel.travel)
            BudgetSlider(title: "Entertainment", income: pocketMoney, binding: $budgetModel.entertainment)
            BudgetSlider(title: "Shopping", income: pocketMoney, binding: $budgetModel.shopping)
            BudgetSlider(title: "Misc", income: pocketMoney, binding: $budgetModel.misc)
        }
    }
    
    private var autoBoostToggle: some View {
        Toggle(isOn: $autoBoost) {
            VStack(alignment: .leading) {
                Text("Auto Boost")
                    .fontWeight(.medium)
                    .foregroundColor(Color("Charcoal"))
                Text("Transfers unused balance to savings")
                    .font(.caption)
                    .foregroundColor(Color("SlateGray"))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var saveButton: some View {
        Button {
            applyPlan()
        } label: {
            Text("Save Plan")
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("CaribbeanTeal"))
                .cornerRadius(12)
        }
        .alert("You saved the plan successfully.", isPresented: $showSavePopup) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .foregroundColor(.primary)
            Spacer()
            Button("Retry") {
                Task { await loadBudgetData() }
            }
            .font(.caption.bold())
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
    private func setupUserProfile() {
        if userProfile.id == nil,
           let uid = SupabaseManager.shared.client.auth.currentUser?.id {
            userProfile.id = uid.uuidString
        } else if userProfile.id == nil {
            print("⚠️ No currentUser found in Supabase auth. Make sure the user is logged in before opening Planner.")
        }
    }

    private func currentUserUUID() -> UUID? {
        if let s = userProfile.id, let u = UUID(uuidString: s) { return u }
        if let u = SupabaseManager.shared.client.auth.currentUser?.id { return u }
        return nil
    }
    
    /// Load saved budget data from Supabase
    private func loadBudgetData() async {
        await MainActor.run {
            isLoading = true
            loadError = nil
        }
        
        guard let userUUID = currentUserUUID() else {
            await MainActor.run {
                isLoading = false
                loadError = "No authenticated user found"
            }
            return
        }
        
        do {
            await budgetModel.loadData(userId: userUUID)
            
            await MainActor.run {
                // Sync the input field with loaded pocket money
                if budgetModel.pocketMoney > 0 {
                    pocketMoneyInput = String(Int(budgetModel.pocketMoney))
                }
                
                // Sync user profile with loaded pocket money
                if budgetModel.pocketMoney > 0 {
                    userProfile.monthlyIncome = Int(budgetModel.pocketMoney)
                }
                
                isLoading = false
            }
            
            print("✅ Budget data loaded successfully for user: \(userUUID)")
        } catch {
            await MainActor.run {
                isLoading = false
                loadError = "Failed to load budget data: \(error.localizedDescription)"
            }
            print("❌ Failed to load budget data:", error)
        }
    }

    private func applyPlan() {
        let amount = pocketMoney
        budgetModel.pocketMoney = amount
        userProfile.monthlyIncome = Int(amount)

        // Daily limit derived from month length
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
        budgetModel.dailyLimit = amount / Double(daysInMonth)

        // Hide keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        guard let userUUID = currentUserUUID() else {
            print("❌ No logged-in Supabase user (userProfile.id is nil and auth.currentUser is nil).")
            return
        }

        let monthKey = DateFormatter.monthKeyFormatter.string(from: .now)

        Task {
            do {
                try await SupabaseBudgetService.shared.saveBudgetPlan(
                    userId: userUUID,
                    month: monthKey,
                    pocketMoney: amount,
                    dailyLimit: budgetModel.dailyLimit,
                    categories: [
                        "Food": budgetModel.food,
                        "Travel": budgetModel.travel,
                        "Entertainment": budgetModel.entertainment,
                        "Shopping": budgetModel.shopping,
                        "Misc": budgetModel.misc
                    ]
                )
                await MainActor.run { showSavePopup = true }
                print("✅ Budget plan saved to Supabase")
            } catch {
                await MainActor.run {
                    loadError = "Failed to save budget plan: \(error.localizedDescription)"
                }
                print("❌ saveBudgetPlan failed:", error)
            }
        }
    }
}

// MARK: - Extensions remain the same

private extension DateFormatter {
    static let monthKeyFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = .init(identifier: .gregorian)
        df.locale   = .init(identifier: "en_US_POSIX")
        df.timeZone = .init(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM"
        return df
    }()

    static let monthDisplayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "LLLL"
        return df
    }()
}

struct BudgetPlanRow: Codable {
    let user_id: UUID
    let month: String
    let pocket_money: Double
    let daily_limit: Double
    let food: Double
    let travel: Double
    let entertainment: Double
    let shopping: Double
    let misc: Double
}

extension SupabaseBudgetService {
    func saveBudgetPlan(
        userId: UUID,
        month: String,
        pocketMoney: Double,
        dailyLimit: Double,
        categories: [String: Double]
    ) async throws {
        let row = BudgetPlanRow(
            user_id: userId,
            month: month,
            pocket_money: pocketMoney,
            daily_limit: dailyLimit,
            food: categories["Food"] ?? 0,
            travel: categories["Travel"] ?? 0,
            entertainment: categories["Entertainment"] ?? 0,
            shopping: categories["Shopping"] ?? 0,
            misc: categories["Misc"] ?? 0
        )

        _ = try await SupabaseManager.shared.client
            .from("budget_plans")
            .upsert(row, onConflict: "user_id,month")
            .select()
            .execute()
    }
}

struct BudgetSlider: View {
    var title: String
    var income: Double
    @Binding var binding: Double
    var isLocked: Bool = false

    private var maxValue: Double {
        let base = income / 5
        let buffer = income * 0.10
        return max(1_000, base + buffer)
    }

    private var cappedValue: Double { min(binding, maxValue) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).foregroundColor(Color("Charcoal"))
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption).foregroundColor(.gray)
                }
                Spacer()
                Text("₹\(Int(cappedValue))")
                    .foregroundColor(Color("Charcoal"))
            }

            Slider(value: $binding, in: 0...maxValue, step: 100)
                .onChange(of: income) { _ in
                    if binding > maxValue { binding = maxValue }
                }
                .tint(Color("PeacockBlue"))

            Text("Max: ₹\(Int(maxValue))")
                .font(.caption2).foregroundColor(.gray)
        }
    }
}

extension BudgetModel {
    func loadData(userId: UUID) async {
        let month = DateFormatter.monthKeyFormatter.string(from: .now)
        
        do {
            // Load saved budget plan
            let budgetPlan = try await SupabaseBudgetService.shared.fetchBudgetPlan(for: userId, month: month)
            
            // Load actual expenses for the month
            let expenses = try await SupabaseBudgetService.shared.fetchExpenses(for: userId, month: month)
            
            await MainActor.run {
                // Update budget allocations
                self.food = budgetPlan["food"] ?? 0
                self.travel = budgetPlan["travel"] ?? 0
                self.entertainment = budgetPlan["entertainment"] ?? 0
                self.shopping = budgetPlan["shopping"] ?? 0
                self.misc = budgetPlan["misc"] ?? 0
                
                // Update pocket money and daily limit
                self.pocketMoney = budgetPlan["pocket_money"] ?? 0
                self.dailyLimit = budgetPlan["daily_limit"] ?? 0
                
                // Update actual spent amounts
                self.foodSpent = expenses["Food"] ?? 0
                self.travelSpent = expenses["Travel"] ?? 0
                self.entertainmentSpent = expenses["Entertainment"] ?? 0
                self.shoppingSpent = expenses["Shopping"] ?? 0
                self.miscSpent = expenses["Misc"] ?? 0
            }
            
            print("✅ Budget data loaded successfully")
        } catch {
            print("❌ Failed to load budget data:", error)
        }
    }
}

// MARK: - SupabaseBudgetService Extensions
extension SupabaseBudgetService {
    /// Fetches the user's budget plan for a specific month
    func fetchBudgetPlan(for userId: UUID, month: String) async throws -> [String: Double] {
        let client = SupabaseManager.shared.client
        
        do {
            let response = try await client
                .from("budget_plans")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("month", value: month)
                .limit(1)
                .execute()
            
            // Parse the response
            guard let data = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
                  let row = data.first else {
                // Return empty budget if no plan exists
                return [
                    "food": 0,
                    "travel": 0,
                    "entertainment": 0,
                    "shopping": 0,
                    "misc": 0,
                    "pocket_money": 0,
                    "daily_limit": 0
                ]
            }
            
            // Helper to safely extract Double values
            func extractDouble(_ key: String) -> Double {
                if let value = row[key] as? Double { return value }
                if let value = row[key] as? NSNumber { return value.doubleValue }
                if let value = row[key] as? String, let double = Double(value) { return double }
                return 0
            }
            
            return [
                "food": extractDouble("food"),
                "travel": extractDouble("travel"),
                "entertainment": extractDouble("entertainment"),
                "shopping": extractDouble("shopping"),
                "misc": extractDouble("misc"),
                "pocket_money": extractDouble("pocket_money"),
                "daily_limit": extractDouble("daily_limit")
            ]
            
        } catch {
            print("❌ Error fetching budget plan:", error)
            throw error
        }
    }
}

// MARK: - Updated PlannerView with Data Loading
extension PlannerView {
    /// Load saved budget data when view appears
    func loadSavedBudgetData() async {
        guard let userUUID = currentUserUUID() else {
            print("❌ No user UUID available for loading budget data")
            return
        }
        
        await budgetModel.loadData(userId: userUUID)
        
        // Update the pocket money input field with loaded value
        await MainActor.run {
            if budgetModel.pocketMoney > 0 {
                pocketMoneyInput = String(Int(budgetModel.pocketMoney))
            }
        }
    }
}

// MARK: - BudgetModel
@MainActor
final class BudgetModel: ObservableObject {
    // User-defined budget allocations
    @Published var food: Double = 0
    @Published var travel: Double = 0
    @Published var entertainment: Double = 0
    @Published var shopping: Double = 0
    @Published var misc: Double = 0

    // Real-time expenses tracking
    @Published var foodSpent: Double = 0
    @Published var travelSpent: Double = 0
    @Published var entertainmentSpent: Double = 0
    @Published var shoppingSpent: Double = 0
    @Published var miscSpent: Double = 0

    // Monthly input and derived metrics
    @Published var pocketMoney: Double = 0
    @Published var dailyLimit: Double = 0
    
    var totalSpent: Double {
        foodSpent + travelSpent + entertainmentSpent + shoppingSpent + miscSpent
    }
    
    var totalPlanned: Double {
        food + travel + entertainment + shopping + misc
    }
    
    func addExpense(userId: UUID, category: String, amount: Double) async {
        do {
            try await ExpensesService.shared.addExpense(
                userId: userId,
                category: category,
                amount: amount
            )
            // Refresh data after adding expense
            await loadData(userId: userId)
        } catch {
            print("❌ Failed to add expense:", error)
        }
    }
}
