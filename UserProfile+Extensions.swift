//
//  UserProfile+Extensions.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 28/08/25.
//

import Foundation
import SwiftUI
import Supabase

extension UserProfile {
    
    // MARK: - Enhanced load method with better error handling (replaces the existing load method)
    func loadEnhanced(for authUID: String) async throws {
        print("🔄 Loading profile for user_id: \(authUID)")
        
        // 🔹 Clear existing data first
        await MainActor.run {
            clearAllData()
        }
        
        guard let uuid = UUID(uuidString: authUID) else {
            print("❌ Invalid UUID: \(authUID)")
            throw ProfileError.invalidUUID
        }
        
        // Use SupabaseManager.shared.client instead of private client property
        let supabaseClient = SupabaseManager.shared.client
        
        do {
            let rows: [UserRow] = try await supabaseClient
                .from("user_profiles")
                .select()
                .eq("user_id", value: uuid)
                .execute()
                .value
            
            print("🔍 Found \(rows.count) rows for user_id: \(uuid)")
            
            if rows.isEmpty {
                print("ℹ️ No profile found for user, will create on first save")
                // Set the storedUID for new users
                await MainActor.run {
                    storedUID = authUID
                }
                return
            }
            
            if rows.count > 1 {
                print("⚠️ Multiple profiles found (\(rows.count)), using the first one")
            }
            
            let row = rows[0]
            await MainActor.run {
                applyUserRow(row)
                self.id = row.id.uuidString
                self.storedUID = authUID // Set after successful load
            }
            print("✅ Profile loaded successfully for: \(fullName.isEmpty ? "New User" : fullName)")
            
        } catch {
            print("❌ Failed to load profile:", error)
            await MainActor.run {
                clearAllData() // Clear on error
            }
            throw ProfileError.loadFailed(error)
        }
    }
    
    // MARK: - Apply UserRow data (made public to avoid 'apply' private access error)
    func applyUserRow(_ row: UserRow) {
        fullName = row.name ?? ""
        email = row.email ?? ""
        phoneNumber = row.phone ?? ""
        photoURL = row.photo_url ?? ""
        isPremium = row.is_premium ?? false
        incomeSource = row.income_source ?? ""
        monthlyIncome = row.monthly_income ?? 0
        dateOfBirth = row.dob ?? Date()
        premiumExpiry = row.premium_expiry
    }
    
    // MARK: - Enhanced save method with upsert logic
    func saveEnhanced() async throws {
        // Use SupabaseManager.shared.client instead of private client property
        let supabaseClient = SupabaseManager.shared.client
        
        guard let authUID = supabaseClient.auth.currentUser?.id.uuidString,
              let authUUID = UUID(uuidString: authUID) else {
            print("❌ No authenticated user found")
            throw ProfileError.saveFailed(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]))
        }

        print("💾 Saving profile for user_id: \(authUID)")

        let existingId: UUID
        
        do {
            let existingRow: UserRow = try await supabaseClient
                .from("user_profiles")
                .select("id")
                .eq("user_id", value: authUUID)
                .single()
                .execute()
                .value
            existingId = existingRow.id
            print("🔍 Updating existing profile with id: \(existingId)")
        } catch {
            existingId = UUID()
            print("🆕 Creating new profile with id: \(existingId)")
        }

        let row = UserRow(
            id: existingId,
            user_id: authUUID,
            name: fullName.isEmpty ? nil : fullName,
            email: email.isEmpty ? nil : email,
            phone: phoneNumber.isEmpty ? nil : phoneNumber,
            dob: dateOfBirth,
            photo_url: photoURL.isEmpty ? nil : photoURL,
            is_premium: isPremium,
            premium_expiry: premiumExpiry,
            income_source: incomeSource.isEmpty ? nil : incomeSource,
            monthly_income: monthlyIncome > 0 ? monthlyIncome : nil
        )

        do {
            let savedRow: UserRow = try await supabaseClient
                .from("user_profiles")
                .upsert(row, onConflict: "user_id")
                .select()
                .single()
                .execute()
                .value
            
            await MainActor.run {
                self.id = savedRow.id.uuidString
                self.storedUID = authUID
            }
            print("✅ Profile saved successfully")
        } catch {
            print("❌ Error saving profile:", error)
            throw ProfileError.saveFailed(error)
        }
    }
}
