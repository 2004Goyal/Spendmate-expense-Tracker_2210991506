//
//  ProfileView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI
import UIKit

//struct ProfileView: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var userProfile: UserProfile
//    @Namespace private var heroNS
//
//    // Local & AppStorage
//    @State private var showEditProfile = false
//    @State private var navigateToSignIn = false
//    @State var profileImage: UIImage? = nil  // Removed private for image handling
//    @State private var showDeleteAlert = false
//    @State private var showPrivacyPolicy = false
//    @State private var showTermsOfService = false
//
//    // NEW: AI Chatbot locked alert
//    @State private var showAIChatbotAlert = false
//
//    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
//
//    // Public profile
//    @AppStorage("isProfilePublic") private var isProfilePublic: Bool = false
//    @State private var showPublicAlert = false
//
//    // Refer & Earn
//    @State private var referralToken: String?
//    @State private var referralInstalls: Int = 0
//    @State private var isLoadingReferral: Bool = false
//    @State private var showShareSheet: Bool = false
//    @State private var referralShareURL: URL?
//    private let REF_BASE_LINK = "https://spendmate.app.link/install?ref=" // TODO: replace with your real dynamic link domain
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                topBar
//
//                ScrollView {
//                    VStack(spacing: 24) {
//                        profileHeader
//                        accountFeaturesSection
//                        aiChatbotSection // NEW: AI Chatbot section
//                        settingsSection
//                        helpSupportSection
//                        referEarnSection
//                        footer
//                        deleteButton
//                        logoutButton
//                    }
//                }
//            }
//            .sheet(isPresented: $showEditProfile) { editProfileSheet }
//            .sheet(isPresented: $showPrivacyPolicy) {
//                PolicySheet(title: "Privacy Policy", content: PrivacyPolicy.text)
//            }
//            .sheet(isPresented: $showTermsOfService) {
//                PolicySheet(title: "Terms of Service", content: TermsOfService.text)
//            }
//            // Native share sheet for referral link
//            .sheet(isPresented: $showShareSheet) {
//                if let url = referralShareURL {
//                    ActivityView(activityItems: [url])
//                }
//            }
//            .fullScreenCover(isPresented: $navigateToSignIn) {
//                NavigationStack {
//                    SignInView(heroNamespace: heroNS)
//                        .navigationBarBackButtonHidden(true)
//                }
//            }
//            .navigationBarBackButtonHidden(true)
//            .background(Color(.systemGray6).ignoresSafeArea())
//            // Public profile info alert
//            .alert("Profile Visibility", isPresented: $showPublicAlert) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text("Others can view your score and your name on challenges leaderboard. Only your points are shown to others, nothing else.")
//            }
//            // NEW: AI Chatbot coming soon alert
//            .alert("AI Assistant Coming Soon", isPresented: $showAIChatbotAlert) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text("We're working on bringing you an intelligent AI assistant to help manage your expenses. Stay tuned for future updates!")
//            }
//            .onChange(of: isProfilePublic) { newValue in
//                if newValue { showPublicAlert = true }
//            }
//            .onAppear {
//                Task {
//                    await refreshReferralProgress()
//                    setupProfileImageHandling() // Profile image setup
//                }
//            }
//            .onChange(of: profileImage) { newImage in
//                if newImage != nil {
//                    Task {
//                        await handleProfileImageUpdate(newImage)
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - Profile Image Handling Methods (ProfileView only)
//
//    func setupProfileImageHandling() {
//        // Load cached image first
//        if let cachedImage = userProfile.getCachedProfileImage() {
//            profileImage = cachedImage
//        }
//        
//        // Set up notification observer for downloaded images
//        NotificationCenter.default.addObserver(
//            forName: .profileImageLoaded,
//            object: nil,
//            queue: .main
//        ) { notification in
//            guard let userInfo = notification.userInfo,
//                  let image = userInfo["image"] as? UIImage,
//                  let userId = userInfo["userId"] as? String,
//                  userId == userProfile.storedUID else { return }
//            
//            profileImage = image
//        }
//        
//        // Download latest image if URL exists
//        Task {
//            if !userProfile.photoURL.isEmpty {
//                await userProfile.downloadAndCacheProfileImage()
//            }
//        }
//    }
//
//    func handleProfileImageUpdate(_ newImage: UIImage?) async {
//        guard let image = newImage else { return }
//        
//        do {
//            try await userProfile.saveWithProfileImage(image)
//            
//            // Cache the uploaded image immediately
//            if let imageData = image.jpegData(compressionQuality: 0.8) {
//                UserDefaults.standard.set(imageData, forKey: "cached_profile_image_\(userProfile.storedUID)")
//            }
//            
//            print("✅ Profile image uploaded and handled successfully")
//        } catch {
//            print("❌ Failed to save profile image: \(error)")
//        }
//    }
//
//    // MARK: - Top Bar
//
//    private var topBar: some View {
//        HStack {
//            Button { dismiss() } label: {
//                Image(systemName: "chevron.left").foregroundColor(.white)
//            }
//            Spacer()
//            Text("Profile").font(.headline).foregroundColor(.white)
//            Spacer()
//            Button { showEditProfile = true } label: {
//                Image(systemName: "square.and.pencil").foregroundColor(.white)
//            }
//        }
//        .padding()
//        .background(Color("PeacockBlue"))
//    }
//
//    // MARK: - Header
//
//    private var profileHeader: some View {
//        HStack(alignment: .top) {
//            avatarWithCrown
//            VStack(alignment: .leading, spacing: 6) {
//                Text(userProfile.fullName)
//                    .font(.title2.bold())
//                    .foregroundColor(Color("Charcoal"))
//
//                Text("Student")
//                    .font(.subheadline)
//                    .foregroundColor(Color("SlateGray"))
//            }
//            .padding(.leading, 8)
//            Spacer()
//        }
//        .padding(.top, 24)
//        .padding(.horizontal)
//    }
//
//    private var avatarWithCrown: some View {
//        if let image = profileImage {
//            AnyView(
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 80, height: 80)
//                    .clipShape(Circle())
//            )
//        } else {
//            AnyView(
//                Circle()
//                    .fill(Color("PeacockBlue"))
//                    .frame(width: 80, height: 80)
//                    .overlay(
//                        Text(initials(from: userProfile.fullName))
//                            .font(.title.bold())
//                            .foregroundColor(.white)
//                    )
//            )
//        }
//    }
//
//    // MARK: - Account Features
//
//    private var accountFeaturesSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Account Features")
//                .font(.headline)
//                .foregroundColor(Color("Charcoal"))
//
//            VStack(spacing: 0) {
//                featureRow(
//                    icon: "tray.and.arrow.down.fill",
//                    title: "SMS Transaction Parsing",
//                    trailing: AnyView(Toggle("", isOn: .constant(true)).labelsHidden())
//                )
//
//                Divider()
//
//                featureRow(
//                    icon: "person.crop.circle.badge.checkmark",
//                    title: "Make Profile Public",
//                    trailing: AnyView(Toggle("", isOn: $isProfilePublic).labelsHidden())
//                )
//            }
//            .background(Color.white)
//            .cornerRadius(12)
//        }
//        .padding(.horizontal)
//    }
//
//    // MARK: - NEW: AI Chatbot Section (Locked)
//    private var aiChatbotSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("AI Assistant")
//                .font(.headline)
//                .foregroundColor(Color("Charcoal"))
//
//            VStack(spacing: 0) {
//                Button(action: {
//                    showAIChatbotAlert = true
//                }) {
//                    HStack {
//                        HStack(spacing: 12) {
//                            Image(systemName: "brain.head.profile")
//                                .foregroundColor(Color("CaribbeanTeal"))
//                            VStack(alignment: .leading, spacing: 2) {
//                                Text("Mica AI Chatbot")
//                                    .foregroundColor(Color("Charcoal"))
//                                Text("Get intelligent expense insights")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                        Spacer()
//                        
//                        // Coming Soon badge
//                        Text("Coming Soon")
//                            .font(.caption2)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.blue)
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 4)
//                            .background(Color.blue.opacity(0.15))
//                            .cornerRadius(6)
//                    }
//                    .padding()
//                    .background(Color.white)
//                }
//            }
//            .background(Color.white)
//            .cornerRadius(12)
//        }
//        .padding(.horizontal)
//    }
//
//    // MARK: - Settings
//
//    private var settingsSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Settings")
//                .font(.headline)
//                .foregroundColor(Color("Charcoal"))
//
//            VStack(spacing: 0) {
//                featureRow(icon: "bell.fill",
//                           title: "Notifications",
//                           trailing: AnyView(Toggle("", isOn: $notificationsEnabled).labelsHidden()))
//
//                Divider()
//
//                featureRow(icon: "paintpalette.fill",
//                           title: "Theme & Colors",
//                           trailing: AnyView(Image(systemName: "chevron.right").foregroundColor(.secondary)))
//
//                Divider()
//
//                featureRow(icon: "square.and.arrow.up.fill",
//                           title: "Export Data",
//                           trailing: AnyView(Image(systemName: "chevron.right").foregroundColor(.secondary)))
//            }
//            .background(Color.white)
//            .cornerRadius(12)
//        }
//        .padding(.horizontal)
//    }
//    
//    // MARK: - Help & Support
//    private var helpSupportSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Help & Support")
//                .font(.headline)
//                .foregroundColor(Color("Charcoal"))
//
//            VStack(spacing: 0) {
//                Button(action: { openSupportEmail() }) {
//                    HStack {
//                        HStack(spacing: 12) {
//                            Image(systemName: "envelope.fill")
//                                .foregroundColor(Color("CaribbeanTeal"))
//                            VStack(alignment: .leading, spacing: 2) {
//                                Text("Email Us")
//                                    .foregroundColor(Color("Charcoal"))
//                                Text("info.spendmate@gmail.com")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.secondary)
//                    }
//                    .padding()
//                    .background(Color.white)
//                }
//            }
//            .background(Color.white)
//            .cornerRadius(12)
//        }
//        .padding(.horizontal)
//    }
//
//    // MARK: - Open email in Mail or Gmail
//    private func openSupportEmail() {
//        let email   = "info.spendmate@gmail.com"
//        let subject = "SpendMate Support"
//        let body    = "Hi team,%0A%0A" // URL-encoded newlines
//
//        // Prefer Mail (works even if Gmail not installed)
//        if let mailto = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body)") {
//            if UIApplication.shared.canOpenURL(mailto) {
//                UIApplication.shared.open(mailto)
//                return
//            }
//        }
//
//        // Try Gmail (if installed)
//        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        let encodedBody    = body
//        let gmailCandidates = [
//            "googlegmail://co?to=\(email)&subject=\(encodedSubject)&body=\(encodedBody)",
//            "gmail://co?to=\(email)&subject=\(encodedSubject)&body=\(encodedBody)"
//        ]
//
//        for scheme in gmailCandidates {
//            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url)
//                return
//            }
//        }
//
//        // Last fallback: bare mailto (no subject/body)
//        if let bare = URL(string: "mailto:\(email)") {
//            UIApplication.shared.open(bare)
//        }
//    }
//
//    // MARK: - Refer & Earn
//
//    private var referEarnSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Refer & Earn")
//                .font(.headline)
//                .foregroundColor(.white)
//
//            Text("Invite friends to join SpendMate!")
//                .font(.subheadline)
//                .foregroundColor(.white.opacity(0.9))
//
//            // Progress
//            HStack {
//                Text("\(referralInstalls) friends joined")
//                    .font(.caption)
//                    .foregroundColor(.white)
//                Spacer()
//            }
//
//            Button {
//                Task { await prepareReferralAndShare() }
//            } label: {
//                HStack(spacing: 8) {
//                    if isLoadingReferral { ProgressView().tint(.white) }
//                    Text("Share Link").fontWeight(.semibold)
//                }
//                .padding(.horizontal, 20).padding(.vertical, 10)
//                .background(Color.white.opacity(0.2))
//                .foregroundColor(.white)
//                .cornerRadius(20)
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .background(
//            LinearGradient(colors: [Color("PeacockBlue"), Color("CaribbeanTeal")],
//                           startPoint: .topLeading, endPoint: .bottomTrailing)
//        )
//        .cornerRadius(16)
//        .padding(.horizontal)
//    }
//
//    // MARK: - Footer
//
//    private var footer: some View {
//        VStack(spacing: 6) {
//            Text("App Version \(appVersion)")
//                .font(.caption)
//                .foregroundColor(Color("SlateGray"))
//
//            HStack(spacing: 20) {
//                Button("Terms of Service") {
//                    showTermsOfService = true
//                }
//                Button("Privacy Policy") {
//                    showPrivacyPolicy = true
//                }
//            }
//            .font(.caption)
//            .foregroundColor(Color("SlateGray"))
//        }
//    }
//
//    private var appVersion: String {
//        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
//    }
//
//    // MARK: - Danger Zone
//
//    private var deleteButton: some View {
//        Button {
//            showDeleteAlert = true
//        } label: {
//            Text("Delete Account")
//                .fontWeight(.semibold)
//                .foregroundColor(.white)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color.red)
//                .cornerRadius(12)
//        }
//        .padding(.horizontal)
//        .alert("Are you sure you want to delete your account?",
//               isPresented: $showDeleteAlert) {
//            Button("Yes, Delete", role: .destructive) { deleteUserData() }
//            Button("Cancel", role: .cancel) { }
//        } message: {
//            Text("This will permanently remove your data. You cannot undo this action.")
//        }
//    }
//
//    private var logoutButton: some View {
//        Button {
//            navigateToSignIn = true
//        } label: {
//            Text("Logout")
//                .fontWeight(.semibold)
//                .foregroundColor(.red)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color.white)
//                .cornerRadius(12)
//        }
//        .padding(.horizontal)
//        .padding(.top, 4)
//        .padding(.bottom, 40)
//    }
//
//    // MARK: - Row builder
//
//    @ViewBuilder
//    private func featureRow(icon: String, title: String, trailing: AnyView) -> some View {
//        HStack {
//            HStack(spacing: 12) {
//                Image(systemName: icon)
//                    .foregroundColor(Color("CaribbeanTeal"))
//                Text(title)
//                    .foregroundColor(Color("Charcoal"))
//            }
//            Spacer()
//            trailing
//        }
//        .padding()
//        .background(Color.white)
//    }
//
//    // MARK: - Edit Profile Sheet
//
//    private var editProfileSheet: some View {
//        NavigationStack {
//            EditProfileView(
//                fullName: $userProfile.fullName,
//                email: $userProfile.email,
//                phoneNumber: $userProfile.phoneNumber,
//                dateOfBirth: $userProfile.dateOfBirth,
//                profileImage: $profileImage
//            )
//        }
//    }
//
//    // MARK: - Utilities
//
//    private func initials(from name: String) -> String {
//        name.split(separator: " ")
//            .prefix(2)
//            .compactMap { $0.first }
//            .map(String.init)
//            .joined().uppercased()
//    }
//
//    private func deleteUserData() {
//        print("🗑 User data deleted")
//        navigateToSignIn = true
//    }
//}
//
//// MARK: - Refer & Earn helpers (Supabase)
//
//extension ProfileView {
//    private struct ProgressRow: Decodable { let installs: Int }
//
//    // Atomically get/create referral token via RPC
//    private func ensureReferralToken() async throws -> String {
//        try await SupabaseManager.shared.client
//            .rpc("ensure_referral_token")
//            .execute()
//            .value
//    }
//
//    // Refresh installs progress via RPC
//    private func refreshReferralProgress() async {
//        do {
//            let token: String = try await ensureReferralToken()
//            await MainActor.run { referralToken = token }
//
//            let rows: [ProgressRow] = try await SupabaseManager.shared.client
//                .rpc("get_referral_progress")
//                .execute()
//                .value
//            let installs = rows.first?.installs ?? 0
//
//            await MainActor.run { referralInstalls = installs }
//        } catch {
//            print("❌ Referral progress error:", error)
//        }
//    }
//
//    // Build + share the dynamic link
//    private func prepareReferralAndShare() async {
//        await MainActor.run { isLoadingReferral = true }
//        defer { Task { await MainActor.run { isLoadingReferral = false } } }
//
//        do {
//            let token: String = try await ensureReferralToken()
//            await MainActor.run {
//                referralToken = token
//                referralShareURL = URL(string: REF_BASE_LINK + token)
//                showShareSheet = (referralShareURL != nil)
//            }
//        } catch {
//            print("❌ Share link error:", error)
//        }
//    }
//}
//
//// MARK: - Share Sheet Wrapper
//
//struct ActivityView: UIViewControllerRepresentable {
//    let activityItems: [Any]
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
//    }
//    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
//}
struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userProfile: UserProfile
    @Namespace private var heroNS

    // Local & AppStorage
    @State private var showEditProfile = false
    @State private var navigateToSignIn = false
    @State var profileImage: UIImage? = nil  // Removed private for image handling
    @State private var showDeleteAlert = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false

    // NEW: AI Chatbot locked alert
    @State private var showAIChatbotAlert = false

    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true

    // Public profile
    @AppStorage("isProfilePublic") private var isProfilePublic: Bool = false
    @State private var showPublicAlert = false

    // Refer & Earn
    @State private var referralToken: String?
    @State private var referralInstalls: Int = 0
    @State private var isLoadingReferral: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var referralShareURL: URL?
    private let REF_BASE_LINK = "https://spendmate.app.link/install?ref=" // TODO: replace with your real dynamic link domain

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                topBar

                ScrollView {
                    VStack(spacing: 24) {
                        profileHeader
                        accountFeaturesSection
                        aiChatbotSection // NEW: AI Chatbot section
                        settingsSection
                        helpSupportSection
                        referEarnSection
                        footer
                        deleteButton
                        logoutButton
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) { editProfileSheet }
            .sheet(isPresented: $showPrivacyPolicy) {
                PolicySheet(title: "Privacy Policy", content: PrivacyPolicy.text)
            }
            .sheet(isPresented: $showTermsOfService) {
                PolicySheet(title: "Terms of Service", content: TermsOfService.text)
            }
            // Native share sheet for referral link
            .sheet(isPresented: $showShareSheet) {
                if let url = referralShareURL {
                    ActivityView(activityItems: [url])
                }
            }
            .fullScreenCover(isPresented: $navigateToSignIn) {
                NavigationStack {
                    SignInView(heroNamespace: heroNS)
                        .navigationBarBackButtonHidden(true)
                }
            }
            .navigationBarBackButtonHidden(true)
            .background(Color(.systemGray6).ignoresSafeArea())
            // Public profile info alert
            .alert("Profile Visibility", isPresented: $showPublicAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Others can view your score and your name on challenges leaderboard. Only your points are shown to others, nothing else.")
            }
            // NEW: AI Chatbot coming soon alert
            .alert("AI Assistant Coming Soon", isPresented: $showAIChatbotAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("We're working on bringing you an intelligent AI assistant to help manage your expenses. Stay tuned for future updates!")
            }
            .onChange(of: isProfilePublic) { newValue in
                if newValue { showPublicAlert = true }
            }
            .onAppear {
                Task {
                    await refreshReferralProgress()
                    setupProfileImageHandling() // Profile image setup
                }
            }
            .onChange(of: profileImage) { newImage in
                if newImage != nil {
                    Task {
                        await handleProfileImageUpdate(newImage)
                    }
                }
            }
        }
    }

    // MARK: - Profile Image Handling Methods (ProfileView only)

    func setupProfileImageHandling() {
        // Load cached image first
        if let cachedImage = userProfile.getCachedProfileImage() {
            profileImage = cachedImage
        }
        
        // Set up notification observer for downloaded images
        NotificationCenter.default.addObserver(
            forName: .profileImageLoaded,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let image = userInfo["image"] as? UIImage,
                  let userId = userInfo["userId"] as? String,
                  userId == userProfile.storedUID else { return }
            
            profileImage = image
        }
        
        // Download latest image if URL exists
        Task {
            if !userProfile.photoURL.isEmpty {
                await userProfile.downloadAndCacheProfileImage()
            }
        }
    }

    func handleProfileImageUpdate(_ newImage: UIImage?) async {
        guard let image = newImage else { return }
        
        do {
            try await userProfile.saveWithProfileImage(image)
            
            // Cache the uploaded image immediately
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(imageData, forKey: "cached_profile_image_\(userProfile.storedUID)")
            }
            
            print("✅ Profile image uploaded and handled successfully")
        } catch {
            print("❌ Failed to save profile image: \(error)")
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").foregroundColor(.white)
            }
            Spacer()
            Text("Profile").font(.headline).foregroundColor(.white)
            Spacer()
            Button { showEditProfile = true } label: {
                Image(systemName: "square.and.pencil").foregroundColor(.white)
            }
        }
        .padding()
        .background(Color("PeacockBlue"))
    }

    // MARK: - Header

    private var profileHeader: some View {
        HStack(alignment: .top) {
            avatarWithCrown
            VStack(alignment: .leading, spacing: 6) {
                Text(userProfile.fullName)
                    .font(.title2.bold())
                    .foregroundColor(Color("Charcoal"))

                Text("Student")
                    .font(.subheadline)
                    .foregroundColor(Color("SlateGray"))
            }
            .padding(.leading, 8)
            Spacer()
        }
        .padding(.top, 24)
        .padding(.horizontal)
    }

    private var avatarWithCrown: some View {
        if let image = profileImage {
            AnyView(
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            )
        } else {
            AnyView(
                Circle()
                    .fill(Color("PeacockBlue"))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(initials(from: userProfile.fullName))
                            .font(.title.bold())
                            .foregroundColor(.white)
                    )
            )
        }
    }

    // MARK: - Account Features

    private var accountFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Features")
                .font(.headline)
                .foregroundColor(Color("Charcoal"))

            VStack(spacing: 0) {
                featureRow(
                    icon: "tray.and.arrow.down.fill",
                    title: "SMS Transaction Parsing",
                    trailing: AnyView(Toggle("", isOn: .constant(true)).labelsHidden())
                )

                Divider()

                featureRow(
                    icon: "person.crop.circle.badge.checkmark",
                    title: "Make Profile Public",
                    trailing: AnyView(Toggle("", isOn: $isProfilePublic).labelsHidden())
                )
            }
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    // MARK: - NEW: AI Chatbot Section (Locked)
    private var aiChatbotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Assistant")
                .font(.headline)
                .foregroundColor(Color("Charcoal"))

            VStack(spacing: 0) {
                Button(action: {
                    showAIChatbotAlert = true
                }) {
                    HStack {
                        HStack(spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(Color("CaribbeanTeal"))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Mica AI Chatbot")
                                    .foregroundColor(Color("Charcoal"))
                                Text("Get intelligent expense insights")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        
                        // Coming Soon badge
                        Text("Coming Soon")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(6)
                    }
                    .padding()
                    .background(Color.white)
                }
            }
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(Color("Charcoal"))

            VStack(spacing: 0) {
                featureRow(icon: "bell.fill",
                           title: "Notifications",
                           trailing: AnyView(Toggle("", isOn: $notificationsEnabled).labelsHidden()))
            }
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Help & Support
    private var helpSupportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Help & Support")
                .font(.headline)
                .foregroundColor(Color("Charcoal"))

            VStack(spacing: 0) {
                Button(action: { openSupportEmail() }) {
                    HStack {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(Color("CaribbeanTeal"))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Email Us")
                                    .foregroundColor(Color("Charcoal"))
                                Text("info.spendmate@gmail.com")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white)
                }
            }
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    // MARK: - Open email in Mail or Gmail
    private func openSupportEmail() {
        let email   = "info.spendmate@gmail.com"
        let subject = "SpendMate Support"
        let body    = "Hi team,%0A%0A" // URL-encoded newlines

        // Prefer Mail (works even if Gmail not installed)
        if let mailto = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body)") {
            if UIApplication.shared.canOpenURL(mailto) {
                UIApplication.shared.open(mailto)
                return
            }
        }

        // Try Gmail (if installed)
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody    = body
        let gmailCandidates = [
            "googlegmail://co?to=\(email)&subject=\(encodedSubject)&body=\(encodedBody)",
            "gmail://co?to=\(email)&subject=\(encodedSubject)&body=\(encodedBody)"
        ]

        for scheme in gmailCandidates {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }

        // Last fallback: bare mailto (no subject/body)
        if let bare = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(bare)
        }
    }

    // MARK: - Refer & Earn

    private var referEarnSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Refer & Earn")
                .font(.headline)
                .foregroundColor(.white)

            Text("Invite friends to join SpendMate!")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))

            // Progress
            HStack {
                Text("\(referralInstalls) friends joined")
                    .font(.caption)
                    .foregroundColor(.white)
                Spacer()
            }

            Button {
                Task { await prepareReferralAndShare() }
            } label: {
                HStack(spacing: 8) {
                    if isLoadingReferral { ProgressView().tint(.white) }
                    Text("Share Link").fontWeight(.semibold)
                }
                .padding(.horizontal, 20).padding(.vertical, 10)
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [Color("PeacockBlue"), Color("CaribbeanTeal")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 6) {
            Text("App Version \(appVersion)")
                .font(.caption)
                .foregroundColor(Color("SlateGray"))

            HStack(spacing: 20) {
                Button("Terms of Service") {
                    showTermsOfService = true
                }
                Button("Privacy Policy") {
                    showPrivacyPolicy = true
                }
            }
            .font(.caption)
            .foregroundColor(Color("SlateGray"))
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    // MARK: - Danger Zone

    private var deleteButton: some View {
        Button {
            showDeleteAlert = true
        } label: {
            Text("Delete Account")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .alert("Are you sure you want to delete your account?",
               isPresented: $showDeleteAlert) {
            Button("Yes, Delete", role: .destructive) { deleteUserData() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove your data. You cannot undo this action.")
        }
    }

    private var logoutButton: some View {
        Button {
            navigateToSignIn = true
        } label: {
            Text("Logout")
                .fontWeight(.semibold)
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.top, 4)
        .padding(.bottom, 40)
    }

    // MARK: - Row builder

    @ViewBuilder
    private func featureRow(icon: String, title: String, trailing: AnyView) -> some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color("CaribbeanTeal"))
                Text(title)
                    .foregroundColor(Color("Charcoal"))
            }
            Spacer()
            trailing
        }
        .padding()
        .background(Color.white)
    }

    // MARK: - Edit Profile Sheet

    private var editProfileSheet: some View {
        NavigationStack {
            EditProfileView(
                fullName: $userProfile.fullName,
                email: $userProfile.email,
                phoneNumber: $userProfile.phoneNumber,
                dateOfBirth: $userProfile.dateOfBirth,
                profileImage: $profileImage
            )
        }
    }

    // MARK: - Utilities

    private func initials(from name: String) -> String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined().uppercased()
    }

    private func deleteUserData() {
        print("🗑 User data deleted")
        navigateToSignIn = true
    }
}

