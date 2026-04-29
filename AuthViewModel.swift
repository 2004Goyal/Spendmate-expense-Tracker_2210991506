//
//  AuthViewModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI
import Combine
import Supabase

//@MainActor
//class AuthViewModel: ObservableObject {
//    @Published var fullName: String = ""
//    @Published var email: String = ""
//    @Published var phoneNumber: String = ""
//    @Published var dateOfBirth: Date = Date()
//    @Published var photoURL: String? = nil
//
//    // ✅ Use your shared Supabase client
//    private let client = SupabaseManager.shared.client
//
//    func saveUserProfile() async {
//        // If your SDK returns UUID for id (most recent):
//        guard let uid = client.auth.currentUser?.id else {
//            print("❌ No signed-in user")
//            return
//        }
//        // If your SDK returns String for id, use this instead:
//        // guard let uidString = client.auth.currentUser?.id,
//        //       let uid = UUID(uuidString: uidString) else { print("❌ Invalid auth.uid()"); return }
//
//        let row = UserProfileRow(
//            id: uid,                 // 👈 MUST equal auth.uid()
//            name: fullName,
//            email: email,
//            phone: phoneNumber,
//            dob: dateOfBirth,
//            photo_url: photoURL
//        )
//
//        do {
//            // 🔑 Execute + decode
//            let inserted: [UserProfileRow] = try await client
//                .from("user_profiles")
//                .insert(row)
//                .select()
//                .execute()
//                .value
//
//            guard inserted.first != nil else {
//                throw NSError(domain: "InsertFailed", code: -1,
//                              userInfo: [NSLocalizedDescriptionKey: "No row returned"])
//            }
//
//            print("✅ Profile saved to Supabase")
//        } catch {
//            print("❌ Error saving profile:", error)
//        }
//    }
//}


import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var dateOfBirth: Date = Date()
    @Published var photoURL: String? = nil

    // ✅ Use your shared Supabase client
    private let client = SupabaseManager.shared.client

    func saveUserProfile() async {
        guard let uid = client.auth.currentUser?.id else {
            print("❌ No signed-in user")
            return
        }

        // Use the FIXED UserProfileRow with user_id field
        let row = UserProfileRow(
            id: uid,                 // Primary key
            user_id: uid,           // Foreign key - THIS IS THE CRITICAL FIX!
            name: fullName,
            email: email,
            phone: phoneNumber.isEmpty ? nil : phoneNumber,
            dob: dateOfBirth,
            photo_url: photoURL,
            is_premium: false,
            premium_expiry: nil,
            income_source: nil,
            monthly_income: nil
        )

        do {
            // 🔒 Execute + decode with enhanced error handling
            let inserted: [UserProfileRow] = try await client
                .from("user_profiles")
                .insert(row)
                .select()
                .execute()
                .value

            guard inserted.first != nil else {
                throw NSError(domain: "InsertFailed", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "No row returned after insert"])
            }

            print("✅ Profile saved to Supabase successfully")
        } catch {
            print("❌ Error saving profile:", error)
            print("❌ Error details: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Enhanced profile save with better error handling
    func saveUserProfileEnhanced() async throws {
        guard let uid = client.auth.currentUser?.id else {
            throw AuthError.noAuthenticatedUser
        }

        let row = UserProfileRow(
            id: uid,
            user_id: uid,  // Critical: both id and user_id must be set
            name: fullName.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            phone: phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty ? nil : phoneNumber,
            dob: dateOfBirth,
            photo_url: photoURL,
            is_premium: false,
            premium_expiry: nil,
            income_source: nil,
            monthly_income: nil
        )

        do {
            // Try insert first, then upsert if needed
            let _: [UserProfileRow] = try await client
                .from("user_profiles")
                .insert(row)
                .select()
                .execute()
                .value

            print("✅ Profile saved successfully")
        } catch {
            // If insert fails (e.g., duplicate), try upsert
            print("ℹ️ Insert failed, trying upsert: \(error)")
            
            let _: [UserProfileRow] = try await client
                .from("user_profiles")
                .upsert(row)
                .select()
                .execute()
                .value
            
            print("✅ Profile upserted successfully")
        }
    }
}

// MARK: - Auth Errors
enum AuthError: Error, LocalizedError {
    case noAuthenticatedUser
    case profileSaveFailed
    case invalidUserData
    
    var errorDescription: String? {
        switch self {
        case .noAuthenticatedUser:
            return "No authenticated user found"
        case .profileSaveFailed:
            return "Failed to save user profile"
        case .invalidUserData:
            return "Invalid user data provided"
        }
    }
}
