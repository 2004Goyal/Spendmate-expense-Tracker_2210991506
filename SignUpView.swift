//
//  SignupView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI
import Supabase

//struct SignUpView: View {
//    @StateObject var userProfile = UserProfile()
//    @State private var fullName: String = ""
//    @State private var phoneNumber: String = ""
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
//    @State private var showPassword: Bool = false
//    @State private var showConfirmPassword: Bool = false
//    @State private var showValidation: Bool = false
//    @State private var navigateToOnboarding: Bool = false
//    @State private var navigateToSignIn: Bool = false
//    @State private var showErrorAlert: Bool = false
//    @State private var errorMessage: String = ""
//    @State private var isLoading: Bool = false
//    
//    let heroNamespace: Namespace.ID
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color("MistyAqua")
//                    .ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(spacing: 24) {
//                        // Header
//                        VStack(spacing: 8) {
//                            Text("Create Account")
//                                .font(.largeTitle)
//                                .fontWeight(.bold)
//                                .foregroundColor(Color("Charcoal"))
//                            
//                            Text("Join SpendMate and start managing your finances")
//                                .font(.subheadline)
//                                .foregroundColor(Color("SlateGray"))
//                                .multilineTextAlignment(.center)
//                        }
//                        .padding(.top, 40)
//                        .padding(.bottom, 20)
//                        
//                        // Form Fields
//                        VStack(spacing: 16) {
//                            InputField(title: "Full Name", text: $fullName, placeholder: "Enter your full name")
//                            if showValidation && fullName.trimmingCharacters(in: .whitespaces).isEmpty {
//                                ValidationText("Full name cannot be empty")
//                            }
//                            
//                            InputField(title: "Phone Number", text: $phoneNumber, placeholder: "Enter your phone number", keyboardType: .numberPad)
//                            if showValidation && !phoneNumber.isEmpty && !isValidPhone(phoneNumber) {
//                                ValidationText("Phone number must be 10 digits")
//                            }
//                            
//                            InputField(title: "Email Address", text: $email, placeholder: "Enter your email", keyboardType: .emailAddress)
//                            if showValidation && !isValidEmail(email) {
//                                ValidationText("Enter a valid email with @")
//                            }
//                            
//                            SecureInputField(title: "Password", text: $password, showText: $showPassword, placeholder: "Create a password")
//                            if showValidation && !isValidPassword(password) {
//                                ValidationText("Password must be 6+ chars, 1 capital, 1 number, 1 special char")
//                            }
//                            
//                            SecureInputField(title: "Confirm Password", text: $confirmPassword, showText: $showConfirmPassword, placeholder: "Confirm your password")
//                            if showValidation && password != confirmPassword {
//                                ValidationText("Passwords do not match")
//                            }
//                        }
//                        
//                        // Navigation Links
//                        NavigationLink(destination: IncomeInputView(), isActive: $navigateToOnboarding) {
//                            EmptyView()
//                        }
//                        NavigationLink(destination: SignInView(heroNamespace: heroNamespace).navigationBarBackButtonHidden(true), isActive: $navigateToSignIn) {
//                            EmptyView()
//                        }
//                        
//                        // Sign Up Button
//                        Button(action: {
//                            Task { await handleSignUp() }
//                        }) {
//                            HStack {
//                                if isLoading {
//                                    ProgressView()
//                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                        .scaleEffect(0.8)
//                                }
//                                Text(isLoading ? "Creating Account..." : "Sign Up")
//                            }
//                            .foregroundColor(.white)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(allFieldsValid() && !isLoading ?
//                                       Color("CaribbeanTeal") : Color.gray.opacity(0.5))
//                            .cornerRadius(12)
//                        }
//                        .disabled(isLoading)
//                        
//                        HStack {
//                            Text("Already have an account?")
//                                .foregroundColor(Color("SlateGray"))
//                            Button("Sign In") {
//                                navigateToSignIn = true
//                            }
//                            .foregroundColor(Color("CaribbeanTeal"))
//                            .fontWeight(.medium)
//                        }
//                        .padding(.top, 6)
//                    }
//                    .padding(.horizontal, 24)
//                    .padding(.bottom, 40)
//                }
//            }
//        }
//        .alert("⚠️ Registration Failed", isPresented: $showErrorAlert) {
//            Button("OK", role: .cancel) {}
//        } message: {
//            Text(errorMessage)
//        }
//    }
//    
//    // MARK: - Sign Up Handler
//    @MainActor
//    private func handleSignUp() async {
//        showValidation = true
//        
//        let validation = validateAllFields()
//        if !validation.isValid {
//            errorMessage = validation.errorMessage ?? "Please check your information"
//            showErrorAlert = true
//            return
//        }
//        
//        isLoading = true
//        await registerUser()
//        isLoading = false
//    }
//    
//    // MARK: - Fixed Sign Up Method
//    func registerUser() async {
//        let client = SupabaseManager.shared.client
//        do {
//            print("🔐 Starting user registration for email: \(email)")
//            
//            // 1) Sign up
//            _ = try await client.auth.signUp(email: email, password: password)
//            print("✅ Supabase auth signup successful")
//            
//            // 2) Ensure session (required for RLS 'authenticated' role)
//            if client.auth.currentUser == nil {
//                print("🔄 No current user, signing in explicitly...")
//                try await client.auth.signIn(email: email, password: password)
//            }
//            
//            guard let uid = client.auth.currentUser?.id else {
//                throw NSError(domain: "Auth", code: -1,
//                            userInfo: [NSLocalizedDescriptionKey: "No session after sign-up/sign-in"])
//            }
//            
//            print("✅ User authenticated with UID: \(uid)")
//            
//            // 3) Insert profile with CORRECT schema including user_id
//            let phoneToSave = phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty ? nil : phoneNumber
//            
//            let row = UserProfileRow(
//                id: uid,           // Primary key
//                user_id: uid,      // Foreign key to auth.users - THIS IS THE CRITICAL FIX!
//                name: fullName.trimmingCharacters(in: .whitespaces),
//                email: email.trimmingCharacters(in: .whitespaces),
//                phone: phoneToSave,
//                dob: Date(),
//                photo_url: nil,
//                is_premium: false,
//                premium_expiry: nil,
//                income_source: nil,
//                monthly_income: nil
//            )
//            
//            // Insert with minimal return to avoid select policy issues
//            try await client
//                .from("user_profiles")
//                .insert(row, returning: .minimal)
//            
//            print("✅ Profile saved to Supabase with correct schema")
//            
//            // 4) Update environment object and navigate
//            await MainActor.run {
//                userProfile.id = uid.uuidString
//                userProfile.storedUID = uid.uuidString
//                userProfile.fullName = fullName.trimmingCharacters(in: .whitespaces)
//                userProfile.email = email.trimmingCharacters(in: .whitespaces)
//                userProfile.phoneNumber = phoneToSave ?? ""
//                userProfile.dateOfBirth = Date()
//                navigateToOnboarding = true
//            }
//            
//        } catch {
//            print("❌ Supabase signup/profile error:", error)
//            print("❌ Error details: \(error.localizedDescription)")
//            
//            await MainActor.run {
//                errorMessage = handleSignupError(error)
//                showErrorAlert = true
//            }
//        }
//    }
//    
//    // MARK: - Enhanced Error Handling
//    private func handleSignupError(_ error: Error) -> String {
//        let errorDescription = error.localizedDescription.lowercased()
//        
//        if errorDescription.contains("email already registered") ||
//           errorDescription.contains("user_already_registered") ||
//           errorDescription.contains("duplicate key value violates unique constraint") {
//            return "This email is already registered. Please sign in instead."
//        } else if errorDescription.contains("password") && (errorDescription.contains("weak") || errorDescription.contains("short")) {
//            return "Password must be at least 6 characters with 1 capital letter, 1 number, and 1 special character."
//        } else if errorDescription.contains("invalid email") ||
//                  (errorDescription.contains("email") && errorDescription.contains("format")) {
//            return "Please enter a valid email address."
//        } else if errorDescription.contains("network") || errorDescription.contains("connection") {
//            return "Network error. Please check your internet connection and try again."
//        } else if errorDescription.contains("timeout") {
//            return "Connection timeout. Please try again."
//        } else if errorDescription.contains("signup_disabled") {
//            return "New registrations are temporarily disabled. Please try again later."
//        } else if errorDescription.contains("rate limit") || errorDescription.contains("too many requests") {
//            return "Too many registration attempts. Please wait a few minutes and try again."
//        } else if errorDescription.contains("invalid session") || errorDescription.contains("no session") {
//            return "Authentication failed. Please try signing up again."
//        } else {
//            return "Registration failed. Please check your information and try again. If the problem persists, contact support."
//        }
//    }
//    
//    // MARK: - Enhanced Validation
//    private func validateAllFields() -> (isValid: Bool, errorMessage: String?) {
//        let trimmedName = fullName.trimmingCharacters(in: .whitespaces)
//        if trimmedName.isEmpty {
//            return (false, "Full name is required")
//        }
//        
//        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
//        if !isValidEmail(trimmedEmail) {
//            return (false, "Please enter a valid email address")
//        }
//        
//        let trimmedPhone = phoneNumber.trimmingCharacters(in: .whitespaces)
//        if !trimmedPhone.isEmpty && !isValidPhone(trimmedPhone) {
//            return (false, "Phone number must be exactly 10 digits")
//        }
//        
//        if !isValidPassword(password) {
//            return (false, "Password must be at least 6 characters with 1 capital letter, 1 number, and 1 special character")
//        }
//        
//        if password != confirmPassword {
//            return (false, "Passwords do not match")
//        }
//        
//        return (true, nil)
//    }
//    
//    // MARK: - Validation Helper Methods
//    func isValidPhone(_ phone: String) -> Bool {
//        let digits = phone.filter { $0.isNumber }
//        return digits.count == 10
//    }
//    
//    func isValidEmail(_ email: String) -> Bool {
//        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
//        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
//        return emailPredicate.evaluate(with: email)
//    }
//    
//    func isValidPassword(_ password: String) -> Bool {
//        guard password.count >= 6 else { return false }
//        
//        let capitalLetter = password.rangeOfCharacter(from: .uppercaseLetters) != nil
//        let number = password.rangeOfCharacter(from: .decimalDigits) != nil
//        let specialChar = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil
//        
//        return capitalLetter && number && specialChar
//    }
//    
//    func allFieldsValid() -> Bool {
//        let validation = validateAllFields()
//        return validation.isValid
//    }
//}
//
//// MARK: - Validation Text Helper
//struct ValidationText: View {
//    let message: String
//    
//    init(_ message: String) {
//        self.message = message
//    }
//    
//    var body: some View {
//        HStack {
//            Text(message)
//                .font(.caption)
//                .foregroundColor(.red)
//            Spacer()
//        }
//        .padding(.horizontal, 4)
//    }
//}


