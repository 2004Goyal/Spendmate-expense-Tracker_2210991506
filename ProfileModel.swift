//
//  ProfileModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 10/07/25.
//

import Foundation
import SwiftUI

//Profile Model
struct FeatureToggleRow: View {
    var icon: String
    var title: String
    var isOn: Bool
    var isPremium: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("PeacockBlue"))
                .frame(width: 24)
            Text(title)
                .foregroundColor(Color("Charcoal"))
            if isPremium {
                Text("Premium")
                    .font(.caption)
                    .padding(4)
                    .background(Color("MistyAqua"))
                    .cornerRadius(6)
            }
            Spacer()
            Toggle("", isOn: .constant(isOn))
                .labelsHidden()
        }
        .padding()
    }
}
////
struct SettingRow: View {
    var icon: String
    var title: String
    var isPremium: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("PeacockBlue"))
                .frame(width: 24)
            Text(title)
                .foregroundColor(Color("Charcoal"))
            if isPremium {
                Text("Premium")
                    .font(.caption)
                    .padding(4)
                    .background(Color("MistyAqua"))
                    .cornerRadius(6)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color("SlateGray"))
        }
        .padding()
    }
}


//Edit Profile Model
struct CustomTextField: View {
    var label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 18))
                .foregroundColor(Color("Charcoal"))
            TextField(label, text: $text)
                .font(.system(size: 18))
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .keyboardType(keyboardType)
        }
    }
}


