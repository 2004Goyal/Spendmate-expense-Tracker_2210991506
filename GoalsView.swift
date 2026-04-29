//
//  GoalsView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI
import Supabase

struct GoalRef: Identifiable, Hashable { let id: UUID }
//
//// MARK: - Enhanced Goals View
//struct GoalsView: View {
//    @EnvironmentObject var savingsModel: SavingsModel
//    @EnvironmentObject var goalsModel: GoalsModel
//    @EnvironmentObject var userProfile: UserProfile
//
//    @State private var currentSavings: Double = 0
//    @State private var goalName = ""
//    @State private var goalAmount = ""
//    @State private var targetDate = Date()
//    @State private var showPicker = false
//    @State private var isCreatingGoal = false
//    @State private var showError = false
//    @State private var errorMessage = ""
//    @State private var isInitialLoad = true
//
//    var body: some View {
//        VStack(spacing: 0) {
//            topBar
//
//            ScrollView {
//                VStack(alignment: .leading, spacing: 24) {
//                    savingsCard
//
//                    if let first = goalsModel.goals.first {
//                        ActiveGoalCard(goal: first) {
//                            goalsModel.selectedGoalId = first.id
//                        }
//                    }
//
//                    if goalsModel.goals.count > 1 {
//                        Text("Other Goals")
//                            .font(.headline)
//                            .foregroundColor(.gray)
//
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 16) {
//                                ForEach(goalsModel.goals.dropFirst()) { goal in
//                                    MiniGoalCard(goal: goal)
//                                        .onTapGesture {
//                                            goalsModel.selectedGoalId = goal.id
//                                        }
//                                }
//                            }.padding(.horizontal)
//                        }
//                    }
//
//                    createGoalSection
//                }
//                .padding()
//            }
//        }
//        .background(Color.white.ignoresSafeArea())
//        .navigationDestination(
//            item: Binding<GoalRef?>(
//                get: { goalsModel.selectedGoalId.map { GoalRef(id: $0) } },
//                set: { goalsModel.selectedGoalId = $0?.id }
//            )
//        ) { ref in
//            if let goal = goalsModel.goals.first(where: { $0.id == ref.id }) {
//                GoalDetailView(goal: goal, savings: $currentSavings)
//                    .environmentObject(savingsModel)
//                    .environmentObject(goalsModel)
//            } else {
//                Text("Goal not found")
//            }
//        }
//        .onAppear {
//            currentSavings = savingsModel.savingsFromReport
//            
//            // Only load from server on initial appearance
//            if isInitialLoad {
//                isInitialLoad = false
//                Task {
//                    await goalsModel.loadSafely()
//                }
//            }
//        }
//        .onChange(of: savingsModel.savingsFromReport) { newVal in
//            currentSavings = newVal
//        }
//        .alert("Error", isPresented: $showError) {
//            Button("OK") { }
//        } message: {
//            Text(errorMessage)
//        }
//    }
//
//    private var topBar: some View {
//        HStack {
//            Text("Goals")
//                .font(.title.bold())
//                .foregroundColor(.white)
//            Spacer()
//        }
//        .padding()
//        .background(Color("PeacockBlue"))
//    }
//
//    private var savingsCard: some View {
//        HStack {
//            Text("Available Savings")
//            Spacer()
//            Text("₹\(Int(currentSavings))")
//                .font(.headline.bold())
//                .foregroundColor(.green)
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//    }
//
//    private var createGoalSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Create New Goal")
//                .font(.headline)
//                .foregroundColor(.gray)
//
//            TextField("What are you saving for?", text: $goalName)
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(12)
//
//            TextField("Enter target amount", text: $goalAmount)
//                .keyboardType(.decimalPad)
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(12)
//
//            Button {
//                showPicker.toggle()
//            } label: {
//                HStack {
//                    Text(targetDate, style: .date)
//                        .foregroundColor(.gray)
//                    Spacer()
//                    Image(systemName: "calendar")
//                }
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(12)
//            }
//
//            if showPicker {
//                DatePicker("", selection: $targetDate, displayedComponents: .date)
//                    .datePickerStyle(.graphical)
//            }
//
//            Button("Create Goal") {
//                createGoal()
//            }
//            .disabled(isCreatingGoal)
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(isCreatingGoal ? Color.gray : Color("CaribbeanTeal"))
//            .foregroundColor(.white)
//            .cornerRadius(12)
//            .overlay {
//                if isCreatingGoal {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                        .scaleEffect(0.8)
//                }
//            }
//        }
//    }
//    
//    private func createGoal() {
//        let trimmedName = goalName.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedName.isEmpty else {
//            showErrorAlert("Please enter a goal name.")
//            return
//        }
//        
//        guard let amountValue = Double(goalAmount), amountValue > 0 else {
//            showErrorAlert("Please enter a valid amount.")
//            return
//        }
//        
//        guard targetDate > Date() else {
//            showErrorAlert("Please select a future target date.")
//            return
//        }
//
//        isCreatingGoal = true
//        hideKeyboard()
//
//        Task {
//            let success = await goalsModel.createGoal(
//                name: trimmedName,
//                targetAmount: amountValue,
//                targetDate: targetDate
//            )
//            
//            await MainActor.run {
//                isCreatingGoal = false
//                
//                if success {
//                    // Schedule notification
//                    if let newGoal = goalsModel.goals.first {
//                        NotificationManager.scheduleGoalReminder(
//                            goalID: newGoal.id,
//                            goalName: newGoal.name,
//                            deadline: newGoal.targetDate
//                        )
//                    }
//                    
//                    // Reset form
//                    goalName = ""
//                    goalAmount = ""
//                    targetDate = Date()
//                    showPicker = false
//                } else {
//                    showErrorAlert("Failed to create goal. Please try again.")
//                }
//            }
//        }
//    }
//    
//    private func showErrorAlert(_ message: String) {
//        errorMessage = message
//        showError = true
//    }
//
//    private func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
//                                        to: nil, from: nil, for: nil)
//    }
//}
//
//// MARK: - Enhanced Goal Detail View
//struct GoalDetailView: View {
//    @ObservedObject var goal: Goal
//    @Binding var savings: Double
//    @Environment(\.dismiss) private var dismiss
//    @EnvironmentObject var savingsModel: SavingsModel
//    @EnvironmentObject var goalsModel: GoalsModel
//
//    @State private var showTransfer = false
//    @State private var transferAmount = ""
//    @State private var errorMsg: String?
//    @State private var isTransferring = false
//
//    var body: some View {
//        VStack(spacing: 0) {
//            ZStack {
//                Color("PeacockBlue").ignoresSafeArea(edges: .top)
//
//                HStack {
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 20, weight: .medium))
//                            .foregroundColor(.white)
//                            .padding(.leading, 8)
//                    }
//
//                    Spacer()
//
//                    Text("Goal Details")
//                        .font(.title3.bold())
//                        .foregroundColor(.white)
//
//                    Spacer()
//                    Image(systemName: "chevron.left")
//                        .opacity(0)
//                        .padding(.trailing, 8)
//                }
//                .padding(.horizontal)
//                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 16)
//            }
//            .frame(height: 80 + (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 16))
//
//            Spacer()
//
//            ScrollView {
//                VStack(spacing: 24) {
//                    // Goal Card
//                    goalCard
//                    
//                    // Recommended Contribution Plan
//                    contributionPlan
//                    
//                    // Transaction History
//                    transactionHistory
//
//                    // Add Button
//                    addFundsButton
//                }
//                .padding()
//            }
//        }
//        .edgesIgnoringSafeArea(.top)
//        .sheet(isPresented: $showTransfer) {
//            transferSheet
//        }
//        .navigationBarBackButtonHidden(true)
//        .navigationBarHidden(true)
//    }
//    
//    private var goalCard: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                Text(goal.name)
//                    .font(.title3.bold())
//                Spacer()
//                Text("Saved: ₹\(Int(goal.savedAmount))")
//                    .foregroundColor(.green)
//                    .font(.subheadline)
//            }
//
//            HStack {
//                Text("Target: ₹\(Int(goal.targetAmount))")
//                    .foregroundColor(.gray)
//                    .font(.subheadline)
//                Spacer()
//            }
//
//            ProgressView(value: goal.progress)
//                .tint(Color("CaribbeanTeal"))
//                .frame(height: 8)
//                .background(Color(.systemGray5))
//                .cornerRadius(4)
//
//            HStack {
//                Image(systemName: "calendar")
//                    .foregroundColor(.gray)
//                Text("Deadline: \(goal.targetDate.formatted(date: .abbreviated, time: .omitted))")
//                    .foregroundColor(.gray)
//                    .font(.caption)
//                Spacer()
//                Text("\(goal.monthsLeft) mo left")
//                    .foregroundColor(.gray)
//                    .font(.caption)
//            }
//        }
//        .padding()
//        .background(Color("MistyAqua"))
//        .cornerRadius(16)
//    }
//    
//    private var contributionPlan: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Recommended Contribution Plan")
//                .font(.headline)
//                .padding(.bottom, 4)
//
//            let plan = fixedPlan(for: goal)
//            if plan.isEmpty {
//                Text("No schedule available.")
//                    .foregroundColor(.gray)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.vertical, 12)
//            } else {
//                ForEach(Array(plan.enumerated()), id: \.offset) { _, item in
//                    HStack {
//                        Text(item.date.formatted(date: .abbreviated, time: .omitted))
//                        Spacer()
//                        Text("₹\(Int(item.amount))").bold()
//                    }
//                    .padding(.vertical, 4)
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(16)
//    }
//    
//    private var transactionHistory: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Transaction History")
//                .font(.headline)
//                .padding(.bottom, 4)
//
//            if goal.additions.isEmpty {
//                Text("No transactions yet.")
//                    .foregroundColor(.gray)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.vertical, 12)
//            } else {
//                ForEach(goal.additions.indices.reversed(), id: \.self) { i in
//                    let add = goal.additions[i]
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text("₹\(Int(add.amount))")
//                                .font(.headline)
//                            Text(add.date.formatted(date: .abbreviated, time: .omitted))
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                        Spacer()
//                    }
//                    .padding(.vertical, 4)
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(16)
//    }
//    
//    private var addFundsButton: some View {
//        Button {
//            showTransfer = true
//        } label: {
//            HStack {
//                Image(systemName: "plus")
//                Text("Add to this Goal")
//                    .fontWeight(.semibold)
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color("CaribbeanTeal"))
//            .foregroundColor(.white)
//            .cornerRadius(12)
//            .shadow(radius: 2)
//        }
//    }
//
//    // Fixed plan calculation
//    private func fixedPlan(for goal: Goal) -> [(date: Date, amount: Double)] {
//        let cal = Calendar.current
//        let start = cal.startOfDay(for: goal.createdAt)
//        let target = cal.startOfDay(for: goal.targetDate)
//
//        guard start <= target else { return [(target, goal.targetAmount)] }
//
//        let months = cal.dateComponents([.month], from: start, to: target).month ?? 0
//        let count = max(1, months == 0 ? 1 : months)
//
//        var dates: [Date] = []
//        if count == 1 {
//            dates = [target]
//        } else {
//            for i in 1..<count {
//                dates.append(cal.date(byAdding: .month, value: i, to: start) ?? target)
//            }
//            dates.append(target)
//        }
//
//        let total = max(0, goal.targetAmount)
//        let base = floor(total / Double(count))
//        var remainder = Int(total - base * Double(count))
//        return dates.enumerated().map { _, d in
//            var amt = base
//            if remainder > 0 { amt += 1; remainder -= 1 }
//            return (d, amt)
//        }
//    }
//
//    private var transferSheet: some View {
//        NavigationStack {
//            VStack(spacing: 24) {
//                Text("Transfer from Savings")
//                    .font(.headline)
//
//                TextField("₹0", text: $transferAmount)
//                    .keyboardType(.decimalPad)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(10)
//
//                if let msg = errorMsg {
//                    Text(msg).foregroundColor(.red)
//                }
//
//                Button("Transfer") {
//                    transferFunds()
//                }
//                .disabled(isTransferring)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(isTransferring ? Color.gray : Color("CaribbeanTeal"))
//                .foregroundColor(.white)
//                .cornerRadius(10)
//                .overlay {
//                    if isTransferring {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            .scaleEffect(0.8)
//                    }
//                }
//            }
//            .padding()
//            .navigationTitle("Add Funds")
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") { showTransfer = false }
//                }
//            }
//        }
//        .presentationDetents([.height(300)])
//    }
//    
//    private func transferFunds() {
//        guard let amt = Double(transferAmount), amt > 0 else {
//            errorMsg = "Please enter a valid amount."
//            return
//        }
//
//        if amt > savings {
//            errorMsg = "You don't have enough savings."
//            return
//        }
//        
//        isTransferring = true
//        errorMsg = nil
//
//        Task {
//            // Update locally first (optimistic update)
//            await MainActor.run {
//                withAnimation {
//                    savings -= amt
//                    savingsModel.savingsFromReport = savings
//                    goal.savedAmount += amt
//                    goal.additions.append((amt, Date()))
//                }
//            }
//            
//            // Persist to server
//            await goalsModel.updateGoal(goal)
//            
//            await MainActor.run {
//                isTransferring = false
//                transferAmount = ""
//                errorMsg = nil
//                showTransfer = false
//            }
//        }
//    }
//}
//
//// MARK: - Card Components (unchanged)
//struct MiniGoalCard: View {
//    let goal: Goal
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(goal.name)
//                .font(.subheadline)
//                .lineLimit(1)
//
//            ProgressView(value: goal.progress)
//                .tint(Color("CaribbeanTeal"))
//                .frame(width: 120)
//
//            Text("₹\(Int(goal.savedAmount))/₹\(Int(goal.targetAmount))")
//                .font(.caption2)
//                .foregroundColor(.gray)
//        }
//        .padding()
//        .frame(width: 140)
//        .background(Color("MistyAqua"))
//        .cornerRadius(12)
//    }
//}
//
//struct ActiveGoalCard: View {
//    let goal: Goal
//    let onAddTap: () -> Void
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(goal.name).font(.headline)
//
//            Text("₹\(Int(goal.savedAmount)) / ₹\(Int(goal.targetAmount))")
//                .font(.title3.bold())
//                .foregroundColor(.green)
//
//            Text("\(goal.monthsLeft) months left")
//                .font(.caption)
//                .foregroundColor(.gray)
//
//            ProgressView(value: goal.progress)
//                .tint(Color("CaribbeanTeal"))
//
//            Button(action: onAddTap) {
//                HStack {
//                    Image(systemName: "plus")
//                    Text("Add to this Goal")
//                }
//                .foregroundColor(.white)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color("CaribbeanTeal"))
//                .cornerRadius(10)
//            }
//        }
//        .padding()
//        .background(Color("MistyAqua"))
//        .cornerRadius(16)
//    }
//}
// MARK: - Updated Goals View with Savings Integration
struct GoalsView: View {
    @EnvironmentObject var savingsModel: SavingsModel
    @EnvironmentObject var goalsModel: GoalsModel
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var spendingModel: SpendingModel  // ✅ Added for savings calculation

