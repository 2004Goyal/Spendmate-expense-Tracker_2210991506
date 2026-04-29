//
//  ChatBubble.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 06/07/25.
//

import Foundation
import SwiftUI

struct UserChatBubble: View {
    let text: String
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .padding(12)
                .background(Color("CaribbeanTeal"))
                .foregroundColor(.white)
                .cornerRadius(16)
                .frame(maxWidth: 280, alignment: .trailing)
        }
        .transition(.move(edge: .trailing))
    }
}

struct MicaChatBubble: View {
    let text: String
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "bolt.fill")
                .foregroundColor(Color("PeacockBlue"))
            Text(text)
                .padding(12)
                .background(Color.white)
                .foregroundColor(Color("Charcoal"))
                .cornerRadius(16)
                .frame(maxWidth: 280, alignment: .leading)
            Spacer()
        }
        .transition(.move(edge: .leading))
    }
}

struct TypingDotsView: View {
    @State private var scale: [CGFloat] = [0.8, 0.8, 0.8]
    let dotCount = 3

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<dotCount, id: \.self) { i in
                Circle()
                    .fill(Color("PeacockBlue"))
                    .frame(width: 8, height: 8)
                    .scaleEffect(scale[i])
                    .animation(Animation.easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.2), value: scale[i])
            }
        }
        .onAppear {
            for i in 0..<dotCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                    scale[i] = 1.0
                }
            }
        }
    }
}
