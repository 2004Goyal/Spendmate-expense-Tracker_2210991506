//
//  UserProfile.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 15/07/25.
//


import SwiftUI
import Supabase
import Foundation

@MainActor
class UserProfile: ObservableObject {
    @AppStorage("uid") var storedUID: String = ""

    @Published var id: String?                 // row id (PK) - optional for you
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var dateOfBirth: Date = Date()
    @Published var photoURL: String = ""
    @Published var isPremium: Bool = false
    @Published var premiumExpiry: Date?
    @Published var incomeSource: String = ""
    @Published var monthlyIncome: Int = 0

    private let client = SupabaseManager.shared.client
    
    // 🔹 REMOVED singleton pattern - each instance is independent
    // static let shared = UserProfile()

    // MARK: - Schema row
    struct UserRow: Codable {
        let id: UUID
        let user_id: UUID
        let name: String?
        let email: String?
        let phone: String?
        let dob: Date?
        let photo_url: String?
        let is_premium: Bool?
        let premium_expiry: Date?
        let income_source: String?
        let monthly_income: Int?

        init(
            id: UUID,
            user_id: UUID,
            name: String? = nil,
            email: String? = nil,
            phone: String? = nil,
            dob: Date? = nil,
            photo_url: String? = nil,
            is_premium: Bool? = nil,
            premium_expiry: Date? = nil,
            income_source: String? = nil,
            monthly_income: Int? = nil
        ) {
            self.id = id
            self.user_id = user_id
            self.name = name
            self.email = email
            self.phone = phone
            self.dob = dob
            self.photo_url = photo_url
            self.is_premium = is_premium
            self.premium_expiry = premium_expiry
            self.income_source = income_source
            self.monthly_income = monthly_income
        }

        enum CodingKeys: String, CodingKey {
            case id, user_id, name, email, phone, dob, photo_url, is_premium, premium_expiry, income_source, monthly_income
        }

        // MARK: - Decoding
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            id = try c.decode(UUID.self, forKey: .id)
            user_id = try c.decode(UUID.self, forKey: .user_id)
            name = try c.decodeIfPresent(String.self, forKey: .name)
            email = try c.decodeIfPresent(String.self, forKey: .email)
            phone = try c.decodeIfPresent(String.self, forKey: .phone)
            photo_url = try c.decodeIfPresent(String.self, forKey: .photo_url)
            is_premium = try c.decodeIfPresent(Bool.self, forKey: .is_premium)
            income_source = try c.decodeIfPresent(String.self, forKey: .income_source)
            monthly_income = try c.decodeIfPresent(Int.self, forKey: .monthly_income)
            dob = Self.decodeFlexibleDate(forKey: .dob, in: c)
            premium_expiry = Self.decodeFlexibleDate(forKey: .premium_expiry, in: c)
        }

