//
//  SpendingModel+Extensions.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 19/08/25.
//

import Foundation

// MARK: - SpendingModel Extensions for Monthly Reports
extension SpendingModel {
    /// Get total expenses for current loaded data
    var totalExpensesForDate: Double {
        foodSpent + travelSpent + entertainmentSpent + shoppingSpent + miscSpent
    }
    
    /// Load recent expenses for a specific date/month
    func loadRecentExpenses(userId: UUID, for date: Date, limit: Int = 3) async {
        // Use the existing public method that already works
        await loadRecentExpenses(userId: userId, limit: limit)
    }
    
    /// Load history for a specific date/month
    func loadHistory(userId: UUID, for date: Date) async {
        // Use the existing public method that already works
        await loadHistory(userId: userId)
    }
    
    /// Clear all data (useful when switching months)
    func clearData() {
        foodSpent = 0
        travelSpent = 0
        entertainmentSpent = 0
        shoppingSpent = 0
        miscSpent = 0
        recentExpenses.removeAll()
        history.removeAll()
    }
    
    /// Refresh all data for a specific date
    func refreshAllData(userId: UUID, for date: Date = .now) async {
        await loadData(userId: userId, for: date)
        await loadRecentExpenses(userId: userId, for: date)
        await loadHistory(userId: userId, for: date)
    }
    
    /// Get spending breakdown as dictionary
    var spendingBreakdown: [String: Double] {
        [
            "Food": foodSpent,
            "Travel": travelSpent,
            "Entertainment": entertainmentSpent,
            "Shopping": shoppingSpent,
            "Misc": miscSpent
        ]
    }
    
    /// Get spending percentages
    func getSpendingPercentages() -> [String: Double] {
        let total = totalExpensesForDate
        guard total > 0 else { return [:] }
        
        return [
            "Food": (foodSpent / total) * 100,
            "Travel": (travelSpent / total) * 100,
            "Entertainment": (entertainmentSpent / total) * 100,
            "Shopping": (shoppingSpent / total) * 100,
            "Misc": (miscSpent / total) * 100
        ]
    }
    
    /// Check if there's any spending data
    var hasSpendingData: Bool {
        totalExpensesForDate > 0
    }
    
    /// Get top spending categories (sorted by amount)
    var topSpendingCategories: [(String, Double)] {
        let categories = [
            ("Food", foodSpent),
            ("Travel", travelSpent),
            ("Entertainment", entertainmentSpent),
            ("Shopping", shoppingSpent),
            ("Misc", miscSpent)
        ]
        return categories.sorted { $0.1 > $1.1 }.filter { $0.1 > 0 }
    }
}
