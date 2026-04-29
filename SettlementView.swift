//
//  SettlementView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 30/06/25.
//

import Foundation
import SwiftUI


struct SettleUpView: View {
    let groupID: String
    let payeeName: String
    var amountOwed: Double

    @EnvironmentObject var userProfile: UserProfile
    @Environment(\.dismiss) var dismiss

    @State private var amount = ""
    @State private var selectedDate = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @StateObject private var viewModel = GroupSettlementViewModel()

    var body: some View {
        VStack(spacing: 24) {
            // Title
            Text("Settle Up")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            // Info Card
            VStack(alignment: .leading, spacing: 12) {
                Text("You owe")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    Text(payeeName)
                        .font(.headline)
                    Spacer()
                    Text("₹\(Int(amountOwed))")
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)

            // Input Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Enter amount to pay:")
                    .font(.subheadline)

                TextField("₹\(Int(amountOwed))", text: $amount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))

                DatePicker("Select settlement date", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            // Save Button
            Button {
                settleTransaction()
            } label: {
                Text(viewModel.isSettling ? "Saving..." : "Save Transaction")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isSettling ? Color.gray : Color(hex: "#0097A7"))
                    .cornerRadius(10)
            }
            .disabled(viewModel.isSettling)

            Spacer()
        }
        .padding(.top)
        .background(Color.white.ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Settlement Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                }
            )
        }
    }

    func settleTransaction() {
        let paidAmount = Double(amount.replacingOccurrences(of: "₹", with: "").trimmingCharacters(in: .whitespaces)) ?? 0.0

        if paidAmount <= 0 {
            alertMessage = "Please enter a valid amount."
            showAlert = true
            return
        }

        guard let uuid = UUID(uuidString: groupID) else {
            alertMessage = "Invalid group ID."
            showAlert = true
            return
        }

        let payer = userProfile.fullName.isEmpty ? "You" : userProfile.fullName

        viewModel.settleUp(groupID: uuid, payerName: payer, payeeName: payeeName, amount: paidAmount) { success in
            if success {
                alertMessage = "✅ You paid ₹\(Int(paidAmount)) to \(payeeName)."
            } else {
                alertMessage = "❌ Failed to save settlement. Please try again."
            }
            showAlert = true
        }
    }
}
