//
//  NotificationManager.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 14/07/25.
//

import Foundation
import UserNotifications
import SwiftUI

//struct NotificationManager {
//    
//    // MARK: Permission (call once in App init)
//    static func requestPermission() {
//        UNUserNotificationCenter.current()
//            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//                if let error = error {
//                    print("❌ Notification error:", error.localizedDescription)
//                } else {
//                    print(granted ? "✅ Permission granted" : "❌ Permission denied")
//                }
//            }
//    }
//    
//    // MARK: Daily savings reminder (8 PM every day)
//    static func scheduleDailySavingsReminder() {
//        var comp = DateComponents()
//        comp.hour = 20                       // 8 PM
//        
//        let content = UNMutableNotificationContent()
//        content.title = "💰 Daily Savings Check"
//        content.body  = "Review today’s spending and keep your savings on track!"
//        content.sound = .default
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: true)
//        let req     = UNNotificationRequest(identifier: "daily_savings_check",
//                                            content: content,
//                                            trigger: trigger)
//        UNUserNotificationCenter.current().add(req)
//    }
//    
//    // MARK: Goal-deadline reminder (2 days before)
//    static func scheduleGoalReminder(goalID: UUID, goalName: String, deadline: Date) {
//        guard let remind = Calendar.current.date(byAdding: .day, value: -2, to: deadline) else { return }
//        var comp = Calendar.current.dateComponents([.year, .month, .day], from: remind)
//        comp.hour = 9
//        
//        let content = UNMutableNotificationContent()
//        content.title = "🎯 Goal Deadline Approaching"
//        content.body  = "Your goal “\(goalName)” is due soon. Add a bit more to reach it!"
//        content.sound = .default
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
//        let reqID   = "goal-\(goalID.uuidString)"
//        UNUserNotificationCenter.current().add(
//            UNNotificationRequest(identifier: reqID, content: content, trigger: trigger)
//        )
//    }
//    
//    // MARK: Expense over-limit alert  ← ★ This is the member you’re missing
//    static func sendExpenseLimitAlert(amount: Double, limit: Double) {
//        let content = UNMutableNotificationContent()
//        content.title = "⚠️ Spending Alert"
//        content.body  = "You’ve spent ₹\(Int(amount)) today, over your limit of ₹\(Int(limit))."
//        content.sound = .default
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//        UNUserNotificationCenter.current().add(
//            UNNotificationRequest(identifier: UUID().uuidString,
//                                  content: content,
//                                  trigger: trigger)
//        )
//    }
//}
//


import Foundation
import UserNotifications

class NotificationManager {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error)")
            }
        }
    }
    
    static func scheduleDailySavingsReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Savings Reminder"
        content.body = "Don't forget to track your expenses today!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailySavings", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule daily reminder: \(error)")
            } else {
                print("✅ Daily savings reminder scheduled")
            }
        }
    }
    
    static func scheduleGoalReminder(goalID: UUID, goalName: String, deadline: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Goal Reminder"
        content.body = "Don't forget about your goal: \(goalName)"
        content.sound = .default
        
        // Schedule reminder 1 day before deadline
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: deadline) ?? deadline
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: "goal_\(goalID.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule goal reminder: \(error)")
            } else {
                print("✅ Goal reminder scheduled for \(goalName)")
            }
        }
    }
    
    static func cancelGoalReminder(goalID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["goal_\(goalID.uuidString)"])
    }
}
