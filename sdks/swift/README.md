# AstroSDK — OpenWave Swift SDK

Swift SDK for OpenWave-compatible payment gateways. Requires iOS 15+ / macOS 12+. Uses Swift Concurrency (`async/await`) and `CryptoKit`.

Current additive API release: **1.1.0**. SwiftPM derives package versions from repository tags; `Package.swift` intentionally has no version field.

## Installation (Swift Package Manager)

```swift
// Package.swift
dependencies: [
    .package(path: "../astro-sdk/sdks/swift")
]
```

The public SDK monorepo currently distributes Swift from `sdks/swift`; clone it and add that directory as a local package in Xcode. Do not point SwiftPM at the monorepo root until a root package manifest or dedicated tagged Swift repository is published.

## NPT availability and rename (bank server only)

```swift
let bankAstro = AstroClient(config: AstroConfig(
    baseURL: URL(string: "https://astro.neptune.ly/api/v1")!,
    bankKey: ProcessInfo.processInfo.environment["OPENWAVE_BANK_KEY"]
))

let availability = try await bankAstro.alias.availability("mtellesy.new")
guard availability.status != "UNKNOWN" else {
    throw RegistryUnavailable()
}

let result = try await bankAstro.alias.rename(RenameAliasRequest(
    currentAliasUsername: "mtellesy",
    newAliasUsername: "mtellesy.new",
    nationalId: "123456789012"
))
assert(result.previousRetired) // the old NPT name can never be reused
assert(result.reauthenticationRequired)
print(result.retiredHandle)
print(result.nextStep) // End old sessions; sign in again with the new NPT name.
```

Keep the bank key and national ID outside customer iOS builds. The bank backend must propagate `nextStep` and require a clean sign-in when `reauthenticationRequired` is true. OpenWave Identity remains authoritative for ownership, permanent retirement, and login-approval challenges.

## Quick Start

```swift
import AstroSDK

let astro = AstroClient(config: AstroConfig(
    baseURL: URL(string: "https://astro.neptune.ly/api/v1")!,
    merchantKey: ProcessInfo.processInfo.environment["ASTRO_KEY"]
))

// Create a payment session
let session = try await astro.payments.createSession(
    CreateSessionRequest(
        amount: 50_000,   // 50.000 LYD
        currency: "LYD",
        destination: Destination(type: "alias", value: "mtellesy"),
        reference: "order_1042",
        redirectUrl: "myapp://payment/result"
    )
)

// Open checkout URL in Safari / SFSafariViewController
let url = URL(string: session.checkoutUrl)!
await UIApplication.shared.open(url)
```

## Modules

| Property | Type | Description |
|---|---|---|
| `astro.payments` | `PaymentsClient` | Sessions, mandates |
| `astro.alias` | `AliasClient` | Profile, accounts, resolve, availability, bank-server rename |
| `astro.openBanking` | `OpenBankingClient` | Consent, token, accounts, transactions |
| Credit & Finance handoff | Backend-created hosted URL | Finance offer acceptance |
| `astro.identity` | `IdentityClient` | Resolve alias, list banks |
| `astro.webhookVerifier(secret:)` | `WebhookVerifier` | HMAC-SHA256 verification |

## Payment Result Handling (Deep Link)

```swift
// In SceneDelegate or @main App
func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
    guard let url = urlContexts.first?.url,
          url.scheme == "myapp", url.host == "payment" else { return }
    let params = URLComponents(url: url, resolvingAgainstBaseURL: false)?
        .queryItems?.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
    if params?["status"] == "completed" {
        // Notify order manager
    }
}
```

## Open Banking

```swift
// 1. Create consent
let consent = try await astro.openBanking.createConsent(
    bankHandle: "andalus",
    scopes: ["accounts:read", "transactions:read"],
    redirectUri: "myapp://ob/callback",
    state: UUID().uuidString,
    codeChallenge: pkce.challenge
)

// 2. Open consentUrl, handle redirect, exchange code
let tokens = try await astro.openBanking.exchangeCode(
    code: callbackCode,
    redirectUri: "myapp://ob/callback",
    consentId: consent.consentId,
    codeVerifier: pkce.verifier
)

// 3. Fetch data
let accounts = try await astro.openBanking.getAccounts(
    accessToken: tokens.accessToken,
    consentId: consent.consentId
)
```

## Credit & Finance handoff

iOS apps should open hosted finance acceptance URLs returned by a trusted backend. Do not expose finance provider keys or assessment details in the app.

## Webhook Verification (Server-Side Swift / Vapor)

```swift
let verifier = astro.webhookVerifier(secret: ProcessInfo.processInfo.environment["WEBHOOK_SECRET"]!)

// In Vapor route:
app.post("webhooks", "astro") { req async throws -> Response in
    let body = req.body.string ?? ""
    let sig = req.headers.first(name: "X-OpenWave-Signature") ?? ""
    try verifier.handle(rawBody: body, signature: sig, handlers: [
        "payment.completed": { payload in
            let ref = (payload["data"] as? [String: Any])?["reference"] as? String
            await db.markPaid(ref)
        }
    ])
    return Response(status: .ok)
}
```

## Error Handling

```swift
do {
    let session = try await astro.payments.createSession(...)
} catch let error as AstroError {
    print("\(error.statusCode): [\(error.code)] \(error.localizedDescription)")
}
```

## License

UNLICENSED — Neptune Fintech internal SDK
