//
//  ViewReportsView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI
import Charts
import UIKit

//struct MonthlyReportView: View {
//    @Environment(\.dismiss) private var dismiss
//    @EnvironmentObject var budgetModel: BudgetModel
//    @EnvironmentObject var savingsModel: SavingsModel
//    @EnvironmentObject var spendingModel: SpendingModel
//    @EnvironmentObject var userProfile: UserProfile
//    @EnvironmentObject var goalsModel: GoalsModel
//
//    @State private var showExportOptions = false
//    @State private var isLoading = true
//    @State private var showDatePicker = false
//    @State private var selectedDate = Date()
//    
//    // For real-time updates
//    @State private var refreshTrigger = UUID()
//
//    var body: some View {
//        // ✅ Use real-time income from UserProfile + BudgetModel
//        let income = max(Double(userProfile.monthlyIncome), budgetModel.pocketMoney)
//        
//        let food   = spendingModel.foodSpent
//        let travel = spendingModel.travelSpent
//        let ent    = spendingModel.entertainmentSpent
//        let shop   = spendingModel.shoppingSpent
//        let misc   = spendingModel.miscSpent
//
//        let totalSpentDouble = food + travel + ent + shop + misc
//        let totalSpent       = Int(totalSpentDouble.rounded())
//        
//        // ✅ Enhanced savings calculation with goals - recalculated in real-time
//        let savingsBreakdown = calculateSavingsBreakdown(income: income, totalExpenses: totalSpentDouble)
//
//        let foodPercent   = percent(food,   total: totalSpentDouble)
//        let travelPercent = percent(travel, total: totalSpentDouble)
//        let entPercent    = percent(ent,    total: totalSpentDouble)
//        let shopPercent   = percent(shop,   total: totalSpentDouble)
//        let miscPercent   = percent(misc,   total: totalSpentDouble)
//
//        let chartData: [(String, Double, Color)] = [
//            ("Food", foodPercent, Color("CaribbeanTeal")),
//            ("Travel", travelPercent, Color("PeacockBlue")),
//            ("Entertainment", entPercent, Color("SeaGreen")),
//            ("Shopping", shopPercent, Color("Orange")),
//            ("Misc", miscPercent, Color("DeepTeal"))
//        ]
//
//        VStack(spacing: 0) {
//            // ✅ Enhanced top bar with date picker
//            enhancedTopBar
//            
//            if isLoading {
//                loadingView
//            } else {
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 20) {
//                        Spacer().frame(height: 12)
//                        
//                        // ✅ Date-specific summary message
//                        dateInfoCard
//
//                        // Enhanced Summary with Goals
//                        enhancedSummaryCards(
//                            income: income,
//                            totalSpent: totalSpent,
//                            savingsBreakdown: savingsBreakdown
//                        )
//
//                        // Donut Chart
//                        spendingChartSection(chartData: chartData)
//
//                        // Top Spenders
//                        topSpendersSection(
//                            food: food, travel: travel, ent: ent,
//                            shop: shop, misc: misc, totalSpent: totalSpentDouble
//                        )
//                        
//                        // ✅ Real-time Goals Summary Section
//                        realTimeGoalsSummarySection
//                        
//                        // Smart Tips
//                        smartTipsSection(
//                            income: Int(income), totalSpent: totalSpent,
//                            food: food, travel: travel, ent: ent, shop: shop, misc: misc
//                        )
//
//                        // Export Button
//                        exportSection(
//                            income: income, totalSpent: totalSpent,
//                            food: food, travel: travel, ent: ent, shop: shop, misc: misc,
//                            chartData: chartData, savingsBreakdown: savingsBreakdown
//                        )
//                    }
//                }
//            }
//        }
//        .task {
//            await loadReportData()
//        }
//        .onChange(of: selectedDate) { newDate in
//            Task {
//                await loadDataForSelectedDate(newDate)
//            }
//        }
//        .onChange(of: userProfile.monthlyIncome) { _ in
//            // ✅ Refresh when income changes
//            Task {
//                await refreshData()
//            }
//        }
//        .onChange(of: budgetModel.pocketMoney) { _ in
//            // ✅ Refresh when pocket money changes
//            Task {
//                await refreshData()
//            }
//        }
//        .background(Color.white)
//        .navigationBarBackButtonHidden(true)
//        .sheet(isPresented: $showDatePicker) {
//            datePickerSheet
//        }
//    }
//    
//    // MARK: - View Components
//    
//    // ✅ Enhanced top bar with working calendar
//    private var enhancedTopBar: some View {
//        HStack {
//            Button { dismiss() } label: {
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 18, weight: .medium))
//                    .foregroundColor(.white)
//            }
//            Spacer()
//            VStack(spacing: 2) {
//                Text("Monthly Report")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                Text(selectedDate.formatted(.dateTime.month(.wide).year()))
//                    .font(.caption)
//                    .foregroundColor(.white.opacity(0.8))
//            }
//            Spacer()
//            Button {
//                showDatePicker = true
//            } label: {
//                Image(systemName: "calendar")
//                    .font(.system(size: 18, weight: .medium))
//                    .foregroundColor(.white)
//            }
//        }
//        .padding()
//        .background(Color("PeacockBlue"))
//    }
//    
//    // ✅ Date-specific info card
//    private var dateInfoCard: some View {
//        HStack {
//            Image(systemName: "calendar.badge.clock")
//                .foregroundColor(Color("CaribbeanTeal"))
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text("Showing data for")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                Text(selectedDate.formatted(.dateTime.month(.wide).year()))
//                    .font(.subheadline.weight(.semibold))
//                    .foregroundColor(Color("Charcoal"))
//            }
//            
//            Spacer()
//            
//            if !Calendar.current.isDate(selectedDate, equalTo: Date(), toGranularity: .month) {
//                Button("Current Month") {
//                    selectedDate = Date()
//                }
//                .font(.caption)
//                .padding(.horizontal, 8)
//                .padding(.vertical, 4)
//                .background(Color("CaribbeanTeal"))
//                .foregroundColor(.white)
//                .cornerRadius(6)
//            }
//        }
//        .padding()
//        .background(Color("MistyAqua").opacity(0.3))
//        .cornerRadius(12)
//        .padding(.horizontal)
//    }
//    
//    // ✅ Working date picker sheet
//    private var datePickerSheet: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                DatePicker(
//                    "Select Month",
//                    selection: $selectedDate,
//                    displayedComponents: [.date]
//                )
//                .datePickerStyle(.graphical)
//                .onChange(of: selectedDate) { newDate in
//                    // Auto-dismiss when date is selected
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        showDatePicker = false
//                    }
//                }
//                
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("Select Month")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        showDatePicker = false
//                    }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Done") {
//                        showDatePicker = false
//                    }
//                }
//            }
//        }
//        .presentationDetents([.height(500), .large])
//    }
//    
//    private var loadingView: some View {
//        VStack {
//            Spacer()
//            ProgressView("Loading report data...")
//                .foregroundColor(.gray)
//            Spacer()
//        }
//    }
    
