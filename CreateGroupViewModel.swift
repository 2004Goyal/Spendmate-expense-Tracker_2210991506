//
//  CreateGroupViewModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 04/08/25.
//

import Foundation
import Supabase
import SwiftUI
import PhotosUI
import MessageUI
import Contacts

//struct GroupCreateWithImageModel: Encodable {
//    let name: String
//    let type: String
//    let members: [String]
//    let image_url: String?
//}
//
//extension CreateGroupViewModel {
//    // Add these computed or stored properties to handle the missing scope errors
//    // Since we're extending, we'll need to use associated objects or refactor slightly
//    
//    func uploadGroupImage(_ image: UIImage) async -> String? {
//        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return nil }
//        
//        let fileName = "\(UUID().uuidString).jpg"
//        let filePath = "group-images/\(fileName)"
//        
//        do {
//            // Fixed: Remove 'path:' label
//            try await SupabaseManager.shared.client.storage
//                .from("group-images")
//                .upload(filePath, data: imageData)
//            
//            // Get public URL
//            let publicURL = try SupabaseManager.shared.client.storage
//                .from("group-images")
//                .getPublicURL(path: filePath)
//            
//            return publicURL.absoluteString
//        } catch {
//            print("Failed to upload image: \(error)")
//            return nil
//        }
//    }
//    
//    func createGroupWithImage(userID: UUID, imageURL: String?) async -> GroupModel? {
//        isSaving = true
//        defer { isSaving = false }
//        
//        // Process members to extract phone numbers or UUIDs
//        var processedMembers: [String] = []
//        for member in addedMembers {
//            if member.contains("|") {
//                // Extract phone number from "Name|Phone" format
//                let parts = member.split(separator: "|")
//                if parts.count > 1 {
//                    // Try to convert phone to UUID if it's stored as user ID
//                    let phoneOrId = String(parts[1])
//                    if let uuid = UUID(uuidString: phoneOrId) {
//                        processedMembers.append(uuid.uuidString.lowercased())
//                    } else {
//                        // Keep as phone number if not UUID
//                        processedMembers.append(phoneOrId)
//                    }
//                }
//            } else if let uuid = UUID(uuidString: member) {
//                processedMembers.append(uuid.uuidString.lowercased())
//            } else {
//                processedMembers.append(member)
//            }
//        }
//        
//        // Remove duplicates
//        let memberIDs = Array(Set(processedMembers))
//        
//        // Create group with image URL
//        do {
//            // Fixed: Use proper Encodable struct instead of [String: Any]
//            let groupData = GroupCreateWithImageModel(
//                name: groupName,
//                type: selectedType,
//                members: memberIDs,
//                image_url: imageURL
//            )
//            
//            try await SupabaseManager.shared.client
//                .from("groups")
//                .insert(groupData)
//                .execute()
//            
//            alertMessage = "Group created successfully 🎉"
//            showAlert = true
//            return nil
//        } catch {
//            alertMessage = "Failed to create group: \(error.localizedDescription)"
//            showAlert = true
//            return nil
//        }
//    }
//}
//
//// MARK: - Contact Manager Extensions
//extension ContactManager {
//    struct ContactDetail {
//        let name: String
//        let phoneNumber: String
//    }
//    
//    static func fetchContactsWithNames(completion: @escaping ([ContactDetail]) -> Void) {
//        var contactDetails: [ContactDetail] = []
//        let store = CNContactStore()
//        
//        store.requestAccess(for: .contacts) { granted, error in
//            guard granted else {
//                DispatchQueue.main.async {
//                    completion([])
//                }
//                return
//            }
//            
//            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
//            let request = CNContactFetchRequest(keysToFetch: keys)
//            
//            do {
//                try store.enumerateContacts(with: request) { contact, _ in
//                    let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
//                    let displayName = fullName.isEmpty ? "Unknown" : fullName
//                    
//                    for number in contact.phoneNumbers {
//                        let cleaned = number.value.stringValue.filter("0123456789".contains)
//                        if !cleaned.isEmpty {
//                            contactDetails.append(ContactDetail(name: displayName, phoneNumber: cleaned))
//                        }
//                    }
//                }
//                DispatchQueue.main.async {
//                    completion(contactDetails)
//                }
//            } catch {
//                print("❌ Failed to fetch contacts:", error)
//                DispatchQueue.main.async {
//                    completion([])
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Standalone Contact Picker View
//struct ContactPickerView: View {
//    @Binding var selectedContacts: [ContactInfo]
//    @Environment(\.dismiss) var dismiss
//    @State private var contacts: [ContactInfo] = []
//    @State private var searchText = ""
//    
//    struct ContactInfo: Identifiable, Equatable {
//        let id = UUID()
//        let name: String
//        let phoneNumber: String
//        
//        static func == (lhs: ContactInfo, rhs: ContactInfo) -> Bool {
//            lhs.phoneNumber == rhs.phoneNumber
//        }
//    }
//    
//    var filteredContacts: [ContactInfo] {
//        if searchText.isEmpty {
//            return contacts
//        } else {
//            return contacts.filter {
//                $0.name.localizedCaseInsensitiveContains(searchText) ||
//                $0.phoneNumber.contains(searchText)
//            }
//        }
//    }
//    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(filteredContacts, id: \.id) { contact in
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text(contact.name)
//                                .font(.headline)
//                            Text(contact.phoneNumber)
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                        
//                        Spacer()
//                        
//                        if selectedContacts.contains(where: { $0.phoneNumber == contact.phoneNumber }) {
//                            Image(systemName: "checkmark.circle.fill")
//                                .foregroundColor(.blue)
//                        }
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        toggleSelection(for: contact)
//                    }
//                }
//            }
//            .searchable(text: $searchText, prompt: "Search contacts")
//            .navigationTitle("Select Contacts")
//            .navigationBarItems(
//                leading: Button("Cancel") { dismiss() },
//                trailing: Button("Done") {
//                    dismiss()
//                }
//            )
//        }
//        .onAppear {
//            loadContacts()
//        }
//    }
//    
//    private func toggleSelection(for contact: ContactInfo) {
//        if let index = selectedContacts.firstIndex(where: { $0.phoneNumber == contact.phoneNumber }) {
//            selectedContacts.remove(at: index)
//        } else {
//            selectedContacts.append(contact)
//        }
//    }
//    
//    private func loadContacts() {
//        ContactManager.fetchContactsWithNames { contactList in
//            self.contacts = contactList.map {
//                ContactInfo(name: $0.name, phoneNumber: $0.phoneNumber)
//            }
//        }
//    }
//}
//
//// MARK: - Email Service
//struct EmailService {
//    static func sendInviteEmail(to email: String, groupName: String, inviteLink: String) {
//        let subject = "Join \(groupName) on SpendMate"
//        let body = "You've been invited to join '\(groupName)' on SpendMate!\n\nClick here to join: \(inviteLink)"
//        
//        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
//            UIApplication.shared.open(url)
//        }
//    }
//}
//
//// MARK: - Mail Composer View
//struct MailComposerView: UIViewControllerRepresentable {
//    @Binding var isPresented: Bool
//    let recipient: String
//    let subject: String
//    let body: String
//    
//    func makeUIViewController(context: Context) -> MFMailComposeViewController {
//        let composer = MFMailComposeViewController()
//        composer.mailComposeDelegate = context.coordinator
//        composer.setToRecipients([recipient])
//        composer.setSubject(subject)
//        composer.setMessageBody(body, isHTML: false)
//        return composer
//    }
//    
//    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
//        let parent: MailComposerView
//        
//        init(_ parent: MailComposerView) {
//            self.parent = parent
//        }
//        
//        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//            parent.isPresented = false
//        }
//    }
//}
//
//// MARK: - Image Picker View
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var selectedImage: UIImage?
//    @Environment(\.dismiss) var dismiss
//    var sourceType: UIImagePickerController.SourceType = .photoLibrary
//    
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.sourceType = sourceType
//        picker.delegate = context.coordinator
//        picker.allowsEditing = true
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        let parent: ImagePicker
//        
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//        
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
//                parent.selectedImage = image
//            }
//            parent.dismiss()
//        }
//        
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            parent.dismiss()
//        }
//    }
//}
//
//// MARK: - Email Input Dialog
//struct EmailInputDialog: View {
//    @Binding var isPresented: Bool
//    @State private var email = ""
//    let groupName: String
//    let inviteLink: String
//    let onSend: (String) -> Void
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Invite via Email")
//                .font(.headline)
//            
//            TextField("Enter email address", text: $email)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .keyboardType(.emailAddress)
//                .autocapitalization(.none)
//            
//            HStack(spacing: 16) {
//                Button("Cancel") {
//                    isPresented = false
//                }
//                .foregroundColor(.red)
//                
//                Button("Send Invite") {
//                    if isValidEmail(email) {
//                        onSend(email)
//                        isPresented = false
//                    }
//                }
//                .disabled(!isValidEmail(email))
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 10)
//        .padding(.horizontal, 40)
//    }
//    
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
//        return predicate.evaluate(with: email)
//    }
//}
//
//// MARK: - SQL Migration for groups table image_url
//
//@MainActor
//class CreateGroupViewModel: ObservableObject {
//    @Published var selectedImage: UIImage?
//    @Published var groupPhotoURL: String?
//    @Published var showImagePicker = false
//    @Published var showContactPicker = false
//    @Published var showMailComposer = false
//    @Published var recipientEmail = ""
//    @Published var showAlert: Bool = false
//    @Published var alertMessage: String = ""
//    @Published var isSaving: Bool = false
//    @Published var groupName: String = ""
//    @Published var selectedType: String = "Trip"
//    @Published var addedMembers: [String] = [] // may contain phone numbers from UI
//
//
//
//    private let client = SupabaseManager.shared.client
//
//    func createGroup(userID: UUID) async -> GroupModel? {
//        isSaving = true
//        defer { isSaving = false }
//
//        // ✅ Keep only UUID-looking strings + add creator + dedupe
//        // Keep only UUID-looking strings, lowercase, add creator already handled above,
//        // and dedupe.
//        let memberIDs = Array(Set(
//            addedMembers.compactMap { UUID(uuidString: $0)?.uuidString.lowercased() }
//        ))
//
//        let group = GroupCreateModel(
//            name: groupName,
//            type: selectedType,
//            members: memberIDs      // text[] of lowercased UUIDs
//        )
//
//        do {
//            // Avoid SELECT on insert if you want to minimize policy needs
//            try await client
//                .from("groups")
//                .insert(group, returning: .minimal)
//                .execute()
//
//            alertMessage = "Group created successfully 🎉"
//            showAlert = true
//            return nil
//        } catch {
//            alertMessage = "Failed to create group: \(error.localizedDescription)"
//            showAlert = true
//            return nil
//        }
//
//    }
//}
// MARK: - Contact Manager Extensions
extension ContactManager {
    struct ContactDetail {
        let name: String
        let phoneNumber: String
    }
    
