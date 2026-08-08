import Foundation

public final class AliasClient {
    private let http: AstroHTTPClient
    init(http: AstroHTTPClient) { self.http = http }

    public func getProfile(_ alias: String) async throws -> AliasProfile {
        try await http.perform(http.request(http.url("/alias/\(alias)")))
    }

    public func getAccounts(_ alias: String) async throws -> [LinkedAccount] {
        let result = try await http.perform(http.request(http.url("/alias/\(alias)/accounts"))) as AccountsWrapper
        return result.accounts
    }

    public func resolve(_ alias: String) async throws -> ResolveResult {
        try await http.perform(http.request(http.url("/identity/resolve", query: ["alias": alias])))
    }

    public func deactivate(_ alias: String) async throws -> AliasProfile {
        try await http.perform(http.request(http.url("/alias/\(alias)/deactivate"), method: "POST"))
    }

    /// Bank-server only. UNKNOWN is a registry transport state, not availability.
    public func availability(_ alias: String) async throws -> AliasAvailability {
        try await http.perform(http.request(http.url("/alias/\(alias)/availability")))
    }

    /// Bank-server only. Identity permanently retires the previous NPT name.
    public func rename(_ request: RenameAliasRequest) async throws -> RenameAliasResult {
        try await http.perform(http.request(http.url("/alias/rename"), method: "PATCH", body: request))
    }
}

private struct AccountsWrapper: Decodable { let accounts: [LinkedAccount] }
