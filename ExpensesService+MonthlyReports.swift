//
//  ExpensesService+MonthlyReports.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 19/08/25.
//

import Foundation

// MARK: - ExpensesService Extensions for Monthly Reports
extension ExpensesService {
    /// Fetch expenses for a specific date range
    func fetchExpensesForDateRange(for userId: UUID, from: Date, to: Date) async throws -> [String: Double] {
        let fromString = DateFormatter.yyyyMMdd.string(from: from)
        let toString = DateFormatter.yyyyMMdd.string(from: to)

        let rows: [Row] = try await client
            .from("expenses")
            .select()
            .eq("user_id", value: userId.uuidString)
            .gte("date", value: fromString)
            .lte("date", value: toString)
            .order("date", ascending: false)
            .execute()
            .value

        var totals: [String: Double] = [:]
        for row in rows {
            let key = canonicalCategory(row.category)
            totals[key, default: 0] += row.amount
        }
        return totals
    }
    
    /// Fetch recent expenses with month filtering (optional enhancement)
    func fetchRecentExpensesForMonth(for userId: UUID, month: String, limit: Int = 3) async throws -> [ExpenseListItem] {
        let from = "\(month)-01"
        let to = "\(month)-31"
        
        let resp = try await client
            .from("expenses")
            .select("*")
            .eq("user_id", value: userId.uuidString)
            .gte("date", value: from)
            .lte("date", value: to)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()

        return try JSONDecoder().decode([ExpenseListItem].self, from: resp.data)
    }
    
    /// Fetch history for a specific month (optional enhancement)
    func fetchHistoryForMonth(for userId: UUID, month: String) async throws -> [ExpenseListItem] {
        let from = "\(month)-01"
        let to = "\(month)-31"
        
        let resp = try await client
            .from("expenses")
            .select("*")
            .eq("user_id", value: userId.uuidString)
            .gte("date", value: from)
            .lte("date", value: to)
            .order("created_at", ascending: false)
            .execute()

        return try JSONDecoder().decode([ExpenseListItem].self, from: resp.data)
    }
    
    /// Get expense data for multiple months (for comparison)
    func fetchExpensesForMonths(for userId: UUID, months: [String]) async throws -> [String: [String: Double]] {
        var results: [String: [String: Double]] = [:]
        
        for month in months {
            do {
                let monthData = try await fetchExpenses(for: userId, month: month)
                results[month] = monthData
            } catch {
                print("❌ Failed to fetch data for month \(month): \(error)")
                results[month] = [:]
            }
        }
        
        return results
    }
    
    /// Get daily expenses for a month (for detailed analytics)
    func fetchDailyExpensesForMonth(for userId: UUID, month: String) async throws -> [String: Double] {
        let from = "\(month)-01"
        let to = "\(month)-31"

        let rows: [Row] = try await client
            .from("expenses")
            .select()
            .eq("user_id", value: userId.uuidString)
            .gte("date", value: from)
            .lte("date", value: to)
            .order("date", ascending: true)
            .execute()
            .value

        var dailyTotals: [String: Double] = [:]
        for row in rows {
            dailyTotals[row.date, default: 0] += row.amount
        }
        return dailyTotals
    }
    
    /// Get spending trends (month over month comparison)
    func getSpendingTrends(for userId: UUID, months: Int = 6) async throws -> [MonthlyTrend] {
        let calendar = Calendar.current
        let today = Date()
        var trends: [MonthlyTrend] = []
        
        for i in 0..<months {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: today) else { continue }
            let monthString = DateFormatter.yyyyMM.string(from: monthDate)
            
            do {
                let expenses = try await fetchExpenses(for: userId, month: monthString)
                let total = expenses.values.reduce(0, +)
                
                trends.append(MonthlyTrend(
                    month: monthDate,
                    monthString: monthString,
                    totalSpent: total,
                    categoryBreakdown: expenses
                ))
            } catch {
                print("❌ Failed to get trend data for \(monthString): \(error)")
            }
        }
        
        return trends.reversed() // Show oldest to newest
    }
}

// MARK: - Data Models for Analytics
struct MonthlyTrend {
    let month: Date
    let monthString: String
    let totalSpent: Double
    let categoryBreakdown: [String: Double]
    
    var monthName: String {
        month.formatted(.dateTime.month(.wide))
    }
    
    var year: String {
        month.formatted(.dateTime.year())
    }
}

// MARK: - Helper Extensions
extension DateFormatter {
    static let monthName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    static let shortMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
}
