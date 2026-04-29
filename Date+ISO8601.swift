//
//  Date+ISO8601.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 17/07/25.
//

import Foundation

extension Date {
    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }
}

extension String {
    var iso8601Date: Date? {
        ISO8601DateFormatter().date(from: self)
    }
}
