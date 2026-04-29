//
//  IncomeInputView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI

struct IncomeInputView: View {
    @State private var selectedSource: String? = nil
    @State private var navigateToMonthlyIncome = false
    @State private var showError = false

    @EnvironmentObject var userProfile: UserProfile

    let options: [(icon: String, label: String)] = [
        ("briefcase", "Self-Employed"),
        ("person.2.fill", "Parents"),
        ("clock", "Part-Time Job"),
        ("laptopcomputer", "Freelancing")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color("MistyAqua").ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("What's your source of income?")
                        .font(.title2.bold())
                        .foregroundColor(Color("PeacockBlue"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 32)

                    ForEach(options, id: \.label) { option in
                        IncomeOptionCard(
                            iconName: option.icon,
                            title: option.label,
                            isSelected: selectedSource == option.label
                        ) {
                            selectedSource = option.label
                            showError = false
                        }
                    }

                    if showError {
                        Text("⚠️ Please select one income source.")
                            .foregroundColor(.red)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, -10)
                    }

                    Spacer()

                    NavigationLink(destination: MonthlyIncomeInputView().environmentObject(userProfile).navigationBarBackButtonHidden(true), isActive: $navigateToMonthlyIncome) {
                        EmptyView()
                    }

                    Button(action: {
                        if let selected = selectedSource {
                            userProfile.incomeSource = selected
                            navigateToMonthlyIncome = true
                        } else {
                            showError = true
                        }
                    }) {
                        Text("Continue")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedSource != nil ? Color("CaribbeanTeal") : Color.gray.opacity(0.5))
                            .cornerRadius(12)
                    }
                    .disabled(selectedSource == nil)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct IncomeOptionCard: View {
    var iconName: String
    var title: String
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.black)

                Text(title)
                    .foregroundColor(.black)

                Spacer()

                Circle()
                    .strokeBorder(Color("CaribbeanTeal"), lineWidth: 2)
                    .background(Circle().fill(isSelected ? Color("CaribbeanTeal") : Color.clear))
                    .frame(width: 24, height: 24)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}