// MARK: - Refer & Earn helpers (Supabase)

extension ProfileView {
    private struct ProgressRow: Decodable { let installs: Int }

    // Atomically get/create referral token via RPC
    private func ensureReferralToken() async throws -> String {
        try await SupabaseManager.shared.client
            .rpc("ensure_referral_token")
            .execute()
            .value
    }

    // Refresh installs progress via RPC
    private func refreshReferralProgress() async {
        do {
            let token: String = try await ensureReferralToken()
            await MainActor.run { referralToken = token }

            let rows: [ProgressRow] = try await SupabaseManager.shared.client
                .rpc("get_referral_progress")
                .execute()
                .value
            let installs = rows.first?.installs ?? 0

            await MainActor.run { referralInstalls = installs }
        } catch {
            print("❌ Referral progress error:", error)
        }
    }

    // Build + share the dynamic link
    private func prepareReferralAndShare() async {
        await MainActor.run { isLoadingReferral = true }
        defer { Task { await MainActor.run { isLoadingReferral = false } } }

        do {
            let token: String = try await ensureReferralToken()
            await MainActor.run {
                referralToken = token
                referralShareURL = URL(string: REF_BASE_LINK + token)
                showShareSheet = (referralShareURL != nil)
            }
        } catch {
            print("❌ Share link error:", error)
        }
    }
}

// MARK: - Share Sheet Wrapper

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
