//
//  ContactManager.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 06/08/25.
//

import Foundation
import Contacts

class ContactManager {
    static func fetchContacts(completion: @escaping ([String]) -> Void) {
        var phoneNumbers: [String] = []
        let store = CNContactStore()

        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                completion([])
                return
            }

            let keys = [CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)

            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    for number in contact.phoneNumbers {
                        let cleaned = number.value.stringValue.filter("0123456789".contains)
                        phoneNumbers.append(cleaned)
                    }
                }
                completion(phoneNumbers)
            } catch {
                print("❌ Failed to fetch contacts:", error)
                completion([])
            }
        }
    }
}
