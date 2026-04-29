//
//  GroupCreateModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 04/08/25.
//

import Foundation

struct GroupCreateModel: Codable {
    let name: String
    let type: String
    let members: [String]
}
