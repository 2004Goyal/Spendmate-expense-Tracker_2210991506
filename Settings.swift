//
//  Settings.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 15/07/25.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage("isPremiumUser") private var isPremiumUser: Bool = false
    @Environment(\.dismiss) var dismiss
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var showLogoutConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("General")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.gray)
                    }

                    Button("Privacy Policy") { showPrivacy = true }
                    Button("Terms of Service") { showTerms = true }
                }

                Section(header: Text("Support")) {
                    Button("Send Feedback") {
                        if let url = URL(string: "mailto:info.spendmate@gmail.com") {
                            UIApplication.shared.open(url)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showLogoutConfirm = true
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPrivacy) {
                PolicySheet(title: "Privacy Policy", content: PrivacyPolicy.text)
            }
            .sheet(isPresented: $showTerms) {
                PolicySheet(title: "Terms of Service", content: TermsOfService.text)
            }
            .alert("Are you sure you want to logout?", isPresented: $showLogoutConfirm) {
                Button("Logout", role: .destructive) {
                    // Reset app state
                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - Policy Modal Sheet
//struct PolicySheet: View {
//    let title: String
//    let content: String
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                Text(content)
//                    .padding()
//                    .font(.body)
//                    .foregroundColor(.primary)
//            }
//            .navigationTitle(title)
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button("Done") {
//                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
//                    }
//                }
//            }
//        }
//    }
//}
struct PolicySheet: View {
    let title: String
    let attributedContent: AttributedString?
    let plainContent: String?
    
    // Convenience initializers
    init(title: String, content: String) {
        self.title = title
        self.plainContent = content
        self.attributedContent = nil
    }
    
    init(title: String, attributedContent: AttributedString) {
        self.title = title
        self.attributedContent = attributedContent
        self.plainContent = nil
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let attributedContent = attributedContent {
                        Text(attributedContent)
                            .font(.body)
                            .foregroundColor(Color("Charcoal"))
                            .padding()
                            .environment(\.openURL, OpenURLAction { url in
                                openURL(url)
                                return .handled
                            })
                    } else if let plainContent = plainContent {
                        Text(plainContent)
                            .font(.body)
                            .foregroundColor(Color("Charcoal"))
                            .padding()
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("PeacockBlue"))
                }
            }
        }
    }
}


struct PrivacyPolicy {
    static let text = """
    SpendMate is committed to protecting your privacy. We only collect the data necessary to provide core app features such as expense tracking, budgeting, and premium services.

    Data collected:
    - Name, Email, Phone (for login)
    - Expense inputs, goals, and preferences

    We do not sell your data to third parties. All sensitive information is securely stored using industry-standard encryption and security practices.

    Data Usage:
    - Personal information is used solely for account management and app functionality
    - Expense data helps provide personalized insights and budgeting recommendations
    - Anonymous usage statistics may be collected to improve app performance

    Data Sharing:
    - We do not share, sell, or rent your personal information to third parties
    - Data may only be disclosed if required by law or to protect our users' safety

    Data Security:
    - All data is encrypted in transit and at rest
    - We implement regular security audits and updates
    - User passwords are hashed and never stored in plain text

    Your Rights:
    - Request access to your personal data
    - Request correction of inaccurate information
    - Request deletion of your account and associated data
    - Opt-out of non-essential communications

    For detailed privacy information, terms of service, and data handling procedures, please visit our comprehensive privacy portal:
    
    https://2004goyal.github.io/Spendmate-URLs/

    For privacy-related questions or concerns, email: info.spendmate@gmail.com

    Last updated: August 2025
    """
}

struct TermsOfService {
    static let text = """
    By using SpendMate, you agree to our terms:

    Usage Rights:
    - You may use the app for personal financial management
    - The app is intended for individual use and personal expense tracking
    - You are responsible for the accuracy of data you input

    Premium Services:
    - Premium features are optional and billed based on the selected plan
    - Billing occurs according to your chosen subscription period
    - You may cancel your subscription at any time through your device settings

    Limitations:
    - We are not liable for financial decisions made based on app insights
    - The app provides tools and suggestions, not professional financial advice
    - We do not guarantee specific financial outcomes

    Account Responsibility:
    - You are responsible for maintaining the security of your account
    - Notify us immediately of any unauthorized access
    - Do not share your account credentials with others

    Service Availability:
    - We strive to maintain 99% uptime but cannot guarantee uninterrupted service
    - Features may be updated, modified, or discontinued with notice
    - We reserve the right to suspend accounts that violate these terms

    Intellectual Property:
    - SpendMate and its features are protected by copyright and trademark laws
    - You may not copy, modify, or distribute the app without permission

    For comprehensive terms of service, detailed policies, and support documentation, please visit:
    
    """
    
    // Separate URL for linking
    static let supportURL = "https://2004goyal.github.io/Support-Url/"
    
    static let textAfterURL = """

    Continued use of the app means you accept these terms and any future updates.

    For support, questions, or issues regarding these terms, contact: info.spendmate@gmail.com

    Last updated: August 2025
    """
    
    // Complete attributed text with clickable link
    static var attributedText: AttributedString {
        var result = AttributedString(text)
        
        // Create clickable link
        var linkText = AttributedString(supportURL)
        linkText.foregroundColor = .blue
        linkText.underlineStyle = .single
        linkText.link = URL(string: supportURL)
        
        result.append(linkText)
        result.append(AttributedString(textAfterURL))
        
        return result
    }
}
