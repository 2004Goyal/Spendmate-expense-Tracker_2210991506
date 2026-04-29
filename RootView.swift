//
//  RootView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 16/07/25.
//

import Foundation
import SwiftUI

struct RootView: View {
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var goalsModel: GoalsModel
    @Namespace private var heroNS

    @State private var isLoading = true
    @State private var navigateToDashboard = false

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading…")
            } else if navigateToDashboard {
                MainTabView()
            } else {
                // ✅ Always start on Sign In
                SignInView(heroNamespace: heroNS)
            }
        }
        .task {
            // ❗️Do not auto-route to dashboard
            // Remove storedUID-based auto navigation
            defer { isLoading = false }
            navigateToDashboard = false

            // (Optional) If you still want to prewarm caches without navigating:
            // await userProfile.clear() / light local setup, etc.
        }
    }
}
