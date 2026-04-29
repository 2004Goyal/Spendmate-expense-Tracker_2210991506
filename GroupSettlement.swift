//
//  GroupSettlement.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 04/08/25.
//

import Foundation

struct GroupSettlement: Codable {
    let group_id: UUID
    let payer: String
    let payee: String
    let amount: Double
}
