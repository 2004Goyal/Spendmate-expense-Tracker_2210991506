//
//  UserTypeView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI

//struct MonthlyIncomeInputView: View {
//    @State private var monthlyIncome: String = ""
//    @State private var navigateToSignIn = false
//    @State private var showError = false
//
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var userProfile: UserProfile
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color("MistyAqua").ignoresSafeArea()
//
//                VStack(alignment: .leading, spacing: 24) {
//                    HStack {
//                        Button(action: { dismiss() }) {
//                            Image(systemName: "chevron.left")
//                                .font(.title3)
//                                .foregroundColor(Color("PeacockBlue"))
//                        }
//                        Spacer()
//                    }
//                    .padding(.top)
//
//                    Text("How much do you earn monthly?")
//                        .font(.title2.bold())
//                        .foregroundColor(Color("PeacockBlue"))
//
//                    Text("We’ll use this to plan your budget")
//                        .font(.subheadline)
//                        .foregroundColor(Color("SlateGray"))
//
//                    HStack {
//                        Text("₹")
//                            .foregroundColor(.gray)
//                        TextField("Enter your monthly income", text: $monthlyIncome)
//                            .keyboardType(.numberPad)
//                            .foregroundColor(Color("Charcoal"))
//                    }
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(12)
//
//                    if showError {
//                        Text("⚠️ Please enter a valid monthly income.")
//                            .font(.footnote)
//                            .foregroundColor(.red)
//                    }
//
//                    Spacer()
//
//                    NavigationLink(destination: SignInView().navigationBarBackButtonHidden(true), isActive: $navigateToSignIn) {
//                        EmptyView()
//                    }
//
//                    Button(action: {
//                        if isValidIncome() {
//                            userProfile.monthlyIncome = Int(monthlyIncome) ?? 0
//                            Task {
//                                await userProfile.save()
//                                navigateToSignIn = true
//                            }
//                        } else {
//                            showError = true
//                        }
//                    }) {
//                        Text("Finish")
//                            .foregroundColor(.white)
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(isValidIncome() ? Color("CaribbeanTeal") : Color.gray.opacity(0.4))
//                            .cornerRadius(12)
//                    }
//                    .disabled(!isValidIncome())
//                }
//                .padding(.horizontal, 24)
//            }
//        }
//    }
//
//    private func isValidIncome() -> Bool {
//        return !monthlyIncome.isEmpty && Int(monthlyIncome) != nil
//    }
//}
//
import SwiftUI

struct MonthlyIncomeInputView: View {
    @State private var monthlyIncome: String = ""
    @State private var navigateToSignIn = false
    @State private var showError = false

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userProfile: UserProfile

    // ✅ Needed because SignInView(heroNamespace:) now requires a namespace
    @Namespace private var heroNS

    var body: some View {
        NavigationStack {
            ZStack {
                Color("MistyAqua").ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    // Top bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(Color("PeacockBlue"))
                        }
                        Spacer()
                    }
                    .padding(.top)

                    Text("How much do you earn monthly?")
                        .font(.title2.bold())
                        .foregroundColor(Color("PeacockBlue"))

                    Text("We’ll use this to plan your budget")
                        .font(.subheadline)
                        .foregroundColor(Color("SlateGray"))

                    // Input
                    HStack {
                        Text("₹").foregroundColor(.gray)
                        TextField("Enter your monthly income", text: $monthlyIncome)
                            .keyboardType(.numberPad)
                            .foregroundColor(Color("Charcoal"))
                            .onChange(of: monthlyIncome) { newValue in
                                // allow only digits
                                monthlyIncome = newValue.filter(\.isNumber)
                            }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)

                    if showError {
                        Text("⚠️ Please enter a valid monthly income.")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }

                    Spacer()

                    // Programmatic nav to SignInView (with hero namespace)
                    NavigationLink(
                        destination: SignInView(heroNamespace: heroNS)
                            .navigationBarBackButtonHidden(true),
                        isActive: $navigateToSignIn
                    ) { EmptyView() }

                    Button(action: saveAndGo) {
                        Text("Finish")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValidIncome() ? Color("CaribbeanTeal") : Color.gray.opacity(0.4))
                            .cornerRadius(12)
                    }
                    .disabled(!isValidIncome())
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func isValidIncome() -> Bool {
        let trimmed = monthlyIncome.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return false }
        if let val = Int(trimmed), val > 0 { return true }
        return false
    }

    private func saveAndGo() {
        if isValidIncome() {
            userProfile.monthlyIncome = Int(monthlyIncome) ?? 0
            Task {
                await userProfile.save()
                // ensure UI update on main actor
                await MainActor.run { navigateToSignIn = true }
            }
            showError = false
        } else {
            showError = true
        }
    }
}