//    private func enhancedSummaryCards(
//        income: Double,
//        totalSpent: Int,
//        savingsBreakdown: (available: Double, goals: Double, total: Double)
//    ) -> some View {
//        VStack(spacing: 12) {
//            // First row: Income, Expenses, Total Savings
//            HStack(spacing: 12) {
//                SummaryCard(title: "Income", value: "₹\(Int(income))", color: .blue)
//                SummaryCard(title: "Expenses", value: "₹\(totalSpent)", color: .red)
//                SummaryCard(title: "Total Savings", value: "₹\(Int(savingsBreakdown.total))", color: .green)
//            }
//            
//            // Second row: Available Savings, Goal Savings
//            HStack(spacing: 12) {
//                SummaryCard(title: "Available", value: "₹\(Int(savingsBreakdown.available))", color: .mint)
//                SummaryCard(title: "In Goals", value: "₹\(Int(savingsBreakdown.goals))", color: .teal)
//                SummaryCard(title: "Goals Count", value: "\(goalsModel.goals.count)", color: .purple)
//            }
//        }
//        .padding(.horizontal)
//    }
//    
//    private func spendingChartSection(chartData: [(String, Double, Color)]) -> some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Spending by Category")
//                .font(.headline)
//                .padding(.horizontal)
//
//            DonutChartView(data: chartData)
//        }
//    }
//    
//    private func topSpendersSection(
//        food: Double, travel: Double, ent: Double,
//        shop: Double, misc: Double, totalSpent: Double
//    ) -> some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Top Spenders")
//                .font(.headline)
//                .padding(.horizontal)
//
//            VStack(spacing: 10) {
//                ForEach(spendingModel.topSpendingCategories.prefix(3), id: \.0) { category, amount in
//                    let pct = totalSpent > 0 ? Int((amount / totalSpent) * 100) : 0
//                    let icon = categoryIcon(for: category)
//                    TopSpenderCard(name: category, amount: "₹\(Int(amount))", percent: "\(pct)%", icon: icon)
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//    
//    // ✅ Real-time goals summary section that updates automatically
//    private var realTimeGoalsSummarySection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                Text("Goals Summary")
//                    .font(.headline)
//                Spacer()
//                if !goalsModel.goals.isEmpty {
//                    Text("Updated: \(Date().formatted(.dateTime.hour().minute()))")
//                        .font(.caption2)
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.horizontal)
//            
//            if goalsModel.goals.isEmpty {
//                Text("No goals created yet")
//                    .foregroundColor(.gray)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(12)
//                    .padding(.horizontal)
//            } else {
//                VStack(spacing: 8) {
//                    ForEach(goalsModel.goals.prefix(3)) { goal in
//                        GoalReportCard(goal: goal)
//                            .id("\(goal.id)-\(goal.savedAmount)-\(refreshTrigger)")  // ✅ Force refresh
//                    }
//                    
//                    if goalsModel.goals.count > 3 {
//                        Text("+ \(goalsModel.goals.count - 3) more goals")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                            .frame(maxWidth: .infinity, alignment: .center)
//                    }
//                }
//                .padding(.horizontal)
//            }
//        }
//    }
//    
//    private func smartTipsSection(
//        income: Int, totalSpent: Int,
//        food: Double, travel: Double, ent: Double, shop: Double, misc: Double
//    ) -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Smart Financial Tips")
//                .font(.headline)
//                .padding(.horizontal)
//            
//            VStack(alignment: .leading, spacing: 8) {
//                ForEach(generateSmartTips(income: income, totalSpent: totalSpent, food: food, travel: travel, ent: ent, shop: shop, misc: misc), id: \.self) { tip in
//                    Text("• \(tip)")
//                }
//            }
//            .foregroundColor(Color("Charcoal"))
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//            .padding(.horizontal)
//        }
//    }
//    
//    private func exportSection(
//        income: Double, totalSpent: Int,
//        food: Double, travel: Double, ent: Double, shop: Double, misc: Double,
//        chartData: [(String, Double, Color)],
//        savingsBreakdown: (available: Double, goals: Double, total: Double)
//    ) -> some View {
//        Button {
//            showExportOptions = true
//        } label: {
//            HStack {
//                Image(systemName: "square.and.arrow.up")
//                Text("Export Report for \(selectedDate.formatted(.dateTime.month(.abbreviated).year()))")
//            }
//            .foregroundColor(.white)
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color("CaribbeanTeal"))
//            .cornerRadius(12)
//        }
//        .padding(.horizontal)
//        .padding(.bottom, 16)
//        .confirmationDialog("Export Report As", isPresented: $showExportOptions, titleVisibility: .visible) {
//            Button("📄 Export as PDF") {
//                exportAsPDF(income: income, totalSpent: totalSpent, food: food, travel: travel, ent: ent, shop: shop, misc: misc, chartData: chartData, savingsBreakdown: savingsBreakdown)
//            }
//            Button("📊 Export as CSV") {
//                exportAsCSV(income: income, totalSpent: totalSpent, food: food, travel: travel, ent: ent, shop: shop, misc: misc, savingsBreakdown: savingsBreakdown)
//            }
//            Button("Cancel", role: .cancel) { }
//        }
//    }
//
//    // MARK: - Data Loading & Management
//    
//    private func loadReportData() async {
//        await MainActor.run { isLoading = true }
//        await loadDataForSelectedDate(selectedDate)
//        await MainActor.run { isLoading = false }
//    }
//    
//    // ✅ Load data for specific date using your existing SpendingModel
//    private func loadDataForSelectedDate(_ date: Date) async {
//        guard let id = userProfile.id, let uuid = UUID(uuidString: id) else {
//            return
//        }
//        
//        // Load data for the selected month using your existing methods
//        async let budgetLoad: Void = budgetModel.loadData(userId: uuid)
//        async let spendingLoad: Void = spendingModel.loadData(userId: uuid, for: date)  // ✅ Your method supports date!
//        async let goalsLoad: Void = goalsModel.loadSafely()
//        
//        // Wait for all data to load
//        _ = await (budgetLoad, spendingLoad, goalsLoad)
//        
//        await updateSavingsCalculation()
//        await MainActor.run {
//            refreshTrigger = UUID()  // Trigger UI refresh
//        }
//    }
//    
//    // ✅ Refresh data when income changes
//    private func refreshData() async {
//        await loadDataForSelectedDate(selectedDate)
//    }
//    
//    // ✅ Update savings calculation
//    private func updateSavingsCalculation() async {
//        await MainActor.run {
//            let income = max(Double(userProfile.monthlyIncome), budgetModel.pocketMoney)
//            let totalExpenses = spendingModel.totalExpensesForDate  // ✅ Using your extension
//            
//            savingsModel.loadSavingsWithGoals(
//                income: income,
//                totalExpenses: totalExpenses,
//                goals: goalsModel.goals
//            )
//        }
//    }
//    
//    // ✅ Calculate savings breakdown in real-time
//    private func calculateSavingsBreakdown(income: Double, totalExpenses: Double) -> (available: Double, goals: Double, total: Double) {
//        let totalGoalSavings = goalsModel.goals.reduce(0) { total, goal in
//            total + goal.savedAmount
//        }
//        
//        let theoreticalSavings = max(income - totalExpenses, 0)
//        let availableSavings = max(theoreticalSavings - totalGoalSavings, 0)
//        
//        return (available: availableSavings, goals: totalGoalSavings, total: theoreticalSavings)
//    }
//
//    // MARK: - Helper Functions
//
//    private func percent(_ value: Double, total: Double) -> Double {
//        total > 0 ? (value / total) * 100 : 0
//    }
//
//    private func categoryIcon(for category: String) -> String {
//        switch category {
//        case "Food": return "fork.knife"
//        case "Travel": return "car"
//        case "Entertainment": return "tv"
//        case "Shopping": return "bag"
//        case "Misc": return "ellipsis"
//        default: return "circle"
//        }
//    }
//
//    private func generateSmartTips(income: Int, totalSpent: Int, food: Double, travel: Double, ent: Double, shop: Double, misc: Double) -> [String] {
//        var tips: [String] = []
//
//        // Compare actual spend vs planner limits
//        if food > budgetModel.food {
//            tips.append("⚠️ Overspending on Food. Try home cooking this week.")
//        }
//        if travel > budgetModel.travel {
//            tips.append("✈️ Travel exceeded your plan. Try public transport.")
//        }
//        if (food + travel + ent + shop + misc) > budgetModel.totalPlanned {
//            tips.append("🚨 You're spending more than your planned monthly limit.")
//        }
//
//        // ✅ Goal-related tips with real-time calculation
//        let savingsBreakdown = calculateSavingsBreakdown(income: Double(income), totalExpenses: Double(totalSpent))
//        if savingsBreakdown.available > 1000 {
//            tips.append("💡 You have ₹\(Int(savingsBreakdown.available)) available. Consider creating a savings goal!")
//        }
//        
//        if goalsModel.goals.isEmpty && savingsBreakdown.total > 500 {
//            tips.append("🎯 Start saving for your future! Create your first savings goal.")
//        }
//
//        let savings = income - totalSpent
//        if income > 0, savings < income / 10 {
//            tips.append("💡 Savings are low. Limit your entertainment or shopping.")
//        }
//
//        if tips.isEmpty {
//            tips.append("✅ Great job! Your spending is within budget.")
//        }
//        return tips
//    }
//
//    // MARK: - Export Functions
//    
//    private func exportAsCSV(
//        income: Double, totalSpent: Int,
//        food: Double, travel: Double, ent: Double, shop: Double, misc: Double,
//        savingsBreakdown: (available: Double, goals: Double, total: Double)
//    ) {
//        let monthYear = selectedDate.formatted(.dateTime.month(.wide).year())
//        var rows = [
//            ["Category", "Amount (₹)"],
//            ["Report Month", monthYear],
//            ["Income", "\(Int(income))"],
//            ["Food", "\(Int(food))"],
//            ["Travel", "\(Int(travel))"],
//            ["Entertainment", "\(Int(ent))"],
//            ["Shopping", "\(Int(shop))"],
//            ["Misc", "\(Int(misc))"],
//            ["Total Spent", "\(totalSpent)"],
//            ["Available Savings", "\(Int(savingsBreakdown.available))"],
//            ["Goal Savings", "\(Int(savingsBreakdown.goals))"],
//            ["Total Savings", "\(Int(savingsBreakdown.total))"]
//        ]
//        
//        // Add goal details
//        if !goalsModel.goals.isEmpty {
//            rows.append(["", ""])
//            rows.append(["Goal Name", "Saved Amount (₹)"])
//            for goal in goalsModel.goals {
//                rows.append([goal.name, "\(Int(goal.savedAmount))"])
//            }
//        }
//        
//        let csv = rows.map { $0.joined(separator: ",") }.joined(separator: "\n")
//        let fileName = "MonthlyReport_\(selectedDate.formatted(.dateTime.year().month(.twoDigits))).csv"
//        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//        try? csv.write(to: url, atomically: true, encoding: .utf8)
//        share(url: url)
//    }
//
//    private func exportAsPDF(
//        income: Double, totalSpent: Int,
//        food: Double, travel: Double, ent: Double, shop: Double, misc: Double,
//        chartData: [(String, Double, Color)],
//        savingsBreakdown: (available: Double, goals: Double, total: Double)
//    ) {
//        let monthName = selectedDate.formatted(.dateTime.month(.wide))
//        let year = selectedDate.formatted(.dateTime.year())
//        let today = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
//
//        let chartView = DonutChartView(data: chartData).frame(width: 240, height: 240)
//        let chartRenderer = ImageRenderer(content: chartView)
//
//        let renderer = ImageRenderer(content:
//            VStack(alignment: .leading, spacing: 16) {
//                Text("📊 Monthly Expense Report").font(.title2.bold())
//                Text("Month: \(monthName) \(year)").foregroundColor(.gray)
//                Text("Generated on: \(today)").font(.footnote).foregroundColor(.gray)
//                Divider()
//                
//                HStack {
//                    Text("Income: ₹\(Int(income))")
//                    Spacer()
//                    Text("Total Savings: ₹\(Int(savingsBreakdown.total))")
//                }
//                Text("Total Expenses: ₹\(totalSpent)").bold()
//                
//                HStack {
//                    Text("Available: ₹\(Int(savingsBreakdown.available))")
//                    Spacer()
//                    Text("In Goals: ₹\(Int(savingsBreakdown.goals))")
//                }
//
//                VStack(alignment: .leading) {
//                    Text("Category-wise Spend:").font(.subheadline.bold())
//                    Text("🍽 Food: ₹\(Int(food))")
//                    Text("🚗 Travel: ₹\(Int(travel))")
//                    Text("🎬 Entertainment: ₹\(Int(ent))")
//                    Text("🛍 Shopping: ₹\(Int(shop))")
//                    Text("📦 Misc: ₹\(Int(misc))")
//                }.font(.callout)
//
//                if !goalsModel.goals.isEmpty {
//                    VStack(alignment: .leading) {
//                        Text("Active Goals:").font(.subheadline.bold())
//                        ForEach(goalsModel.goals.prefix(3)) { goal in
//                            Text("🎯 \(goal.name): ₹\(Int(goal.savedAmount))/₹\(Int(goal.targetAmount))")
//                        }
//                    }.font(.callout)
//                }
//
//                Divider()
//                Text("📈 Pie Chart Summary").font(.subheadline.bold())
//                if let chartImage = chartRenderer.uiImage {
//                    Image(uiImage: chartImage)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 240, height: 240)
//                }
//            }
//            .padding().frame(width: 350)
//        )
//
//        if let img = renderer.uiImage {
//            let pdf = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
//                .pdfData { ctx in ctx.beginPage(); img.draw(in: CGRect(x: 72, y: 72, width: 468, height: 648)) }
//            let fileName = "MonthlyReport_\(selectedDate.formatted(.dateTime.year().month(.wide))).pdf"
//            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//            try? pdf.write(to: url)
//            share(url: url)
//        }
//    }
//
//    private func share(url: URL) {
//        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            scene.windows.first?.rootViewController?.present(
//                UIActivityViewController(activityItems: [url], applicationActivities: nil),
//                animated: true
//            )
//        }
//    }
//}
//
//// MARK: - Enhanced Goal Report Card Component
//struct GoalReportCard: View {
//    let goal: Goal
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text(goal.name)
//                    .font(.subheadline.weight(.medium))
//                    .lineLimit(1)
//                
//                Text("₹\(Int(goal.savedAmount)) / ₹\(Int(goal.targetAmount))")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                
//                // ✅ Show last updated time for real-time feel
//                if let lastAddition = goal.additions.last {
//                    Text("Last updated: \(lastAddition.date.formatted(.dateTime.month().day()))")
//                        .font(.caption2)
//                        .foregroundColor(.blue)
//                }
//            }
//            
//            Spacer()
//            
//            VStack(alignment: .trailing, spacing: 4) {
//                Text("\(Int(goal.progress * 100))%")
//                    .font(.caption.weight(.semibold))
//                    .foregroundColor(goal.progress >= 1.0 ? .green : .blue)
//                
//                ProgressView(value: goal.progress)
//                    .tint(Color("CaribbeanTeal"))
//                    .frame(width: 60)
//                
//                if goal.progress >= 1.0 {
//                    Text("✅ Complete")
//                        .font(.caption2)
//                        .foregroundColor(.green)
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(8)
//    }
//}
    // Updated enhancedSummaryCards function


    
    
    
    
    
    
    


