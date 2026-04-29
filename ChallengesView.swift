//
//  ChallengesView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI
import Combine
import AudioToolbox
import UIKit
import AVFoundation

extension View {
    @ViewBuilder
    func glow(_ color: Color, radius: CGFloat = 18) -> some View {
        self
            .shadow(color: color.opacity(0.55), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.25), radius: radius/2, x: 0, y: 0)
    }
}

extension ChallengesViewModel {
    // Make the initials function accessible
    static func initials(from name: String) -> String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined()
    }
}

extension Array where Element == Achievement {
    func sortedUnlockedFirst() -> [Achievement] {
        self.sorted { a, b in
            if a.earned != b.earned { return a.earned && !b.earned }
            if a.earned, b.earned {
                let ad = a.earnedDate ?? .distantPast
                let bd = b.earnedDate ?? .distantPast
                return ad > bd
            }
            return a.label < b.label
        }
    }
}

private extension Text {
    var headerStyle: some View {
        self.font(.headline).foregroundColor(Color("Charcoal"))
    }
}

// MARK: - Helper Enums and Structs

enum Haptics {
    static func success() {
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(.success)
    }
}

enum SoftSound {
    static func play() {
        AudioServicesPlaySystemSound(1104) // subtle "tock"
    }
}

enum AchievementFilter: String, CaseIterable {
    case all = "All"
    case earned = "Earned"
    case locked = "Locked"
}

enum ChallengeFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

// MARK: - Visual Effects

struct SparkleBurst: View {
    @State private var animate = false
    let color: Color
    
    var body: some View {
        ZStack {
            ForEach(0..<16, id: \.self) { i in
                Circle()
                    .fill(color.opacity(0.9))
                    .frame(width: 6, height: 6)
                    .offset(x: animate ? CGFloat.random(in: -120...120) : 0,
                            y: animate ? CGFloat.random(in: -120...120) : 0)
                    .opacity(animate ? 0 : 1)
                    .animation(.easeOut(duration: 0.9).delay(Double(i) * 0.02), value: animate)
            }
        }
        .onAppear { animate = true }
    }
}

struct ActiveChallengeCard: View {
    let title, days: String
    let progress: CGFloat
    let color: Color
    
    var body: some View {
        VStack(alignment:.leading, spacing:8){
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(Color("Charcoal"))
                .lineLimit(2) // Limit to 2 lines to prevent size variation
                .fixedSize(horizontal: false, vertical: true)
            
            Text("\(days) Days Complete")
                .font(.caption)
                .foregroundColor(Color("SlateGray"))
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .frame(height: 6)
                .background(Color(.systemGray5))
                .cornerRadius(4)
        }
        .padding(16)
        .frame(width: 220, height: 120) // Fixed dimensions for consistency
        .background(Color("MistyAqua"))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

// MARK: - Main ChallengesView

struct ChallengesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userProfile: UserProfile
    @AppStorage("isProfilePublic") private var isProfilePublic: Bool = false
    @StateObject private var vm = ChallengesViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                topBar
                Spacer().frame(height: 16)
                ScrollView { content }
            }
            .background(Color.white)
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(item: $vm.justUnlocked, onDismiss: { vm.justUnlocked = nil }) { a in
                UnlockedCelebrationView(achievement: a)
            }
        }
        .onAppear {
            vm.setCurrentUser(
                name: userProfile.fullName.isEmpty ? "You" : userProfile.fullName,
                isPublic: isProfilePublic
            )
            Task { await vm.refreshJoinablesBasedOnRules() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task { await vm.refreshJoinablesBasedOnRules() }
        }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").foregroundColor(.white)
            }
            Spacer()
            Text("Challenges").font(.headline).foregroundColor(.white)
            Spacer()
        }
        .padding()
        .frame(height: 52)
        .background(Color("PeacockBlue"))
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Active Challenges Section with "See all" button
            HStack {
                Text("Your Active Challenges").headerStyle
                Spacer()
                NavigationLink(destination: AllActiveChallengesView().environmentObject(vm)) {
                    HStack(spacing: 6) {
                        Text("See all").font(.subheadline.weight(.semibold))
                        Image(systemName: "chevron.right").font(.caption.bold())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("MistyAqua"))
                    .cornerRadius(14)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(vm.activeChallenges.prefix(5)) { ch in
                        NavigationLink {
                            ChallengeDetailView(ch: ch).environmentObject(vm)
                        } label: {
                            ActiveChallengeCard(
                                title: ch.title,
                                days: "\(ch.completedDays)/\(ch.totalDays)",
                                progress: ch.progress,
                                color: ch.color
                            )
                        }
                    }
                }
                .padding(.horizontal, 2)
            }

            HStack {
                Text("Your Achievements").headerStyle
                Spacer()
                NavigationLink(destination: AchievementsGalleryView().environmentObject(vm)) {
                    HStack(spacing: 6) {
                        Text("See all").font(.subheadline.weight(.semibold))
                        Image(systemName: "chevron.right").font(.caption.bold())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("MistyAqua"))
                    .cornerRadius(14)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(vm.achievements.sortedUnlockedFirst()) { a in
                        AchievementBadgePremium(achievement: a)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 8)
            }

            Text("Join New Challenge").headerStyle
            if vm.newChallenges.isEmpty {
                let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: nextSunday()).day ?? 0
                Text("🎯 New challenges will come in \(daysLeft) day\(daysLeft == 1 ? "" : "s")")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(vm.newChallenges) { ch in
                        NewChallengeRow(icon: ch.icon, title: ch.title, points: ch.points) {
                            vm.joinChallenge(ch)
                        }
                    }
                }
            }

            Text("Top Savers Leaderboard").headerStyle
            VStack(spacing: 6) {
                ForEach(vm.leaders) { l in
                    LeaderRow(initials: l.initials, name: l.name, points: l.points, rank: l.rank)
                }
                
                if let userInfo = vm.currentUserLeaderboardInfo,
                   !vm.leaders.contains(where: { $0.name == vm.ownerName }) {
                    LeaderRow(
                        initials: ChallengesViewModel.initials(from: vm.ownerName),
                        name: vm.ownerName,
                        points: "\(userInfo.points)",
                        rank: "#\(userInfo.rank)"
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("CaribbeanTeal"), lineWidth: 2)
                    )
                }
            }

            // Milestones section with proper spacing
            VStack(alignment: .leading, spacing: 16) {
                Text("Milestones").headerStyle
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(vm.milestoneCatalog) { m in
                            let prog = Double(vm.totalCompleted) / Double(m.threshold)
                            FlippableMilestoneCard(
                                milestone: m,
                                progress: min(1.0, max(0.0, prog)),
                                unlocked: vm.totalCompleted >= m.threshold,
                                remaining: max(0, m.threshold - vm.totalCompleted)
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 20)
                }
            }

            Text("👉 A ₹50 daily coffee adds up to ₹1,500/month! Track your expenses to save more.")
                .font(.footnote)
                .foregroundColor(Color("SlateGray"))
                .padding(.top, 12)
        }
        .padding()
        .padding(.bottom, 20)
    }

    private func nextSunday() -> Date {
        var components = DateComponents()
        components.hour = 0
        components.weekday = 1
        return Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)!
    }
}