    @State private var currentSavings: Double = 0
    @State private var goalName = ""
    @State private var goalAmount = ""
    @State private var targetDate = Date()
    @State private var showPicker = false
    @State private var isCreatingGoal = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isInitialLoad = true

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // ✅ Enhanced savings card with breakdown
                    enhancedSavingsCard

                    if let first = goalsModel.goals.first {
                        ActiveGoalCard(goal: first) {
                            goalsModel.selectedGoalId = first.id
                        }
                    }

                    if goalsModel.goals.count > 1 {
                        Text("Other Goals")
                            .font(.headline)
                            .foregroundColor(.gray)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(goalsModel.goals.dropFirst()) { goal in
                                    MiniGoalCard(goal: goal)
                                        .onTapGesture {
                                            goalsModel.selectedGoalId = goal.id
                                        }
                                }
                            }.padding(.horizontal)
                        }
                    }

                    createGoalSection
                }
                .padding()
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationDestination(
            item: Binding<GoalRef?>(
                get: { goalsModel.selectedGoalId.map { GoalRef(id: $0) } },
                set: { goalsModel.selectedGoalId = $0?.id }
            )
        ) { ref in
            if let goal = goalsModel.goals.first(where: { $0.id == ref.id }) {
                GoalDetailView(goal: goal, savings: $currentSavings)
                    .environmentObject(savingsModel)
                    .environmentObject(goalsModel)
            } else {
                Text("Goal not found")
            }
        }
        .onAppear {
            // Only load from server on initial appearance
            if isInitialLoad {
                isInitialLoad = false
                Task {
                    await loadGoalsAndSavings()
                }
            } else {
                updateCurrentSavings()
            }
        }
        .onChange(of: savingsModel.availableSavings) { newVal in
            currentSavings = newVal
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private var topBar: some View {
        HStack {
            Text("Goals")
                .font(.title.bold())
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(Color("PeacockBlue"))
    }

    // ✅ Enhanced savings card with breakdown
    private var enhancedSavingsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Savings")
                    .font(.headline)
                    .foregroundColor(Color("Charcoal"))
                Spacer()
            }
            
            VStack(spacing: 8) {
                // Available Savings
                HStack {
                    Text("Available for Goals")
                        .font(.subheadline)
                    Spacer()
                    Text("₹\(Int(savingsModel.availableSavings))")
                        .font(.headline.bold())
                        .foregroundColor(.green)
                }
                
                // Total in Goals
                if savingsModel.totalGoalSavings > 0 {
                    HStack {
                        Text("Already in Goals")
                            .font(.subheadline)
                        Spacer()
                        Text("₹\(Int(savingsModel.totalGoalSavings))")
                            .font(.subheadline.bold())
                            .foregroundColor(.blue)
                    }
                    
                    Divider()
                    
                    // Total Savings
                    HStack {
                        Text("Total Savings")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("₹\(Int(savingsModel.totalSavings))")
                            .font(.headline.bold())
                            .foregroundColor(Color("CaribbeanTeal"))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var createGoalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create New Goal")
                .font(.headline)
                .foregroundColor(.gray)

            TextField("What are you saving for?", text: $goalName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            TextField("Enter target amount", text: $goalAmount)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            Button {
                showPicker.toggle()
            } label: {
                HStack {
                    Text(targetDate, style: .date)
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "calendar")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            if showPicker {
                DatePicker("", selection: $targetDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }

            Button("Create Goal") {
                createGoal()
            }
            .disabled(isCreatingGoal)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isCreatingGoal ? Color.gray : Color("CaribbeanTeal"))
            .foregroundColor(.white)
            .cornerRadius(12)
            .overlay {
                if isCreatingGoal {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
            }
        }
    }
    
    // MARK: - Functions
    
    /// Load goals and recalculate savings
    private func loadGoalsAndSavings() async {
        await goalsModel.loadSafely()
        await recalculateSavings()
        updateCurrentSavings()
    }
    
    /// Recalculate savings based on income, expenses, and goals
    private func recalculateSavings() async {
        guard let userUUID = currentUserUUID() else { return }
        
        // Load expense data if needed
        await spendingModel.loadData(userId: userUUID)
        
        await MainActor.run {
            let income = Double(userProfile.monthlyIncome)
            let totalExpenses = spendingModel.foodSpent + spendingModel.travelSpent +
                               spendingModel.entertainmentSpent + spendingModel.shoppingSpent +
                               spendingModel.miscSpent
            
            savingsModel.loadSavingsWithGoals(
                income: income,
                totalExpenses: totalExpenses,
                goals: goalsModel.goals
            )
        }
    }
    
    private func updateCurrentSavings() {
        currentSavings = savingsModel.availableSavings
    }
    
    private func currentUserUUID() -> UUID? {
        guard let idString = userProfile.id else { return nil }
        return UUID(uuidString: idString)
    }
    
    private func createGoal() {
        let trimmedName = goalName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            showErrorAlert("Please enter a goal name.")
            return
        }
        
        guard let amountValue = Double(goalAmount), amountValue > 0 else {
            showErrorAlert("Please enter a valid amount.")
            return
        }
        
        guard targetDate > Date() else {
            showErrorAlert("Please select a future target date.")
            return
        }

        isCreatingGoal = true
        hideKeyboard()

        Task {
            let success = await goalsModel.createGoal(
                name: trimmedName,
                targetAmount: amountValue,
                targetDate: targetDate
            )
            
            await MainActor.run {
                isCreatingGoal = false
                
                if success {
                    // Recalculate savings after goal creation
                    Task {
                        await recalculateSavings()
                    }
                    
                    // Schedule notification
                    if let newGoal = goalsModel.goals.first {
                        NotificationManager.scheduleGoalReminder(
                            goalID: newGoal.id,
                            goalName: newGoal.name,
                            deadline: newGoal.targetDate
                        )
                    }
                    
                    // Reset form
                    goalName = ""
                    goalAmount = ""
                    targetDate = Date()
                    showPicker = false
                } else {
                    showErrorAlert("Failed to create goal. Please try again.")
                }
            }
        }
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - Enhanced Goal Detail View with Savings Integration
struct GoalDetailView: View {
    @ObservedObject var goal: Goal
    @Binding var savings: Double
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var savingsModel: SavingsModel
    @EnvironmentObject var goalsModel: GoalsModel
    @EnvironmentObject var spendingModel: SpendingModel
    @EnvironmentObject var userProfile: UserProfile

    @State private var showTransfer = false
    @State private var transferAmount = ""
    @State private var errorMsg: String?
    @State private var isTransferring = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color("PeacockBlue").ignoresSafeArea(edges: .top)

                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                    }

                    Spacer()

                    Text("Goal Details")
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    Spacer()
                    Image(systemName: "chevron.left")
                        .opacity(0)
                        .padding(.trailing, 8)
                }
                .padding(.horizontal)
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 16)
            }
            .frame(height: 80 + (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 16))

            Spacer()

            ScrollView {
                VStack(spacing: 24) {
                    // Goal Card
                    goalCard
                    
                    // Recommended Contribution Plan
                    contributionPlan
                    
                    // Transaction History
                    transactionHistory

                    // Add Button
                    addFundsButton
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showTransfer) {
            transferSheet
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.name)
                    .font(.title3.bold())
                Spacer()
                Text("Saved: ₹\(Int(goal.savedAmount))")
                    .foregroundColor(.green)
                    .font(.subheadline)
            }

            HStack {
                Text("Target: ₹\(Int(goal.targetAmount))")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                Spacer()
            }

            ProgressView(value: goal.progress)
                .tint(Color("CaribbeanTeal"))
                .frame(height: 8)
                .background(Color(.systemGray5))
                .cornerRadius(4)

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                Text("Deadline: \(goal.targetDate.formatted(date: .abbreviated, time: .omitted))")
                    .foregroundColor(.gray)
                    .font(.caption)
                Spacer()
                Text("\(goal.monthsLeft) mo left")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color("MistyAqua"))
        .cornerRadius(16)
    }
    
    private var contributionPlan: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended Contribution Plan")
                .font(.headline)
                .padding(.bottom, 4)

            let plan = fixedPlan(for: goal)
            if plan.isEmpty {
                Text("No schedule available.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                ForEach(Array(plan.enumerated()), id: \.offset) { _, item in
                    HStack {
                        Text(item.date.formatted(date: .abbreviated, time: .omitted))
                        Spacer()
                        Text("₹\(Int(item.amount))").bold()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var transactionHistory: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transaction History")
                .font(.headline)
                .padding(.bottom, 4)

            if goal.additions.isEmpty {
                Text("No transactions yet.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                ForEach(goal.additions.indices.reversed(), id: \.self) { i in
                    let add = goal.additions[i]
                    HStack {
                        VStack(alignment: .leading) {
                            Text("₹\(Int(add.amount))")
                                .font(.headline)
                            Text(add.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var addFundsButton: some View {
        Button {
            showTransfer = true
        } label: {
            HStack {
                Image(systemName: "plus")
                Text("Add to this Goal")
                    .fontWeight(.semibold)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("CaribbeanTeal"))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }

    // Fixed plan calculation
    private func fixedPlan(for goal: Goal) -> [(date: Date, amount: Double)] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: goal.createdAt)
        let target = cal.startOfDay(for: goal.targetDate)

        guard start <= target else { return [(target, goal.targetAmount)] }

        let months = cal.dateComponents([.month], from: start, to: target).month ?? 0
        let count = max(1, months == 0 ? 1 : months)

        var dates: [Date] = []
        if count == 1 {
            dates = [target]
        } else {
            for i in 1..<count {
                dates.append(cal.date(byAdding: .month, value: i, to: start) ?? target)
            }
            dates.append(target)
        }

        let total = max(0, goal.targetAmount)
        let base = floor(total / Double(count))
        var remainder = Int(total - base * Double(count))
        return dates.enumerated().map { _, d in
            var amt = base
            if remainder > 0 { amt += 1; remainder -= 1 }
            return (d, amt)
        }
    }

    private var transferSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Transfer from Savings")
                    .font(.headline)
                
                // ✅ Show available savings
                Text("Available: ₹\(Int(savingsModel.availableSavings))")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                TextField("₹0", text: $transferAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                if let msg = errorMsg {
                    Text(msg).foregroundColor(.red)
                }

                Button("Transfer") {
                    transferFunds()
                }
                .disabled(isTransferring)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isTransferring ? Color.gray : Color("CaribbeanTeal"))
                .foregroundColor(.white)
                .cornerRadius(10)
                .overlay {
                    if isTransferring {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                }
            }
            .padding()
            .navigationTitle("Add Funds")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showTransfer = false }
                }
            }
        }
        .presentationDetents([.height(350)])
    }
    
    private func transferFunds() {
        guard let amt = Double(transferAmount), amt > 0 else {
            errorMsg = "Please enter a valid amount."
            return
        }

        // ✅ Use savingsModel.availableSavings instead of local savings binding
        if amt > savingsModel.availableSavings {
            errorMsg = "You don't have enough available savings."
            return
        }
        
        isTransferring = true
        errorMsg = nil

        Task {
            // ✅ Update using savingsModel
            let transferSuccess = await MainActor.run {
                savingsModel.transferToGoal(amount: amt)
            }
            
            if transferSuccess {
                await MainActor.run {
                    withAnimation {
                        goal.savedAmount += amt
                        goal.additions.append((amt, Date()))
                        
                        // Update binding for backward compatibility
                        savings = savingsModel.availableSavings
                    }
                }
                
                // Persist to server
                await goalsModel.updateGoal(goal)
                
                // Recalculate savings to ensure consistency
                await recalculateSavingsAfterTransfer()
            }
            
            await MainActor.run {
                isTransferring = false
                transferAmount = ""
                errorMsg = nil
                showTransfer = false
            }
        }
    }
    
    /// Recalculate savings after transfer to maintain consistency
    private func recalculateSavingsAfterTransfer() async {
        guard let userUUID = currentUserUUID() else { return }
        
        await MainActor.run {
            let income = Double(userProfile.monthlyIncome)
            let totalExpenses = spendingModel.foodSpent + spendingModel.travelSpent +
                               spendingModel.entertainmentSpent + spendingModel.shoppingSpent +
                               spendingModel.miscSpent
            
            savingsModel.recalculateAfterGoalUpdate(
                income: income,
                totalExpenses: totalExpenses,
                goals: goalsModel.goals
            )
        }
    }
    
    private func currentUserUUID() -> UUID? {
        guard let idString = userProfile.id else { return nil }
        return UUID(uuidString: idString)
    }
}

// MARK: - Card Components (unchanged)
struct MiniGoalCard: View {
    let goal: Goal
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(goal.name)
                .font(.subheadline)
                .lineLimit(1)

            ProgressView(value: goal.progress)
                .tint(Color("CaribbeanTeal"))
                .frame(width: 120)

            Text("₹\(Int(goal.savedAmount))/₹\(Int(goal.targetAmount))")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 140)
        .background(Color("MistyAqua"))
        .cornerRadius(12)
    }
}

struct ActiveGoalCard: View {
    let goal: Goal
    let onAddTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(goal.name).font(.headline)

            Text("₹\(Int(goal.savedAmount)) / ₹\(Int(goal.targetAmount))")
                .font(.title3.bold())
                .foregroundColor(.green)

            Text("\(goal.monthsLeft) months left")
                .font(.caption)
                .foregroundColor(.gray)

            ProgressView(value: goal.progress)
                .tint(Color("CaribbeanTeal"))

            Button(action: onAddTap) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add to this Goal")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("CaribbeanTeal"))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color("MistyAqua"))
        .cornerRadius(16)
    }
}
