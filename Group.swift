//
//  Group.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 04/08/25.
//

import Foundation

struct GroupModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: String
    let members: [String]
    let created_at: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, type, members
        case created_at = "created_at"
    }
}