// Complete MonthlyReportView with the updated summary cards
struct MonthlyReportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var budgetModel: BudgetModel
    @EnvironmentObject var savingsModel: SavingsModel
    @EnvironmentObject var spendingModel: SpendingModel
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var goalsModel: GoalsModel

    @State private var showExportOptions = false
    @State private var isLoading = true
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    
    // For real-time updates
    @State private var refreshTrigger = UUID()

    var body: some View {
        // ✅ Use real-time income from UserProfile + BudgetModel
        let income = max(Double(userProfile.monthlyIncome), budgetModel.pocketMoney)
        
        let food   = spendingModel.foodSpent
        let travel = spendingModel.travelSpent
        let ent    = spendingModel.entertainmentSpent
        let shop   = spendingModel.shoppingSpent
        let misc   = spendingModel.miscSpent

        let totalSpentDouble = food + travel + ent + shop + misc
        let totalSpent       = Int(totalSpentDouble.rounded())
        
        // ✅ Enhanced savings calculation with goals - recalculated in real-time
        let savingsBreakdown = calculateSavingsBreakdown(income: income, totalExpenses: totalSpentDouble)

        let foodPercent   = percent(food,   total: totalSpentDouble)
        let travelPercent = percent(travel, total: totalSpentDouble)
        let entPercent    = percent(ent,    total: totalSpentDouble)
        let shopPercent   = percent(shop,   total: totalSpentDouble)
        let miscPercent   = percent(misc,   total: totalSpentDouble)

        let chartData: [(String, Double, Color)] = [
            ("Food", foodPercent, Color("CaribbeanTeal")),
            ("Travel", travelPercent, Color("PeacockBlue")),
            ("Entertainment", entPercent, Color("SeaGreen")),
            ("Shopping", shopPercent, Color("Orange")),
            ("Misc", miscPercent, Color("DeepTeal"))
        ]

        VStack(spacing: 0) {
            // ✅ Enhanced top bar with date picker
            enhancedTopBar
            
            if isLoading {
                loadingView
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer().frame(height: 12)
                        
                        // ✅ Date-specific summary message
                        dateInfoCard

                        // Enhanced Summary with Goals
                        enhancedSummaryCards(
                            income: income,
                            totalSpent: totalSpent,
                            savingsBreakdown: savingsBreakdown
                        )

                        // Donut Chart
                        spendingChartSection(chartData: chartData)

                        // Top Spenders
                        topSpendersSection(
                            food: food, travel: travel, ent: ent,
                            shop: shop, misc: misc, totalSpent: totalSpentDouble
                        )
                        
                        // ✅ Real-time Goals Summary Section
                        realTimeGoalsSummarySection
                        
                        // Smart Tips
                        smartTipsSection(
                            income: Int(income), totalSpent: totalSpent,
                            food: food, travel: travel, ent: ent, shop: shop, misc: misc
                        )

                        // Export Button
                        exportSection(
                            income: income, totalSpent: totalSpent,
                            food: food, travel: travel, ent: ent, shop: shop, misc: misc,
                            chartData: chartData, savingsBreakdown: savingsBreakdown
                        )
                    }
                }
            }
        }
        .task {
            await loadReportData()
        }
        .onChange(of: selectedDate) { newDate in
            Task {
                await loadDataForSelectedDate(newDate)
            }
        }
        .onChange(of: userProfile.monthlyIncome) { _ in
            // ✅ Refresh when income changes
            Task {
                await refreshData()
            }
        }
        .onChange(of: budgetModel.pocketMoney) { _ in
            // ✅ Refresh when pocket money changes
            Task {
                await refreshData()
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
    }
    
    // MARK: - View Components
    
    // ✅ Enhanced top bar with working calendar
    private var enhancedTopBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            Spacer()
            VStack(spacing: 2) {
                Text("Monthly Report")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            Button {
                showDatePicker = true
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color("PeacockBlue"))
    }
    
    // ✅ Date-specific info card
    private var dateInfoCard: some View {
        HStack {
            Image(systemName: "calendar.badge.clock")
                .foregroundColor(Color("CaribbeanTeal"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Showing data for")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color("Charcoal"))
            }
            
            Spacer()
            
            if !Calendar.current.isDate(selectedDate, equalTo: Date(), toGranularity: .month) {
                Button("Current Month") {
                    selectedDate = Date()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color("CaribbeanTeal"))
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color("MistyAqua").opacity(0.3))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // ✅ Working date picker sheet
    private var datePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Select Month",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .onChange(of: selectedDate) { newDate in
                    // Auto-dismiss when date is selected
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showDatePicker = false
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showDatePicker = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showDatePicker = false
                    }
                }
            }
        }
        .presentationDetents([.height(500), .large])
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading report data...")
                .foregroundColor(.gray)
            Spacer()
        }
    }
    // Updated enhancedSummaryCards function
    private func enhancedSummaryCards(
        income: Double,
        totalSpent: Int,
        savingsBreakdown: (available: Double, goals: Double, total: Double)
    ) -> some View {
        VStack(spacing: 12) {
            // First row: Income, Expenses, Total Savings
            HStack(spacing: 12) {
                EnhancedSummaryCard(
                    title: "Income",
                    value: "₹\(Int(income))",
                    color: .blue,
                    arrow: .down,
                    hasBorder: false
                )
                EnhancedSummaryCard(
                    title: "Expenses",
                    value: "₹\(totalSpent)",
                    color: .red,
                    arrow: .up,
                    hasBorder: false
                )
                EnhancedSummaryCard(
                    title: "Total Savings",
                    value: "₹\(Int(savingsBreakdown.total))",
                    color: .green,
                    arrow: .none,
                    hasBorder: true
                )
            }
            
            // Second row: Available Savings, Goal Savings, Goals Count
            HStack(spacing: 12) {
                EnhancedSummaryCard(
                    title: "Available",
                    value: "₹\(Int(savingsBreakdown.available))",
                    color: .mint,
                    arrow: .down,
                    hasBorder: false
                )
                EnhancedSummaryCard(
                    title: "In Goals",
                    value: "₹\(Int(savingsBreakdown.goals))",
                    color: .teal,
                    arrow: .up,
                    hasBorder: false
                )
                EnhancedSummaryCard(
                    title: "Goals Count",
                    value: "\(goalsModel.goals.count)",
                    color: .purple,
                    arrow: .none,
                    hasBorder: true
                )
            }
        }
        .padding(.horizontal)
    }

    // Enhanced Summary Card Component
    struct EnhancedSummaryCard: View {
        let title: String
        let value: String
        let color: Color
        let arrow: ArrowDirection
        let hasBorder: Bool
        
        enum ArrowDirection {
            case up, down, none
        }
        
        var body: some View {
            VStack(spacing: 8) {
                HStack {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    if arrow != .none {
                        Image(systemName: arrow == .up ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                            .foregroundColor(arrowColor)
                    }
                }
                
                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(Color(.systemGray6)) // Keep original background for all cards
            .overlay(
                // Add border for specific cards
                RoundedRectangle(cornerRadius: 8)
                    .stroke(hasBorder ? color.opacity(0.5) : Color.clear, lineWidth: hasBorder ? 2 : 0)
            )
            .cornerRadius(8)
        }
        
        private var arrowColor: Color {
            switch arrow {
            case .up:
                return .red // Up arrows are red (expenses going up, money in goals going up)
            case .down:
                return .green // Down arrows are green (income coming down/in, available savings coming down/in)
            case .none:
                return .clear
            }
        }
    }
    
    private func spendingChartSection(chartData: [(String, Double, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)
                .padding(.horizontal)

            DonutChartView(data: chartData)
        }
    }
    
    private func topSpendersSection(
        food: Double, travel: Double, ent: Double,
        shop: Double, misc: Double, totalSpent: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Spenders")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 10) {
                ForEach(spendingModel.topSpendingCategories.prefix(3), id: \.0) { category, amount in
                    let pct = totalSpent > 0 ? Int((amount / totalSpent) * 100) : 0
                    let icon = categoryIcon(for: category)
                    TopSpenderCard(name: category, amount: "₹\(Int(amount))", percent: "\(pct)%", icon: icon)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // ✅ Real-time goals summary section that updates automatically
    private var realTimeGoalsSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Goals Summary")
                    .font(.headline)
                Spacer()
                if !goalsModel.goals.isEmpty {
                    Text("Updated: \(Date().formatted(.dateTime.hour().minute()))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            if goalsModel.goals.isEmpty {
                Text("No goals created yet")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 8) {
                    ForEach(goalsModel.goals.prefix(3)) { goal in
                        GoalReportCard(goal: goal)
                            .id("\(goal.id)-\(goal.savedAmount)-\(refreshTrigger)")  // ✅ Force refresh
                    }
                    
                    if goalsModel.goals.count > 3 {
                        Text("+ \(goalsModel.goals.count - 3) more goals")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func smartTipsSection(
        income: Int, totalSpent: Int,
        food: Double, travel: Double, ent: Double, shop: Double, misc: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Smart Financial Tips")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(generateSmartTips(income: income, totalSpent: totalSpent, food: food, travel: travel, ent: ent, shop: shop, misc: misc), id: \.self) { tip in
                    Text("• \(tip)")
                }
            }
            .foregroundColor(Color("Charcoal"))
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private func exportSection(
        income: Double, totalSpent: Int,
        food: Double, travel: Double, ent: Double, shop: Double, misc: Double,
        chartData: [(String, Double, Color)],
        savingsBreakdown: (available: Double, goals: Double, total: Double)
    ) -> some View {
        Button {
            showExportOptions = true
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Export Report for \(selectedDate.formatted(.dateTime.month(.abbreviated).year()))")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("CaribbeanTeal"))
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .confirmationDialog("Export Report As", isPresented: $showExportOptions, titleVisibility: .visible) {
            Button("📄 Export as PDF") {
                exportAsPDF(income: income, totalSpent: totalSpent, food: food, travel: travel, ent: ent, shop: shop, misc: misc, chartData: chartData, savingsBreakdown: savingsBreakdown)
            }
            Button("📊 Export as CSV") {
                exportAsCSV(income: income, totalSpent: totalSpent, food: food, travel: travel, ent: ent, shop: shop, misc: misc, savingsBreakdown: savingsBreakdown)
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    // MARK: - Data Loading & Management
    
    private func loadReportData() async {
        await MainActor.run { isLoading = true }
        await loadDataForSelectedDate(selectedDate)
        await MainActor.run { isLoading = false }
    }
    
    // ✅ Load data for specific date using your existing SpendingModel
    private func loadDataForSelectedDate(_ date: Date) async {
        guard let id = userProfile.id, let uuid = UUID(uuidString: id) else {
            return
        }
        
        // Load data for the selected month using your existing methods
        async let budgetLoad: Void = budgetModel.loadData(userId: uuid)
        async let spendingLoad: Void = spendingModel.loadData(userId: uuid, for: date)  // ✅ Your method supports date!
        async let goalsLoad: Void = goalsModel.loadSafely()
        
        // Wait for all data to load
        _ = await (budgetLoad, spendingLoad, goalsLoad)
        
        await updateSavingsCalculation()
        await MainActor.run {
            refreshTrigger = UUID()  // Trigger UI refresh
        }
    }
    
    // ✅ Refresh data when income changes
    private func refreshData() async {
        await loadDataForSelectedDate(selectedDate)
    }
    
    // ✅ Update savings calculation
    private func updateSavingsCalculation() async {
        await MainActor.run {
            let income = max(Double(userProfile.monthlyIncome), budgetModel.pocketMoney)
            let totalExpenses = spendingModel.totalExpensesForDate  // ✅ Using your extension
            
            savingsModel.loadSavingsWithGoals(
                income: income,
                totalExpenses: totalExpenses,
                goals: goalsModel.goals
            )
        }
    }
    
    // ✅ Calculate savings breakdown in real-time
    private func calculateSavingsBreakdown(income: Double, totalExpenses: Double) -> (available: Double, goals: Double, total: Double) {
        let totalGoalSavings = goalsModel.goals.reduce(0) { total, goal in
            total + goal.savedAmount
        }
        
        let theoreticalSavings = max(income - totalExpenses, 0)
        let availableSavings = max(theoreticalSavings - totalGoalSavings, 0)
        
        return (available: availableSavings, goals: totalGoalSavings, total: theoreticalSavings)
    }

    // MARK: - Helper Functions

    private func percent(_ value: Double, total: Double) -> Double {
        total > 0 ? (value / total) * 100 : 0
    }

    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Food": return "fork.knife"
        case "Travel": return "car"
        case "Entertainment": return "tv"
        case "Shopping": return "bag"
        case "Misc": return "ellipsis"
        default: return "circle"
        }
    }

    private func generateSmartTips(income: Int, totalSpent: Int, food: Double, travel: Double, ent: Double, shop: Double, misc: Double) -> [String] {
        var tips: [String] = []

        // Compare actual spend vs planner limits
        if food > budgetModel.food {
            tips.append("⚠️ Overspending on Food. Try home cooking this week.")
        }
        if travel > budgetModel.travel {
            tips.append("✈️ Travel exceeded your plan. Try public transport.")
        }
        if (food + travel + ent + shop + misc) > budgetModel.totalPlanned {
            tips.append("🚨 You're spending more than your planned monthly limit.")
        }

        // ✅ Goal-related tips with real-time calculation
        let savingsBreakdown = calculateSavingsBreakdown(income: Double(income), totalExpenses: Double(totalSpent))
        if savingsBreakdown.available > 1000 {
            tips.append("💡 You have ₹\(Int(savingsBreakdown.available)) available. Consider creating a savings goal!")
        }
        
        if goalsModel.goals.isEmpty && savingsBreakdown.total > 500 {
            tips.append("🎯 Start saving for your future! Create your first savings goal.")
        }

        let savings = income - totalSpent
        if income > 0, savings < income / 10 {
            tips.append("💡 Savings are low. Limit your entertainment or shopping.")
        }

        if tips.isEmpty {
            tips.append("✅ Great job! Your spending is within budget.")
        }
        return tips
    }

    // MARK: - Export Functions
    
    private func exportAsCSV(
        income: Double, totalSpent: Int,
        food: Double, travel: Double, ent: Double, shop: Double, misc: Double,
        savingsBreakdown: (available: Double, goals: Double, total: Double)
    ) {
        let monthYear = selectedDate.formatted(.dateTime.month(.wide).year())
        var rows = [
            ["Category", "Amount (₹)"],
            ["Report Month", monthYear],
            ["Income", "\(Int(income))"],
            ["Food", "\(Int(food))"],
            ["Travel", "\(Int(travel))"],
            ["Entertainment", "\(Int(ent))"],
            ["Shopping", "\(Int(shop))"],
            ["Misc", "\(Int(misc))"],
            ["Total Spent", "\(totalSpent)"],
            ["Available Savings", "\(Int(savingsBreakdown.available))"],
            ["Goal Savings", "\(Int(savingsBreakdown.goals))"],
            ["Total Savings", "\(Int(savingsBreakdown.total))"]
        ]
        
        // Add goal details
        if !goalsModel.goals.isEmpty {
            rows.append(["", ""])
            rows.append(["Goal Name", "Saved Amount (₹)"])
            for goal in goalsModel.goals {
                rows.append([goal.name, "\(Int(goal.savedAmount))"])
            }
        }
        
        let csv = rows.map { $0.joined(separator: ",") }.joined(separator: "\n")
        let fileName = "MonthlyReport_\(selectedDate.formatted(.dateTime.year().month(.twoDigits))).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        share(url: url)
    }

    private func exportAsPDF(
        income: Double, totalSpent: Int,
        food: Double, travel: Double, ent: Double, shop: Double, misc: Double,
        chartData: [(String, Double, Color)],
        savingsBreakdown: (available: Double, goals: Double, total: Double)
    ) {
        let monthName = selectedDate.formatted(.dateTime.month(.wide))
        let year = selectedDate.formatted(.dateTime.year())
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)

        let chartView = DonutChartView(data: chartData).frame(width: 240, height: 240)
        let chartRenderer = ImageRenderer(content: chartView)

        let renderer = ImageRenderer(content:
            VStack(alignment: .leading, spacing: 16) {
                Text("📊 Monthly Expense Report").font(.title2.bold())
                Text("Month: \(monthName) \(year)").foregroundColor(.gray)
                Text("Generated on: \(today)").font(.footnote).foregroundColor(.gray)
                Divider()
                
                HStack {
                    Text("Income: ₹\(Int(income))")
                    Spacer()
                    Text("Total Savings: ₹\(Int(savingsBreakdown.total))")
                }
                Text("Total Expenses: ₹\(totalSpent)").bold()
                
                HStack {
                    Text("Available: ₹\(Int(savingsBreakdown.available))")
                    Spacer()
                    Text("In Goals: ₹\(Int(savingsBreakdown.goals))")
                }

                VStack(alignment: .leading) {
                    Text("Category-wise Spend:").font(.subheadline.bold())
                    Text("🍽 Food: ₹\(Int(food))")
                    Text("🚗 Travel: ₹\(Int(travel))")
                    Text("🎬 Entertainment: ₹\(Int(ent))")
                    Text("🛍 Shopping: ₹\(Int(shop))")
                    Text("📦 Misc: ₹\(Int(misc))")
                }.font(.callout)

                if !goalsModel.goals.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Active Goals:").font(.subheadline.bold())
                        ForEach(goalsModel.goals.prefix(3)) { goal in
                            Text("🎯 \(goal.name): ₹\(Int(goal.savedAmount))/₹\(Int(goal.targetAmount))")
                        }
                    }.font(.callout)
                }

                Divider()
                Text("📈 Pie Chart Summary").font(.subheadline.bold())
                if let chartImage = chartRenderer.uiImage {
                    Image(uiImage: chartImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 240)
                }
            }
            .padding().frame(width: 350)
        )

        if let img = renderer.uiImage {
            let pdf = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
                .pdfData { ctx in ctx.beginPage(); img.draw(in: CGRect(x: 72, y: 72, width: 468, height: 648)) }
            let fileName = "MonthlyReport_\(selectedDate.formatted(.dateTime.year().month(.wide))).pdf"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try? pdf.write(to: url)
            share(url: url)
        }
    }

    private func share(url: URL) {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController?.present(
                UIActivityViewController(activityItems: [url], applicationActivities: nil),
                animated: true
            )
        }
    }
}

// MARK: - Enhanced Goal Report Card Component
struct GoalReportCard: View {
    let goal: Goal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                
                Text("₹\(Int(goal.savedAmount)) / ₹\(Int(goal.targetAmount))")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // ✅ Show last updated time for real-time feel
                if let lastAddition = goal.additions.last {
                    Text("Last updated: \(lastAddition.date.formatted(.dateTime.month().day()))")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(goal.progress >= 1.0 ? .green : .blue)
                
                ProgressView(value: goal.progress)
                    .tint(Color("CaribbeanTeal"))
                    .frame(width: 60)
                
                if goal.progress >= 1.0 {
                    Text("✅ Complete")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
