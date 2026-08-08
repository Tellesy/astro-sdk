# Astro Kotlin SDK

Kotlin/JVM SDK for OpenWave-compatible payment gateways. Uses Ktor HTTP client with coroutines.

## Installation

```kotlin
// build.gradle.kts
dependencies {
    implementation("ly.neptune.astro:astro-kotlin:1.1.0")
}
```

## Quick Start

```kotlin
import ly.neptune.astro.*
import kotlinx.coroutines.runBlocking

val astro = astroClient {
    baseUrl = "https://astro.neptune.ly/api/v1"
    merchantKey = System.getenv("ASTRO_MERCHANT_KEY")
}

runBlocking {
    // Create a payment session
    val session = astro.payments.createSession(
        CreateSessionRequest(
            amount = 50_000,   // 50.000 LYD
            currency = "LYD",
            destination = Destination(type = "alias", value = "mtellesy"),
            reference = "order_1042",
            redirectUrl = "https://myapp.com/result"
        )
    )
    println("Checkout URL: ${session.checkoutUrl}")

    // Resolve an alias
    val resolved = astro.identity.resolve("mtellesy")
    println("Routes to bank: ${resolved.bankHandle}")
}

astro.close()
```

## Modules

| Module | Description |
|---|---|
| `astro.payments` | Create/list/cancel sessions, mandates |
| `astro.alias` | Get profile, linked accounts, availability, bank-server rename, deactivate |
| `astro.openBanking` | Consents, token exchange, accounts, transactions |
| `astro.finance` | Credit assessment and finance-offer targets, when enabled |
| `astro.identity` | Resolve alias, list banks |
| `WebhookVerifier` | HMAC-SHA256 signature verification |
| `WebhookReceiver` | Event-based webhook dispatcher |

## NPT availability and rename (bank server only)

```kotlin
val bankAstro = AstroClient(
    AstroConfig(
        baseUrl = "https://astro.neptune.ly/api/v1",
        bankKey = System.getenv("OPENWAVE_BANK_KEY")
    )
)

val availability = bankAstro.alias.availability("mtellesy.new")
check(availability.status != "UNKNOWN") { "Identity could not be consulted" }

val result = bankAstro.alias.rename(
    RenameAliasRequest(
        currentAliasUsername = "mtellesy",
        newAliasUsername = "mtellesy.new",
        nationalId = "123456789012"
    )
)
check(result.previousRetired) // the old NPT name can never be reused
check(result.reauthenticationRequired)
println(result.retiredHandle)
println(result.nextStep) // End old sessions; sign in again with the new NPT name.
```

Keep the bank key and national ID on the bank server. Propagate `nextStep` to the authenticated bank app and enforce `reauthenticationRequired` before continuing. OpenWave Identity remains authoritative for ownership, permanent retirement, and login-approval challenges.

## Webhook Handler (Ktor server)

```kotlin
val receiver = WebhookReceiver(secret = System.getenv("ASTRO_WEBHOOK_SECRET"))

receiver
    .on("payment.completed") { payload ->
        val obj = payload as JsonObject
        val ref = obj["data"]?.jsonObject?.get("reference")?.jsonPrimitive?.content
        db.orders.markPaid(ref)
    }
    .on("payment.failed") { payload ->
        // handle failure
    }

// In your route handler
post("/webhooks/astro") {
    val body = call.receiveText()
    val sig = call.request.headers["X-OpenWave-Signature"] ?: return@post call.respond(400)
    receiver.handle(body, sig)
    call.respond(HttpStatusCode.OK)
}
```

## Error Handling

```kotlin
try {
    val session = astro.payments.createSession(...)
} catch (e: AstroRequestException) {
    println("Error ${e.status}: [${e.code}] ${e.message}")
    println("Request ID: ${e.requestId}")
}
```

## Open Banking

```kotlin
// 1. Create consent (bank admin key required)
val consent = astro.openBanking.createConsent(
    CreateConsentRequest(
        bankHandle = "andalus",
        scopes = listOf("accounts:read", "transactions:read"),
        redirectUri = "https://myapp.com/ob/callback",
        state = generateState(),
        codeChallenge = pkce.challenge
    )
)
// Redirect user to consent.consentUrl

// 2. Exchange code after redirect
val tokens = astro.openBanking.exchangeCode(
    code = params["code"]!!, redirectUri = "...", consentId = consent.consentId, codeVerifier = pkce.verifier
)

// 3. Fetch data
val accounts = astro.openBanking.getAccounts(tokens.accessToken, consent.consentId)
val txns = astro.openBanking.getTransactions(tokens.accessToken, consent.consentId, accounts[0].accountId)
```

## Credit & Finance target

Use server-side Kotlin for Credit & Finance orchestration when the deployment exposes the module. Customer acceptance still happens in hosted Astro UI, not inside merchant UI.

## License

UNLICENSED — Neptune Fintech internal SDK
