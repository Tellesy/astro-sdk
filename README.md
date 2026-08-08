<div align="center">

<img src="./docs/neptune-logo.png" alt="Neptune. Financial Technology And Solutions" width="520">

# Astro SDK

</div>

Official SDKs for **Neptune. Astro**, the OpenWave gateway implementation by Neptune Fintech.

**Docs:** https://neptune-ly.github.io/astro-sdk/

---

## SDKs

| SDK | Language | Install |
|---|---|---|
| [`sdks/js`](./sdks/js) | TypeScript / Node.js 18+ | `npm install @neptune.fintech/astro-sdk` |
| [`sdks/react`](./sdks/react) | React 18+ | `npm install @neptune.fintech/astro-react` |
| [`sdks/web`](./sdks/web) | Browser drop-in | `<script src="astro.js">` |
| [`sdks/flutter`](./sdks/flutter) | Flutter / Dart 3+ | pub.dev / git |
| [`sdks/kotlin`](./sdks/kotlin) | Kotlin / JVM | Gradle |
| [`sdks/swift`](./sdks/swift) | Swift / iOS 15+ | Swift Package Manager |

## Quick Install

### TypeScript / Node.js
```bash
npm install @neptune.fintech/astro-sdk
```

### Flutter
```yaml
dependencies:
  astro_sdk:
    git:
      url: https://github.com/neptune-ly/astro-sdk.git
      path: sdks/flutter
```

### Swift (SPM, local package)
```swift
// Package.swift
.package(path: "../astro-sdk/sdks/swift")
```

The Swift package currently lives under `sdks/swift`; clone this monorepo and add that directory locally. The repository root is not a Swift package manifest.

All API clients use an Astro base URL ending in `/api/v1`, for example `https://astro.neptune.ly/api/v1`. SDK method paths are relative to that prefix.

## NPT lifecycle ownership

OpenWave Identity is authoritative for NPT ownership, permanent retirement, and login-approval challenges. Astro provides public resolution plus bank-server availability and rename methods. `UNKNOWN` availability means Identity could not be consulted and must never be treated as free. A successful rename exposes `retired_handle`, `previous_retired: true`, `reauthentication_required: true`, and Identity's `next_step`; end old-handle sessions and require sign-in with the new NPT name before continuing.

Keep bank keys and national IDs on bank servers. Astro does not duplicate Identity login approvals, and browser/mobile packages intentionally do not expose rename UI hooks.

### Kotlin (Gradle)
```kotlin
dependencies {
    implementation("ly.neptune.astro:astro-kotlin:1.1.0")
}
```

## OpenWave Standard

Built on the [OpenWave](https://neptune-ly.github.io/openwave-spec/) open payment standard.

## Sandbox, Live, and Branding

Production integrations must keep sandbox and live traffic separated at the backend: different merchant keys, webhook secrets, redirect origins, callback URLs, and reconciliation targets. Browser and mobile SDKs receive only a scoped session, hosted URL, or presentment claim result.

Astro-hosted checkout and consent surfaces can render approved merchant, bank, TPP, and gateway branding from server-returned metadata such as display name, logo URL, brand color, support email, website, and environment. Merchant apps may display that approved metadata beside checkout buttons or QR/NFC presentments, but fulfilment still waits for signed final webhooks or trusted server status.

See the [Astro SDK production readiness guide](https://neptune-ly.github.io/astro-sdk/guide/production-readiness.html) and the [OpenWave production readiness guide](https://neptune-ly.github.io/openwave-spec/guide/production-readiness.html).

## Credit & Finance

The SDK documentation now covers OpenWave **Credit & Finance** targets:

- credit-assessment consent scopes
- BNPL installment offers
- revolving-credit drawdown handoff
- Murabaha installment disclosures
- hosted offer acceptance
- finance contract and repayment webhook events

Finance assessment and offer creation are server-side operations. Browser and mobile SDKs should only open hosted acceptance URLs returned by trusted backends.

## Presented Payments

The SDK surface now includes the implementation rules for OpenWave **presented payments**:

- merchant-presented QR
- merchant-presented NFC
- merchant-presented app handoff
- presented recurring mandate approval

These SDKs do not move OTP, PIN, or push approval into merchant UI. Scan or tap only starts the flow. Final customer authorization still happens in the hosted or secure SDK surface defined by OpenWave.

For Libya QR interoperability, OpenWave QR uses the normal EMV TLV container instead of a separate proprietary QR format. The default OpenWave template is Merchant Account Information tag `26` with `26.00 = LY.OPENWAVE`, `26.01 = presentment_id`, `26.02 = claim_token`, `26.03 = QR`, and `26.04 = P` for payment or `M` for mandate approval. Optional operator metadata uses tag `50` with `50.00 = LY.OPENWAVE.OP` and `50.01 = operator_id`. Existing NUMO/LYPay QR codes keep their current route; scanners route to OpenWave only when the `LY.OPENWAVE` GUI is present.

NFC uses an NFC Forum NDEF URI record, preferably an HTTPS universal/app link to the same presentment claim resource. Android and iOS apps can scan/tap first, but they must open the claim-returned hosted, SDK, bank-app, or wallet-controlled authorization surface before approval.

For recurring mandate approval, the claim response should use `auth_surface.type = "HOSTED_MANDATE_CONSENT"` or return `mandate_consent_url`.

Fulfilment must stay server-side. Merchant backends should fulfil orders or activate subscriptions only after verifying a signed final event, normally `payment.completed`; frontend redirects, mobile callbacks, and `payment.settlement_pending` are not fulfilment proof.

Banks and wallets can also implement the same presented-payment channel directly when their operator enables it. The SDK guides below describe both the gateway-mediated and direct-operator models.

## License

SDK artifacts are provided for integration use. Source code is proprietary — © Neptune Fintech.
