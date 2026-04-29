//
//  SavingsModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 17/07/25.
//

// SavingsModel.swift
import Foundation
import SwiftUI

//class SavingsModel: ObservableObject {
//    @Published var savingsFromReport: Double = 0
//}


@MainActor
class SavingsModel: ObservableObject {
    @Published var savingsFromReport: Double = 0
    @Published var totalGoalSavings: Double = 0
    @Published var availableSavings: Double = 0
    
    /// Calculate and update all savings values
    func updateSavings(income: Double, totalExpenses: Double, goals: [Goal]) {
        // Calculate total amount saved in goals
        totalGoalSavings = goals.reduce(0) { total, goal in
            total + goal.savedAmount
        }
        
        // Calculate theoretical savings (income - expenses)
        let theoreticalSavings = max(income - totalExpenses, 0)
        
        // Available savings = theoretical savings - amount already allocated to goals
        availableSavings = max(theoreticalSavings - totalGoalSavings, 0)
        
        // Update the main savings value (for backward compatibility)
        savingsFromReport = availableSavings
    }
    
    /// Transfer money from available savings to a goal
    func transferToGoal(amount: Double) -> Bool {
        guard amount > 0 && amount <= availableSavings else {
            return false
        }
        
        availableSavings -= amount
        savingsFromReport = availableSavings
        return true
    }
    
    /// Get total savings (available + goals)
    var totalSavings: Double {
        availableSavings + totalGoalSavings
    }
    
    /// Get savings breakdown for reporting
    var savingsBreakdown: (available: Double, goals: Double, total: Double) {
        (available: availableSavings, goals: totalGoalSavings, total: totalSavings)
    }
}

// MARK: - SavingsModel Extensions for Goal Integration
extension SavingsModel {
    /// Load and calculate savings with goal data
    func loadSavingsWithGoals(
        income: Double,
        totalExpenses: Double,
        goals: [Goal]
    ) {
        updateSavings(income: income, totalExpenses: totalExpenses, goals: goals)
    }
    
    /// Recalculate savings when goals are updated
    func recalculateAfterGoalUpdate(
        income: Double,
        totalExpenses: Double,
        goals: [Goal]
    ) {
        updateSavings(income: income, totalExpenses: totalExpenses, goals: goals)
    }
}
