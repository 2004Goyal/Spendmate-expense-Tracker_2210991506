//
//  AddSquadView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 30/06/25.
//

import Foundation
import SwiftUI
import Contacts
import PhotosUI
import MessageUI

//struct CreateGroupView: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var userProfile: UserProfile
//    @Binding var showGroupExpenses: Bool
//    var onGroupCreated: (GroupInfo) -> Void
//
//    @StateObject private var viewModel = CreateGroupViewModel()
//    
//    // Contact picker and sharing state
//    @State private var showContactPicker = false
//    @State private var selectedContacts: [ContactPickerView.ContactInfo] = []
//    @State private var showEmailDialog = false
//    @State private var showMailComposer = false
//    @State private var recipientEmail = ""
//    @State private var inviteLink = ""
//
//    let groupTypes = ["Trip", "Home", "Couple", "Other"]
//    let typeIcons: [String: String] = [
//        "Trip": "airplane",
//        "Home": "house.fill",
//        "Couple": "heart.fill",
//        "Other": "bookmark.fill"
//    ]
//
//    var body: some View {
//        VStack(spacing: 24) {
//            // Add spacing below navigation bar
//            Color.clear.frame(height: 20)
//            
//            groupNameField
//            groupTypeSelector
//            addMembersSection
//            createButton
//        }
//        .padding()
//        .navigationBarBackButtonHidden(true)
//        .toolbarBackground(Color("PeacockBlue"), for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button {
//                    showGroupExpenses = true
//                    dismiss()
//                } label: {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(.white)
//                }
//            }
//
//            ToolbarItem(placement: .principal) {
//                Text("Add Group")
//                    .foregroundColor(.white)
//                    .font(.headline)
//            }
//        }
//        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
//            Button("OK") {
//                if viewModel.alertMessage.contains("successfully") {
//                    showGroupExpenses = true
//                    dismiss()
//                }
//            }
//        }
//        .sheet(isPresented: $showContactPicker) {
//            ContactPickerView(selectedContacts: $selectedContacts)
//                .onDisappear {
//                    // Add selected contacts to the group
//                    for contact in selectedContacts {
//                        if !viewModel.addedMembers.contains(where: { $0.contains(contact.phoneNumber) }) {
//                            // Store as "Name|PhoneNumber" format for display
//                            viewModel.addedMembers.append("\(contact.name)|\(contact.phoneNumber)")
//                        }
//                    }
//                }
//        }
//        .sheet(isPresented: $showMailComposer) {
//            MailComposerView(
//                isPresented: $showMailComposer,
//                recipient: recipientEmail,
//                subject: "Join \(viewModel.groupName) on SpendMate",
//                body: "You've been invited to join '\(viewModel.groupName)' on SpendMate!\n\nClick here to join: \(inviteLink)"
//            )
//        }
//        .overlay(
//            Group {
//                if showEmailDialog {
//                    Color.black.opacity(0.3)
//                        .ignoresSafeArea()
//                        .onTapGesture {
//                            showEmailDialog = false
//                        }
//                    
//                    EmailInputDialog(
//                        isPresented: $showEmailDialog,
//                        groupName: viewModel.groupName,
//                        inviteLink: inviteLink,
//                        onSend: { email in
//                            recipientEmail = email
//                            if MFMailComposeViewController.canSendMail() {
//                                showMailComposer = true
//                            } else {
//                                EmailService.sendInviteEmail(
//                                    to: email,
//                                    groupName: viewModel.groupName,
//                                    inviteLink: inviteLink
//                                )
//                            }
//                        }
//                    )
//                }
//            }
//        )
//    }
//
//    private var groupNameField: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Group Name")
//                .font(.subheadline)
//            TextField("e.g., Goa Trip 2025", text: $viewModel.groupName)
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//        }
//    }
//
//    private var groupTypeSelector: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Group Type")
//                .font(.subheadline)
//
//            HStack(spacing: 0) {
//                ForEach(groupTypes, id: \.self) { type in
//                    Spacer()
//                    Button {
//                        viewModel.selectedType = type
//                    } label: {
//                        VStack(spacing: 6) {
//                            Image(systemName: typeIcons[type] ?? "questionmark")
//                                .font(.title2)
//                            Text(type)
//                                .font(.caption)
//                        }
//                        .frame(width: 70, height: 70)
//                        .foregroundColor(viewModel.selectedType == type ? .white : Color(hex: "#0097A7"))
//                        .background(viewModel.selectedType == type ? Color(hex: "#0097A7") : Color(hex: "#E6F7F8"))
//                        .cornerRadius(12)
//                    }
//                    Spacer()
//                }
//            }
//        }
//    }
//
//    private var addMembersSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Add Members")
//                .font(.headline)
//                .foregroundColor(Color(hex: "#005F6A"))
//            Text("Choose how you'd like to add your friends")
//                .font(.caption)
//                .foregroundColor(.gray)
//
//            // Add from Contacts button
//            Button(action: {
//                showContactPicker = true
//            }) {
//                HStack {
//                    Image(systemName: "person.2.fill")
//                    Text("Add from Contacts")
//                }
//                .frame(maxWidth: .infinity)
//                .padding()
//                .foregroundColor(Color(hex: "#005F6A"))
//                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#005F6A"), lineWidth: 1))
//            }
//
//            // Invite via Email button
//            Button(action: {
//                inviteLink = generateInviteLink()
//                showEmailDialog = true
//            }) {
//                HStack {
//                    Image(systemName: "envelope.fill")
//                    Text("Invite via Email")
//                }
//                .frame(maxWidth: .infinity)
//                .padding()
//                .foregroundColor(Color(hex: "#005F6A"))
//                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#005F6A"), lineWidth: 1))
//            }
//
//            // Share Link button
//            Button(action: {
//                shareInviteLink()
//            }) {
//                HStack {
//                    Image(systemName: "link")
//                    Text("Share Invite Link")
//                }
//                .frame(maxWidth: .infinity)
//                .padding()
//                .foregroundColor(Color(hex: "#005F6A"))
//                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#005F6A"), lineWidth: 1))
//            }
//
//            // Display added members
//            if !viewModel.addedMembers.isEmpty {
//                Text("Added Members")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .padding(.top, 8)
//                
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 8) {
//                        ForEach(viewModel.addedMembers, id: \.self) { member in
//                            HStack {
//                                // Check if member contains name|phone format
//                                if member.contains("|") {
//                                    let parts = member.split(separator: "|")
//                                    Text(String(parts[0])) // Show name
//                                        .font(.caption)
//                                } else {
//                                    Text(member)
//                                        .font(.caption)
//                                }
//                                
//                                Button {
//                                    viewModel.addedMembers.removeAll { $0 == member }
//                                    // Also remove from selectedContacts if needed
//                                    if member.contains("|") {
//                                        let parts = member.split(separator: "|")
//                                        if parts.count > 1 {
//                                            let phone = String(parts[1])
//                                            selectedContacts.removeAll { $0.phoneNumber == phone }
//                                        }
//                                    }
//                                } label: {
//                                    Image(systemName: "xmark.circle.fill")
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 6)
//                            .background(Color(hex: "#E6F7F8"))
//                            .cornerRadius(20)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    private func generateInviteLink() -> String {
//        let token = UUID().uuidString.prefix(8)
//        return "https://spendmate.app/join?group=\(token)"
//    }
//    
//    private func shareInviteLink() {
//        let link = generateInviteLink()
//        let activityVC = UIActivityViewController(
//            activityItems: ["Join my group '\(viewModel.groupName)' on SpendMate: \(link)"],
//            applicationActivities: nil
//        )
//        
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let rootViewController = windowScene.windows.first?.rootViewController {
//            rootViewController.present(activityVC, animated: true)
//        }
//    }
//    
//    private var createButton: some View {
//        Button {
//            Task { @MainActor in
//                // Get user ID as String
//                let supabaseUserID = SupabaseManager.shared.client.auth.currentUser?.id.uuidString
//                let effectiveUserID = userProfile.id ?? supabaseUserID
//
//                guard let idString = effectiveUserID,
//                      let userUUID = UUID(uuidString: idString) else {
//                    viewModel.alertMessage = "You're not signed in. Please sign in again."
//                    viewModel.showAlert = true
//                    return
//                }
//
//                // Ensure the creator is in members (lowercased)
//                let me = userUUID.uuidString.lowercased()
//                
//                // Process members to extract phone numbers only
//                var processedMembers: [String] = []
//                for member in viewModel.addedMembers {
//                    if member.contains("|") {
//                        // Extract phone number from "Name|Phone" format
//                        let parts = member.split(separator: "|")
//                        if parts.count > 1 {
//                            processedMembers.append(String(parts[1]))
//                        }
//                    } else {
//                        processedMembers.append(member)
//                    }
//                }
//                
//                // Add creator if not already in the list
//                if !processedMembers.contains(me) {
//                    processedMembers.append(me)
//                }
//                
//                // Update viewModel with processed members
//                viewModel.addedMembers = processedMembers
//
//                // Create the group without image
//                if let insertedGroup = await viewModel.createGroup(userID: userUUID) {
//                    let groupInfo = GroupInfo(
//                        id: insertedGroup.id.uuidString,
//                        name: insertedGroup.name,
//                        type: insertedGroup.type,
//                        members: insertedGroup.members
//                    )
//                    onGroupCreated(groupInfo)
//                }
//            }
//        } label: {
//            Text(viewModel.isSaving ? "Creating..." : "Create Group")
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(viewModel.isSaving ? Color.gray : Color(hex: "#0097A7"))
//                .foregroundColor(.white)
//                .cornerRadius(12)
//        }
//        .disabled(viewModel.isSaving || viewModel.groupName.isEmpty)
//    }
//}
struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userProfile: UserProfile
    @Binding var showGroupExpenses: Bool
    var onGroupCreated: (GroupInfo) -> Void

    @StateObject private var viewModel = CreateGroupViewModel()
    
    // Contact picker and sharing state
    @State private var showContactPicker = false
    @State private var selectedContacts: [ContactPickerView.ContactInfo] = []
    @State private var showEmailDialog = false
    @State private var showMailComposer = false
    @State private var recipientEmail = ""
    @State private var inviteLink = ""

    let groupTypes = ["Trip", "Home", "Couple", "Other"]
    let typeIcons: [String: String] = [
        "Trip": "airplane",
        "Home": "house.fill",
        "Couple": "heart.fill",
        "Other": "bookmark.fill"
    ]

    var body: some View {
        VStack(spacing: 24) {
            groupNameField
            groupTypeSelector
            addMembersSection
            createButton
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color("PeacockBlue"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showGroupExpenses = true
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Add Group")
                    .foregroundColor(.white)
                    .font(.headline)
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.alertMessage.contains("successfully") {
                    showGroupExpenses = true
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showContactPicker) {
            ContactPickerView(selectedContacts: $selectedContacts)
                .onDisappear {
                    // Add selected contacts to the group
                    for contact in selectedContacts {
                        if !viewModel.addedMembers.contains(where: { $0.contains(contact.phoneNumber) }) {
                            // Store as "Name|PhoneNumber" format for display
                            viewModel.addedMembers.append("\(contact.name)|\(contact.phoneNumber)")
                        }
                    }
                }
        }
        .sheet(isPresented: $showMailComposer) {
            MailComposerView(
                isPresented: $showMailComposer,
                recipient: recipientEmail,
                subject: "Join \(viewModel.groupName) on SpendMate",
                body: "You've been invited to join '\(viewModel.groupName)' on SpendMate!\n\nClick here to join: \(inviteLink)"
            )
        }
        .overlay(
            Group {
                if showEmailDialog {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showEmailDialog = false
                        }
                    
                    EmailInputDialog(
                        isPresented: $showEmailDialog,
                        groupName: viewModel.groupName,
                        inviteLink: inviteLink,
                        onSend: { email in
                            recipientEmail = email
                            if MFMailComposeViewController.canSendMail() {
                                showMailComposer = true
                            } else {
                                EmailService.sendInviteEmail(
                                    to: email,
                                    groupName: viewModel.groupName,
                                    inviteLink: inviteLink
                                )
                            }
                        }
                    )
                }
            }
        )
    }

    private var groupNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Group Name")
                .font(.subheadline)
            TextField("e.g., Goa Trip 2025", text: $viewModel.groupName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }

    private var groupTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Group Type")
                .font(.subheadline)

            HStack(spacing: 0) {
                ForEach(groupTypes, id: \.self) { type in
                    Spacer()
                    Button {
                        viewModel.selectedType = type
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: typeIcons[type] ?? "questionmark")
                                .font(.title2)
                            Text(type)
                                .font(.caption)
                        }
                        .frame(width: 70, height: 70)
                        .foregroundColor(viewModel.selectedType == type ? .white : Color(hex: "#0097A7"))
                        .background(viewModel.selectedType == type ? Color(hex: "#0097A7") : Color(hex: "#E6F7F8"))
                        .cornerRadius(12)
                    }
                    Spacer()
                }
            }
        }
    }

    private var addMembersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Members")
                .font(.headline)
                .foregroundColor(Color(hex: "#005F6A"))
            Text("Choose how you'd like to add your friends")
                .font(.caption)
                .foregroundColor(.gray)

            // Add from Contacts button
            Button(action: {
                showContactPicker = true
            }) {
                HStack {
                    Image(systemName: "person.2.fill")
                    Text("Add from Contacts")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(Color(hex: "#005F6A"))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#005F6A"), lineWidth: 1))
            }

            // Invite via Email button
            Button(action: {
                inviteLink = generateInviteLink()
                showEmailDialog = true
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Invite via Email")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(Color(hex: "#005F6A"))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#005F6A"), lineWidth: 1))
            }

            // Share Link button
            Button(action: {
                shareInviteLink()
            }) {
                HStack {
                    Image(systemName: "link")
                    Text("Share Invite Link")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(Color(hex: "#005F6A"))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#005F6A"), lineWidth: 1))
            }

            // Display added members
            if !viewModel.addedMembers.isEmpty {
                Text("Added Members")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.addedMembers, id: \.self) { member in
                            HStack {
                                // Check if member contains name|phone format
                                if member.contains("|") {
                                    let parts = member.split(separator: "|")
                                    Text(String(parts[0])) // Show name
                                        .font(.caption)
                                } else {
                                    Text(member)
                                        .font(.caption)
                                }
                                
                                Button {
                                    viewModel.addedMembers.removeAll { $0 == member }
                                    // Also remove from selectedContacts if needed
                                    if member.contains("|") {
                                        let parts = member.split(separator: "|")
                                        if parts.count > 1 {
                                            let phone = String(parts[1])
                                            selectedContacts.removeAll { $0.phoneNumber == phone }
                                        }
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#E6F7F8"))
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }

    private func generateInviteLink() -> String {
        let token = UUID().uuidString.prefix(8)
        return "https://spendmate.app/join?group=\(token)"
    }
    
    private func shareInviteLink() {
        let link = generateInviteLink()
        let activityVC = UIActivityViewController(
            activityItems: ["Join my group '\(viewModel.groupName)' on SpendMate: \(link)"],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private var createButton: some View {
        Button {
            Task { @MainActor in
                // Get user ID as String
                let supabaseUserID = SupabaseManager.shared.client.auth.currentUser?.id.uuidString
                let effectiveUserID = userProfile.id ?? supabaseUserID

                guard let idString = effectiveUserID,
                      let userUUID = UUID(uuidString: idString) else {
                    viewModel.alertMessage = "You're not signed in. Please sign in again."
                    viewModel.showAlert = true
                    return
                }

                // Ensure the creator is in members (lowercased)
                let me = userUUID.uuidString.lowercased()
                
                // Process members to extract phone numbers only
                var processedMembers: [String] = []
                for member in viewModel.addedMembers {
                    if member.contains("|") {
                        // Extract phone number from "Name|Phone" format
                        let parts = member.split(separator: "|")
                        if parts.count > 1 {
                            processedMembers.append(String(parts[1]))
                        }
                    } else {
                        processedMembers.append(member)
                    }
                }
                
                // Add creator if not already in the list
                if !processedMembers.contains(me) {
                    processedMembers.append(me)
                }
                
                // Update viewModel with processed members
                viewModel.addedMembers = processedMembers

                // Create the group without image
                if let insertedGroup = await viewModel.createGroup(userID: userUUID) {
                    let groupInfo = GroupInfo(
                        id: insertedGroup.id.uuidString,
                        name: insertedGroup.name,
                        type: insertedGroup.type,
                        members: insertedGroup.members
                    )
                    onGroupCreated(groupInfo)
                }
            }
        } label: {
            Text(viewModel.isSaving ? "Creating..." : "Create Group")
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isSaving ? Color.gray : Color(hex: "#0097A7"))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(viewModel.isSaving || viewModel.groupName.isEmpty)
    }
}
