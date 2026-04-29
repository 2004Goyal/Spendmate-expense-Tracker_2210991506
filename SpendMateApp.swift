//
//  SpendMateApp.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import SwiftUI
import UserNotifications



//@main
//struct SpendMateApp: App {
//    // Existing models
//    @StateObject var budgetModel  = BudgetModel()
//    @StateObject var userProfile  = UserProfile()
//    @StateObject var savingsModel = SavingsModel()
//    @StateObject var goalsModel   = GoalsModel()
//    @StateObject var spendingModel = SpendingModel()   // Dashboard state
//    
//    // Routing
//    enum Route { case splash, signIn, dashboard, reset }
//    @Namespace private var heroNS
//    @State private var route: Route = .splash
//    @State private var splashMinElapsed = false
//    @State private var bootstrapDone = false
//    @State private var loggedIn = false
//    @State private var openReset = false
//    
//    init() {
//        NotificationManager.requestPermission()
//        NotificationManager.scheduleDailySavingsReminder()
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            ZStack {
//                // Destination scenes
//                Group {
//                    switch route {
//                    case .dashboard: DashboardView()
//                    case .signIn:    SignInView(heroNamespace: heroNS)
//                    case .reset:     CreateNewPasswordView()
//                    case .splash:    EmptyView() // covered by splash overlay
//                    }
//                }
//                .opacity(route == .splash ? 0 : 1)
//                
//                // Splash overlay (shown first)
//                if route == .splash {
//                    SplashHero(ns: heroNS) { splashFinished() }
//                        .transition(.identity)
//                }
//            }
//            // Environment objects
//            .environmentObject(budgetModel)
//            .environmentObject(spendingModel)
//            .environmentObject(userProfile)
//            .environmentObject(savingsModel)
//            .environmentObject(goalsModel)
//            // Bootstrap work runs while splash is visible
//            .task { await bootstrap() }
//            .onOpenURL { url in
//                if url.absoluteString.contains("reset") {
//                    openReset = true
//                    // if splash already over, route immediately
//                    decideRouteIfReady()
//                }
//            }
//        }
//    }
//    
//    // MARK: - Flow helpers
//    
//    private func splashFinished() {
//        splashMinElapsed = true
//        decideRouteIfReady()
//    }
//    
//    private func decideRouteIfReady() {
//        // Route when both splash minimum + bootstrap are done, or reset link is present
//        if openReset { route = .reset; return }
//        guard splashMinElapsed && bootstrapDone else { return }
//        route = loggedIn ? .dashboard : .signIn
//    }
//    
//    private func bootstrap() async {
//        print("🚀 Starting bootstrap process...")
//        
//        // 🔹 ALWAYS clear all data first to prevent session mixing
//        await clearAllAppData()
//        
//        let hasUID = !userProfile.storedUID.isEmpty
//        print("📱 Stored UID exists: \(hasUID)")
//        
//        await withTaskGroup(of: Void.self) { group in
//            // 1) Minimum splash duration (~0.9s)
//            group.addTask {
//                try? await Task.sleep(nanoseconds: 900_000_000)
//                print("⏰ Splash minimum duration completed")
//            }
//            
//            // 2) Validate and load data if a user is cached
//            if hasUID {
//                group.addTask {
//                    await validateAndLoadUserSession()
//                }
//            } else {
//                print("👤 No stored user session found")
//            }
//            
//            await group.waitForAll()
//        }
//        
//        // Update UI state on main actor
//        await MainActor.run {
//            bootstrapDone = true
//            print("✅ Bootstrap completed. Logged in: \(loggedIn)")
//        }
//        decideRouteIfReady()
//    }
//    
//    // MARK: - Session Management
//    
//    @MainActor
//    private func clearAllAppData() {
//        print("🧹 Clearing all app data...")
//        userProfile.clearAllData()
//        budgetModel.clearData()
//        savingsModel.clearData()
//        spendingModel.clearData()
//        goalsModel.clearData()
//        loggedIn = false
//    }
//    
//    private func validateAndLoadUserSession() async {
//        let storedUID = userProfile.storedUID
//        print("🔍 Validating stored session for UID: \(storedUID)")
//        
//        // Check if the stored session is still valid with Supabase
//        let client = SupabaseManager.shared.client
//        
//        do {
//            // Try to get the current session
//            let session = try await client.auth.session
//            let currentUID = session.user.id.uuidString
//            
//            print("✅ Valid Supabase session found for UID: \(currentUID)")
//            
//            // Verify the stored UID matches the current session
//            if storedUID == currentUID {
//                print("🔄 UIDs match, loading user data...")
//                await loadAllUserData(
//                    userId: currentUID,
//                    userProfile: userProfile,
//                    budgetModel: budgetModel,
//                    savingsModel: savingsModel,
//                    spendingModel: spendingModel
//                )
//                
//                await MainActor.run {
//                    loggedIn = true
//                }
//                print("✅ User session restored successfully")
//            } else {
//                print("⚠️ Stored UID doesn't match current session. Clearing...")
//                await MainActor.run {
//                    userProfile.clearAllData()
//                    loggedIn = false
//                }
//            }
//            
//        } catch {
//            print("❌ No valid Supabase session found: \(error)")
//            print("🧹 Clearing stored session data...")
//            
//            await MainActor.run {
//                userProfile.clearAllData()
//                loggedIn = false
//            }
//        }
//    }
//    
//    // MARK: - Bootstrap loader (enhanced with error handling)
//    
//    func loadAllUserData(
//        userId: String,
//        userProfile: UserProfile,
//        budgetModel: BudgetModel,
//        savingsModel: SavingsModel,
//        spendingModel: SpendingModel
//    ) async {
//        print("📥 Loading all user data for UID: \(userId)")
//        
//        // Load user profile first
//        await userProfile.load(for: userId)
//        print("👤 Profile loaded: \(userProfile.fullName.isEmpty ? "New User" : userProfile.fullName)")
//        
//        // Load other data if we have a valid UUID
//        guard let uuid = UUID(uuidString: userId) else {
//            print("❌ Invalid UUID format: \(userId)")
//            return
//        }
//        
//        // Load budget and spending data concurrently
//        await withTaskGroup(of: Void.self) { group in
//            group.addTask {
//                await budgetModel.loadData(userId: uuid)
//                print("💰 Budget data loaded")
//            }
//            
//            group.addTask {
//                await spendingModel.loadData(userId: uuid)
//                print("💸 Spending data loaded")
//            }
//            
//            await group.waitForAll()
//        }
//        
//        // Calculate savings from spending report
//        let totalSpent = budgetModel.foodSpent +
//                        budgetModel.travelSpent +
//                        budgetModel.entertainmentSpent +
//                        budgetModel.shoppingSpent +
//                        budgetModel.miscSpent
//        
//        let income = await MainActor.run { userProfile.monthlyIncome }
//        let savings = max(income - Int(totalSpent), 0)
//        
//        await MainActor.run {
//            savingsModel.savingsFromReport = Double(savings)
//        }
//        
//        print("💵 Savings calculated: \(savings) from income: \(income) - spent: \(totalSpent)")
//        print("✅ All user data loaded successfully")
//    }
//}
//
//// MARK: - Extensions for clearing data (add these to your respective models)
//
extension BudgetModel {
    func clearData() {
        // Reset all budget properties to default values
        foodSpent = 0
        travelSpent = 0
        entertainmentSpent = 0
        shoppingSpent = 0
        miscSpent = 0
        // Add other budget properties as needed
    }
}
//
extension SavingsModel {
    func clearData() {
        // Reset all savings properties to default values
        savingsFromReport = 0
        // Add other savings properties as needed
    }
}

//extension SpendingModel {
//    func clearData() {
//        // Reset all spending properties to default values
//        // Add spending properties as needed
//    }
//}

extension GoalsModel {
    func clearData() {
        // Reset all goals properties to default values
        // Add goals properties as needed
    }
}
@main
struct SpendMateApp: App {
    // Existing models
    @StateObject var budgetModel  = BudgetModel()
    @StateObject var userProfile  = UserProfile()
    @StateObject var savingsModel = SavingsModel()
    @StateObject var goalsModel   = GoalsModel()
    @StateObject var spendingModel = SpendingModel()
    
    // Routing - Enhanced for password reset
    enum Route { case splash, signIn, dashboard, passwordReset }
    @Namespace private var heroNS
    @State private var route: Route = .splash
    @State private var splashMinElapsed = false
    @State private var bootstrapDone = false
    @State private var loggedIn = false
    @State private var passwordResetRequested = false
    @State private var resetAccessToken: String? = nil
    @State private var resetRefreshToken: String? = nil
    
    init() {
        NotificationManager.requestPermission()
        NotificationManager.scheduleDailySavingsReminder()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Destination scenes
                Group {
                    switch route {
                    case .dashboard:
                        DashboardView()
                    case .signIn:
                        SignInView(heroNamespace: heroNS)
                    case .passwordReset:
                        UpdatePasswordView {
                            // After successful password update, go back to sign in
                            route = .signIn
                            passwordResetRequested = false
                            resetAccessToken = nil
                            resetRefreshToken = nil
                        }
                    case .splash:
                        EmptyView() // covered by splash overlay
                    }
                }
                .opacity(route == .splash ? 0 : 1)
                
                // Splash overlay (shown first)
                if route == .splash {
                    SplashHero(ns: heroNS) { splashFinished() }
                        .transition(.identity)
                }
            }
            // Environment objects
            .environmentObject(budgetModel)
            .environmentObject(spendingModel)
            .environmentObject(userProfile)
            .environmentObject(savingsModel)
            .environmentObject(goalsModel)
            // Bootstrap work runs while splash is visible
            .task { await bootstrap() }
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
    }
    
    // MARK: - Deep Link Handling
    
    private func handleDeepLink(_ url: URL) {
        print("🔗 Received deep link: \(url.absoluteString)")
        
        // Check if it's a password reset link
        if url.absoluteString.contains("reset") || url.absoluteString.contains("recovery") {
            print("🔐 Password reset link detected")
            
            // Extract tokens from URL fragments or query parameters
            extractResetTokens(from: url)
            
            passwordResetRequested = true
            
            // If splash/bootstrap is done, route immediately
            if splashMinElapsed && bootstrapDone {
                route = .passwordReset
            }
        }
        
        // Handle other deep links (group invites, etc.)
        else if url.absoluteString.contains("join") {
            // Handle group invite links
            print("👥 Group invite link detected")
            // You can add group invite handling here later
        }
    }
    
    private func extractResetTokens(from url: URL) {
        print("🔍 Extracting tokens from URL: \(url)")
        
        // Method 1: Check URL fragment (after #)
        if let fragment = url.fragment {
            print("📝 URL fragment: \(fragment)")
            var components = URLComponents()
            components.query = fragment
            
            if let queryItems = components.queryItems {
                for item in queryItems {
                    if item.name == "access_token" {
                        resetAccessToken = item.value
                        print("✅ Found access_token in fragment")
                    } else if item.name == "refresh_token" {
                        resetRefreshToken = item.value
                        print("✅ Found refresh_token in fragment")
                    }
                }
            }
        }
        
        // Method 2: Check query parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            print("📝 URL query items: \(queryItems)")
            
            for item in queryItems {
                if item.name == "access_token" {
                    resetAccessToken = item.value
                    print("✅ Found access_token in query")
                } else if item.name == "refresh_token" {
                    resetRefreshToken = item.value
                    print("✅ Found refresh_token in query")
                }
            }
        }
    }
    
    // MARK: - Flow helpers
    
    private func splashFinished() {
        splashMinElapsed = true
        decideRouteIfReady()
    }
    
    private func decideRouteIfReady() {
        // Route when both splash minimum + bootstrap are done
        guard splashMinElapsed && bootstrapDone else { return }
        
        // Priority: Password reset > Dashboard > Sign in
        if passwordResetRequested {
            route = .passwordReset
        } else {
            route = loggedIn ? .dashboard : .signIn
        }
    }
    
    private func bootstrap() async {
        print("🚀 Starting bootstrap process...")
        
        // Clear all data first
        await clearAllAppData()
        
        let hasUID = !userProfile.storedUID.isEmpty
        print("📱 Stored UID exists: \(hasUID)")
        
        await withTaskGroup(of: Void.self) { group in
            // 1) Minimum splash duration
            group.addTask {
                try? await Task.sleep(nanoseconds: 900_000_000)
                print("⏰ Splash minimum duration completed")
            }
            
            // 2) Validate and load data if a user is cached (but not if password reset is requested)
            if hasUID && !passwordResetRequested {
                group.addTask {
                    await validateAndLoadUserSession()
                }
            } else {
                print("👤 No stored user session found or password reset requested")
            }
            
            await group.waitForAll()
        }
        
        // Update UI state on main actor
        await MainActor.run {
            bootstrapDone = true
            print("✅ Bootstrap completed. Logged in: \(loggedIn)")
        }
        decideRouteIfReady()
    }
    
    // MARK: - Session Management (same as before)
    
    @MainActor
    private func clearAllAppData() {
        print("🧹 Clearing all app data...")
        userProfile.clearAllData()
        budgetModel.clearData()
        savingsModel.clearData()
        spendingModel.clearData()
        goalsModel.clearData()
        loggedIn = false
    }
    
    private func validateAndLoadUserSession() async {
        let storedUID = userProfile.storedUID
        print("🔍 Validating stored session for UID: \(storedUID)")
        
        let client = SupabaseManager.shared.client
        
        do {
            let session = try await client.auth.session
            let currentUID = session.user.id.uuidString
            
            print("✅ Valid Supabase session found for UID: \(currentUID)")
            
            if storedUID == currentUID {
                print("🔄 UIDs match, loading user data...")
                await loadAllUserData(
                    userId: currentUID,
                    userProfile: userProfile,
                    budgetModel: budgetModel,
                    savingsModel: savingsModel,
                    spendingModel: spendingModel
                )
                
                await MainActor.run {
                    loggedIn = true
                }
                print("✅ User session restored successfully")
            } else {
                print("⚠️ Stored UID doesn't match current session. Clearing...")
                await MainActor.run {
                    userProfile.clearAllData()
                    loggedIn = false
                }
            }
            
        } catch {
            print("❌ No valid Supabase session found: \(error)")
            print("🧹 Clearing stored session data...")
            
            await MainActor.run {
                userProfile.clearAllData()
                loggedIn = false
            }
        }
    }
    
    func loadAllUserData(
        userId: String,
        userProfile: UserProfile,
        budgetModel: BudgetModel,
        savingsModel: SavingsModel,
        spendingModel: SpendingModel
    ) async {
        print("📥 Loading all user data for UID: \(userId)")
        
        await userProfile.load(for: userId)
        print("👤 Profile loaded: \(userProfile.fullName.isEmpty ? "New User" : userProfile.fullName)")
        
        guard let uuid = UUID(uuidString: userId) else {
            print("❌ Invalid UUID format: \(userId)")
            return
        }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await budgetModel.loadData(userId: uuid)
                print("💰 Budget data loaded")
            }
            
            group.addTask {
                await spendingModel.loadData(userId: uuid)
                print("💸 Spending data loaded")
            }
            
            await group.waitForAll()
        }
        
        let totalSpent = budgetModel.foodSpent +
                        budgetModel.travelSpent +
                        budgetModel.entertainmentSpent +
                        budgetModel.shoppingSpent +
                        budgetModel.miscSpent
        
        let income = await MainActor.run { userProfile.monthlyIncome }
        let savings = max(income - Int(totalSpent), 0)
        
        await MainActor.run {
            savingsModel.savingsFromReport = Double(savings)
        }
        
        print("💵 Savings calculated: \(savings)")
        print("✅ All user data loaded successfully")
    }
}
