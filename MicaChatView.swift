//
//  MicaChatView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI

struct MicaChatView: View {
//    @StateObject private var viewModel = MicaViewModel()
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi! I'm MICA, your money buddy. How can I help you today?", isUser: false)
    ]
    @State private var inputText = ""
    @State private var isTyping = false
    
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var budgetModel: BudgetModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Ask MICA 🧠")
                .font(.title2.bold())
                .foregroundColor(Color("PeacockBlue"))
                .padding()

            Divider()

            // Chat Area
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(messages) { msg in
                            if msg.isUser {
                                UserChatBubble(text: msg.text)
                            } else {
                                MicaChatBubble(text: msg.text)
                            }
                        }

                        // Typing Indicator
                        if isTyping {
                            TypingDotsView()
                                .padding(.leading, 20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            scrollView.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input Area
            HStack {
                TextField("", text: $inputText, prompt: Text("Ask something like 'Biggest expense last month'").foregroundColor(Color("SlateGray")))
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color("CaribbeanTeal"))
                        .clipShape(Circle())
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color("MistyAqua").opacity(0.25))
        }
        .background(Color("MistyAqua").ignoresSafeArea())
    }

    // MARK: - Send Message Logic
//    func sendMessage() {
//        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedText.isEmpty else { return }
//
//        let userMessage = ChatMessage(text: trimmedText, isUser: true)
//        messages.append(userMessage)
//        inputText = ""
//        isTyping = true
//
//        MicaService.shared.sendMessage(toMica: trimmedText) { response in
//            DispatchQueue.main.async {
//                messages.append(ChatMessage(text: response ?? "Sorry, I didn’t catch that.", isUser: false))
//                isTyping = false
//            }
//        }
//    }
    
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let userMessage = ChatMessage(text: trimmedText, isUser: true)
        messages.append(userMessage)
        inputText = ""
        isTyping = true

        // ✅ Real-time context
        let context = buildUserFinancialContext()
        let fullPrompt = context + "\n\nUser asked: \(trimmedText)"

        MicaService.shared.sendMessage(toMica: fullPrompt) { response in
            DispatchQueue.main.async {
                messages.append(ChatMessage(text: response ?? "Sorry, I didn’t catch that.", isUser: false))
                isTyping = false
            }
        }
    }
    func buildUserFinancialContext() -> String {
        let income = userProfile.monthlyIncome
        let foodSpent = Int(budgetModel.foodSpent)
        let foodLimit = Int(budgetModel.food)
        let travelSpent = Int(budgetModel.travelSpent)
        let travelLimit = Int(budgetModel.travel)
        let entertainmentSpent = Int(budgetModel.entertainmentSpent)
        let entertainmentLimit = Int(budgetModel.entertainment)
        let shoppingSpent = Int(budgetModel.shoppingSpent)
        let shoppingLimit = Int(budgetModel.shopping)
        let miscSpent = Int(budgetModel.miscSpent)
        let miscLimit = Int(budgetModel.misc)

        let totalBudget = foodLimit + travelLimit + entertainmentLimit + shoppingLimit + miscLimit
        let totalSpent = foodSpent + travelSpent + entertainmentSpent + shoppingSpent + miscSpent

        return """
        📊 User Financial Snapshot:
        - Monthly Income: ₹\(income)
        - Total Budget: ₹\(totalBudget)
        - Total Spent So Far: ₹\(totalSpent)

        💸 Current Spending by Category:
        - Food: ₹\(foodSpent) / ₹\(foodLimit)
        - Travel: ₹\(travelSpent) / ₹\(travelLimit)
        - Entertainment: ₹\(entertainmentSpent) / ₹\(entertainmentLimit)
        - Shopping: ₹\(shoppingSpent) / ₹\(shoppingLimit)
        - Misc: ₹\(miscSpent) / ₹\(miscLimit)

        Based on this, give clear and practical suggestions:
        - How to avoid overspending
        - Where to reduce expenses
        - How to increase savings
        """
    }

}
