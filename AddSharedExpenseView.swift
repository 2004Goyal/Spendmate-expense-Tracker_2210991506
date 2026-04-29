//
//  AddSharedExpenseView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 30/06/25.
//

import Foundation
import SwiftUI
import Supabase

private struct ExpenseCreateModel: Codable {
    let title: String
    let amount: Double
    let paid_by: String
    let split_type: String
    let shared_with: [String]
    let group_id: String
}

struct AddGroupExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    @Binding var selectedGroup: GroupInfo?

    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var paidBy: String = "You"
    @State private var splitType: SplitType = .equal
    @State private var members: [String] = []
    @State private var selectedMembers = Set<String>()
    @State private var isSaving = false
    @State private var errorText: String?

    enum SplitType: String, CaseIterable { case equal = "Split Equally", custom = "Custom Split" }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with single back button
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Add Group Expense")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                // spacer to balance layout
                Image(systemName: "chevron.left")
                    .foregroundColor(.clear)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color("PeacockBlue"))

            ScrollView {
                VStack(spacing: 16) {

                    // Title
                    labeledField("Expense Title") {
                        TextField("e.g., Dinner at Café Mocha", text: $title)
                    }

                    // Amount
                    labeledField("Amount") {
                        TextField("₹ Enter total amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }

                    // Paid By
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Paid By").font(.subheadline)
                        Picker("", selection: $paidBy) {
                            Text("You").tag("You")
                            ForEach(members.filter { $0 != "You" }, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }

                    // Segmented control with colored background bar
                    // MARK: - Members card WITH segmented control inside
                    VStack(spacing: 0) {
                        // Segmented control as the card header
                        HStack(spacing: 0) {
                            ForEach(SplitType.allCases, id: \.self) { tab in
                                Button {
                                    withAnimation {
                                        splitType = tab
                                        syncSelectionForSplitType()
                                    }
                                } label: {
                                    Text(tab.rawValue)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(splitType == tab ? .white : .black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(splitType == tab ? Color(hex: "#0097A7") : Color.clear)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(6)
                        .background(Color("MistyAqua"))      // colored bar behind segments, inside the card
                        .cornerRadius(12)
                        .padding([.top, .horizontal], 10)
                        .padding(.bottom, 8)

                        // Members list with ticks
                        VStack(spacing: 10) {
                            ForEach(members, id: \.self) { name in
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(.systemGray4))
                                        .frame(width: 36, height: 36)
                                        .overlay(Text(initial(of: name)).foregroundColor(.white).bold())

                                    Text(name).foregroundColor(.black)
                                    Spacer()

                                    let isOn = isMemberSelected(name)
                                    Image(systemName: isOn ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(isOn ? Color(hex: "#0097A7") : .gray)
                                        .onTapGesture { toggleMember(name) }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    }
                    .background(Color(.systemGray6))  // the members card background
                    .cornerRadius(12)

                    // Summary card (single color with white text)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Summary")
                            .font(.headline)
                            .foregroundColor(.white)
                        summaryRow("Paid by", value: paidBy)
                        summaryRow("Split type", value: splitType == .equal ? "Equal" : "Custom")
                        summaryRow("Your share", value: "₹\(Int(yourShare))")
                        summaryRow("Others share", value: "₹\(Int(othersShare))")
                    }
                    .padding()
                    .background(Color(hex: "#0097A7"))  // <-- single solid color
                    .cornerRadius(16)

                    if let err = errorText {
                        Text(err).foregroundColor(.red).font(.footnote)
                    }

                    Button {
                        Task { await saveExpense() }
                    } label: {
                        Text(isSaving ? "Saving..." : "Add Expense to Group")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isSaving ? Color.gray : Color(hex: "#0097A7"))
                            .cornerRadius(12)
                    }
                    .disabled(isSaving)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .background(Color("MistyAqua").ignoresSafeArea())
        }
        .onAppear {
            guard let group = selectedGroup else { return }
            let me = userDisplayName
            var list = group.members
            if !list.contains(me) { list.insert(me, at: 0) }
            members = list.map { $0 == me ? "You" : $0 }
            selectedMembers = Set(members) // default: equal split = everyone
        }
        .onChange(of: splitType) { _ in syncSelectionForSplitType() }
        .navigationBarBackButtonHidden(true)      // <-- hide default back button to avoid 2
    }

    // MARK: - UI helpers

    func labeledField(_ title: String, @ViewBuilder field: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline)
            field()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }

    func summaryRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.white)
            Spacer()
            Text(value).foregroundColor(.white).bold()
        }
    }

    var userDisplayName: String {
        userProfile.fullName.isEmpty ? "You" : userProfile.fullName
    }

    func initial(of name: String) -> String {
        (name == "You" ? userDisplayName : name)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .first.map { String($0) } ?? "?"
    }

    func isMemberSelected(_ name: String) -> Bool {
        splitType == .equal ? true : selectedMembers.contains(name)
    }

    func toggleMember(_ name: String) {
        guard splitType == .custom else { return }
        if selectedMembers.contains(name) { selectedMembers.remove(name) }
        else { selectedMembers.insert(name) }
    }

    func syncSelectionForSplitType() {
        if splitType == .equal {
            selectedMembers = Set(members)
        } else {
            selectedMembers = ["You"]
        }
    }

    var selectedForSplit: [String] {
        splitType == .equal ? members : Array(selectedMembers)
    }

    var amountValue: Double {
        Double(amount.replacingOccurrences(of: "₹", with: "").trimmingCharacters(in: .whitespaces)) ?? 0
    }

    var yourShare: Double {
        guard amountValue > 0 else { return 0 }
        let count = max(selectedForSplit.count, 1)
        let share = amountValue / Double(count)
        return selectedForSplit.contains("You") ? share : 0
    }

    var othersShare: Double {
        guard amountValue > 0 else { return 0 }
        let count = max(selectedForSplit.count, 1)
        let share = amountValue / Double(count)
        let othersCount = selectedForSplit.filter { $0 != "You" }.count
        return share * Double(othersCount)
    }

    // MARK: - Save
    private func saveExpense() async {
        guard let group = selectedGroup else { return }
        guard amountValue > 0 else { errorText = "Please enter a valid amount."; return }
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorText = "Please enter a title."; return
        }

        let actualPaidBy = (paidBy == "You") ? userDisplayName : paidBy
        let actualShared = selectedForSplit.map { $0 == "You" ? userDisplayName : $0 }

        let payload = ExpenseCreateModel(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amountValue,
            paid_by: actualPaidBy,
            split_type: splitType.rawValue,
            shared_with: actualShared,
            group_id: group.id
        )

        do {
            isSaving = true
            try await SupabaseManager.shared.client
                .from("Expenses")
                .insert(payload)
                .execute()
            isSaving = false
            dismiss()
        } catch {
            isSaving = false
            errorText = "Failed to save expense: \(error.localizedDescription)"
            print("❌ Save expense error:", error)
        }
    }
}