import SwiftUI
import Network

struct SignUpView: View {
    @StateObject var userProfile = UserProfile()
    @State private var fullName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var showValidation: Bool = false
    @State private var navigateToOnboarding: Bool = false
    @State private var navigateToSignIn: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    // Network monitoring
    @StateObject private var networkMonitor = NetworkMonitor()
    
    let heroNamespace: Namespace.ID
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("MistyAqua")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Network status indicator
                        if !networkMonitor.isConnected {
                            NetworkStatusBanner()
                        }
                        
                        // Header
                        VStack(spacing: 8) {
                            Text("Create Account")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("Charcoal"))
                            
                            Text("Join SpendMate and start managing your finances")
                                .font(.subheadline)
                                .foregroundColor(Color("SlateGray"))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                        
                        // Form Fields
                        VStack(spacing: 16) {
                            InputField(title: "Full Name", text: $fullName, placeholder: "Enter your full name")
                            if showValidation && fullName.trimmingCharacters(in: .whitespaces).isEmpty {
                                ValidationText("Full name cannot be empty")
                            }
                            
                            InputField(title: "Phone Number", text: $phoneNumber, placeholder: "Enter your phone number", keyboardType: .numberPad)
                            if showValidation && !phoneNumber.isEmpty && !isValidPhone(phoneNumber) {
                                ValidationText("Phone number must be 10 digits")
                            }
                            
                            InputField(title: "Email Address", text: $email, placeholder: "Enter your email", keyboardType: .emailAddress)
                            if showValidation && !isValidEmail(email) {
                                ValidationText("Enter a valid email with @")
                            }
                            
                            SecureInputField(title: "Password", text: $password, showText: $showPassword, placeholder: "Create a password")
                            if showValidation && !isValidPassword(password) {
                                ValidationText("Password must be 6+ chars, 1 capital, 1 number, 1 special char")
                            }
                            
                            SecureInputField(title: "Confirm Password", text: $confirmPassword, showText: $showConfirmPassword, placeholder: "Confirm your password")
                            if showValidation && password != confirmPassword {
                                ValidationText("Passwords do not match")
                            }
                        }
                        