// MARK: - Card Components

// FIXED: Compact Active Challenge Card with better visibility
struct CompactActiveChallengeCard: View {
    let title: String
    let startDate: Date
    let isCompleted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Challenge title - limited to 2 lines
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("Charcoal"))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // Status badge
            HStack(spacing: 4) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "clock.fill")
                    .font(.system(size: 10))
                Text(isCompleted ? "Completed" : "Active")
                    .font(.system(size: 10, weight: .medium))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(isCompleted ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
            .foregroundColor(isCompleted ? .green : .orange)
            .cornerRadius(6)
            
            // Start date at bottom
            Text("Started \(startDate.formatted(.dateTime.month(.abbreviated).day()))")
                .font(.system(size: 10))
                .foregroundColor(Color("SlateGray"))
        }
        .padding(12)
        .frame(width: 160, height: 100) // Smaller, fixed dimensions
        .background(Color("MistyAqua"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("CaribbeanTeal").opacity(0.3), lineWidth: 1)
        )
    }
}

struct NewChallengeRow: View {
    let icon, title, points: String
    let join: () -> Void
    
    var body: some View {
        HStack{
            Image(systemName: icon).foregroundColor(Color("CaribbeanTeal"))
                .padding(12).background(Color("MistyAqua")).clipShape(Circle())
            VStack(alignment:.leading){
                Text(title).foregroundColor(Color("Charcoal"))
                Text("\(points) points").font(.caption).foregroundColor(Color("SlateGray"))
            }
            Spacer()
            Button("Join", action: join)
                .padding(.horizontal,16).padding(.vertical,6)
                .background(Color("CaribbeanTeal")).foregroundColor(.white).cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct LeaderRow: View {
    let initials, name, points, rank: String
    
    var body: some View {
        HStack{
            Circle().fill(Color("MistyAqua")).frame(width:36, height:36)
                .overlay(Text(initials).font(.caption.bold()))
            VStack(alignment:.leading){
                Text(name).foregroundColor(Color("Charcoal"))
                Text("\(points) points").font(.caption).foregroundColor(Color("SlateGray"))
            }
            Spacer()
            Text(rank).fontWeight(.semibold).foregroundColor(Color("CaribbeanTeal"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Flippable Milestone Card

struct FlippableMilestoneCard: View {
    let milestone: Milestone
    let progress: Double
    let unlocked: Bool
    let remaining: Int
    
    @State private var flipped = false
    
    var body: some View {
        ZStack {
            frontCard.opacity(flipped ? 0 : 1)
            backCard.opacity(flipped ? 1 : 0)
        }
        .frame(width: 180, height: 200)
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x:0,y:1,z:0))
        .animation(.easeInOut(duration: 0.6), value: flipped)
        .onTapGesture {
            flipped.toggle()
        }
    }
    
    private var frontCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: milestone.icon).font(.title3)
                Spacer()
                Text("\(milestone.threshold)").font(.title2.bold())
            }
            .foregroundColor(Color("Charcoal"))

            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.2), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                Circle()
                    .trim(from: 0, to: CGFloat(min(1, max(0, progress))))
                    .stroke(milestone.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(round(progress * 100)))%")
                    .font(.headline.bold()).foregroundColor(Color("Charcoal"))
            }
            .frame(width: 80, height: 80)
            
            Text("Challenges")
                .font(.subheadline.bold())
                .foregroundColor(Color("Charcoal"))

            if unlocked {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Unlocked").font(.subheadline.bold())
                }
                .foregroundColor(.green)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.12))
                .cornerRadius(10)
            } else {
                Text("\(remaining) more to go")
                    .font(.footnote.bold()).foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(
            LinearGradient(colors: [milestone.color.opacity(0.15), .white],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(milestone.color.opacity(0.35), lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var backCard: some View {
        VStack(spacing: 10) {
            Image(systemName: milestone.icon)
                .font(.title2)
                .foregroundColor(milestone.color)
            
            Text("Complete")
                .font(.headline.bold())
                .foregroundColor(Color("Charcoal"))
            
            Text("\(milestone.threshold)")
                .font(.title.bold())
                .foregroundColor(milestone.color)
            
            Text("challenges to earn this milestone")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
            
            if unlocked {
                Text("🏆 Achieved!")
                    .font(.subheadline.bold())
                    .foregroundColor(.green)
                    .padding(.top, 4)
            } else {
                Text("\(remaining) remaining")
                    .font(.subheadline.bold())
                    .foregroundColor(milestone.color)
                    .padding(.top, 4)
            }
        }
        .padding(14)
        .background(
            LinearGradient(colors: [milestone.color.opacity(0.25), .white.opacity(0.9)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(milestone.color.opacity(0.5), lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .rotation3DEffect(.degrees(180), axis: (x:0,y:1,z:0))
    }
}

// MARK: - Compact Grid Challenge Card for Grid View

struct CompactGridChallengeCard: View {
    let challenge: ActiveChallenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title - more concise
            Text(challenge.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("Charcoal"))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Status badge
            HStack(spacing: 4) {
                Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : "clock.fill")
                    .font(.system(size: 11))
                Text(challenge.isCompleted ? "Done" : "Active")
                    .font(.system(size: 10, weight: .medium))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(challenge.isCompleted ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
            .foregroundColor(challenge.isCompleted ? .green : .orange)
            .cornerRadius(6)
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(challenge.completedDays)/\(challenge.totalDays) days")
                        .font(.system(size: 11))
                        .foregroundColor(Color("SlateGray"))
                    Spacer()
                    Text("\(Int(challenge.progress * 100))%")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(challenge.color)
                }
                
                ProgressView(value: challenge.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: challenge.color))
                    .frame(height: 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(2)
            }
            
            Spacer()
            
            // Start date at bottom
            Text("Started \(challenge.startDate.formatted(.dateTime.month(.abbreviated).day()))")
                .font(.system(size: 10))
                .foregroundColor(Color("SlateGray"))
        }
        .padding(12)
        .frame(height: 140) // Reduced height
        .background(
            LinearGradient(
                colors: [challenge.color.opacity(0.08), Color("MistyAqua").opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(challenge.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - All Active Challenges View

struct AllActiveChallengesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: ChallengesViewModel
    @State private var filter: ChallengeFilter = .all
    
    private var filteredChallenges: [ActiveChallenge] {
        switch filter {
        case .all:
            return vm.activeChallenges
        case .active:
            return vm.activeChallenges.filter { !$0.isCompleted }
        case .completed:
            return vm.activeChallenges.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                Spacer()
                Text("All Challenges")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                
                // Placeholder for symmetry
                Image(systemName: "chevron.left")
                    .foregroundColor(.clear)
                    .font(.title2)
            }
            .padding()
            .frame(height: 52)
            .background(Color("PeacockBlue"))
            
            // Main Content
            VStack(spacing: 0) {
                // Filter Section
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ForEach(ChallengeFilter.allCases, id: \.self) { filterType in
                            FilterChip(
                                title: filterType.rawValue,
                                isSelected: filter == filterType
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    filter = filterType
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Stats Summary
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Total",
                            count: vm.activeChallenges.count,
                            color: Color("PeacockBlue")
                        )
                        StatCard(
                            title: "Active",
                            count: vm.activeChallenges.filter { !$0.isCompleted }.count,
                            color: Color("CaribbeanTeal")
                        )
                        StatCard(
                            title: "Completed",
                            count: vm.activeChallenges.filter { $0.isCompleted }.count,
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                }
                .background(Color("MistyAqua").opacity(0.3))
                .padding(.bottom, 8)
                
                // Challenges Grid
                if filteredChallenges.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20)
                        ], spacing: 24) {
                            ForEach(filteredChallenges) { ch in
                                NavigationLink {
                                    ChallengeDetailView(ch: ch).environmentObject(vm)
                                } label: {
                                    CompactGridChallengeCard(challenge: ch)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: getEmptyStateIcon())
                .font(.system(size: 60))
                .foregroundColor(Color("SlateGray").opacity(0.6))
            
            Text(getEmptyStateTitle())
                .font(.title3.bold())
                .foregroundColor(Color("Charcoal"))
            
            Text(getEmptyStateMessage())
                .font(.subheadline)
                .foregroundColor(Color("SlateGray"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private func getEmptyStateIcon() -> String {
        switch filter {
        case .all: return "target"
        case .active: return "clock"
        case .completed: return "checkmark.circle"
        }
    }
    
    private func getEmptyStateTitle() -> String {
        switch filter {
        case .all: return "No Challenges Yet"
        case .active: return "No Active Challenges"
        case .completed: return "No Completed Challenges"
        }
    }
    
    private func getEmptyStateMessage() -> String {
        switch filter {
        case .all: return "Start your savings journey by joining your first challenge!"
        case .active: return "All your challenges are completed. Great job!"
        case .completed: return "Complete some challenges to see them here."
        }
    }
}

// MARK: - Additional Required Components

struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(count)")
                .font(.title2.bold())
                .foregroundColor(color)
            
            Text(title)
                .font(.caption.bold())
                .foregroundColor(Color("Charcoal"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : Color("Charcoal"))
                .background(chipBackground)
                .cornerRadius(20)
                .overlay(
                    Capsule().stroke(Color("PeacockBlue").opacity(0.25), lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            LinearGradient(
                gradient: Gradient(colors: [Color("PeacockBlue"), Color("CaribbeanTeal")]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            Color.white
        }
    }
}

// MARK: - Achievement Badge Premium

struct AchievementBadgePremium: View {
    let achievement: Achievement
    @State private var flipped = false
    @State private var showBurst = false

    var body: some View {
        ZStack {
            glassCard.opacity(flipped ? 0 : 1)
            if achievement.earned { backCard.opacity(flipped ? 1 : 0) }
            if showBurst { SparkleBurst(color: achievement.color).allowsHitTesting(false) }
        }
        .frame(width: 128, height: 160)
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x:0,y:1,z:0))
        .animation(.easeInOut(duration: 0.35), value: flipped)
        .onTapGesture {
            guard achievement.earned else { return }
            flipped.toggle()
            if flipped {
                showBurst = true
                DispatchQueue.main.asyncAfter(deadline: .now()+0.9){ showBurst = false }
            }
        }
    }

    private var glassCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.65))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(LinearGradient(colors: [achievement.color.opacity(0.8), .white.opacity(0.3)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.2)
                )
                .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 6)

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AngularGradient(colors: [achievement.color, achievement.color.opacity(0.3), achievement.color], center: .center))
                        .frame(width: 84, height: 84)
                        .opacity(0.25)
                        .blur(radius: 0.5)
                        .overlay(Circle().stroke(achievement.color.opacity(0.4), lineWidth: 1.2))
                        .glow(achievement.color, radius: 8)
                    Image(systemName: achievement.icon)
                        .resizable().scaledToFit().frame(width: 36, height: 36)
                        .foregroundColor(achievement.color)
                        .glow(achievement.color, radius: 6)
                }

                Text(achievement.label)
                    .font(.caption.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("Charcoal"))
                    .padding(.horizontal, 6)
            }
            .padding(.vertical, 14)
        }
        .overlay(
            Group {
                if !achievement.earned {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill").font(.caption)
                        Text("Locked").font(.caption2.bold())
                    }
                    .padding(6)
                    .foregroundColor(.secondary)
                    .background(Color.white.opacity(0.85), in: Capsule())
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
        )
    }

    private var backCard: some View {
        let dateText: String = achievement.earnedDate.map {
            DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none)
        } ?? "—"
        let byText = achievement.earnedBy ?? "—"

        return ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [achievement.color.opacity(0.18), .white.opacity(0.8)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(achievement.color.opacity(0.5), lineWidth: 1))
            VStack(spacing: 6) {
                Text("🏆 Unlocked").font(.caption.bold()).foregroundColor(.green)
                Text(achievement.label).font(.caption).multilineTextAlignment(.center).foregroundColor(Color("Charcoal")).padding(.horizontal, 6)
                Text("Earned on \(dateText)").font(.caption2).foregroundColor(.secondary)
                Text("by \(byText)").font(.caption2).foregroundColor(.secondary)
            }
            .padding(12)
        }
        .rotation3DEffect(.degrees(180), axis: (x:0,y:1,z:0))
    }
}

// MARK: - Challenge Detail View
// MARK: - Updated Challenge Detail View with Yes/No Options

//struct ChallengeDetailView: View {
//    let ch: ActiveChallenge
//    @EnvironmentObject private var vm: ChallengesViewModel
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                Text(ch.title)
//                    .font(.title2.bold())
//                    .multilineTextAlignment(.center)
//                    .padding(.top)
//
//                Text("Joined on \(ch.startDate.formatted(date:.abbreviated, time:.omitted))")
//                    .foregroundColor(.gray)
//
//                ProgressView(value: ch.progress)
//                    .progressViewStyle(LinearProgressViewStyle(tint: ch.color))
//                    .frame(height: 10)
//                    .background(Color(.systemGray5))
//                    .cornerRadius(5)
//                    .padding(.horizontal)
//
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Daily Progress").font(.headline).foregroundColor(Color("Charcoal"))
//
//                    ForEach(0..<ch.totalDays, id: \.self) { day in
//                        DayProgressRow(
//                            day: day,
//                            challenge: ch,
//                            onYes: { vm.markDayCompleted(for: ch.id, day: day) },
//                            onNo: { vm.markDayMissed(for: ch.id, day: day) }
//                        )
//                    }
//                }
//                .padding(.horizontal)
//            }
//            .padding(.bottom)
//        }
//        .navigationTitle("Challenge Details")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - Day Progress Row with Yes/No Options
//
//struct DayProgressRow: View {
//    let day: Int
//    let challenge: ActiveChallenge
//    let onYes: () -> Void
//    let onNo: () -> Void
//    
//    private var isDone: Bool {
//        guard day < challenge.dailyCompletion.count else { return false }
//        return challenge.dailyCompletion[day]
//    }
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            // Day Header
//            HStack {
//                Text("Day \(day + 1)")
//                    .font(.subheadline.bold())
//                    .foregroundColor(.primary)
//                
//                Spacer()
//                
//                // Status Badge
//                HStack(spacing: 6) {
//                    Image(systemName: isDone ? "checkmark.circle.fill" : "xmark.circle.fill")
//                        .font(.system(size: 16))
//                    Text(isDone ? "Completed" : "Missed")
//                        .font(.caption.bold())
//                }
//                .padding(.horizontal, 12)
//                .padding(.vertical, 6)
//                .background(isDone ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
//                .foregroundColor(isDone ? .green : .red)
//                .cornerRadius(12)
//            }
//            
//            // Question
//            Text("Did you complete this day?")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            // Yes/No Options in Series (Vertical)
//            VStack(spacing: 12) {
//                // Yes Button
//                Button(action: onYes) {
//                    HStack(spacing: 8) {
//                        Image(systemName: "checkmark.circle.fill")
//                            .font(.system(size: 16))
//                        Text("Yes")
//                            .font(.subheadline.bold())
//                        Spacer()
//                        if isDone {
//                            Image(systemName: "checkmark")
//                                .font(.system(size: 14, weight: .bold))
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 12)
//                    .background(isDone ? Color.green : Color.green.opacity(0.15))
//                    .foregroundColor(isDone ? .white : .green)
//                    .cornerRadius(12)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color.green, lineWidth: isDone ? 0 : 1.5)
//                    )
//                }
//                .scaleEffect(isDone ? 1.02 : 1.0)
//                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDone)
//                
//                // No Button
//                Button(action: onNo) {
//                    HStack(spacing: 8) {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.system(size: 16))
//                        Text("No")
//                            .font(.subheadline.bold())
//                        Spacer()
//                        if !isDone {
//                            Image(systemName: "checkmark")
//                                .font(.system(size: 14, weight: .bold))
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 12)
//                    .background(!isDone ? Color.red : Color.red.opacity(0.15))
//                    .foregroundColor(!isDone ? .white : .red)
//                    .cornerRadius(12)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color.red, lineWidth: !isDone ? 0 : 1.5)
//                        )
//                }
//                .scaleEffect(!isDone ? 1.02 : 1.0)
//                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDone)
//            }
//        }
//        .padding(16)
//        .background(Color("MistyAqua").opacity(0.5))
//        .cornerRadius(16)
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(isDone ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
//        )
//        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
//    }
//}
//////////////////////
struct ChallengeDetailView: View {
    let ch: ActiveChallenge
    @EnvironmentObject private var vm: ChallengesViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(ch.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top)

                Text("Joined on \(ch.startDate.formatted(date:.abbreviated, time:.omitted))")
                    .foregroundColor(.gray)

                ProgressView(value: ch.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: ch.color))
                    .frame(height: 10)
                    .background(Color(.systemGray5))
                    .cornerRadius(5)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Progress").font(.headline).foregroundColor(Color("Charcoal"))

                    ForEach(0..<ch.totalDays, id: \.self) { day in
                        DayProgressRow(
                            day: day,
                            challenge: ch,
                            onYes: { vm.markDayCompleted(for: ch.id, day: day) },
                            onNo: { vm.markDayMissed(for: ch.id, day: day) }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .navigationTitle("Challenge Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Day Progress Row with Yes/No Options

struct DayProgressRow: View {
    let day: Int
    let challenge: ActiveChallenge
    let onYes: () -> Void
    let onNo: () -> Void
    
    private var isDone: Bool {
        guard day < challenge.dailyCompletion.count else { return false }
        return challenge.dailyCompletion[day]
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Day Header
            HStack {
                Text("Day \(day + 1)")
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Status Badge
                HStack(spacing: 6) {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 16))
                    Text(isDone ? "Completed" : "Missed")
                        .font(.caption.bold())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isDone ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                .foregroundColor(isDone ? .green : .red)
                .cornerRadius(12)
            }
            
            // Question and Options in a single VStack
            VStack(alignment: .leading, spacing: 16) {
                Text("Did you complete this day?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Yes/No Options - Vertically Stacked (Series)
                VStack(spacing: 10) {
                    // Yes Button - Full Width
                    Button(action: onYes) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                            Text("Yes")
                                .font(.subheadline.bold())
                            Spacer()
                            if isDone {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(isDone ? Color.green : Color.green.opacity(0.1))
                        .foregroundColor(isDone ? .white : .green)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: isDone ? 0 : 2)
                        )
                    }
                    .scaleEffect(isDone ? 1.02 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDone)
                    
                    // No Button - Full Width
                    Button(action: onNo) {
                        HStack(spacing: 10) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                            Text("No")
                                .font(.subheadline.bold())
                            Spacer()
                            if !isDone {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(!isDone ? Color.red : Color.red.opacity(0.1))
                        .foregroundColor(!isDone ? .white : .red)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: !isDone ? 0 : 2)
                        )
                    }
                    .scaleEffect(!isDone ? 1.02 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDone)
                }
            }
        }
        .padding(16)
        .background(Color("MistyAqua").opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isDone ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
// MARK: - Achievement Detail Sheet

struct AchievementDetailSheet: View {
    let achievement: Achievement
    @EnvironmentObject var vm: ChallengesViewModel

    private var progress: Double { vm.progressTowards(achievement) }
    private var target: Int? { vm.targetForAchievement(achievement) }
    private var remaining: Int? { vm.remainingForAchievement(achievement) }
    private var howTo: String { vm.howToEarnText(for: achievement) }

    private var shareText: String {
        if achievement.earned {
            let when = achievement.earnedDate.map {
                DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none)
            } ?? "today"
            return "I just unlocked \"\(achievement.label)\" in SpendMate on \(when)! 🎉"
        } else if let t = target {
            return "I'm \(Int(round(progress * 100)))% towards \"\(achievement.label)\" in SpendMate (\(min(vm.totalCompleted, t))/\(t))."
        } else {
            return "I'm working towards \"\(achievement.label)\" in SpendMate!"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)

            ZStack {
                Circle().fill(achievement.color.opacity(0.12)).frame(width: 120, height: 120)
                Image(systemName: achievement.icon)
                    .resizable().scaledToFit().frame(width: 60, height: 60)
                    .foregroundColor(achievement.color)
                    .glow(achievement.color, radius: 8)
            }

            Text(achievement.label).font(.title3.bold()).multilineTextAlignment(.center).padding(.horizontal)

            if let t = target {
                VStack(spacing: 8) {
                    ProgressView(value: progress).tint(achievement.color).padding(.horizontal)
                    HStack(spacing: 8) {
                        Text("\(min(vm.totalCompleted, t))/\(t) completed")
                            .font(.subheadline.bold()).foregroundColor(Color("Charcoal"))
                        if let r = remaining, r > 0 {
                            Text("•  \(r) to go").font(.subheadline.bold()).foregroundColor(.secondary)
                        }
                    }
                }.padding(.top, 2)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("How to earn").font(.headline).foregroundColor(Color("Charcoal"))
                Text(howTo).foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            if achievement.earned {
                VStack(spacing: 10) {
                    if let d = achievement.earnedDate {
                        Text("🏆 Unlocked on \(DateFormatter.localizedString(from: d, dateStyle: .medium, timeStyle: .none))")
                            .foregroundColor(.secondary)
                    }
                    if let by = achievement.earnedBy {
                        Text("by \(by)").foregroundColor(.secondary)
                    }
                    ShareLink(item: shareText) {
                        Label("Share achievement", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .background(LinearGradient(colors: [Color("PeacockBlue"), Color("CaribbeanTeal")],
                                                       startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 4)
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .presentationDetents([.height(550), .large])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Supporting Views for Achievements Gallery

private struct CircularPercentRing: View {
    let progress: Double
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.22),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(Color.white, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(round(progress * 100)))%")
                .font(.headline.bold()).foregroundColor(.white)
        }
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
    }
}

private struct AwardsSummaryCard: View {
    let earned: Int
    let total: Int
    private var progress: Double { total == 0 ? 0 : Double(earned) / Double(total) }

    var body: some View {
        HStack(spacing: 16) {
            CircularPercentRing(progress: progress, lineWidth: 10)
                .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: 6) {
                Text("Awards Earned").font(.subheadline.weight(.semibold)).foregroundColor(.white)
                HStack(spacing: 6) {
                    Text("\(earned)").font(.title3.bold()).foregroundColor(.white)
                    Text("of \(total)").font(.subheadline.bold()).foregroundColor(.white.opacity(0.9))
                }
                Text(progress >= 1 ? "All caught up 🎉" : "Keep going!")
                    .font(.caption.bold())
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color.white.opacity(0.18))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            LinearGradient(colors: [Color("PeacockBlue"), Color("CaribbeanTeal")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
        )
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.12), lineWidth: 1))
        .padding(.horizontal)
        .padding(.top, 12)
    }
}

struct ShowcaseAchievementTile: View {
    let achievement: Achievement
    enum SizeStyle { case small, medium, large
        var height: CGFloat { self == .small ? 150 : (self == .medium ? 185 : 220) }
    }
    let sizeStyle: SizeStyle

    var body: some View {
        let bg = LinearGradient(colors: [achievement.color.opacity(0.18), .white.opacity(0.85)],
                                startPoint: .topLeading, endPoint: .bottomTrailing)
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(bg)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(achievement.color.opacity(0.35), lineWidth: 1))
                .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 6)

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AngularGradient(colors: [achievement.color, achievement.color.opacity(0.25), achievement.color], center: .center))
                        .frame(width: 66, height: 66)
                        .opacity(0.28).blur(radius: 0.5)

                    Image(systemName: achievement.icon)
                        .resizable().scaledToFit()
                        .frame(width: 34, height: 34)
                        .foregroundColor(achievement.color)
                        .glow(achievement.color, radius: achievement.earned ? 8 : 0)
                }

                Text(achievement.label)
                    .font(.footnote.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("Charcoal"))
                    .lineLimit(2)
                    .padding(.horizontal, 8)

                if achievement.earned {
                    Text("Unlocked")
                        .font(.caption2.bold()).foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(LinearGradient(colors: [Color("PeacockBlue"), Color("CaribbeanTeal")],
                                                   startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill").font(.caption2)
                        Text("Locked").font(.caption2.bold())
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.white.opacity(0.85), in: Capsule())
                }

                Spacer(minLength: 0)
            }
            .padding(12)
        }
        .frame(height: sizeStyle.height)
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Masonry Layout

struct MasonryLayout: Layout {
    let columns: Int
    let spacing: CGFloat
    let staggerStep: CGFloat
    let minRowSeparation: CGFloat

    init(columns: Int,
         spacing: CGFloat = 8,
         staggerStep: CGFloat = 6,
         minRowSeparation: CGFloat = 2)
    {
        self.columns = max(1, columns)
        self.spacing = spacing
        self.staggerStep = max(0, staggerStep)
        self.minRowSeparation = max(0, minRowSeparation)
    }

    private var scale: CGFloat { UIScreen.main.scale }
    private func px(_ v: CGFloat, _ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGFloat {
        (v * scale).rounded(rule) / scale
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let totalWidth = proposal.width ?? 0
        guard columns > 0, totalWidth > 0 else { return .zero }

        let rawColWidth = (totalWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        let colWidth = px(rawColWidth, .down)

        var heights = (0..<columns).map { px(CGFloat($0) * staggerStep, .up) }
        var maxHeight: CGFloat = heights.max() ?? 0

        for sub in subviews {
            var size = sub.sizeThatFits(.init(width: colWidth, height: nil))
            size.height = px(size.height, .up)

            var idx = heights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0

            if let closeCol = closestColumnIndex(to: heights[idx], among: heights, excluding: idx),
               abs(heights[idx] - heights[closeCol]) < minRowSeparation
            {
                heights[idx] += px(spacing / 2, .up)
            }

            heights[idx] += size.height + spacing
            maxHeight = max(maxHeight, heights[idx])
        }

        let finalHeight = max(0, px(maxHeight - spacing, .up))
        return CGSize(width: totalWidth, height: finalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let totalWidth = bounds.width
        guard columns > 0, totalWidth > 0 else { return }

        let colWidth = px((totalWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns), .down)
        var yOffsets = (0..<columns).map { px(CGFloat($0) * staggerStep, .up) }

        for sub in subviews {
            var size = sub.sizeThatFits(.init(width: colWidth, height: nil))
            size.height = px(size.height, .up)

            var idx = yOffsets.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0

            if let closeCol = closestColumnIndex(to: yOffsets[idx], among: yOffsets, excluding: idx),
               abs(yOffsets[idx] - yOffsets[closeCol]) < minRowSeparation
            {
                yOffsets[idx] += px(spacing / 2, .up)
            }

            let x = bounds.minX + CGFloat(idx) * (colWidth + spacing)
            let y = bounds.minY + yOffsets[idx]

            sub.place(
                at: CGPoint(x: px(x), y: px(y)),
                anchor: .topLeading,
                proposal: .init(width: colWidth, height: size.height)
            )

            yOffsets[idx] += size.height + spacing
        }
    }

    private func closestColumnIndex(to value: CGFloat, among arr: [CGFloat], excluding: Int) -> Int? {
        var bestIdx: Int?
        var bestDelta: CGFloat = .greatestFiniteMagnitude
        for (i, v) in arr.enumerated() where i != excluding {
            let d = abs(v - value)
            if d < bestDelta {
                bestDelta = d
                bestIdx = i
            }
        }
        return bestIdx
    }
}

// MARK: - Achievements Gallery View

struct AchievementsGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: ChallengesViewModel
    @State private var filter: AchievementFilter = .all
    @State private var selected: Achievement? = nil

    private var earned: [Achievement] { vm.achievements.filter { $0.earned }.sortedUnlockedFirst() }
    private var locked: [Achievement] { vm.achievements.filter { !$0.earned }.sortedUnlockedFirst() }
    private var filtered: [Achievement] {
        switch filter {
        case .all:    return vm.achievements.sortedUnlockedFirst()
        case .earned: return earned
        case .locked: return locked
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "chevron.left").foregroundColor(.white) }
                Spacer()
                Text("All Achievements").font(.headline).foregroundColor(.white)
                Spacer()
            }
            .padding().frame(height: 52).background(Color("PeacockBlue"))

            ScrollView {
                VStack(spacing: 18) {

                    AwardsSummaryCard(
                        earned: vm.achievements.filter { $0.earned }.count,
                        total: vm.achievements.count
                    )

                    HStack(spacing: 10) {
                        ForEach(AchievementFilter.allCases, id: \.self) { f in
                            FilterChip(title: f.rawValue, isSelected: filter == f) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    filter = f
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    if !earned.isEmpty && filter != .locked {
                        Text("Recently Unlocked")
                            .font(.headline).foregroundColor(Color("Charcoal")).padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(earned.prefix(10)) { a in
                                    AchievementBadgePremium(achievement: a)
                                        .scaleEffect(1.06)
                                        .padding(.horizontal, 2)
                                        .glow(a.color, radius: 8)
                                        .onTapGesture { selected = a }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .frame(height: 188)
                        }
                    }

                    Text(filter == .earned ? "Unlocked Awards" :
                         (filter == .locked ? "Locked Awards" : "All Awards"))
                        .font(.headline).foregroundColor(Color("Charcoal")).padding(.horizontal)

                    MasonryLayout(columns: 3, spacing: 18) {
                        ForEach(filtered) { a in
                            ShowcaseAchievementTile(
                                achievement: a,
                                sizeStyle: a.earned ? .large :
                                    (a.id.uuidString.hashValue.isMultiple(of: 3) ? .medium : .small)
                            )
                            .padding(.bottom, 2)
                            .onTapGesture { selected = a }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 14)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("MistyAqua").opacity(0.45), .white]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(item: $selected) { ach in
            AchievementDetailSheet(achievement: ach).environmentObject(vm)
        }
    }
}

// MARK: - Celebration View

struct UnlockedCelebrationView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    @State private var bgOpacity: Double = 0
    @State private var cardScale: CGFloat = 0.6
    @State private var crownBounce: CGFloat = 0.6

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                achievement.color.opacity(0.9),
                Color.black.opacity(0.85)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .opacity(bgOpacity)
            .animation(.easeOut(duration: 0.25), value: bgOpacity)

            SparkleBurst(color: .white)
            SparkleBurst(color: achievement.color)

            VStack(spacing: 18) {
                Image(systemName: "crown.fill")
                    .resizable().scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.yellow)
                    .scaleEffect(crownBounce)
                    .shadow(color: .yellow.opacity(0.6), radius: 12)

                Text("Achievement Unlocked!")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                AchievementBadgePremium(achievement: achievement)
                    .scaleEffect(cardScale)
                    .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 10)

                Button { dismiss() } label: {
                    Text("Awesome!")
                        .font(.headline)
                        .padding(.horizontal, 22).padding(.vertical, 12)
                        .background(Color.white)
                        .foregroundColor(Color("PeacockBlue"))
                        .cornerRadius(14)
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            Haptics.success()
            SoftSound.play()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                bgOpacity = 1; cardScale = 1.0; crownBounce = 1.0
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                crownBounce = 1.08
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Achievement unlocked: \(achievement.label). Double tap to close.")
    }
}