        // MARK: - Encoding
        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(id, forKey: .id)
            try c.encode(user_id, forKey: .user_id)
            try c.encodeIfPresent(name, forKey: .name)
            try c.encodeIfPresent(email, forKey: .email)
            try c.encodeIfPresent(phone, forKey: .phone)
            try c.encodeIfPresent(photo_url, forKey: .photo_url)
            try c.encodeIfPresent(is_premium, forKey: .is_premium)
            try c.encodeIfPresent(income_source, forKey: .income_source)
            try c.encodeIfPresent(monthly_income, forKey: .monthly_income)
            if let d = dob { try c.encode(Self.ymd.string(from: d), forKey: .dob) }
            if let e = premium_expiry { try c.encode(Self.iso8601Basic.string(from: e), forKey: .premium_expiry) }
        }

        static func decodeFlexibleDate(forKey key: CodingKeys,
                                       in container: KeyedDecodingContainer<CodingKeys>) -> Date? {
            if let s = try? container.decode(String.self, forKey: key) {
                if let d = ymd.date(from: s) { return d }
                if let d = iso8601Frac.date(from: s) { return d }
                if let d = iso8601Basic.date(from: s) { return d }
                if let secs = Double(s) { return Date(timeIntervalSince1970: secs) }
                return nil
            }
            if let secs = try? container.decode(Double.self, forKey: key) {
                return Date(timeIntervalSince1970: secs)
            }
            return nil
        }

        private static let ymd: DateFormatter = {
            let f = DateFormatter()
            f.calendar = .init(identifier: .iso8601)
            f.locale = .init(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(secondsFromGMT: 0)
            f.dateFormat = "yyyy-MM-dd"
            return f
        }()

        private static let iso8601Basic: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.timeZone = TimeZone(secondsFromGMT: 0)!
            f.formatOptions = [.withInternetDateTime]
            return f
        }()

        private static let iso8601Frac: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.timeZone = TimeZone(secondsFromGMT: 0)!
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return f
        }()
    }

    // MARK: - Clear all data (call on logout and before new login)
    func clearAllData() {
        print("🧹 Clearing all user profile data")
        id = nil
        fullName = ""
        email = ""
        phoneNumber = ""
        dateOfBirth = Date()
        photoURL = ""
        isPremium = false
        premiumExpiry = nil
        incomeSource = ""
        monthlyIncome = 0
        storedUID = ""
    }

    // MARK: - Load by auth UID (user_id), not by row PK
    func load(for authUID: String) async {
        print("🔄 Loading profile for user_id: \(authUID)")
        
        // 🔹 Clear existing data first
        clearAllData()
        
        do {
            guard let uuid = UUID(uuidString: authUID) else {
                print("❌ Invalid UUID: \(authUID)")
                return
            }
            
            let rows: [UserRow] = try await client
                .from("user_profiles")
                .select()
                .eq("user_id", value: uuid)
                .execute()
                .value
            
            print("🔍 Found \(rows.count) rows for user_id: \(uuid)")
            
            if rows.isEmpty {
                print("ℹ️ No profile found for user, will create on first save")
                // Set the storedUID for new users
                storedUID = authUID
                return
            }
            
            if rows.count > 1 {
                print("⚠️ Multiple profiles found (\(rows.count)), using the first one")
            }
            
            let row = rows[0]
            apply(row)
            self.id = row.id.uuidString
            self.storedUID = authUID // Set after successful load
            print("✅ Profile loaded successfully for: \(fullName.isEmpty ? "New User" : fullName)")
            
        } catch {
            print("❌ Failed to load profile:", error)
            clearAllData() // Clear on error
        }
    }

    // MARK: - Save / Upsert (conflict on user_id)
    func save() async {
        guard let authUID = client.auth.currentUser?.id.uuidString,
              let authUUID = UUID(uuidString: authUID) else {
            print("❌ No authenticated user found")
            return
        }

        print("💾 Saving profile for user_id: \(authUID)")

        let existingId: UUID
        
        do {
            let existingRow: UserRow = try await client
                .from("user_profiles")
                .select("id")
                .eq("user_id", value: authUUID)
                .single()
                .execute()
                .value
            existingId = existingRow.id
            print("📝 Updating existing profile with id: \(existingId)")
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
            let savedRow: UserRow = try await client
                .from("user_profiles")
                .upsert(row, onConflict: "user_id")
                .select()
                .single()
                .execute()
                .value
            
            self.id = savedRow.id.uuidString
            self.storedUID = authUID
            print("✅ Profile saved successfully")
        } catch {
            print("❌ Error saving profile:", error)
        }
    }

    private func apply(_ row: UserRow) {
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

    func logout() {
        print("🚪 Logging out user")
        clearAllData()
        
        // Also sign out from Supabase
        Task {
            do {
                try await client.auth.signOut()
                print("✅ Signed out from Supabase")
            } catch {
                print("❌ Error signing out: \(error)")
            }
        }
    }
    
    // MARK: - Profile Image Methods

    /// Save profile with image upload - UPDATED VERSION
    //
    //  Add these methods to your existing UserProfile.swift class
    //  Copy and paste these INSIDE your UserProfile class (before the closing brace)
    //

    // MARK: - Profile Image Methods

    /// Get cached profile image from UserDefaults
    func getCachedProfileImage() -> UIImage? {
        guard let imageData = UserDefaults.standard.data(forKey: "cached_profile_image_\(storedUID)") else {
            return nil
        }
        return UIImage(data: imageData)
    }

    /// Clear cached profile image
    func clearCachedProfileImage() {
        UserDefaults.standard.removeObject(forKey: "cached_profile_image_\(storedUID)")
    }

    /// Save profile with image upload
    func saveWithProfileImage(_ image: UIImage?) async throws {
        guard let authUID = SupabaseManager.shared.client.auth.currentUser?.id else {
            throw ProfileImageError.notAuthenticated
        }
        
        var newPhotoURL = self.photoURL
        
        // Upload image if provided
        if let image = image {
            do {
                newPhotoURL = try await SupabaseManager.shared.uploadProfileImage(image, for: authUID)
                print("✅ Profile image uploaded successfully")
            } catch {
                print("❌ Upload failed: \(error)")
                throw error
            }
        }
        
        // Get existing profile ID or use auth UID as both id and user_id
        let profileId: UUID
        if let existingId = self.id, let uuid = UUID(uuidString: existingId) {
            profileId = uuid
        } else {
            profileId = authUID // Use auth UID as the profile ID
        }
        
        // Create/update profile row with correct ID handling
        let row = UserRow(
            id: profileId,        // Use existing ID or auth UID
            user_id: authUID,     // Always use auth UID for user_id
            name: fullName,
            email: email,
            phone: phoneNumber,
            dob: dateOfBirth,
            photo_url: newPhotoURL,
            is_premium: isPremium,
            premium_expiry: premiumExpiry,
            income_source: incomeSource,
            monthly_income: monthlyIncome
        )
        
        do {
            let savedRow: UserRow = try await SupabaseManager.shared.client
                .from("user_profiles")
                .upsert(row, onConflict: "user_id")  // Upsert based on user_id, not id
                .select()
                .single()
                .execute()
                .value
            
            // Update local state with the saved data
            await MainActor.run {
                self.photoURL = newPhotoURL
                self.id = savedRow.id.uuidString  // Update local ID with saved ID
            }
            
            print("✅ Profile saved successfully with ID: \(savedRow.id)")
        } catch {
            print("❌ Error saving profile: \(error)")
            throw error
        }
    }

    /// Download and cache profile image
    func downloadAndCacheProfileImage() async {
        guard !photoURL.isEmpty else { return }
        
        do {
            let image = try await SupabaseManager.shared.downloadProfileImage(from: photoURL)
            
            // Store in UserDefaults for offline access
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(imageData, forKey: "cached_profile_image_\(storedUID)")
            }
            
            // Post notification for UI update
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .profileImageLoaded,
                    object: nil,
                    userInfo: ["image": image, "userId": storedUID]
                )
            }
            
            print("✅ Profile image downloaded and cached")
        } catch {
            print("❌ Failed to download profile image: \(error)")
        }
    }
}
