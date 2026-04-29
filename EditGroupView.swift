//
//  EditGroupView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 20/08/25.
//

import Foundation
import SwiftUI
import PhotosUI
import Contacts
import ContactsUI

//struct EditGroupView: View {
//    @Binding var selectedGroup: GroupInfo?
//    @Environment(\.dismiss) private var dismiss
//    @EnvironmentObject var userProfile: UserProfile
//    
//    @State private var groupName: String = ""
//    @State private var groupMembers: [String] = []
//    @State private var newMemberEmail: String = ""
//    @State private var selectedImage: PhotosPickerItem? = nil
//    @State private var groupImage: UIImage? = nil
//    @State private var isUpdating: Bool = false
//    @State private var showAlert: Bool = false
//    @State private var alertMessage: String = ""
//    
//    // Contact picker and link sharing
//    @State private var showContactPicker = false
//    @State private var showLinkShare = false
//    @State private var groupInviteLink: String = ""
//    @State private var showAddMemberOptions = false
//    @State private var showEmailInput = false
//    @State private var selectedContactsForPicker: [ContactPickerView.ContactInfo] = []
//    
//    var body: some View {
//        ZStack {
//            Color.white.ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                topBar
//                mainContent
//                updateButton
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//        .onAppear {
//            setupInitialData()
//            generateInviteLink()
//        }
//        .alert("Update Status", isPresented: $showAlert) {
//            Button("OK") {
//                if alertMessage.contains("successfully") {
//                    dismiss()
//                }
//            }
//        } message: {
//            Text(alertMessage)
//        }
//        .confirmationDialog("Add Members", isPresented: $showAddMemberOptions) {
//            Button("From Contacts") {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    showContactPicker = true
//                }
//            }
//            Button("Share Invite Link") {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    showLinkShare = true
//                }
//            }
//            Button("Cancel", role: .cancel) {}
//        } message: {
//            Text("Choose how to add new members")
//        }
//        .sheet(isPresented: $showContactPicker) {
//            ContactPickerView(selectedContacts: $selectedContactsForPicker)
//                .onDisappear {
//                    addContactsToGroup(selectedContactsForPicker)
//                    selectedContactsForPicker.removeAll()
//                }
//        }
//        .sheet(isPresented: $showLinkShare) {
//            ShareLinkView(inviteLink: groupInviteLink, groupId: selectedGroup?.id ?? "")
//        }
//    }
//    
//    // MARK: - Sub Views
//    
//    private var mainContent: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//                groupImageSection
//                groupNameSection
//                membersSection
//                Spacer(minLength: 40)
//            }
//            .padding()
//        }
//    }
//    
//    private var groupImageSection: some View {
//        VStack(spacing: 16) {
//            Text("Group Picture")
//                .font(.headline)
//                .foregroundColor(.black)
//            
//            PhotosPicker(
//                selection: $selectedImage,
//                matching: .images,
//                photoLibrary: .shared()
//            ) {
//                if let groupImage = groupImage {
//                    Image(uiImage: groupImage)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 120, height: 120)
//                        .clipShape(Circle())
//                        .overlay(Circle().stroke(Color("PeacockBlue"), lineWidth: 3))
//                } else {
//                    Circle()
//                        .fill(Color("MistyAqua"))
//                        .frame(width: 120, height: 120)
//                        .overlay(placeholderContent)
//                        .overlay(Circle().stroke(Color("PeacockBlue"), lineWidth: 2))
//                }
//            }
//            .onChange(of: selectedImage) { newItem in
//                Task {
//                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
//                        groupImage = UIImage(data: data)
//                    }
//                }
//            }
//        }
//        .frame(maxWidth: .infinity)
//    }
//    
//    private var placeholderContent: some View {
//        VStack(spacing: 8) {
//            Image(systemName: "camera.fill")
//                .font(.system(size: 32))
//                .foregroundColor(Color("PeacockBlue"))
//            Text("Add Photo")
//                .font(.caption)
//                .foregroundColor(Color("PeacockBlue"))
//        }
//    }
//    
//    private var groupNameSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Group Name")
//                .font(.headline)
//                .foregroundColor(.black)
//            
//            TextField("Enter group name", text: $groupName)
//                .padding()
//                .background(Color("MistyAqua"))
//                .cornerRadius(12)
//                .font(.body)
//        }
//    }
//    
//    private var membersSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            membersHeader
//            emailInputSection
//            membersList
//        }
//    }
//    
//    private var membersHeader: some View {
//        HStack {
//            Text("Members (\(groupMembers.count))")
//                .font(.headline)
//                .foregroundColor(.black)
//            
//            Spacer()
//            
//            Button {
//                showAddMemberOptions = true
//            } label: {
//                Image(systemName: "plus.circle.fill")
//                    .foregroundColor(Color("PeacockBlue"))
//                    .font(.title2)
//            }
//        }
//    }
//    
//    private var emailInputSection: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Add by Email")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//            
//            HStack {
//                TextField("Enter member email", text: $newMemberEmail)
//                    .padding()
//                    .background(Color("MistyAqua"))
//                    .cornerRadius(8)
//                    .keyboardType(.emailAddress)
//                    .autocapitalization(.none)
//                
//                Button {
//                    addNewMember()
//                } label: {
//                    Image(systemName: "plus.circle.fill")
//                        .foregroundColor(Color("PeacockBlue"))
//                        .font(.title2)
//                }
//                .disabled(newMemberEmail.isEmpty)
//            }
//        }
//    }
//    
//    private var membersList: some View {
//        LazyVStack(spacing: 12) {
//            ForEach(Array(groupMembers.enumerated()), id: \.offset) { index, member in
//                memberRow(member: member, index: index)
//            }
//        }
//    }
//    
//    private func memberRow(member: String, index: Int) -> some View {
//        HStack(spacing: 12) {
//            Circle()
//                .fill(Color("PeacockBlue"))
//                .frame(width: 40, height: 40)
//                .overlay(
//                    Text(String(member.prefix(1).uppercased()))
//                        .font(.headline)
//                        .foregroundColor(.white)
//                )
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text(member)
//                    .font(.body)
//                    .foregroundColor(.black)
//                
//                if member == userProfile.fullName || member == "You" {
//                    Text("You")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//            }
//            
//            Spacer()
//            
//            // Don't allow removing current user
//            if member != userProfile.fullName && member != "You" {
//                Button {
//                    removeMember(at: index)
//                } label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.red)
//                        .font(.title3)
//                }
//            }
//        }
//        .padding()
//        .background(Color("MistyAqua"))
//        .cornerRadius(12)
//    }
//    
//    private var updateButton: some View {
//        VStack {
//            Button {
//                updateGroup()
//            } label: {
//                HStack {
//                    if isUpdating {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            .scaleEffect(0.8)
//                        Text("Updating...")
//                    } else {
//                        Text("Update Group")
//                    }
//                }
//                .font(.headline)
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color("PeacockBlue"))
//                .cornerRadius(12)
//            }
//            .disabled(isUpdating || groupName.isEmpty)
//            .padding()
//        }
//    }
//    
//    // MARK: - Top Bar matching previous screens
//    var topBar: some View {
//        VStack(spacing: 4) {
//            HStack {
//                Button { dismiss() } label: {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(.white)
//                        .font(.system(size: 18, weight: .medium))
//                }
//                
//                Spacer()
//                
//                VStack(spacing: 2) {
//                    Text("Edit Group")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                    Text("Manage group settings")
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.8))
//                }
//                
//                Spacer()
//                
//                // Empty space to balance the layout
//                Color.clear
//                    .frame(width: 24, height: 24)
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 10)
//        }
//        .background(Color("PeacockBlue"))
//    }
//    
//    // MARK: - Helper Functions
//    
//    private func setupInitialData() {
//        guard let group = selectedGroup else { return }
//        groupName = group.name
//        groupMembers = group.members
//    }
//    
//    private func generateInviteLink() {
//        guard let group = selectedGroup else { return }
//        // Generate a shareable link with actual domain
//        groupInviteLink = "https://squadpay.app/join/\(group.id)"
//    }
//    
//    private func addNewMember() {
//        let email = newMemberEmail.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !email.isEmpty,
//              !groupMembers.contains(email),
//              isValidEmail(email) else { return }
//        
//        groupMembers.append(email)
//        newMemberEmail = ""
//        
//        // Send invitation via backend
//        sendInvitation(to: email)
//    }
//    
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }
//    
//    private func sendInvitation(to email: String) {
//        guard let groupId = selectedGroup?.id else { return }
//        
//        Task {
//            do {
//                struct InvitationData: Encodable {
//                    let group_id: String
//                    let email: String
//                    let invited_by: String
//                    let status: String
//                }
//                
//                let invitation = InvitationData(
//                    group_id: groupId,
//                    email: email,
//                    invited_by: userProfile.fullName.isEmpty ? "You" : userProfile.fullName,
//                    status: "pending"
//                )
//                
//                try await SupabaseManager.shared.client
//                    .from("group_invitations")
//                    .insert(invitation)
//                    .execute()
//                
//                print("✅ Invitation sent to \(email)")
//            } catch {
//                print("❌ Error sending invitation: \(error)")
//            }
//        }
//    }
//    
//    private func addContactsToGroup(_ contacts: [ContactPickerView.ContactInfo]) {
//        for contact in contacts {
//            let email = contact.phoneNumber // This might actually be an email in your case
//            if !groupMembers.contains(email) && isValidEmail(email) {
//                groupMembers.append(email)
//                sendInvitation(to: email)
//            } else if !groupMembers.contains(contact.name) {
//                // If not a valid email, add the contact name
//                groupMembers.append(contact.name)
//            }
//        }
//    }
//    
//    private func removeMember(at index: Int) {
//        guard index < groupMembers.count else { return }
//        groupMembers.remove(at: index)
//    }
//    
//    private func updateGroup() {
//        guard let group = selectedGroup,
//              let groupId = UUID(uuidString: group.id) else { return }
//        
//        isUpdating = true
//        
//        Task {
//            do {
//                // Create encodable struct for update
//                struct GroupUpdate: Encodable {
//                    let name: String
//                    let members: [String]
//                }
//                
//                let updatedGroup = GroupUpdate(
//                    name: groupName,
//                    members: groupMembers
//                )
//                
//                try await SupabaseManager.shared.client
//                    .from("groups")
//                    .update(updatedGroup)
//                    .eq("id", value: groupId)
//                    .execute()
//                
//                // Update local selected group
//                DispatchQueue.main.async {
//                    self.selectedGroup = GroupInfo(
//                        id: group.id,
//                        name: self.groupName,
//                        type: group.type,
//                        members: self.groupMembers,
//                        expenses: group.expenses
//                    )
//                    
//                    self.isUpdating = false
//                    self.alertMessage = "Group updated successfully!"
//                    self.showAlert = true
//                }
//                
//            } catch {
//                DispatchQueue.main.async {
//                    self.isUpdating = false
//                    self.alertMessage = "Failed to update group. Please try again."
//                    self.showAlert = true
//                }
//                print("❌ Error updating group: \(error)")
//            }
//        }
//    }
//}
//
//// MARK: - Share Link View (unchanged, but separated for clarity)
//struct ShareLinkView: View {
//    let inviteLink: String
//    let groupId: String
//    @Environment(\.dismiss) private var dismiss
//    @State private var showShareSheet = false
//    @State private var copiedToClipboard = false
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 32) {
//                headerSection
//                linkSection
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("Invite Members")
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarBackButtonHidden(true)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                    .foregroundColor(Color("PeacockBlue"))
//                }
//            }
//            .sheet(isPresented: $showShareSheet) {
//                ShareSheet(items: [inviteLink])
//            }
//        }
//    }
//    
//    private var headerSection: some View {
//        VStack(spacing: 20) {
//            Image(systemName: "link.circle.fill")
//                .font(.system(size: 80))
//                .foregroundColor(Color("PeacockBlue"))
//            
//            VStack(spacing: 8) {
//                Text("Invite Link")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                
//                Text("Share this link with friends to join the group")
//                    .font(.body)
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//            }
//        }
//    }
//    
//    private var linkSection: some View {
//        VStack(spacing: 16) {
//            // Link display with copy functionality
//            VStack(spacing: 8) {
//                HStack {
//                    Text(inviteLink)
//                        .font(.system(.callout, design: .monospaced))
//                        .foregroundColor(.primary)
//                        .lineLimit(nil)
//                        .multilineTextAlignment(.leading)
//                    
//                    Spacer()
//                    
//                    Button {
//                        copyToClipboard()
//                    } label: {
//                        Image(systemName: copiedToClipboard ? "checkmark.circle.fill" : "doc.on.doc")
//                            .foregroundColor(copiedToClipboard ? .green : Color("PeacockBlue"))
//                            .font(.title3)
//                    }
//                }
//                .padding()
//                .background(Color("MistyAqua"))
//                .cornerRadius(12)
//                
//                Text(copiedToClipboard ? "Copied to clipboard!" : "Tap icon to copy")
//                    .font(.caption)
//                    .foregroundColor(copiedToClipboard ? .green : .gray)
//            }
//            
//            // Share button
//            Button {
//                showShareSheet = true
//            } label: {
//                HStack {
//                    Image(systemName: "square.and.arrow.up")
//                    Text("Share Link")
//                }
//                .font(.headline)
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color("PeacockBlue"))
//                .cornerRadius(12)
//            }
//        }
//        .padding(.horizontal)
//    }
//    
//    private func copyToClipboard() {
//        UIPasteboard.general.string = inviteLink
//        copiedToClipboard = true
//        
//        // Reset the copied state after 2 seconds
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            copiedToClipboard = false
//        }
//        
//        // Haptic feedback
//        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
//        impactFeedback.impactOccurred()
//    }
//}
//
//// MARK: - Share Sheet
//struct ShareSheet: UIViewControllerRepresentable {
//    let items: [Any]
//    
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
//        return controller
//    }
//    
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
//}
struct EditGroupView: View {
    @Binding var selectedGroup: GroupInfo?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    
    @State private var groupName: String = ""
    @State private var groupMembers: [String] = []
    @State private var newMemberEmail: String = ""
    @State private var isUpdating: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // Contact picker and link sharing
    @State private var showContactPicker = false
    @State private var showLinkShare = false
    @State private var groupInviteLink: String = ""
    @State private var showAddMemberOptions = false
    @State private var showEmailInput = false
    @State private var selectedContactsForPicker: [ContactPickerView.ContactInfo] = []
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                mainContent
                updateButton
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupInitialData()
            generateInviteLink()
        }
        .alert("Update Status", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .confirmationDialog("Add Members", isPresented: $showAddMemberOptions) {
            Button("From Contacts") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showContactPicker = true
                }
            }
            Button("Share Invite Link") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showLinkShare = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose how to add new members")
        }
        .sheet(isPresented: $showContactPicker) {
            ContactPickerView(selectedContacts: $selectedContactsForPicker)
                .onDisappear {
                    addContactsToGroup(selectedContactsForPicker)
                    selectedContactsForPicker.removeAll()
                }
        }
        .sheet(isPresented: $showLinkShare) {
            ShareLinkView(inviteLink: groupInviteLink, groupId: selectedGroup?.id ?? "")
        }
    }
    
    // MARK: - Sub Views
    
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                groupNameSection
                membersSection
                Spacer(minLength: 40)
            }
            .padding()
        }
    }
    
    private var groupNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Group Name")
                .font(.headline)
                .foregroundColor(.black)
            
            TextField("Enter group name", text: $groupName)
                .padding()
                .background(Color("MistyAqua"))
                .cornerRadius(12)
                .font(.body)
        }
    }
    
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            membersHeader
            emailInputSection
            membersList
        }
    }
    
    private var membersHeader: some View {
        HStack {
            Text("Members (\(groupMembers.count))")
                .font(.headline)
                .foregroundColor(.black)
            
            Spacer()
            
            Button {
                showAddMemberOptions = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color("PeacockBlue"))
                    .font(.title2)
            }
        }
    }
    
    private var emailInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add by Email")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                TextField("Enter member email", text: $newMemberEmail)
                    .padding()
                    .background(Color("MistyAqua"))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                Button {
                    addNewMember()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color("PeacockBlue"))
                        .font(.title2)
                }
                .disabled(newMemberEmail.isEmpty)
            }
        }
    }
    
    private var membersList: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(groupMembers.enumerated()), id: \.offset) { index, member in
                memberRow(member: member, index: index)
            }
        }
    }
    
    private func memberRow(member: String, index: Int) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color("PeacockBlue"))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(member.prefix(1).uppercased()))
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(member)
                    .font(.body)
                    .foregroundColor(.black)
                
                if member == userProfile.fullName || member == "You" {
                    Text("You")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Don't allow removing current user
            if member != userProfile.fullName && member != "You" {
                Button {
                    removeMember(at: index)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
        }
        .padding()
        .background(Color("MistyAqua"))
        .cornerRadius(12)
    }
    
    private var updateButton: some View {
        VStack {
            Button {
                updateGroup()
            } label: {
                HStack {
                    if isUpdating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Updating...")
                    } else {
                        Text("Update Group")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("PeacockBlue"))
                .cornerRadius(12)
            }
            .disabled(isUpdating || groupName.isEmpty)
            .padding()
        }
    }
    
    // MARK: - Top Bar matching previous screens
    var topBar: some View {
        VStack(spacing: 4) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("Edit Group")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Manage group settings")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Empty space to balance the layout
                Color.clear
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color("PeacockBlue"))
    }
    
    // MARK: - Helper Functions
    
    private func setupInitialData() {
        guard let group = selectedGroup else { return }
        groupName = group.name
        groupMembers = group.members
    }
    
    private func generateInviteLink() {
        guard let group = selectedGroup else { return }
        // Generate a shareable link with actual domain
        groupInviteLink = "https://squadpay.app/join/\(group.id)"
    }
    
    private func addNewMember() {
        let email = newMemberEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty,
              !groupMembers.contains(email),
              isValidEmail(email) else { return }
        
        groupMembers.append(email)
        newMemberEmail = ""
        
        // Send invitation via backend
        sendInvitation(to: email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func sendInvitation(to email: String) {
        guard let groupId = selectedGroup?.id else { return }
        
        Task {
            do {
                struct InvitationData: Encodable {
                    let group_id: String
                    let email: String
                    let invited_by: String
                    let status: String
                }
                
                let invitation = InvitationData(
                    group_id: groupId,
                    email: email,
                    invited_by: userProfile.fullName.isEmpty ? "You" : userProfile.fullName,
                    status: "pending"
                )
                
                try await SupabaseManager.shared.client
                    .from("group_invitations")
                    .insert(invitation)
                    .execute()
                
                print("✅ Invitation sent to \(email)")
            } catch {
                print("❌ Error sending invitation: \(error)")
            }
        }
    }
    
    private func addContactsToGroup(_ contacts: [ContactPickerView.ContactInfo]) {
        for contact in contacts {
            let email = contact.phoneNumber // This might actually be an email in your case
            if !groupMembers.contains(email) && isValidEmail(email) {
                groupMembers.append(email)
                sendInvitation(to: email)
            } else if !groupMembers.contains(contact.name) {
                // If not a valid email, add the contact name
                groupMembers.append(contact.name)
            }
        }
    }
    
    private func removeMember(at index: Int) {
        guard index < groupMembers.count else { return }
        groupMembers.remove(at: index)
    }
    
    private func updateGroup() {
        guard let group = selectedGroup,
              let groupId = UUID(uuidString: group.id) else { return }
        
        isUpdating = true
        
        Task {
            do {
                // Create encodable struct for update
                struct GroupUpdate: Encodable {
                    let name: String
                    let members: [String]
                }
                
                let updatedGroup = GroupUpdate(
                    name: groupName,
                    members: groupMembers
                )
                
                try await SupabaseManager.shared.client
                    .from("groups")
                    .update(updatedGroup)
                    .eq("id", value: groupId)
                    .execute()
                
                // Update local selected group
                DispatchQueue.main.async {
                    self.selectedGroup = GroupInfo(
                        id: group.id,
                        name: self.groupName,
                        type: group.type,
                        members: self.groupMembers,
                        expenses: group.expenses
                    )
                    
                    self.isUpdating = false
                    self.alertMessage = "Group updated successfully!"
                    self.showAlert = true
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isUpdating = false
                    self.alertMessage = "Failed to update group. Please try again."
                    self.showAlert = true
                }
                print("❌ Error updating group: \(error)")
            }
        }
    }
}

// MARK: - Share Link View
struct ShareLinkView: View {
    let inviteLink: String
    let groupId: String
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var copiedToClipboard = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                headerSection
                linkSection
                Spacer()
            }
            .padding()
            .navigationTitle("Invite Members")
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
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [inviteLink])
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "link.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color("PeacockBlue"))
            
            VStack(spacing: 8) {
                Text("Invite Link")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Share this link with friends to join the group")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
    
    private var linkSection: some View {
        VStack(spacing: 16) {
            // Link display with copy functionality
            VStack(spacing: 8) {
                HStack {
                    Text(inviteLink)
                        .font(.system(.callout, design: .monospaced))
                        .foregroundColor(.primary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Button {
                        copyToClipboard()
                    } label: {
                        Image(systemName: copiedToClipboard ? "checkmark.circle.fill" : "doc.on.doc")
                            .foregroundColor(copiedToClipboard ? .green : Color("PeacockBlue"))
                            .font(.title3)
                    }
                }
                .padding()
                .background(Color("MistyAqua"))
                .cornerRadius(12)
                
                Text(copiedToClipboard ? "Copied to clipboard!" : "Tap icon to copy")
                    .font(.caption)
                    .foregroundColor(copiedToClipboard ? .green : .gray)
            }
            
            // Share button
            Button {
                showShareSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Link")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("PeacockBlue"))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = inviteLink
        copiedToClipboard = true
        
        // Reset the copied state after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedToClipboard = false
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
