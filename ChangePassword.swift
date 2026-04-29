//
//  ChangePassword.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 16/07/25.
//

import Foundation
import SwiftUI

//struct UpdatePasswordView: View {
//    var onPasswordUpdated: () -> Void  // ✅ Completion handler
//
//    @State private var newPassword = ""
//    @State private var confirmPassword = ""
//    @State private var showNewPassword = false
//    @State private var showConfirmPassword = false
//    @State private var showSuccessAlert = false
//    @State private var showValidationError = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Spacer()
//
//            ZStack {
//                Circle()
//                    .fill(Color(hex: "#0097A7"))
//                    .frame(width: 100, height: 100)
//                Image(systemName: "lock.open.fill")
//                    .font(.system(size: 36))
//                    .foregroundColor(.white)
//            }
//
//            Text("Create a New Password")
//                .font(.title3)
//                .fontWeight(.semibold)
//                .foregroundColor(Color(hex: "#005F6A"))
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
//
//            passwordField("New Password", $newPassword, $showNewPassword)
//            passwordField("Confirm Password", $confirmPassword, $showConfirmPassword)
//
//            Text("Use 1 capital letter, 1 number, and 1 special character")
//                .font(.caption)
//                .foregroundColor(Color(hex: "#6B7280"))
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
//
//            if showValidationError {
//                Text("Passwords do not match or format is invalid.")
//                    .foregroundColor(.red)
//                    .font(.footnote)
//                    .padding(.horizontal)
//            }
//
//            Button("Update Password") {
//                if newPassword == confirmPassword && isValidPassword(newPassword) {
//                    showSuccessAlert = true
//                    showValidationError = false
//                } else {
//                    showValidationError = true
//                }
//            }
//            .foregroundColor(.white)
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color(hex: "#0097A7"))
//            .cornerRadius(10)
//            .padding(.horizontal)
//
//            Spacer()
//        }
//        .padding(.top)
//        .background(Color(hex: "#D4F1F4").ignoresSafeArea())
//        .alert("✅ Password updated successfully!", isPresented: $showSuccessAlert) {
//            Button("OK", role: .cancel) {
//                onPasswordUpdated()  // ✅ Call the handler
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//
//    func passwordField(_ title: String, _ text: Binding<String>, _ show: Binding<Bool>) -> some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color(hex: "#0097A7"))
//                .background(Color.white.cornerRadius(10))
//
//            HStack {
//                if show.wrappedValue {
//                    TextField(title, text: text).autocapitalization(.none)
//                } else {
//                    SecureField(title, text: text).autocapitalization(.none)
//                }
//
//                Button {
//                    show.wrappedValue.toggle()
//                } label: {
//                    Image(systemName: show.wrappedValue ? "eye.slash" : "eye")
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.horizontal)
//        }
//        .frame(height: 56)
//        .padding(.horizontal)
//    }
//
//    func isValidPassword(_ password: String) -> Bool {
//        let capital = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
//        let number = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")
//        let special = NSPredicate(format: "SELF MATCHES %@", ".*[!&^%$#@()/]+.*")
//        return capital.evaluate(with: password) &&
//               number.evaluate(with: password) &&
//               special.evaluate(with: password)
//    }
//}
import SwiftUI

import SwiftUI
import Supabase

