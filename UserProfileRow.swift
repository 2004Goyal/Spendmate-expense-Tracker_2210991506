//
//  UserProfileRow.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 12/08/25.
//

import Foundation

//struct UserProfileRow: Codable {
//    let id: UUID              // MUST equal auth.uid()
//    let name: String
//    let email: String
//    let phone: String?
//    let dob: Date?
//    let photo_url: String?
//}
//
//// MARK: - Schema Fix for UserProfileRow
//extension UserProfileRow {
//    /// Create UserProfileRow that matches UserProfile.UserRow schema
//    init(
//        id: UUID,
//        user_id: UUID,  // Add user_id to match UserRow schema
//        name: String,
//        email: String,
//        phone: String? = nil,
//        dob: Date? = nil,
//        photo_url: String? = nil
//    ) {
//        self.id = id
//        self.name = name
//        self.email = email
//        self.phone = phone
//        self.dob = dob
//        self.photo_url = photo_url
//    }
//}
//
//// MARK: - Updated UserProfileRow to match database schema
//struct UserProfileRowFixed: Codable {
//    let id: UUID
//    let user_id: UUID  // This field was missing!
//    let name: String
//    let email: String
//    let phone: String?
//    let dob: Date?
//    let photo_url: String?
//    
//    // Optional fields to match UserRow completely
//    let is_premium: Bool?
//    let premium_expiry: Date?
//    let income_source: String?
//    let monthly_income: Int?
//    
//    init(
//        id: UUID,
//        user_id: UUID,
//        name: String,
//        email: String,
//        phone: String? = nil,
//        dob: Date? = nil,
//        photo_url: String? = nil,
//        is_premium: Bool? = false,
//        premium_expiry: Date? = nil,
//        income_source: String? = nil,
//        monthly_income: Int? = nil
//    ) {
//        self.id = id
//        self.user_id = user_id
//        self.name = name
//        self.email = email
//        self.phone = phone
//        self.dob = dob
//        self.photo_url = photo_url
//        self.is_premium = is_premium
//        self.premium_expiry = premium_expiry
//        self.income_source = income_source
//        self.monthly_income = monthly_income
//    }
//}
//



// MARK: - Fixed UserProfileRow with complete schema
struct UserProfileRow: Codable {
    let id: UUID              // Primary key
    let user_id: UUID         // Foreign key to auth.users - THIS WAS MISSING!
    let name: String
    let email: String
    let phone: String?
    let dob: Date?
    let photo_url: String?
    
    // Additional fields to match UserProfile.UserRow schema
    let is_premium: Bool?
    let premium_expiry: Date?
    let income_source: String?
    let monthly_income: Int?
    
    init(
        id: UUID,
        user_id: UUID,
        name: String,
        email: String,
        phone: String? = nil,
        dob: Date? = nil,
        photo_url: String? = nil,
        is_premium: Bool? = false,
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
}
