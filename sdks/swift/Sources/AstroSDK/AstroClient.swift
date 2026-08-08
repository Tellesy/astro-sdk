import Foundation

public final class AstroClient {

    public let payments: PaymentsClient
    public let alias: AliasClient
    public let openBanking: OpenBankingClient
    public let identity: IdentityClient
    public let presentments: PresentmentsClient

    private let http: AstroHTTPClient

    public init(config: AstroConfig) {
        http = AstroHTTPClient(config: config)
        payments = PaymentsClient(http: http)
        alias = AliasClient(http: http)
        openBanking = OpenBankingClient(http: http)
        identity = IdentityClient(http: http)
        presentments = PresentmentsClient(http: http)
    }

    public func webhookVerifier(secret: String) -> WebhookVerifier {
        WebhookVerifier(secret: secret)
    }
}

// MARK: - HTTP Engine

final class AstroHTTPClient {
    let config: AstroConfig
    private let session: URLSession
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    init(config: AstroConfig) {
        self.config = config
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = config.timeout
        self.session = URLSession(configuration: cfg)
    }

    func url(_ path: String, query: [String: String?]? = nil) -> URL {
        var components = URLComponents(url: config.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if let q = query {
            components.queryItems = q.compactMap { k, v in v.map { URLQueryItem(name: k, value: $0) } }
        }
        return components.url!
    }

    func request(_ url: URL, method: String = "GET", body: Encodable? = nil, extraHeaders: [String: String] = [:]) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let key = config.merchantKey { req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization") }
        if let key = config.bankKey { req.setValue(key, forHTTPHeaderField: "X-OpenWave-Bank-Key") }
        if let key = config.adminKey { req.setValue(key, forHTTPHeaderField: "X-OpenWave-Admin-Key") }
        extraHeaders.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        if let body = body { req.httpBody = try? JSONEncoder().encode(body) }
        return req
    }

    func perform<T: Decodable>(_ req: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw AstroError(statusCode: 0, code: "NETWORK_ERROR", message: "No HTTP response")
        }
        if (200..<300).contains(http.statusCode) {
            return try decoder.decode(T.self, from: data)
        }
        let errorBody = try? decoder.decode(AstroErrorEnvelope.self, from: data)
        let err = errorBody?.error
        throw AstroError(
            statusCode: http.statusCode,
            code: err?.code ?? errorBody?.code ?? "UNKNOWN_ERROR",
            message: err?.message ?? errorBody?.message ?? "HTTP \(http.statusCode)",
            detail: err?.detail ?? errorBody?.detail
        )
    }
}

private struct AstroErrorPayload: Decodable {
    let code: String?
    let message: String?
    let detail: String?
}

private struct AstroErrorEnvelope: Decodable {
    let error: AstroErrorPayload?
    let code: String?
    let message: String?
    let detail: String?
}
