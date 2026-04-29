//
//  Totals.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 05/07/25.
//

import SwiftUI

struct GroupSummaryView: View {
    let expenses: [ExpenseInfo]
    let currentUser: String

    var totalSpending: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var yourContribution: Double {
        expenses.filter { $0.paidBy == currentUser }.reduce(0) { $0 + $1.amount }
    }

    var yourShare: Double {
        expenses
            .filter { $0.sharedWith.contains(currentUser) }
            .reduce(0) { $0 + ($1.amount / Double(max($1.sharedWith.count, 1))) }
    }

    var balance: Double { yourContribution - yourShare }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Group Summary")
                .font(.title2.bold())
                .padding(.horizontal)

            VStack(spacing: 12) {
                HStack {
                    Text("Group Total").bold()
                    Spacer()
                    Text("₹\(Int(totalSpending))")
                }
                HStack {
                    Text("My Contribution")
                    Spacer()
                    Text("₹\(Int(yourContribution))")
                }
                HStack {
                    Text("My Share")
                    Spacer()
                    Text("₹\(Int(yourShare))")
                }
                HStack {
                    Text("My Balance")
                    Spacer()
                    Text((balance >= 0 ? "+" : "") + "₹\(Int(balance))")
                        .foregroundColor(balance >= 0 ? .green : .red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}