    static func fetchContactsWithNames(completion: @escaping ([ContactDetail]) -> Void) {
        var contactDetails: [ContactDetail] = []
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                    let displayName = fullName.isEmpty ? "Unknown" : fullName
                    
                    for number in contact.phoneNumbers {
                        let cleaned = number.value.stringValue.filter("0123456789".contains)
                        if !cleaned.isEmpty {
                            contactDetails.append(ContactDetail(name: displayName, phoneNumber: cleaned))
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion(contactDetails)
                }
            } catch {
                print("❌ Failed to fetch contacts:", error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
}

// MARK: - Standalone Contact Picker View
struct ContactPickerView: View {
    @Binding var selectedContacts: [ContactInfo]
    @Environment(\.dismiss) var dismiss
    @State private var contacts: [ContactInfo] = []
    @State private var searchText = ""
    
    struct ContactInfo: Identifiable, Equatable {
        let id = UUID()
        let name: String
        let phoneNumber: String
        
        static func == (lhs: ContactInfo, rhs: ContactInfo) -> Bool {
            lhs.phoneNumber == rhs.phoneNumber
        }
    }
    
    var filteredContacts: [ContactInfo] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.phoneNumber.contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredContacts, id: \.id) { contact in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(contact.name)
                                .font(.headline)
                            Text(contact.phoneNumber)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if selectedContacts.contains(where: { $0.phoneNumber == contact.phoneNumber }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleSelection(for: contact)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search contacts")
            .navigationTitle("Select Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadContacts()
        }
    }
    
    private func toggleSelection(for contact: ContactInfo) {
        if let index = selectedContacts.firstIndex(where: { $0.phoneNumber == contact.phoneNumber }) {
            selectedContacts.remove(at: index)
        } else {
            selectedContacts.append(contact)
        }
    }
    
    private func loadContacts() {
        ContactManager.fetchContactsWithNames { contactList in
            self.contacts = contactList.map {
                ContactInfo(name: $0.name, phoneNumber: $0.phoneNumber)
            }
        }
    }
}

// MARK: - Email Service
struct EmailService {
    static func sendInviteEmail(to email: String, groupName: String, inviteLink: String) {
        let subject = "Join \(groupName) on SpendMate"
        let body = "You've been invited to join '\(groupName)' on SpendMate!\n\nClick here to join: \(inviteLink)"
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Mail Composer View
struct MailComposerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let recipient: String
    let subject: String
    let body: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients([recipient])
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerView
        
        init(_ parent: MailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isPresented = false
        }
    }
}

// MARK: - Email Input Dialog
struct EmailInputDialog: View {
    @Binding var isPresented: Bool
    @State private var email = ""
    let groupName: String
    let inviteLink: String
    let onSend: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Invite via Email")
                .font(.headline)
            
            TextField("Enter email address", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.red)
                
                Button("Send Invite") {
                    if isValidEmail(email) {
                        onSend(email)
                        isPresented = false
                    }
                }
                .disabled(!isValidEmail(email))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.horizontal, 40)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}

// MARK: - CreateGroupViewModel (without image functionality)
@MainActor
class CreateGroupViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isSaving: Bool = false
    @Published var groupName: String = ""
    @Published var selectedType: String = "Trip"
    @Published var addedMembers: [String] = [] // may contain phone numbers from UI

    private let client = SupabaseManager.shared.client

    func createGroup(userID: UUID) async -> GroupModel? {
        isSaving = true
        defer { isSaving = false }

        // Keep only UUID-looking strings, lowercase, add creator, and dedupe
        let memberIDs = Array(Set(
            addedMembers.compactMap { UUID(uuidString: $0)?.uuidString.lowercased() }
        ))

        let group = GroupCreateModel(
            name: groupName,
            type: selectedType,
            members: memberIDs      // text[] of lowercased UUIDs
        )

        do {
            // Avoid SELECT on insert if you want to minimize policy needs
            try await client
                .from("groups")
                .insert(group, returning: .minimal)
                .execute()

            alertMessage = "Group created successfully 🎉"
            showAlert = true
            return nil
        } catch {
            alertMessage = "Failed to create group: \(error.localizedDescription)"
            showAlert = true
            return nil
        }
    }
}
