//
//  MicaService.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 06/07/25.
//

import Foundation

class MicaService {
    static let shared = MicaService()

    private let apiKey = SecretsManager.shared.geminiKey
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key="

    func sendMessage(toMica prompt: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: endpoint + apiKey) else {
            completion("⚠️ Invalid Gemini API URL.")
            return
        }

        let headers = [
            "Content-Type": "application/json"
        ]

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("⚠️ Network error.")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("🔍 Gemini raw JSON: \(String(describing: json))")

                if let candidates = json?["candidates"] as? [[String: Any]],
                   let first = candidates.first,
                   let content = first["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    completion("⚠️ MICA couldn’t understand that.")
                }

            } catch {
                print("❌ JSON parse error: \(error.localizedDescription)")
                completion("⚠️ MICA is having trouble understanding right now.")
            }
        }.resume()
    }
}
