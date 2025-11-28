#!/usr/bin/env swift

import Foundation

// Read session key from file
func readSessionKey() -> String? {
    let sessionKeyPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".claude-session-key")

    guard FileManager.default.fileExists(atPath: sessionKeyPath.path) else {
        return nil
    }

    guard let key = try? String(contentsOf: sessionKeyPath, encoding: .utf8) else {
        return nil
    }

    let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedKey.isEmpty ? nil : trimmedKey
}

// Fetch organization ID
func fetchOrganizationId(sessionKey: String) async throws -> String {
    let url = URL(string: "https://claude.ai/api/organizations")!
    var request = URLRequest(url: url)
    request.setValue("sessionKey=\(sessionKey)", forHTTPHeaderField: "Cookie")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpMethod = "GET"

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: "ClaudeAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch org ID"])
    }

    struct Organization: Codable {
        let uuid: String
    }

    let organizations = try JSONDecoder().decode([Organization].self, from: data)
    guard let firstOrg = organizations.first else {
        throw NSError(domain: "ClaudeAPI", code: 2, userInfo: [NSLocalizedDescriptionKey: "No organizations found"])
    }

    return firstOrg.uuid
}

// Fetch usage data
func fetchUsageData(sessionKey: String, orgId: String) async throws -> (utilization: Int, resetsAt: String?) {
    let url = URL(string: "https://claude.ai/api/organizations/\(orgId)/usage")!
    var request = URLRequest(url: url)
    request.setValue("sessionKey=\(sessionKey)", forHTTPHeaderField: "Cookie")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpMethod = "GET"

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: "ClaudeAPI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch usage"])
    }

    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let fiveHour = json["five_hour"] as? [String: Any],
       let utilization = fiveHour["utilization"] as? Int {
        let resetsAt = fiveHour["resets_at"] as? String
        return (utilization, resetsAt)
    }

    throw NSError(domain: "ClaudeAPI", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
}

// Main execution
Task {
    guard let sessionKey = readSessionKey() else {
        print("ERROR:NO_SESSION_KEY")
        exit(1)
    }

    do {
        let orgId = try await fetchOrganizationId(sessionKey: sessionKey)
        let (utilization, resetsAt) = try await fetchUsageData(sessionKey: sessionKey, orgId: orgId)

        // Output format: UTILIZATION|RESETS_AT
        if let resets = resetsAt {
            print("\(utilization)|\(resets)")
        } else {
            print("\(utilization)|")
        }
        exit(0)
    } catch {
        print("ERROR:\(error.localizedDescription)")
        exit(1)
    }
}

// Keep the script running until Task completes
RunLoop.main.run()
