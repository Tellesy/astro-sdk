# @neptune.fintech/astro-react

React 18+ hooks and checkout components for Astro, built on `@neptune.fintech/astro-sdk` and `@neptune.fintech/astro-web`.

```bash
npm install @neptune.fintech/astro-react @neptune.fintech/astro-sdk
```

Use `CheckoutButton` or `useCheckout` with a server-created, scoped payment session. Merchant, bank, and admin keys stay on your backend; never put them in `NEXT_PUBLIC_*`, Vite client variables, or a browser bundle.

```tsx
import { CheckoutButton } from '@neptune.fintech/astro-react'

<CheckoutButton
  sessionId={sessionIdFromYourBackend}
  gatewayUrl="https://astro.neptune.ly"
  onSuccess={handleSuccess}
/>
```

For public alias resolution, configure `AstroProvider` with `baseUrl: 'https://astro.neptune.ly/api/v1'` and no credential. NPT availability and rename are bank-server operations and are intentionally not exposed as browser hooks.

Full documentation: https://neptune-ly.github.io/astro-sdk/sdks/react.html