//struct UpdatePasswordView: View {
//    var onPasswordUpdated: () -> Void  // ✅ Completion handler
//
//    @State private var newPassword = ""
//    @State private var confirmPassword = ""
//    @State private var showNewPassword = false
//    @State private var showConfirmPassword = false
//    @State private var showSuccessAlert = false
//    @State private var showValidationError = false
//    @State private var showErrorAlert = false
//    @State private var isUpdating = false
//    @State private var errorMessage = ""
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Spacer()
//
//            ZStack {
//                Circle()
//                    .fill(Color(hex: "#0097A7"))
//                    .frame(width: 100, height: 100)
//                Image(systemName: "lock.open.fill")
//                    .font(.system(size: 36))
//                    .foregroundColor(.white)
//            }
//
//            Text("Create a New Password")
//                .font(.title3)
//                .fontWeight(.semibold)
//                .foregroundColor(Color(hex: "#005F6A"))
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
//
//            passwordField("New Password", $newPassword, $showNewPassword)
//            passwordField("Confirm Password", $confirmPassword, $showConfirmPassword)
//
//            Text("Use 1 capital letter, 1 number, and 1 special character")
//                .font(.caption)
//                .foregroundColor(Color(hex: "#6B7280"))
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
//
//            if showValidationError {
//                Text("Passwords do not match or format is invalid.")
//                    .foregroundColor(.red)
//                    .font(.footnote)
//                    .padding(.horizontal)
//            }
//
//            Button("Update Password") {
//                Task {
//                    await updatePassword()
//                }
//            }
//            .foregroundColor(.white)
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(isUpdating ? Color.gray : Color(hex: "#0097A7"))
//            .cornerRadius(10)
//            .padding(.horizontal)
//            .disabled(isUpdating)
//            .overlay(
//                // Loading indicator
//                Group {
//                    if isUpdating {
//                        HStack {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                .scaleEffect(0.8)
//                            Text("Updating...")
//                                .foregroundColor(.white)
//                        }
//                    } else {
//                        Text("Update Password")
//                            .foregroundColor(.white)
//                    }
//                }
//            )
//
//            Spacer()
//        }
//        .padding(.top)
//        .background(Color(hex: "#D4F1F4").ignoresSafeArea())
//        .alert("✅ Password updated successfully!", isPresented: $showSuccessAlert) {
//            Button("OK", role: .cancel) {
//                onPasswordUpdated()  // ✅ Call the handler
//            }
//        }
//        .alert("❌ Update Failed", isPresented: $showErrorAlert) {
//            Button("OK", role: .cancel) {}
//        } message: {
//            Text(errorMessage)
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//
//    func passwordField(_ title: String, _ text: Binding<String>, _ show: Binding<Bool>) -> some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color(hex: "#0097A7"))
//                .background(Color.white.cornerRadius(10))
//
//            HStack {
//                if show.wrappedValue {
//                    TextField(title, text: text)
//                        .autocapitalization(.none)
//                        .disabled(isUpdating)
//                } else {
//                    SecureField(title, text: text)
//                        .autocapitalization(.none)
//                        .disabled(isUpdating)
//                }
//
//                Button {
//                    show.wrappedValue.toggle()
//                } label: {
//                    Image(systemName: show.wrappedValue ? "eye.slash" : "eye")
//                        .foregroundColor(.gray)
//                }
//                .disabled(isUpdating)
//            }
//            .padding(.horizontal)
//        }
//        .frame(height: 56)
//        .padding(.horizontal)
//    }
//
//    func isValidPassword(_ password: String) -> Bool {
//        let capital = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
//        let number = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")
//        let special = NSPredicate(format: "SELF MATCHES %@", ".*[!&^%$#@()/]+.*")
//        let minLength = password.count >= 8
//        
//        return capital.evaluate(with: password) &&
//               number.evaluate(with: password) &&
//               special.evaluate(with: password) &&
//               minLength
//    }
//    
//    // MARK: - Password Update with Supabase
//    @MainActor
//    func updatePassword() async {
//        // Reset error states
//        showValidationError = false
//        showErrorAlert = false
//        
//        // Validate passwords
//        guard newPassword == confirmPassword else {
//            showValidationError = true
//            errorMessage = "Passwords do not match."
//            return
//        }
//        
//        guard isValidPassword(newPassword) else {
//            showValidationError = true
//            errorMessage = "Password must contain at least 8 characters, 1 capital letter, 1 number, and 1 special character."
//            return
//        }
//        
//        // Start loading
//        isUpdating = true
//        
//        let client = SupabaseManager.shared.client
//        
//        do {
//            print("🔄 Starting password update process...")
//            
//            // First, verify we have an active session
//            let currentSession = try await client.auth.session
//            let currentUser = currentSession.user
//            print("✅ Current user session active: \(currentUser.email ?? "no email")")
//            print("🔑 User ID: \(currentUser.id)")
//            
//            // Update password in Supabase Auth
//            let updatedUser = try await client.auth.update(
//                user: .init(password: newPassword)
//            )
//            
//            print("✅ Password updated successfully in Supabase")
//            print("👤 Updated user ID: \(updatedUser.id)")
//            print("📧 Updated user email: \(updatedUser.email ?? "no email")")
//            
//            // Verify the update by refreshing the session
//            try await client.auth.refreshSession()
//            print("🔄 Session refreshed after password update")
//            
//            // Show success
//            isUpdating = false
//            showSuccessAlert = true
//            
//            // Clear password fields for security
//            newPassword = ""
//            confirmPassword = ""
//            
//        } catch {
//            print("❌ Error updating password: \(error)")
//            
//            isUpdating = false
//            
//            // More detailed error handling
//            let errorDescription = error.localizedDescription
//            print("🔍 Full error description: \(errorDescription)")
//            
//            // Check for specific error patterns in the description
//            if errorDescription.contains("weak_password") || errorDescription.contains("Password should be") {
//                errorMessage = "Password is too weak. Please use a stronger password."
//            } else if errorDescription.contains("same_password") {
//                errorMessage = "New password cannot be the same as your current password."
//            } else if errorDescription.contains("session_not_found") || errorDescription.contains("invalid_session") {
//                errorMessage = "Session expired. Please sign in again."
//            } else if errorDescription.contains("invalid_credentials") {
//                errorMessage = "Current session is invalid. Please sign in again."
//            } else if errorDescription.contains("rate limit") || errorDescription.contains("too_many_requests") {
//                errorMessage = "Too many requests. Please wait a moment and try again."
//            } else {
//                errorMessage = "Failed to update password. Please try again later."
//            }
//            
//            showErrorAlert = true
//        }
//    }
//}
struct UpdatePasswordView: View {
    var onPasswordUpdated: () -> Void

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var showSuccessAlert = false
    @State private var showValidationError = false
    @State private var showErrorAlert = false
    @State private var isUpdating = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(hex: "#0097A7"))
                    .frame(width: 100, height: 100)
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            Text("Create a New Password")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#005F6A"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            passwordField("New Password", $newPassword, $showNewPassword)
            passwordField("Confirm Password", $confirmPassword, $showConfirmPassword)

            Text("Use 1 capital letter, 1 number, and 1 special character")
                .font(.caption)
                .foregroundColor(Color(hex: "#6B7280"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            if showValidationError {
                Text("Passwords do not match or format is invalid.")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal)
            }

            Button {
                // Use immediate response with haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                Task {
                    await updatePassword()
                }
            } label: {
                HStack {
                    if isUpdating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Updating...")
                    } else {
                        Text("Update Password")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .background(isUpdating ? Color.gray : Color(hex: "#0097A7"))
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(isUpdating || newPassword.isEmpty || confirmPassword.isEmpty)
            .animation(.easeInOut(duration: 0.2), value: isUpdating)

            Spacer()
        }
        .padding(.top)
        .background(Color(hex: "#D4F1F4").ignoresSafeArea())
        .alert("✅ Password updated successfully!", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                onPasswordUpdated()
            }
        }
        .alert("❌ Update Failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .navigationBarBackButtonHidden(true)
    }

    func passwordField(_ title: String, _ text: Binding<String>, _ show: Binding<Bool>) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#0097A7"))
                .background(Color.white.cornerRadius(10))

            HStack {
                if show.wrappedValue {
                    TextField(title, text: text)
                        .autocapitalization(.none)
                        .disabled(isUpdating)
                } else {
                    SecureField(title, text: text)
                        .autocapitalization(.none)
                        .disabled(isUpdating)
                }

                Button {
                    show.wrappedValue.toggle()
                } label: {
                    Image(systemName: show.wrappedValue ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .disabled(isUpdating)
            }
            .padding(.horizontal)
        }
        .frame(height: 56)
        .padding(.horizontal)
    }

    func isValidPassword(_ password: String) -> Bool {
        let capital = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
        let number = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")
        let special = NSPredicate(format: "SELF MATCHES %@", ".*[!&^%$#@()/]+.*")
        let minLength = password.count >= 8
        
        return capital.evaluate(with: password) &&
               number.evaluate(with: password) &&
               special.evaluate(with: password) &&
               minLength
    }
    
    @MainActor
    func updatePassword() async {
        // Ensure we're on the main thread and reset states
        showValidationError = false
        showErrorAlert = false
        
        // Validate passwords
        guard newPassword == confirmPassword else {
            showValidationError = true
            errorMessage = "Passwords do not match."
            return
        }
        
        guard isValidPassword(newPassword) else {
            showValidationError = true
            errorMessage = "Password must contain at least 8 characters, 1 capital letter, 1 number, and 1 special character."
            return
        }
        
        // Start loading on main thread
        isUpdating = true
        
        // Perform the actual update in a separate task to avoid blocking
        Task.detached {
            let client = SupabaseManager.shared.client
            
            do {
                print("🔄 Starting password update process...")
                
                // Try to get current session with timeout
                let session = try await withTimeout(seconds: 10) {
                    try await client.auth.session
                }
                
                print("✅ Using session: \(session.user.email ?? "no email")")
                
                // Update password with timeout
                let updatedUser = try await withTimeout(seconds: 15) {
                    try await client.auth.update(user: .init(password: newPassword))
                }
                
                print("✅ Password updated successfully")
                print("👤 Updated user: \(updatedUser.email ?? "no email")")
                
                // Update UI on main thread
                await MainActor.run {
                    self.isUpdating = false
                    self.showSuccessAlert = true
                    self.newPassword = ""
                    self.confirmPassword = ""
                }
                
            } catch {
                print("❌ Error updating password: \(error)")
                
                await MainActor.run {
                    self.isUpdating = false
                    
                    let errorDescription = error.localizedDescription
                    
                    if errorDescription.contains("timeout") || errorDescription.contains("Timeout") {
                        self.errorMessage = "Request timed out. Please check your connection and try again."
                    } else if errorDescription.contains("weak_password") {
                        self.errorMessage = "Password is too weak. Please use a stronger password."
                    } else if errorDescription.contains("same_password") {
                        self.errorMessage = "New password cannot be the same as your current password."
                    } else if errorDescription.contains("session_not_found") {
                        self.errorMessage = "Reset session expired. Please request a new password reset."
                    } else {
                        self.errorMessage = "Failed to update password. Please try again."
                    }
                    
                    self.showErrorAlert = true
                }
            }
        }
    }
    
    // Helper function to add timeout to async operations
    func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            guard let result = try await group.next() else {
                throw TimeoutError()
            }
            
            group.cancelAll()
            return result
        }
    }
}

struct TimeoutError: Error {
    var localizedDescription: String {
        return "Operation timed out"
    }
}

