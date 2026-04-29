//
//  Balances.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 05/07/25.
//

import Foundation
import SwiftUI

// MARK: - Reminders
func sendReminder(to name: String, amount: Double) {
    let content = UNMutableNotificationContent()
    content.title = "💰 Reminder to Pay"
    content.body = "\(name), you owe ₹\(Int(amount)). Time to settle up!"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("❌ Notification error: \(error)")
        } else {
            print("✅ Reminder sent to \(name)")
        }
    }
}

// MARK: - Who Owes Whom
struct WhoOwesWhomView: View {
    let expenses: [ExpenseInfo]
    let currentUser: String

    @Binding var selectedPayee: String
    @Binding var selectedAmount: Double
    @Binding var showSettleUp: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Section: You owe ...
            if !userOwes.isEmpty {
                ForEach(userOwes, id: \.name) { entry in
                    balanceRow(
                        leadingInitial: initial(of: entry.name),
                        title: "You owe \(entry.name) ₹\(Int(entry.amount))",
                        subtitle: "From \(entry.count) \(entry.count == 1 ? "expense" : "expenses")",
                        titleColor: .red,
                        trailingActionTitle: "Settle Up",
                        trailingAction: {
                            selectedPayee = entry.name
                            selectedAmount = entry.amount
                            showSettleUp = true
                        }
                    )
                }
            }

            // Section: ... owes you
            if !othersOweYou.isEmpty {
                ForEach(othersOweYou, id: \.name) { entry in
                    balanceRow(
                        leadingInitial: initial(of: entry.name),
                        title: "\(entry.name) owes you ₹\(Int(entry.amount))",
                        subtitle: "From \(entry.count) \(entry.count == 1 ? "expense" : "expenses")",
                        titleColor: Color(hex: "#0097A7"),
                        trailingActionTitle: "Remind",
                        trailingAction: { sendReminder(to: entry.name, amount: entry.amount) }
                    )
                }
            }

            if userOwes.isEmpty && othersOweYou.isEmpty {
                Text("No balances yet.")
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Helpers
    func balanceRow(
        leadingInitial: String,
        title: String,
        subtitle: String,
        titleColor: Color,
        trailingActionTitle: String,
        trailingAction: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color(hex: "#0097A7"))
                .frame(width: 36, height: 36)
                .overlay(Text(leadingInitial).foregroundColor(.white).bold())

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline).foregroundColor(titleColor)
                Text(subtitle).font(.caption).foregroundColor(.gray)
            }
            Spacer()
            Button(trailingActionTitle) { trailingAction() }
                .font(.footnote)
                .foregroundColor(Color(hex: "#0097A7"))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    func initial(of name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased().first.map { String($0) } ?? "?"
    }

    // You owe others
    var userOwes: [(name: String, amount: Double, count: Int)] {
        var total: [String: (amount: Double, count: Int)] = [:]
        for exp in expenses where exp.paidBy != currentUser && exp.sharedWith.contains(currentUser) {
            let share = exp.amount / Double(max(exp.sharedWith.count, 1))
            let item = total[exp.paidBy] ?? (0, 0)
            total[exp.paidBy] = (item.amount + share, item.count + 1)
        }
        return total.map { ($0.key, $0.value.amount, $0.value.count) }
    }

    // Others owe you
    var othersOweYou: [(name: String, amount: Double, count: Int)] {
        var total: [String: (amount: Double, count: Int)] = [:]
        for exp in expenses where exp.paidBy == currentUser {
            let share = exp.amount / Double(max(exp.sharedWith.count, 1))
            for member in exp.sharedWith where member != currentUser {
                let item = total[member] ?? (0, 0)
                total[member] = (item.amount + share, item.count + 1)
            }
        }
        return total.map { ($0.key, $0.value.amount, $0.value.count) }
    }
}
