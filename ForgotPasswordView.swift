//
//  ForgotPasswordView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Title
                Text("Forgot Password?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("PeacockBlue"))

                // Subtitle
                Text("Enter your registered email to receive a reset link.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                // Email Input
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email Address")
                        .font(.subheadline)
                        .foregroundColor(.black)

                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                // Send Link Button
                Button(action: {
                    Task { await sendResetLink() }
                }) {
                    Text("Send Reset Link")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("CaribbeanTeal"))
                        .cornerRadius(12)
                }

                // Back Button
                Button("Back to Sign In") {
                    dismiss()
                }
                .font(.footnote)
                .foregroundColor(.gray)

                Spacer()
            }
            .padding(.horizontal, 24)
            .background(Color("MistyAqua"))
            .ignoresSafeArea()
            .alert("Password Reset", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Reset Email Logic
    func sendResetLink() async {
        do {
            try await SupabaseManager.shared.client.auth.resetPasswordForEmail(
                email,
                redirectTo: URL(string: "myapp://reset")!
            )
            alertMessage = "✅ Reset link sent to your email."
        } catch {
            alertMessage = "❌ Failed to send reset link."
            print("Reset password error:", error)
        }
        showAlert = true
    }
}
