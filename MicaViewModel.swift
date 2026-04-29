//
//  MicaViewModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 06/07/25.
//

import Foundation

//class MicaViewModel: ObservableObject {
//    @Published var messages: [ChatMessage] = [
//        ChatMessage(text: "Hi! I'm MICA, your money buddy. How can I help you today?", isUser: false)
//    ]
//    @Published var isTyping = false
//
//    func sendMessage(_ text: String) {
//        let userMessage = ChatMessage(text: text, isUser: true)
//        messages.append(userMessage)
//        isTyping = true
//
//        // ✅ Now using Gemini instead of OpenAI
//        MicaService.shared.sendMessage(toMica: text) { [weak self] reply in
//            DispatchQueue.main.async {
//                self?.messages.append(ChatMessage(text: reply ?? "⚠️ MICA couldn’t understand that.", isUser: false))
//                self?.isTyping = false
//            }
//        }
//    }
//}
