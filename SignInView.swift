//
//  SignInView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import SwiftUI
import Supabase

//struct SignInView: View {
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var isPasswordVisible: Bool = false
//    @State private var navigateToDashboard = false
//    @State private var showErrorAlert = false
//    @State private var errorMessage = ""
//    @State private var isLoading = false
//
//    @EnvironmentObject var userProfile: UserProfile
//    
//    let heroNamespace: Namespace.ID
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 24) {
//                Spacer()
//
//                Image("SpendMateLogo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 200)
//
//                // Email
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Email Address")
//                        .font(.subheadline)
//                        .foregroundColor(.black)
//
//                    TextField("Enter your email", text: $email)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(12)
//                        .keyboardType(.emailAddress)
//                        .autocapitalization(.none)
//                        .disabled(isLoading)
//                }
//
//                // Password
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Password")
//                        .font(.subheadline)
//                        .foregroundColor(.black)
//
//                    ZStack(alignment: .trailing) {
//                        Group {
//                            if isPasswordVisible {
//                                TextField("Enter your password", text: $password)
//                            } else {
//                                SecureField("Enter your password", text: $password)
//                            }
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(12)
//                        .disabled(isLoading)
//
//                        Button {
//                            isPasswordVisible.toggle()
//                        } label: {
//                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
//                                .foregroundColor(.gray)
//                                .padding(.trailing, 16)
//                        }
//                        .disabled(isLoading)
//                    }
//                }
//
//                // Forgot Password
//                HStack {
//                    Spacer()
//                    NavigationLink(destination: ForgotPasswordView()) {
//                        Text("Forgot Password?")
//                            .font(.footnote)
//                            .foregroundColor(Color("CaribbeanTeal"))
//                            .underline()
//                    }
//                    .disabled(isLoading)
//                }
//
//                // Sign In Button
//                Button(action: {
//                    Task { await signInUser() }
//                }) {
//                    HStack {
//                        if isLoading {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                .scaleEffect(0.8)
//                            Text("Signing In...")
//                        } else {
//                            Text("Sign In")
//                        }
//                    }
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(isLoading ? Color.gray : Color("CaribbeanTeal"))
//                    .cornerRadius(12)
//                }
//                .disabled(isLoading || email.isEmpty || password.isEmpty)
//
//                NavigationLink(destination: MainTabView().navigationBarBackButtonHidden(true),
//                               isActive: $navigateToDashboard) {
//                    EmptyView()
//                }
//
//                Spacer()
//
//                // Sign Up Prompt
//                HStack {
//                    Text("Don't have an account?")
//                        .foregroundColor(.gray)
//                    NavigationLink("Sign Up", destination: SignUpView(heroNamespace: heroNamespace))
//                        .foregroundColor(Color("CaribbeanTeal"))
//                        .fontWeight(.medium)
//                }
//                .disabled(isLoading)
//
//                Spacer()
//            }
//            .padding(.horizontal, 24)
//            .background(Color("MistyAqua"))
//            .ignoresSafeArea()
//            .alert("❌ Login Failed", isPresented: $showErrorAlert) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text(errorMessage)
//            }
//            .onAppear {
//                // 🔹 Clear any existing session data when sign-in view appears
//                userProfile.clearAllData()
//            }
//        }
//    }
//
//    // MARK: - Enhanced Login with Supabase (Fixed Version)
//    func signInUser() async {
//        await MainActor.run { isLoading = true }
//        
//        let client = SupabaseManager.shared.client
//
//        // 🔹 Clear existing profile data before new sign-in
//        await MainActor.run {
//            userProfile.clearAllData()
//        }
//
//        do {
//            print("🔐 Attempting to sign in with email: \(email)")
//            
//            // Sign in to Supabase with better error context
//            let session = try await client.auth.signIn(email: email, password: password)
//            let uid = session.user.id.uuidString
//            print("✅ Successfully signed in with UID: \(uid)")
//            print("📧 User email: \(session.user.email ?? "no email")")
//            
//            // Verify session is properly established
//            guard client.auth.currentUser != nil else {
//                throw AuthenticationError.sessionNotEstablished
//            }
//
//            // Load user profile for this specific UID with retry logic
//            await loadUserProfileWithRetry(uid: uid)
//            
//            print("🔥 Profile loaded for UID: \(uid)")
//            print("👤 User name: \(userProfile.fullName.isEmpty ? "New User" : userProfile.fullName)")
//
//            // Navigate to dashboard on main thread
//            await MainActor.run {
//                self.isLoading = false
//                self.navigateToDashboard = true
//            }
//            
//        } catch {
//            await MainActor.run {
//                self.isLoading = false
//                
//                print("❌ Sign in error details:")
//                print("   Error: \(error)")
//                print("   Localized: \(error.localizedDescription)")
//                
//                self.errorMessage = self.handleSignInError(error)
//                self.showErrorAlert = true
//            }
//            print("❌ Sign in error:", error)
//        }
//    }
//    
//    // MARK: - Profile Loading with Retry Logic
//    private func loadUserProfileWithRetry(uid: String, maxRetries: Int = 3) async {
//        for attempt in 1...maxRetries {
//            do {
//                try await userProfile.loadEnhanced(for: uid)
//                print("✅ Profile loaded successfully on attempt \(attempt)")
//                return
//            } catch {
//                print("⚠️ Profile load attempt \(attempt) failed: \(error)")
//                
//                if attempt == maxRetries {
//                    print("❌ Profile loading failed after \(maxRetries) attempts")
//                    // Continue with empty profile - user can complete it later
//                    await MainActor.run {
//                        userProfile.storedUID = uid
//                    }
//                } else {
//                    // Wait before retry
//                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
//                }
//            }
//        }
//    }
//    
//    // MARK: - Enhanced Error Handling
//    private func handleSignInError(_ error: Error) -> String {
//        let errorDescription = error.localizedDescription.lowercased()
//        
//        if let authError = error as? AuthenticationError {
//            switch authError {
//            case .sessionNotEstablished:
//                return "Authentication failed. Please try again."
//            case .profileLoadFailed:
//                return "Sign in successful but profile loading failed. Please restart the app."
//            }
//        }
//        
//        if errorDescription.contains("invalid login credentials") || errorDescription.contains("invalid_credentials") {
//            return "Invalid email or password. Please check your credentials and try again."
//        } else if errorDescription.contains("email not confirmed") || errorDescription.contains("email_not_confirmed") {
//            return "Please verify your email address before signing in. Check your inbox for a verification email."
//        } else if errorDescription.contains("too_many_requests") || errorDescription.contains("rate limit") {
//            return "Too many login attempts. Please wait a few minutes and try again."
//        } else if errorDescription.contains("signup_disabled") {
//            return "Authentication is temporarily disabled. Please try again later."
//        } else if errorDescription.contains("network") || errorDescription.contains("connection") {
//            return "Network error. Please check your internet connection and try again."
//        } else if errorDescription.contains("timeout") {
//            return "Connection timeout. Please try again."
//        } else if errorDescription.contains("user not found") || errorDescription.contains("user_not_found") {
//            return "No account found with this email. Please sign up first."
//        } else {
//            return "Sign in failed. Please check your credentials and try again. If the problem persists, contact support."
//        }
//    }
//}
//
//// MARK: - Custom Authentication Errors
//enum AuthenticationError: Error, LocalizedError {
//    case sessionNotEstablished
//    case profileLoadFailed
//    
//    var errorDescription: String? {
//        switch self {
//        case .sessionNotEstablished:
//            return "Session not properly established"
//        case .profileLoadFailed:
//            return "Failed to load user profile"
//        }
//    }
//}
//
//// MARK: - Profile Errors
//enum ProfileError: Error, LocalizedError {
//    case invalidUUID
//    case loadFailed(Error)
//    case saveFailed(Error)
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidUUID:
//            return "Invalid user identifier"
//        case .loadFailed(let error):
//            return "Failed to load profile: \(error.localizedDescription)"
//        case .saveFailed(let error):
//            return "Failed to save profile: \(error.localizedDescription)"
//        }
//    }
//}
//
//
//
//extension SignInView {
//    
//    // MARK: - Enhanced Sign In Method
//    func signInUserEnhanced() async {
//        await MainActor.run { isLoading = true }
//        
//        let client = SupabaseManager.shared.client
//        
//        // 🔹 Clear existing profile data before new sign-in
//        await MainActor.run {
//            userProfile.clearAllData()
//        }
//        
//        do {
//            print("🔐 Attempting to sign in with email: \(email)")
//            
//            // Sign in to Supabase with better error context
//            let session = try await client.auth.signIn(email: email, password: password)
//            let uid = session.user.id.uuidString
//            print("✅ Successfully signed in with UID: \(uid)")
//            print("📧 User email: \(session.user.email ?? "no email")")
//            
//            // Verify session is properly established
//            guard client.auth.currentUser != nil else {
//                throw AuthenticationError.sessionNotEstablished
//            }
//            
//            // Load user profile for this specific UID with retry logic
//            await loadUserProfileWithRetry(uid: uid)
//            
//            print("🔥 Profile loaded for UID: \(uid)")
//            print("👤 User name: \(userProfile.fullName.isEmpty ? "New User" : userProfile.fullName)")
//            
//            // Navigate to dashboard on main thread
//            await MainActor.run {
//                self.isLoading = false
//                self.navigateToDashboard = true
//            }
//            
//        } catch {
//            await MainActor.run {
//                self.isLoading = false
//                
//                print("❌ Sign in error details:")
//                print("   Error: \(error)")
//                print("   Localized: \(error.localizedDescription)")
//                
//                self.errorMessage = self.handleSignInError(error)
//                self.showErrorAlert = true
//            }
//            print("❌ Sign in error:", error)
//        }
//    }
//}


import SwiftUI
import Network

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var navigateToDashboard = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false

    @EnvironmentObject var userProfile: UserProfile
    @StateObject private var networkMonitor = NetworkMonitor()
    
    let heroNamespace: Namespace.ID

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Network status indicator
                if !networkMonitor.isConnected {
                    NetworkStatusBanner()
                }

                Image("SpendMateLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)

                // Email
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
                        .disabled(isLoading)
                }

                // Password
                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.subheadline)
                        .foregroundColor(.black)

                    ZStack(alignment: .trailing) {
                        Group {
                            if isPasswordVisible {
                                TextField("Enter your password", text: $password)
                            } else {
                                SecureField("Enter your password", text: $password)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .disabled(isLoading)

                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .padding(.trailing, 16)
                        }
                        .disabled(isLoading)
                    }
                }

                // Forgot Password
                HStack {
                    Spacer()
                    NavigationLink(destination: ForgotPasswordView()) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(Color("CaribbeanTeal"))
                            .underline()
                    }
                    .disabled(isLoading)
                }

                // Sign In Button
                Button(action: {
                    Task { await handleSignIn() }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Signing In...")
                        } else {
                            Text("Sign In")
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isLoading || !networkMonitor.isConnected ? Color.gray : Color("CaribbeanTeal"))
                    .cornerRadius(12)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty || !networkMonitor.isConnected)

                NavigationLink(destination: MainTabView().navigationBarBackButtonHidden(true),
                               isActive: $navigateToDashboard) {
                    EmptyView()
                }

                Spacer()

                // Sign Up Prompt
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    NavigationLink("Sign Up", destination: SignUpView(heroNamespace: heroNamespace))
                        .foregroundColor(Color("CaribbeanTeal"))
                        .fontWeight(.medium)
                }
                .disabled(isLoading)

                Spacer()
            }
            .padding(.horizontal, 24)
            .background(Color("MistyAqua"))
            .ignoresSafeArea()
            .alert("❌ Login Failed", isPresented: $showErrorAlert) {
                Button("Retry") {
                    if networkMonitor.isConnected {
                        Task { await handleSignIn() }
                    }
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // 🔹 Clear any existing session data when sign-in view appears
                userProfile.clearAllData()
            }
        }
    }

    // MARK: - Enhanced Sign In Handler with Network Check
    @MainActor
    private func handleSignIn() async {
        // Check network connectivity first
        guard networkMonitor.isConnected else {
            errorMessage = "No internet connection. Please check your network and try again."
            showErrorAlert = true
            return
        }
        
        isLoading = true
        await signInUserWithRetry()
        isLoading = false
    }

    // MARK: - Enhanced Login with Supabase and Retry Logic
    private func signInUserWithRetry(maxRetries: Int = 3) async {
        for attempt in 1...maxRetries {
            do {
                print("🔐 Sign in attempt \(attempt) for email: \(email)")
                try await signInUser()
                return // Success, exit retry loop
                
            } catch {
                print("❌ Sign in attempt \(attempt) failed: \(error)")
                
                let errorCode = (error as NSError).code
                
                // Don't retry for these specific errors
                if errorCode == -1009 || // No internet connection
                   errorCode == -1001 || // Request timed out
                   error.localizedDescription.contains("invalid login credentials") ||
                   error.localizedDescription.contains("user not found") {
                    
                    await MainActor.run {
                        self.errorMessage = self.handleSignInError(error)
                        self.showErrorAlert = true
                    }
                    return
                }
                
                // Retry for network connection lost and other transient errors
                if attempt < maxRetries {
                    print("⏳ Retrying in 2 seconds... (attempt \(attempt + 1)/\(maxRetries))")
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                } else {
                    await MainActor.run {
                        self.errorMessage = self.handleSignInError(error)
                        self.showErrorAlert = true
                    }
                }
            }
        }
    }
    
    // MARK: - Core Sign In Method
    private func signInUser() async throws {
        let client = SupabaseManager.shared.client

        // 🔹 Clear existing profile data before new sign-in
        await MainActor.run {
            userProfile.clearAllData()
        }

        print("🔐 Attempting to sign in with email: \(email)")
        
        // Sign in to Supabase with timeout handling
        let session = try await withTimeout(seconds: 30) {
            try await client.auth.signIn(email: email, password: password)
        }
        let uid = session.user.id.uuidString
        print("✅ Successfully signed in with UID: \(uid)")
        print("📧 User email: \(session.user.email ?? "no email")")
        
        // Verify session is properly established
        guard client.auth.currentUser != nil else {
            throw AuthenticationError.sessionNotEstablished
        }

        // Load user profile for this specific UID with retry logic
        await loadUserProfileWithRetry(uid: uid)
        
        print("🔥 Profile loaded for UID: \(uid)")
        print("👤 User name: \(userProfile.fullName.isEmpty ? "New User" : userProfile.fullName)")

        // Navigate to dashboard on main thread
        await MainActor.run {
            self.navigateToDashboard = true
        }
    }
    
    // MARK: - Profile Loading with Retry Logic
    private func loadUserProfileWithRetry(uid: String, maxRetries: Int = 3) async {
        for attempt in 1...maxRetries {
            do {
                try await userProfile.loadEnhanced(for: uid)
                print("✅ Profile loaded successfully on attempt \(attempt)")
                return
            } catch {
                print("⚠️ Profile load attempt \(attempt) failed: \(error)")
                
                if attempt == maxRetries {
                    print("❌ Profile loading failed after \(maxRetries) attempts")
                    // Continue with empty profile - user can complete it later
                    await MainActor.run {
                        userProfile.storedUID = uid
                    }
                } else {
                    // Wait before retry
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                }
            }
        }
    }
    
    // MARK: - Enhanced Error Handling for Network Issues
    private func handleSignInError(_ error: Error) -> String {
        let nsError = error as NSError
        let errorCode = nsError.code
        let errorDescription = error.localizedDescription.lowercased()
        
        // Handle custom authentication errors
        if let authError = error as? AuthenticationError {
            switch authError {
            case .sessionNotEstablished:
                return "Authentication failed. Please try again."
            case .profileLoadFailed:
                return "Sign in successful but profile loading failed. Please restart the app."
            }
        }
        
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
        if errorDescription.contains("invalid login credentials") || errorDescription.contains("invalid_credentials") {
            return "Invalid email or password. Please check your credentials and try again."
        } else if errorDescription.contains("email not confirmed") || errorDescription.contains("email_not_confirmed") {
            return "Please verify your email address before signing in. Check your inbox for a verification email."
        } else if errorDescription.contains("too_many_requests") || errorDescription.contains("rate limit") {
            return "Too many login attempts. Please wait a few minutes and try again."
        } else if errorDescription.contains("signup_disabled") {
            return "Authentication is temporarily disabled. Please try again later."
        } else if errorDescription.contains("user not found") || errorDescription.contains("user_not_found") {
            return "No account found with this email. Please sign up first."
        } else {
            return "Sign in failed. Please check your internet connection and try again. If the problem persists, contact support."
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
}

// MARK: - Custom Authentication Errors
enum AuthenticationError: Error, LocalizedError {
    case sessionNotEstablished
    case profileLoadFailed
    
    var errorDescription: String? {
        switch self {
        case .sessionNotEstablished:
            return "Session not properly established"
        case .profileLoadFailed:
            return "Failed to load user profile"
        }
    }
}

// MARK: - Profile Errors
enum ProfileError: Error, LocalizedError {
    case invalidUUID
    case loadFailed(Error)
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidUUID:
            return "Invalid user identifier"
        case .loadFailed(let error):
            return "Failed to load profile: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save profile: \(error.localizedDescription)"
        }
    }
}

