# @neptune.fintech/astro-web

Drop-in checkout widget for **Astro**, Neptune's OpenWave gateway. One function call opens a secure, branded, mobile-responsive authorization surface for one-time payments.

The widget only receives a scoped `sessionId`. Your backend owns session creation, merchant keys, webhook verification, and fulfilment.

## Usage

### Via CDN (script tag)

```html
<script src="https://cdn.neptune.ly/astro/v1/astro.umd.js"></script>
<script>
  Astro.checkout({
    sessionId: 'ops_01HZGV...',     // created by your backend
    gatewayUrl: 'https://astro.neptune.ly',
    onSuccess: (e) => {
      console.log('Paid!', e.session_id)
      window.location.href = '/orders/success'
    },
    onFailed: (e) => {
      alert('Payment failed: ' + e.message)
    },
    onDismiss: () => {
      console.log('Customer closed the widget')
    },
  })
</script>
```

### Via npm

```bash
npm install @neptune.fintech/astro-web
```

```ts
import { checkout } from '@neptune.fintech/astro-web'

checkout({
  sessionId: 'ops_01HZGV...',
  gatewayUrl: 'https://astro.neptune.ly',
  theme: 'auto',          // 'light' | 'dark' | 'auto'
  locale: 'en',           // 'en' | 'ar'
  onSuccess: (e) => redirect(e.receipt_url!),
  onFailed: (e) => showError(e.message),
})
```

## How It Works

1. **Your backend** creates a payment session via `POST /payments/initiate` and returns the `session_id` to your frontend
2. **You call `checkout({ sessionId })`** — the widget opens
3. **Customer enters their NPT alias or IBAN** — Astro resolves it with the gateway and identity registry
4. **Customer authenticates with bank SCA** — OTP or push approval is handled in the hosted surface
5. **Payment completes** — `onSuccess` fires and Astro sends a signed webhook to your backend

## Flow Diagram

```
Your page                  Widget                    Astro Gateway
    │                        │                             │
    │─ checkout({sessionId}) ┤                             │
    │                        │── POST /sessions/{id}/initiate ──►│
    │                        │◄── { amount, currency } ────│
    │                        │                             │
    │              [OTP input]│                             │
    │                        │── POST /sessions/{id}/confirm ───►│
    │                        │◄── { status: COMPLETED } ───│
    │◄── onSuccess(event) ───┤                             │
```

## Options

| Option | Type | Required | Description |
|---|---|:---:|---|
| `sessionId` | `string` | ✅ | Payment session ID from your backend |
| `gatewayUrl` | `string` | | Gateway base URL (default: empty — uses relative) |
| `theme` | `'light' \| 'dark' \| 'auto'` | | Widget theme (default: `auto`) |
| `locale` | `'en' \| 'ar'` | | Language (default: `en`) |
| `onSuccess` | `function` | | Called when payment completes |
| `onFailed` | `function` | | Called when payment fails or is rejected |
| `onDismiss` | `function` | | Called when customer closes the widget |

## Security

- **Never put API keys in the frontend** — the widget uses only the `session_id` (not sensitive)
- Session IDs are single-use and expire after 15 minutes
- All gateway communication is HTTPS
- Use your backend webhook as the source of truth for order fulfilment

## Presented Payments

This widget is also the correct secure surface after a QR or NFC presentment is claimed. The merchant page may render a QR code or expose an NFC handoff, but the customer should still land in the Astro-controlled authorization surface before the payment or mandate becomes final.

## Credit & Finance handoff

Finance assessment and offer creation stay on your backend. The frontend should receive only the hosted offer `acceptUrl` and open it in the Astro-controlled surface where the customer sees amount, tenor, disclosure, repayment schedule, and Murabaha terms where applicable.

## License

UNLICENSED — Copyright © Neptune Fintech
