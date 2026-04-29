//
//  ChallengesTypes.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 16/08/25.
//

import Foundation
import SwiftUI

enum ChallengeType: String, Codable { case dailyStreak, oneTimeTarget }

struct ActiveChallenge: Identifiable, Equatable {
    // UI identity
    let id: UUID = UUID()

    // DB identifiers
    let userActiveId: UUID       // user_active_challenges.id
    let dbChallengeId: UUID      // challenges.id

    let title: String
    let totalDays: Int
    let color: Color
    let startDate: Date
    let type: ChallengeType
    var dailyCompletion: [Bool]

    var completedDays: Int { dailyCompletion.filter { $0 }.count }
    var progress: CGFloat  { totalDays == 0 ? 0 : .init(completedDays) / .init(totalDays) }
    var isCompleted: Bool  { completedDays >= totalDays }
}

struct NewChallenge: Identifiable, Equatable {
    let id: UUID = UUID()
    let dbChallengeId: UUID   // carry DB ID for robust matching
    let icon: String
    let title: String
    let points: String
}

struct Achievement: Identifiable, Equatable {
    let id: UUID = UUID()
    let icon: String
    let label: String
    let color: Color
    var earned: Bool = false
    var earnedDate: Date? = nil
    var earnedBy: String? = nil
}

struct Leader: Identifiable, Equatable {
    let id: UUID = UUID()
    let initials: String
    let name: String
    let points: String
    let rank: String
}

struct Milestone: Identifiable, Equatable {
    let id: UUID = UUID()
    let threshold: Int
    let color: Color
    let icon: String
}
