//
//  AddExpenseModal.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI
import UIKit

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss

    @State private var amount: String = ""
    @State private var selectedCategory: String = ""
    @State private var notes: String = ""
    @State private var showImagePicker = false
    @State private var selectedUIImage: UIImage?

    var receiptImage: Image? {
        if let uiImage = selectedUIImage {
            return Image(uiImage: uiImage)
        }
        return nil
    }

//    let categories = ["Food", "Travel", "Shopping", "Entertainment", "Others"]
    // ✅ Replace your categories with this:
    let categories = ["Food", "Travel", "Shopping", "Entertainment", "Misc"]

    var onSave: (_ category: String, _ amount: Double) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Amount Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount")
                        .font(.subheadline)
                        .foregroundColor(Color("SlateGray"))

                    HStack {
                        Text("₹")
                            .foregroundColor(.gray)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                // Category Picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.subheadline)
                        .foregroundColor(Color("SlateGray"))

                    Menu {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory.isEmpty ? "Select category" : selectedCategory)
                                .foregroundColor(selectedCategory.isEmpty ? .gray : Color("Charcoal"))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }

                // Notes
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes (Optional)")
                        .font(.subheadline)
                        .foregroundColor(Color("SlateGray"))

                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .foregroundColor(Color("SlateGray"))
                }

                // Photo Upload
                Button(action: {
                    showImagePicker.toggle()
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Add Photo")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundColor(.gray)
                    )
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $selectedUIImage)
                }

                // Show preview if image selected
                if let image = receiptImage {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.top, 8)
                }

                // Save Button
                Button(action: {
                    guard let value = Double(amount), !selectedCategory.isEmpty else { return }
                    onSave(selectedCategory, value)
                    dismiss()
                }) {
                    Text("Save Expense")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("CaribbeanTeal"))
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Add Expense")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("PeacockBlue"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .background(Color.white)
    }
}
