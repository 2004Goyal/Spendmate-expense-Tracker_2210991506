//
//  AuthModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//
import Foundation
import SwiftUI

// SignUp View
struct InputField: View {
    var title: String
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundColor(Color("SlateGray"))

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("CaribbeanTeal"), lineWidth: 1.2)
                )
                .foregroundColor(Color("Charcoal"))
        }
    }
}

// MARK: - Reusable Secure Field with Eye Toggle
struct SecureInputField: View {
    var title: String
    @Binding var text: String
    @Binding var showText: Bool
    var placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundColor(Color("SlateGray"))

            HStack {
                if showText {
                    TextField(placeholder, text: $text)
                        .foregroundColor(Color("Charcoal"))
                } else {
                    SecureField(placeholder, text: $text)
                        .foregroundColor(Color("Charcoal"))
                }

                Button(action: {
                    showText.toggle()
                }) {
                    Image(systemName: showText ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("CaribbeanTeal"), lineWidth: 1.2)
            )
        }
    }
}
