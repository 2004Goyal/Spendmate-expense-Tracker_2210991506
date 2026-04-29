//
//  SupabaseManagerExtensions.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 20/08/25.
//

import Foundation
import SwiftUI
import Supabase

// MARK: - SupabaseManager Storage Extensions

extension SupabaseManager {
    
    /// Upload profile image to Supabase Storage
    func uploadProfileImage(_ image: UIImage, for userId: UUID) async throws -> String {
        // Compress image to reasonable size
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw ProfileImageError.imageCompressionFailed
        }
        
        // Create unique filename with timestamp to avoid UUID conflicts
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "profile_\(userId.uuidString)_\(timestamp).jpg"
        let filePath = "profiles/\(fileName)"
        
        print("🔄 Uploading to path: \(filePath)")
        
        do {
            // Upload using Data directly
            _ = try await client.storage
                .from("profile-images")
                .upload(path: filePath, file: imageData, options: FileOptions(upsert: true))
            
            // Return the public URL
            let publicURL = try client.storage
                .from("profile-images")
                .getPublicURL(path: filePath)
            
            print("✅ Upload successful: \(publicURL.absoluteString)")
            return publicURL.absoluteString
        } catch {
            print("❌ Profile image upload failed: \(error)")
            throw ProfileImageError.uploadFailed(error.localizedDescription)
        }
    }
    
    /// Download profile image from URL
    func downloadProfileImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw ProfileImageError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw ProfileImageError.imageDecodingFailed
        }
        
        return image
    }
    
    /// Delete profile image from storage
    func deleteProfileImage(for userId: UUID) async throws {
        let fileName = "profile_\(userId.uuidString).jpg"
        let filePath = "profiles/\(fileName)"
        
        try await client.storage
            .from("profile-images")
            .remove(paths: [filePath])
    }
}

// MARK: - Error Types

enum ProfileImageError: LocalizedError {
    case imageCompressionFailed
    case uploadFailed(String)
    case downloadFailed(String)
    case invalidURL
    case imageDecodingFailed
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            return "Failed to compress image"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .downloadFailed(let message):
            return "Download failed: \(message)"
        case .invalidURL:
            return "Invalid image URL"
        case .imageDecodingFailed:
            return "Failed to decode image"
        case .notAuthenticated:
            return "User not authenticated"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let profileImageLoaded = Notification.Name("profileImageLoaded")
}
