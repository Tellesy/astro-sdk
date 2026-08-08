# astro_sdk — OpenWave Flutter/Dart SDK

Flutter/Dart SDK for OpenWave payments. Works in Flutter apps, pure Dart backend, and Dart CLI.

## Installation

```yaml
# pubspec.yaml
dependencies:
  astro_sdk:
    path: ../packages/astro-flutter  # local
    # OR once published:
    # astro_sdk: ^1.1.0
```

## Quick Start

```dart
import 'package:astro_sdk/astro_sdk.dart';

final astro = AstroClient(AstroConfig(
  baseUrl: 'https://astro.neptune.ly/api/v1',
  merchantKey: const String.fromEnvironment('ASTRO_KEY'),
));

// Create a payment session
final session = await astro.payments.createSession(
  amount: 50000,          // 50.000 LYD
  currency: 'LYD',
  destination: Destination(type: 'alias', value: 'mtellesy'),
  reference: 'order_1042',
  redirectUrl: 'https://myapp.com/result',
);

print('Checkout URL: ${session.checkoutUrl}');

// Resolve an alias
final resolved = await astro.identity.resolve('mtellesy');
print('Routes to bank: ${resolved.bankHandle}');
```

## Modules

| Client | Methods |
|---|---|
| `astro.payments` | `createSession`, `getSession`, `cancelSession`, `listSessions`, `createMandate` |
| `astro.alias` | `getProfile`, `getAccounts`, `resolve`, `deactivate`, `availability`, `rename` |
| `astro.openBanking` | `createConsent`, `exchangeCode`, `refreshToken`, `getAccounts`, `getTransactions` |
| Credit & Finance handoff | Open hosted offer acceptance URL returned by your backend |
| `astro.identity` | `resolve`, `listBanks`, `getBank` |
| `WebhookVerifier` | `verify`, `parse`, `handleRaw` |

## NPT availability and rename (bank backend only)

Do not configure a bank key or send a national ID from a customer Flutter build. Call these methods only from a trusted Dart backend or through your bank backend:

```dart
final bankAstro = AstroClient(AstroConfig(
  baseUrl: 'https://astro.neptune.ly/api/v1',
  bankKey: Platform.environment['OPENWAVE_BANK_KEY'],
));

final availability = await bankAstro.alias.availability('mtellesy.new');
if (availability.status == 'UNKNOWN') {
  throw StateError('Identity could not be consulted; do not attempt the rename');
}

final result = await bankAstro.alias.rename(const RenameAliasRequest(
  currentAliasUsername: 'mtellesy',
  newAliasUsername: 'mtellesy.new',
  nationalId: '123456789012',
));
// The bank backend must propagate this boundary to the authenticated app.
assert(result.previousRetired && result.reauthenticationRequired);
print(result.retiredHandle);
print(result.nextStep); // End old sessions; sign in again with the new NPT name.
```

## Flutter Payment Flow

```dart
// 1. On your backend: create session and get session_id
// 2. In Flutter: open checkout URL
final uri = Uri.parse(session.checkoutUrl);
await launchUrl(uri, mode: LaunchMode.externalApplication);

// 3. Handle deep link callback
// AndroidManifest / Info.plist: register your redirect_url scheme
// In your router:
if (uri.path == '/result') {
  final sessionId = uri.queryParameters['session_id'];
  final status = uri.queryParameters['status'];
  if (status == 'completed') {
    // Order fulfilled
  }
}
```

## Webhook Verification (Dart server / edge function)

```dart
final verifier = astro.webhookVerifier(
  const String.fromEnvironment('ASTRO_WEBHOOK_SECRET'),
);

// In your HTTP handler:
final body = await request.body;
final sig = request.headers['x-openwave-signature'] ?? '';

verifier.handleRaw(body, sig, {
  'payment.completed': (payload) {
    final ref = (payload['data'] as Map)['reference'];
    db.markPaid(ref);
  },
  'payment.failed': (payload) {
    // handle failure
  },
});
```

## Open Banking

```dart
// 1. Create consent (bank partner key required)
final consent = await astro.openBanking.createConsent(
  bankHandle: 'andalus',
  scopes: ['accounts:read', 'transactions:read'],
  redirectUri: 'myapp://ob/callback',
  state: generateState(),
  codeChallenge: pkce.challenge,
);

// 2. Open consent URL
await launchUrl(Uri.parse(consent.consentUrl));

// 3. Handle callback deep link, exchange code
final tokens = await astro.openBanking.exchangeCode(
  code: callbackParams['code']!,
  redirectUri: 'myapp://ob/callback',
  consentId: consent.consentId,
  codeVerifier: pkce.verifier,
);

// 4. Fetch accounts and transactions
final accounts = await astro.openBanking.getAccounts(
  tokens.accessToken, consent.consentId,
);
final txns = await astro.openBanking.getTransactions(
  tokens.accessToken, consent.consentId, accounts.first.accountId,
);
```

## Credit & Finance handoff

Flutter apps should not create finance assessments directly. Your backend creates the assessment and offer, then returns the hosted `accept_url`.

```dart
final acceptUrl = await merchantApi.createFinanceOffer(orderId);
await launchUrl(Uri.parse(acceptUrl), mode: LaunchMode.externalApplication);
```

## Error Handling

```dart
try {
  await astro.payments.createSession(...);
} on AstroError catch (e) {
  print('${e.statusCode}: [${e.code}] ${e.message}');
}
```

## License

UNLICENSED — Neptune Fintech internal SDK
