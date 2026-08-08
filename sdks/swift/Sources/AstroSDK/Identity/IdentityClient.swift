import Foundation

public final class IdentityClient {
    private let http: AstroHTTPClient
    init(http: AstroHTTPClient) { self.http = http }

    public func resolve(_ alias: String) async throws -> ResolveResult {
        try await http.perform(http.request(http.url("/identity/resolve", query: ["alias": alias])))
    }

    public func listBanks() async throws -> [BankEntry] {
        try await http.perform(http.request(http.url("/banks")))
    }

    public func getBank(_ handle: String) async throws -> BankEntry {
        try await http.perform(http.request(http.url("/banks/\(handle)")))
    }
}
