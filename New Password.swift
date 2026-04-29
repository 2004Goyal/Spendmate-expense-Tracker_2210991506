//
//  New Password.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 05/07/25.
//

import Foundation
import SwiftUI

struct CreateNewPasswordView: View {
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var passwordUpdated = false
    @State private var navigateToSignIn = false
    @State private var showValidationError = false

    // ✅ Needed because SignInView(heroNamespace:) requires a namespace
    @Namespace private var heroNS

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                // Lock Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "#0097A7"))
                        .frame(width: 100, height: 100)
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }

                // Title
                Text("Create a New Password")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#005F6A"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                // New Password Field
                passwordField(
                    title: "New Password",
                    text: $newPassword,
                    showPassword: $showNewPassword
                )

                // Confirm Password Field
                passwordField(
                    title: "Confirm Password",
                    text: $confirmPassword,
                    showPassword: $showConfirmPassword
                )

                // Hint
                Text("Use 1 capital letter, 1 number, and 1 special character")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#6B7280"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                // Error Message
                if showValidationError {
                    Text("Passwords do not match or format is invalid.")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }

                // Update Password Button
                Button(action: {
                    if newPassword == confirmPassword && isValidPassword(newPassword) {
                        passwordUpdated = true
                        showValidationError = false
                    } else {
                        showValidationError = true
                    }
                }) {
                    Text("Update Password")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#0097A7"))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Success Message and Navigation
                if passwordUpdated {
                    VStack(spacing: 12) {
                        Text("Password reset successfully!")
                            .foregroundColor(Color(hex: "#0097A7"))
                            .font(.subheadline)
                            .fontWeight(.medium)

                        // ✅ Pass heroNamespace here
                        NavigationLink(
                            destination: SignInView(heroNamespace: heroNS)
                                .navigationBarBackButtonHidden(true),
                            isActive: $navigateToSignIn
                        ) { EmptyView() }

                        Button("Sign In") {
                            navigateToSignIn = true
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#005F6A"))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.top)
            .background(Color(hex: "#D4F1F4").ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: - Reusable Password Field
    func passwordField(title: String, text: Binding<String>, showPassword: Binding<Bool>) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#0097A7"), lineWidth: 1)
                .background(Color.white.cornerRadius(10))

            HStack {
                if showPassword.wrappedValue {
                    TextField(title, text: text)
                        .textInputAutocapitalization(.never)
                } else {
                    SecureField(title, text: text)
                        .textInputAutocapitalization(.never)
                }

                Button(action: { showPassword.wrappedValue.toggle() }) {
                    Image(systemName: showPassword.wrappedValue ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 56)
        .padding(.horizontal)
    }

    // MARK: - Validation
    func isValidPassword(_ password: String) -> Bool {
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let numberRegEx = ".*[0-9]+.*"
        let specialCharacterRegEx = ".*[!&^%$#@()/]+.*"
        let testCapital = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let testNumber = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let testSpecial = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        return testCapital.evaluate(with: password) &&
               testNumber.evaluate(with: password) &&
               testSpecial.evaluate(with: password) &&
               password.count >= 6
    }
}


