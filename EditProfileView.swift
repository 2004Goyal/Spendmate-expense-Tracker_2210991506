//
//  EditProfileView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 04/07/25.
//

import Foundation
import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Binding var fullName: String
    @Binding var email: String
    @Binding var phoneNumber: String
    @Binding var dateOfBirth: Date
    @Binding var profileImage: UIImage?

    @Environment(\.dismiss) var dismiss
    @State private var showDatePicker = false
    @State private var showSaveAlert = false
    @State private var showImagePicker = false
    @State private var isUploading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @EnvironmentObject var userProfile: UserProfile

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundColor(.white)
                }
                Spacer()
                Text("Edit Profile").font(.headline).foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding()
            .background(Color("PeacockBlue"))

            ScrollView {
                VStack(spacing: 32) {
                    // Profile Photo with Upload Status
                    VStack(spacing: 12) {
                        ZStack(alignment: .bottomTrailing) {
                            ZStack {
                                if let image = profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(Color("CaribbeanTeal"))
                                }
                                
                                // Upload progress overlay
                                if isUploading {
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(1.2)
                                        )
                                }
                            }

                            Button {
                                showImagePicker = true
                            } label: {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color("CaribbeanTeal"))
                                    .clipShape(Circle())
                            }
                            .offset(x: 5, y: 5)
                            .disabled(isUploading)
                        }

                        Text(isUploading ? "Uploading..." : "Change Photo")
                            .foregroundColor(isUploading ? .blue : .gray)
                    }

                    // Fields
                    VStack(spacing: 20) {
                        CustomTextField(label: "Full Name", text: $userProfile.fullName)
                        CustomTextField(label: "Email", text: $userProfile.email)
                        CustomTextField(label: "Phone", text: $userProfile.phoneNumber)

                        // Date of Birth
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date of Birth")
                                .font(.system(size: 16))
                                .foregroundColor(Color("Charcoal"))

                            HStack {
                                Text(dateOfBirth, style: .date)
                                    .foregroundColor(Color("Charcoal"))
                                Spacer()
                                Button { showDatePicker.toggle() } label: {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color("CaribbeanTeal"))
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray4)))

                            if showDatePicker {
                                DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .labelsHidden()
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Save Button
                    Button {
                        Task { await saveAllChanges() }
                    } label: {
                        HStack {
                            if isUploading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isUploading ? "Saving..." : "Save Changes")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isUploading ? Color.gray : Color("CaribbeanTeal"))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(isUploading)
                }
                .padding()
            }
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showImagePicker) {
            ProfilePhotoPicker(selectedImage: $profileImage)
        }
        .alert("✅ All changes saved successfully.", isPresented: $showSaveAlert) {
            Button("OK") { dismiss() }
        }
        .alert("❌ Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: profileImage) { newImage in
            // Auto-save when image changes
            if newImage != nil {
                Task { await saveAllChanges() }
            }
        }
    }
    
    // MARK: - Save Function with Image Upload
    private func saveAllChanges() async {
        await MainActor.run { isUploading = true }
        
        do {
            try await userProfile.saveWithProfileImage(profileImage)
            await MainActor.run {
                isUploading = false
                showSaveAlert = true
            }
        } catch {
            await MainActor.run {
                isUploading = false
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}


// MARK: - Profile Photo Picker

struct ProfilePhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ProfilePhotoPicker

        init(_ parent: ProfilePhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let itemProvider = results.first?.itemProvider,
                  itemProvider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let uiImage = image as? UIImage {
                        // Resize image if too large
                        let resizedImage = self.resizeImage(uiImage, to: CGSize(width: 800, height: 800))
                        self.parent.selectedImage = resizedImage
                    }
                }
            }
        }
        
        private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: size))
            }
        }
    }
}