                        // Navigation Links
                        NavigationLink(destination: IncomeInputView(), isActive: $navigateToOnboarding) {
                            EmptyView()
                        }
                        NavigationLink(destination: SignInView(heroNamespace: heroNamespace).navigationBarBackButtonHidden(true), isActive: $navigateToSignIn) {
                            EmptyView()
                        }
                        
                        // Sign Up Button
                        Button(action: {
                            Task { await handleSignUp() }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isLoading ? "Creating Account..." : "Sign Up")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(allFieldsValid() && !isLoading && networkMonitor.isConnected ?
                                       Color("CaribbeanTeal") : Color.gray.opacity(0.5))
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || !networkMonitor.isConnected)
                        
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(Color("SlateGray"))
                            Button("Sign In") {
                                navigateToSignIn = true
                            }
                            .foregroundColor(Color("CaribbeanTeal"))
                            .fontWeight(.medium)
                        }
                        .padding(.top, 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("⚠️ Registration Failed", isPresented: $showErrorAlert) {
            Button("Retry") {
                if networkMonitor.isConnected {
                    Task { await handleSignUp() }
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Enhanced Sign Up Handler with Network Retry
    @MainActor
    private func handleSignUp() async {
        // Check network connectivity first
        guard networkMonitor.isConnected else {
            errorMessage = "No internet connection. Please check your network and try again."
            showErrorAlert = true
            return
        }
        
        showValidation = true
        
        let validation = validateAllFields()
        if !validation.isValid {
            errorMessage = validation.errorMessage ?? "Please check your information"
            showErrorAlert = true
            return
        }
        
        isLoading = true
        await registerUserWithRetry()
        isLoading = false
    }
    
    // Fix for the registerUser function - add throws and update calls

    // MARK: - Enhanced Registration with Retry Logic
    private func registerUserWithRetry(maxRetries: Int = 3) async {
        for attempt in 1...maxRetries {
            do {
                print("🔐 Registration attempt \(attempt) for email: \(email)")
                try await registerUser() // Add 'try' here
                return // Success, exit retry loop
                
            } catch {
                print("❌ Registration attempt \(attempt) failed: \(error)")
                
                let errorCode = (error as NSError).code
                
                // Don't retry for these specific errors
                if errorCode == -1009 || // No internet connection
                   errorCode == -1001 || // Request timed out
                   error.localizedDescription.contains("already registered") ||
                   error.localizedDescription.contains("invalid email") {
                    
                    await MainActor.run {
                        errorMessage = handleSignupError(error)
                        showErrorAlert = true
                    }
                    return
                }
                
                // Retry for network connection lost and other transient errors
                if attempt < maxRetries {
                    print("⏳ Retrying in 2 seconds... (attempt \(attempt + 1)/\(maxRetries))")
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                } else {
                    await MainActor.run {
                        errorMessage = handleSignupError(error)
                        showErrorAlert = true
                    }
                }
            }
        }
    }

    // MARK: - Core Registration Method (Add throws)
    private func registerUser() async throws { // Add 'throws' here
        let client = SupabaseManager.shared.client
        
        print("🔐 Starting user registration for email: \(email)")
        
        // 1) Sign up with timeout handling
        _ = try await withTimeout(seconds: 30) {
            try await client.auth.signUp(email: email, password: password)
        }
        print("✅ Supabase auth signup successful")
        
        // 2) Ensure session (required for RLS 'authenticated' role)
        if client.auth.currentUser == nil {
            print("🔄 No current user, signing in explicitly...")
            try await withTimeout(seconds: 30) {
                try await client.auth.signIn(email: email, password: password)
            }
        }
        
        guard let uid = client.auth.currentUser?.id else {
            throw NSError(domain: "Auth", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No session after sign-up/sign-in"])
        }
        
        print("✅ User authenticated with UID: \(uid)")
        
        // 3) Insert profile with CORRECT schema including user_id
        let phoneToSave = phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty ? nil : phoneNumber
        
        let row = UserProfileRow(
            id: uid,           // Primary key
            user_id: uid,      // Foreign key to auth.users - THIS IS THE CRITICAL FIX!
            name: fullName.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            phone: phoneToSave,
            dob: Date(),
            photo_url: nil,
            is_premium: false,
            premium_expiry: nil,
            income_source: nil,
            monthly_income: nil
        )
        
        // Insert with timeout handling
        try await withTimeout(seconds: 30) {
            try await client
                .from("user_profiles")
                .insert(row, returning: .minimal)
        }
        
        print("✅ Profile saved to Supabase with correct schema")
        
        // 4) Update environment object and navigate
        await MainActor.run {
            userProfile.id = uid.uuidString
            userProfile.storedUID = uid.uuidString
            userProfile.fullName = fullName.trimmingCharacters(in: .whitespaces)
            userProfile.email = email.trimmingCharacters(in: .whitespaces)
            userProfile.phoneNumber = phoneToSave ?? ""
            userProfile.dateOfBirth = Date()
            navigateToOnboarding = true
        }
    }
    
    // MARK: - Enhanced Registration with Retry Logic
//    private func registerUserWithRetry(maxRetries: Int = 3) async {
//        for attempt in 1...maxRetries {
//            do {
//                print("🔐 Registration attempt \(attempt) for email: \(email)")
//                await registerUser()
//                return // Success, exit retry loop
//                
//            } catch {
//                print("❌ Registration attempt \(attempt) failed: \(error)")
//                
//                let errorCode = (error as NSError).code
//                
//                // Don't retry for these specific errors
//                if errorCode == -1009 || // No internet connection
//                   errorCode == -1001 || // Request timed out
//                   error.localizedDescription.contains("already registered") ||
//                   error.localizedDescription.contains("invalid email") {
//                    
//                    await MainActor.run {
//                        errorMessage = handleSignupError(error)
//                        showErrorAlert = true
//                    }
//                    return
//                }
//                
//                // Retry for network connection lost and other transient errors
//                if attempt < maxRetries {
//                    print("⏳ Retrying in 2 seconds... (attempt \(attempt + 1)/\(maxRetries))")
//                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
//                } else {
//                    await MainActor.run {
//                        errorMessage = handleSignupError(error)
//                        showErrorAlert = true
//                    }
//                }
//            }
//        }
//    }
    
    // MARK: - Core Registration Method
//    private func registerUser() async throws {
//        let client = SupabaseManager.shared.client
//        
//        print("🔐 Starting user registration for email: \(email)")
//        
//        // 1) Sign up with timeout handling
//        _ = try await withTimeout(seconds: 30) {
//            try await client.auth.signUp(email: email, password: password)
//        }
//        print("✅ Supabase auth signup successful")
//        
//        // 2) Ensure session (required for RLS 'authenticated' role)
//        if client.auth.currentUser == nil {
//            print("🔄 No current user, signing in explicitly...")
//            try await withTimeout(seconds: 30) {
//                try await client.auth.signIn(email: email, password: password)
//            }
//        }
//        
//        guard let uid = client.auth.currentUser?.id else {
//            throw NSError(domain: "Auth", code: -1,
//                        userInfo: [NSLocalizedDescriptionKey: "No session after sign-up/sign-in"])
//        }
//        
//        print("✅ User authenticated with UID: \(uid)")
//        
//        // 3) Insert profile with CORRECT schema including user_id
//        let phoneToSave = phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty ? nil : phoneNumber
//        
//        let row = UserProfileRow(
//            id: uid,           // Primary key
//            user_id: uid,      // Foreign key to auth.users - THIS IS THE CRITICAL FIX!
//            name: fullName.trimmingCharacters(in: .whitespaces),
//            email: email.trimmingCharacters(in: .whitespaces),
//            phone: phoneToSave,
//            dob: Date(),
//            photo_url: nil,
//            is_premium: false,
//            premium_expiry: nil,
//            income_source: nil,
//            monthly_income: nil
//        )
//        
//        // Insert with timeout handling
//        try await withTimeout(seconds: 30) {
//            try await client
//                .from("user_profiles")
//                .insert(row, returning: .minimal)
//        }
//        
//        print("✅ Profile saved to Supabase with correct schema")
//        
//        // 4) Update environment object and navigate
//        await MainActor.run {
//            userProfile.id = uid.uuidString
//            userProfile.storedUID = uid.uuidString
//            userProfile.fullName = fullName.trimmingCharacters(in: .whitespaces)
//            userProfile.email = email.trimmingCharacters(in: .whitespaces)
//            userProfile.phoneNumber = phoneToSave ?? ""
//            userProfile.dateOfBirth = Date()
//            navigateToOnboarding = true
//        }
//    }
    
    // MARK: - Enhanced Error Handling for Network Issues
    private func handleSignupError(_ error: Error) -> String {
        let nsError = error as NSError
        let errorCode = nsError.code
        let errorDescription = error.localizedDescription.lowercased()
        
        // Network-specific errors
        if errorCode == -1005 {
            return "Network connection was lost. Please check your internet connection and try again."
        } else if errorCode == -1009 {
            return "No internet connection. Please connect to the internet and try again."
        } else if errorCode == -1001 {
            return "Request timed out. Please check your connection and try again."
        } else if errorCode == -1004 {
            return "Could not connect to server. Please try again later."
        } else if errorCode == -1200 || errorCode == -1201 {
            return "Secure connection failed. Please check your network settings."
        }
        
        // Authentication-specific errors
        if errorDescription.contains("email already registered") ||
           errorDescription.contains("user_already_registered") ||
           errorDescription.contains("duplicate key value violates unique constraint") {
            return "This email is already registered. Please sign in instead."
        } else if errorDescription.contains("password") && (errorDescription.contains("weak") || errorDescription.contains("short")) {
            return "Password must be at least 6 characters with 1 capital letter, 1 number, and 1 special character."
        } else if errorDescription.contains("invalid email") ||
                  (errorDescription.contains("email") && errorDescription.contains("format")) {
            return "Please enter a valid email address."
        } else if errorDescription.contains("signup_disabled") {
            return "New registrations are temporarily disabled. Please try again later."
        } else if errorDescription.contains("rate limit") || errorDescription.contains("too many requests") {
            return "Too many registration attempts. Please wait a few minutes and try again."
        } else {
            return "Registration failed. Please check your internet connection and try again. If the problem persists, contact support."
        }
    }
    
    // MARK: - Timeout Helper
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NSError(domain: "TimeoutError", code: -1001, userInfo: [NSLocalizedDescriptionKey: "Operation timed out"])
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    // MARK: - Validation Methods (unchanged)
    private func validateAllFields() -> (isValid: Bool, errorMessage: String?) {
        let trimmedName = fullName.trimmingCharacters(in: .whitespaces)
        if trimmedName.isEmpty {
            return (false, "Full name is required")
        }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if !isValidEmail(trimmedEmail) {
            return (false, "Please enter a valid email address")
        }
        
        let trimmedPhone = phoneNumber.trimmingCharacters(in: .whitespaces)
        if !trimmedPhone.isEmpty && !isValidPhone(trimmedPhone) {
            return (false, "Phone number must be exactly 10 digits")
        }
        
        if !isValidPassword(password) {
            return (false, "Password must be at least 6 characters with 1 capital letter, 1 number, and 1 special character")
        }
        
        if password != confirmPassword {
            return (false, "Passwords do not match")
        }
        
        return (true, nil)
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        let digits = phone.filter { $0.isNumber }
        return digits.count == 10
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        guard password.count >= 6 else { return false }
        
        let capitalLetter = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let number = password.rangeOfCharacter(from: .decimalDigits) != nil
        let specialChar = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil
        
        return capitalLetter && number && specialChar
    }
    
    func allFieldsValid() -> Bool {
        let validation = validateAllFields()
        return validation.isValid
    }
}

// MARK: - Network Monitor
class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

// MARK: - Network Status Banner
struct NetworkStatusBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
            Text("No Internet Connection")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red)
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - UI Components (unchanged)
struct ValidationText: View {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var body: some View {
        HStack {
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}
