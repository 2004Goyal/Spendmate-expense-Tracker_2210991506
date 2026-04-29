//
//  ChatMessage.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 06/07/25.
//

import Foundation
import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

