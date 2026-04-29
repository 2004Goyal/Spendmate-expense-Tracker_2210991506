//
//  GoalsModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 17/07/25.
//

import Foundation
import SwiftUI
import Supabase

// MARK: - Goal Class
final class Goal: Identifiable, ObservableObject, Equatable, Hashable {
    let id: UUID
    let createdAt: Date
    @Published var name: String
    @Published var targetAmount: Double
    @Published var savedAmount: Double
    @Published var targetDate: Date
    @Published var additions: [(amount: Double, date: Date)]

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        name: String,
        targetAmount: Double,
        savedAmount: Double,
        targetDate: Date
    ) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.targetAmount = targetAmount
        self.savedAmount = savedAmount
        self.targetDate = targetDate
        self.additions = []
    }

    var progress: Double { targetAmount == 0 ? 0 : savedAmount / targetAmount }
    var monthsLeft: Int {
        Calendar.current.dateComponents([.month], from: .now, to: targetDate).month ?? 0
    }

    static func == (lhs: Goal, rhs: Goal) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Date Extensions
extension Date {
    var rfc3339String: String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f.string(from: self)
    }
}

func parseRFC3339(_ s: String) -> Date? {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f.date(from: s) ?? ISO8601DateFormatter().date(from: s)
}

// MARK: - GoalsModel
final class GoalsModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var selectedGoalId: UUID? = nil

    func load() async {
        do {
            let loaded = try await SupabaseGoalsService.shared.loadGoals()
            await MainActor.run { self.goals = loaded }
        } catch {
            print("❌ Failed to load goals:", error.localizedDescription)
        }
    }

    func save(goal: Goal) async {
        do {
            try await SupabaseGoalsService.shared.saveGoal(goal)
        }
        catch {
            print("❌ Failed to save goal:", error.localizedDescription)
        }
    }

    func update(goal: Goal) async {
        do {
            try await SupabaseGoalsService.shared.updateGoal(goal)
        }
        catch {
            print("❌ Failed to update goal:", error.localizedDescription)
        }
    }
}

// MARK: - Enhanced GoalsModel Extensions
extension GoalsModel {
    /// Enhanced load that preserves local changes
    func loadSafely() async {
        do {
            let loaded = try await SupabaseGoalsService.shared.loadGoals()
            await MainActor.run {
                // Merge loaded goals with any local changes
                self.mergeGoals(loaded)
            }
        } catch {
            print("❌ Failed to load goals:", error.localizedDescription)
        }
    }
    
    /// Merge loaded goals while preserving local changes
    private func mergeGoals(_ loadedGoals: [Goal]) {
        var mergedGoals: [Goal] = []
        
        // Keep locally created goals that might not be synced yet
        let localOnlyGoals = goals.filter { localGoal in
            !loadedGoals.contains { $0.id == localGoal.id }
        }
        
        // Add local-only goals first (newly created)
        mergedGoals.append(contentsOf: localOnlyGoals)
        
        // Add loaded goals, updating any that exist locally
        for loadedGoal in loadedGoals {
            if let localIndex = goals.firstIndex(where: { $0.id == loadedGoal.id }) {
                // Update existing local goal with server data
                let localGoal = goals[localIndex]
                localGoal.name = loadedGoal.name
                localGoal.targetAmount = loadedGoal.targetAmount
                localGoal.savedAmount = loadedGoal.savedAmount
                localGoal.targetDate = loadedGoal.targetDate
                localGoal.additions = loadedGoal.additions
                mergedGoals.append(localGoal)
            } else {
                // Add new goal from server
                mergedGoals.append(loadedGoal)
            }
        }
        
        // Sort by creation date (newest first)
        self.goals = mergedGoals.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Create and save goal with proper error handling
    func createGoal(name: String, targetAmount: Double, targetDate: Date) async -> Bool {
        let newGoal = Goal(
            name: name,
            targetAmount: targetAmount,
            savedAmount: 0,
            targetDate: targetDate
        )
        
        // Add to local array immediately for instant UI feedback
        await MainActor.run {
            self.goals.insert(newGoal, at: 0)
        }
        
        // Save to Supabase
        do {
            try await SupabaseGoalsService.shared.saveGoal(newGoal)
            print("✅ Goal saved successfully: \(newGoal.name)")
            return true
        } catch {
            print("❌ Failed to save goal:", error)
            // Remove from local array if save failed
            await MainActor.run {
                self.goals.removeAll { $0.id == newGoal.id }
            }
            return false
        }
    }
    
    /// Update goal with optimistic updates
    func updateGoal(_ goal: Goal) async {
        // The goal object is already updated in memory (ObservableObject)
        // Just persist to Supabase
        do {
            try await SupabaseGoalsService.shared.updateGoal(goal)
            print("✅ Goal updated successfully: \(goal.name)")
        } catch {
            print("❌ Failed to update goal:", error)
            // Could implement retry logic or show error to user
        }
    }
}
