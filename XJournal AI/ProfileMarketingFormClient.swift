//
//  ProfileMarketingFormClient.swift
//  XJournal AI
//
//  Posts You-tab contact + marketing consent to the Penn Work Studios Google Form.
//  Edit / responses: https://docs.google.com/forms/d/1yBdO9fvOveJUVLrllhN3UXf6tU0bE6NTNZMSpqRVfEY/edit
//

import Foundation

enum ProfileMarketingFormClient {
    struct Payload: Equatable {
        var name: String
        var email: String
        var phone: String
        var marketingOptIn: Bool
    }

    /// Published responder form. `emailAddress` is Google's built-in "Responder input" email field.
    static let viewFormID = "1FAIpQLSfxqlOEkgK9IZNw7zg_UJvpSmNhDb1-BvTd2Ny9Blu9wpj1ag"
    static let nameEntry = "15172110"
    static let phoneEntry = "1702062212"
    static let marketingEntry = "1573850206"

    static var formResponseURL: URL {
        URL(string: "https://docs.google.com/forms/d/e/\(viewFormID)/formResponse")!
    }

    static func formBody(for payload: Payload) -> String {
        var pairs: [(String, String)] = [
            ("emailAddress", payload.email.trimmingCharacters(in: .whitespacesAndNewlines)),
            ("entry.\(marketingEntry)", payload.marketingOptIn ? "Yes" : "No"),
        ]
        let name = payload.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !name.isEmpty {
            pairs.append(("entry.\(nameEntry)", name))
        }
        let phone = payload.phone.trimmingCharacters(in: .whitespacesAndNewlines)
        if !phone.isEmpty {
            pairs.append(("entry.\(phoneEntry)", phone))
        }
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&+=?")
        return pairs
            .map { key, value in
                let k = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
                let v = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
                return "\(k)=\(v)"
            }
            .joined(separator: "&")
    }

    /// Signature used to skip duplicate Confirm posts of the same values.
    static func signature(for payload: Payload) -> String {
        [
            payload.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            payload.name.trimmingCharacters(in: .whitespacesAndNewlines),
            payload.phone.trimmingCharacters(in: .whitespacesAndNewlines),
            payload.marketingOptIn ? "Yes" : "No",
        ].joined(separator: "\u{1e}")
    }

    static func submit(_ payload: Payload) async throws {
        var request = URLRequest(url: formResponseURL, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15",
            forHTTPHeaderField: "User-Agent"
        )
        request.httpBody = Data(formBody(for: payload).utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SubmitError.unexpectedResponse
        }
        guard (200..<400).contains(http.statusCode) else {
            throw SubmitError.http(http.statusCode)
        }
        // Google returns 200 with the form HTML when a required field fails.
        if let body = String(data: data, encoding: .utf8),
           body.localizedCaseInsensitiveContains("your response")
            || body.localizedCaseInsensitiveContains("recorded") {
            return
        }
        if http.statusCode == 200 {
            return
        }
        throw SubmitError.unexpectedResponse
    }

    enum SubmitError: Error, LocalizedError {
        case http(Int)
        case unexpectedResponse

        var errorDescription: String? {
            switch self {
            case .http(let code):
                return "Signup form returned HTTP \(code)."
            case .unexpectedResponse:
                return "Signup form did not confirm the save."
            }
        }
    }
}
