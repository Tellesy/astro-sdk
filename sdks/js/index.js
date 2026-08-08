// src/client.ts
var AstroRequestError = class extends Error {
  constructor(status, error) {
    super(error.message || `HTTP ${status}`);
    this.name = "AstroRequestError";
    this.status = status;
    this.code = error.code;
    this.detail = error.detail;
    this.requestId = error.request_id;
  }
};
var HttpClient = class {
  constructor(config) {
    this.baseUrl = config.baseUrl.replace(/\/$/, "");
    this.timeout = config.timeout ?? 3e4;
    this.defaultHeaders = { "Content-Type": "application/json" };
    if (config.merchantKey) {
      this.defaultHeaders["Authorization"] = `Bearer ${config.merchantKey}`;
    }
    if (config.bankKey) {
      this.defaultHeaders["X-OpenWave-Bank-Key"] = config.bankKey;
    }
    if (config.adminKey) {
      this.defaultHeaders["X-OpenWave-Admin-Key"] = config.adminKey;
    }
  }
  setMerchantKey(key) {
    this.defaultHeaders["Authorization"] = `Bearer ${key}`;
    delete this.defaultHeaders["X-OpenWave-Bank-Key"];
    delete this.defaultHeaders["X-OpenWave-Admin-Key"];
  }
  setBankKey(key) {
    this.defaultHeaders["X-OpenWave-Bank-Key"] = key;
    delete this.defaultHeaders["Authorization"];
    delete this.defaultHeaders["X-OpenWave-Admin-Key"];
  }
  setAdminKey(key) {
    this.defaultHeaders["X-OpenWave-Admin-Key"] = key;
    delete this.defaultHeaders["Authorization"];
    delete this.defaultHeaders["X-OpenWave-Bank-Key"];
  }
  setSessionToken(token) {
    this.defaultHeaders["X-Session-Token"] = token;
  }
  clearSessionToken() {
    delete this.defaultHeaders["X-Session-Token"];
  }
  async request(method, path, body, extraHeaders) {
    const url = `${this.baseUrl}${path}`;
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), this.timeout);
    try {
      const res = await fetch(url, {
        method,
        headers: { ...this.defaultHeaders, ...extraHeaders },
        body: body !== void 0 ? JSON.stringify(body) : void 0,
        signal: controller.signal
      });
      const json = await res.json().catch(() => ({}));
      if (!res.ok) {
        const j = json;
        const raw = j?.error ?? (j?.code || j?.message ? j : null);
        const errBody = typeof raw === "string" ? { code: `HTTP_${res.status}`, message: raw } : {
          code: raw?.code ?? `HTTP_${res.status}`,
          message: raw?.message ?? raw?.error ?? `HTTP ${res.status}`,
          detail: raw?.detail,
          request_id: raw?.request_id
        };
        throw new AstroRequestError(res.status, errBody);
      }
      return json;
    } finally {
      clearTimeout(timer);
    }
  }
  get(path, params, headers) {
    const url = params ? path + "?" + new URLSearchParams(
      Object.entries(params).filter(([, v]) => v !== void 0).map(([k, v]) => [k, String(v)])
    ).toString() : path;
    return this.request("GET", url, void 0, headers);
  }
  post(path, body, headers) {
    return this.request("POST", path, body, headers);
  }
  patch(path, body) {
    return this.request("PATCH", path, body);
  }
  delete(path) {
    return this.request("DELETE", path);
  }
};

// src/payments/index.ts
var PaymentsClient = class {
  constructor(http) {
    this.http = http;
  }
  async createSession(params, options = {}) {
    return this.http.post(
      "/payments/initiate",
      params,
      idempotencyHeaders(options)
    );
  }
  async getSession(sessionId) {
    return this.http.get(`/payments/${sessionId}`);
  }
  async listSessions(params) {
    return this.http.get("/payments", params);
  }
  async previewFee(bankHandle, amount) {
    return this.http.get("/payments/fee", { bankHandle, amount });
  }
  async cancelSession(sessionId) {
    return this.http.post(`/payments/${sessionId}/cancel`);
  }
  async createRefund(sessionId, params, options = {}) {
    return this.http.post(
      `/payments/${sessionId}/refunds`,
      params,
      idempotencyHeaders(options)
    );
  }
  async listRefunds(sessionId) {
    return this.http.get(`/payments/${sessionId}/refunds`);
  }
  async getRefund(refundId) {
    return this.http.get(`/payments/refunds/${refundId}`);
  }
  async createMandate(params, options = {}) {
    return this.http.post(
      "/recurring/mandates",
      params,
      idempotencyHeaders(options)
    );
  }
  async listMandates(params) {
    return this.http.get("/recurring/mandates", params);
  }
  async getMandate(mandateId) {
    return this.http.get(`/recurring/mandates/${mandateId}`);
  }
  async cancelMandate(mandateId) {
    return this.http.delete(`/recurring/mandates/${mandateId}`);
  }
  async chargeMandate(mandateId, params, options = {}) {
    return this.http.post(
      `/recurring/mandates/${mandateId}/charge`,
      params,
      idempotencyHeaders(options)
    );
  }
  async listMandateCharges(mandateId, params) {
    return this.http.get(
      `/recurring/mandates/${mandateId}/charges`,
      params
    );
  }
};
function idempotencyHeaders(options) {
  return options.idempotencyKey ? { "Idempotency-Key": options.idempotencyKey } : void 0;
}

// src/checkout/index.ts
var CheckoutClient = class {
  constructor(http) {
    this.http = http;
  }
  sessionHeaders(sessionToken) {
    return sessionToken ? { "X-Session-Token": sessionToken } : void 0;
  }
  /**
   * Resolve payer identity from alias or IBAN.
   * Returns masked phone + available accounts for the customer to select from.
   */
  async resolvePayer(sessionId, params, sessionToken) {
    return this.http.post(
      `/session/${sessionId}/resolve-payer`,
      params,
      this.sessionHeaders(sessionToken)
    );
  }
  /**
   * Customer selects authentication method (OTP or PUSH).
   * The bank will send an OTP SMS or push notification.
   */
  async selectAuth(sessionId, params, sessionToken) {
    return this.http.post(
      `/session/${sessionId}/select-auth`,
      params,
      this.sessionHeaders(sessionToken)
    );
  }
  /**
   * Customer confirms payment with OTP code or push approval.
   * On success returns COMPLETED status and the bank transfer reference.
   */
  async confirm(sessionId, params, sessionToken) {
    return this.http.post(
      `/session/${sessionId}/confirm-otp`,
      params,
      this.sessionHeaders(sessionToken)
    );
  }
};

// src/alias/index.ts
var AliasClient = class {
  constructor(http) {
    this.http = http;
  }
  async get(username) {
    return this.http.get(`/alias/${encodeURIComponent(username)}`);
  }
  async getAccounts(username) {
    return this.http.get(
      `/alias/${encodeURIComponent(username)}/accounts`
    );
  }
  async deactivate(username) {
    return this.http.delete(`/alias/${encodeURIComponent(username)}`);
  }
  /** Bank-server only. UNKNOWN means Identity could not be consulted; never treat it as available. */
  async availability(username) {
    return this.http.get(
      `/alias/${encodeURIComponent(username)}/availability`
    );
  }
  /** Bank-server only. A successful rename permanently retires the previous NPT name. */
  async rename(params) {
    return this.http.patch("/alias/rename", params);
  }
  async resolve(alias) {
    return this.http.get(`/identity/resolve`, { alias });
  }
};

// src/openbanking/index.ts
var OpenBankingClient = class {
  constructor(http) {
    this.http = http;
  }
  async getBankCapabilities(bankHandle) {
    return this.http.get(`/banks/${bankHandle}/capabilities`);
  }
  async createConsent(params) {
    return this.http.post("/ob/consents", params);
  }
  async getConsent(consentId) {
    return this.http.get(`/ob/consents/${consentId}`);
  }
  async revokeConsent(consentId) {
    return this.http.delete(`/ob/consents/${consentId}`);
  }
  async exchangeCode(params) {
    return this.http.post("/ob/token", {
      grant_type: "authorization_code",
      ...params
    });
  }
  async refreshToken(params) {
    return this.http.post("/ob/token", {
      grant_type: "refresh_token",
      ...params
    });
  }
  async revokeToken(token) {
    return this.http.post("/ob/token/revoke", { token });
  }
  async getAccounts(consentId) {
    return this.http.get("/ob/accounts", void 0, consentHeaders(consentId));
  }
  async getBalances(accountId, consentId) {
    return this.http.get(`/ob/accounts/${accountId}/balances`, void 0, consentHeaders(consentId));
  }
  async getTransactions(accountId, consentId, params) {
    return this.http.get(
      `/ob/accounts/${accountId}/transactions`,
      params,
      consentHeaders(consentId)
    );
  }
  async createPaymentOrder(params, consentId) {
    return this.http.post("/ob/payment-orders", params, {
      "X-Consent-Id": consentId
    });
  }
  async getPaymentOrder(orderId) {
    return this.http.get(`/ob/payment-orders/${orderId}`);
  }
};
function consentHeaders(consentId) {
  return { "X-Consent-Id": consentId };
}

// src/identity/index.ts
var IdentityClient = class {
  constructor(http) {
    this.http = http;
  }
  async resolve(alias) {
    return this.http.get("/identity/resolve", { alias });
  }
  async getProfile(handle) {
    return this.http.get(`/identity/${encodeURIComponent(handle)}`);
  }
  async claimHandle(params) {
    return this.http.post("/identity/claim", params);
  }
  async getAccounts(handle) {
    return this.http.get(`/identity/${encodeURIComponent(handle)}/accounts`);
  }
  async linkAccount(handle, params) {
    return this.http.post(`/identity/${encodeURIComponent(handle)}/accounts`, params);
  }
  async setDefaultAccount(handle, bankHandle) {
    return this.http.patch(`/identity/${encodeURIComponent(handle)}/default`, {
      bank_handle: bankHandle
    });
  }
  async deleteIdentity(handle) {
    return this.http.delete(`/identity/${encodeURIComponent(handle)}`);
  }
  async listBanks() {
    return this.http.get("/banks");
  }
  async getRegistryInfo() {
    return this.http.get("/registry/info");
  }
};

// src/presentments/index.ts
var PresentmentsClient = class {
  constructor(http) {
    this.http = http;
  }
  async capabilities() {
    return this.http.get("/capabilities");
  }
  async create(params, options = {}) {
    return this.http.post(
      "/presentments",
      params,
      options.idempotencyKey ? { "Idempotency-Key": options.idempotencyKey } : void 0
    );
  }
  async get(presentmentId) {
    return this.http.get(`/presentments/${presentmentId}`);
  }
  async list(params) {
    return this.http.get("/presentments", params);
  }
  async claim(presentmentId, params) {
    return this.http.post(`/presentments/${presentmentId}/claim`, params);
  }
  async cancel(presentmentId) {
    return this.http.post(`/presentments/${presentmentId}/cancel`);
  }
  async status(presentmentId) {
    return this.http.get(`/presentments/${presentmentId}/status`);
  }
};

// src/finance/index.ts
var FinanceAssessmentsClient = class {
  constructor(http) {
    this.http = http;
  }
  async create(params) {
    return this.http.post("/credit/assessments", params);
  }
  async list() {
    return this.http.get("/credit/assessments");
  }
  async get(assessmentId) {
    return this.http.get(`/credit/assessments/${assessmentId}`);
  }
  async refresh(assessmentId, params = {}) {
    return this.http.post(`/credit/assessments/${assessmentId}/refresh`, params);
  }
  async revoke(assessmentId) {
    return this.http.delete(`/credit/assessments/${assessmentId}`);
  }
};
var FinanceOffersClient = class {
  constructor(http) {
    this.http = http;
  }
  async create(params) {
    return this.http.post("/finance/offers", params);
  }
  async list() {
    return this.http.get("/finance/offers");
  }
  async get(offerId) {
    return this.http.get(`/finance/offers/${offerId}`);
  }
  async accept(offerId, financeSessionToken, params = {}) {
    return this.http.post(
      `/finance/offers/${offerId}/accept`,
      params,
      { "X-OpenWave-Finance-Session": financeSessionToken }
    );
  }
};
var FinanceContractsClient = class {
  constructor(http) {
    this.http = http;
  }
  async get(contractId) {
    return this.http.get(`/finance/contracts/${contractId}`);
  }
  async repaymentSchedule(contractId) {
    return this.http.get(`/finance/contracts/${contractId}/repayment-schedule`);
  }
  async cancel(contractId) {
    return this.http.post(`/finance/contracts/${contractId}/cancel`);
  }
};
var FinanceClient = class {
  constructor(http) {
    this.http = http;
    this.assessments = new FinanceAssessmentsClient(http);
    this.offers = new FinanceOffersClient(http);
    this.contracts = new FinanceContractsClient(http);
  }
  async capabilities() {
    return this.http.get("/finance/capabilities");
  }
};

// src/webhooks/index.ts
async function hmacSha256(secret, data) {
  if (typeof crypto !== "undefined" && crypto.subtle) {
    const enc = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      enc.encode(secret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );
    const sig = await crypto.subtle.sign("HMAC", key, enc.encode(data));
    return Array.from(new Uint8Array(sig)).map((b) => b.toString(16).padStart(2, "0")).join("");
  }
  const { createHmac } = await import("crypto");
  return createHmac("sha256", secret).update(data).digest("hex");
}
async function verifyWebhookSignature(rawBody, signature, secret) {
  const expected = await hmacSha256(secret, rawBody);
  const actual = normalizeSignature(signature);
  return timingSafeEqualHex(actual, expected);
}
function parseWebhookPayload(rawBody) {
  return JSON.parse(rawBody);
}
function normalizeSignature(signature) {
  const trimmed = signature.trim();
  if (trimmed.startsWith("sha256=")) return trimmed.slice("sha256=".length);
  if (trimmed.startsWith("v1=")) return trimmed.slice("v1=".length);
  return trimmed;
}
async function timingSafeEqualHex(actual, expected) {
  if (!/^[0-9a-f]+$/i.test(actual) || !/^[0-9a-f]+$/i.test(expected) || actual.length !== expected.length) {
    return false;
  }
  if (typeof process !== "undefined" && process.versions?.node) {
    const { timingSafeEqual } = await import("crypto");
    return timingSafeEqual(Buffer.from(actual, "hex"), Buffer.from(expected, "hex"));
  }
  let diff = 0;
  for (let i = 0; i < expected.length; i++) {
    diff |= expected.charCodeAt(i) ^ actual.charCodeAt(i);
  }
  return diff === 0;
}
var WebhookReceiver = class {
  constructor(secret) {
    this.handlers = /* @__PURE__ */ new Map();
    this.secret = secret;
  }
  on(event, handler) {
    const existing = this.handlers.get(event) ?? [];
    existing.push(handler);
    this.handlers.set(event, existing);
    return this;
  }
  async handle(rawBody, signature) {
    const valid = await verifyWebhookSignature(rawBody, signature, this.secret);
    if (!valid) throw new Error("Invalid webhook signature");
    const payload = parseWebhookPayload(rawBody);
    const handlers = [
      ...this.handlers.get(payload.event) ?? [],
      ...this.handlers.get("*") ?? []
    ];
    await Promise.all(handlers.map((h) => h(payload)));
  }
};

// src/index.ts
var AstroClient = class {
  constructor(config) {
    this.http = new HttpClient(config);
    this.payments = new PaymentsClient(this.http);
    this.checkout = new CheckoutClient(this.http);
    this.alias = new AliasClient(this.http);
    this.openBanking = new OpenBankingClient(this.http);
    this.identity = new IdentityClient(this.http);
    this.presentments = new PresentmentsClient(this.http);
    this.finance = new FinanceClient(this.http);
  }
};
function createClient(config) {
  return new AstroClient(config);
}
function createCheckoutClient(opts) {
  const http = new HttpClient({ baseUrl: opts.baseUrl, timeout: opts.timeout });
  if (opts.sessionToken) http.setSessionToken(opts.sessionToken);
  return new CheckoutClient(http);
}
export {
  AliasClient,
  AstroClient,
  AstroRequestError,
  CheckoutClient,
  FinanceClient,
  HttpClient,
  IdentityClient,
  OpenBankingClient,
  PaymentsClient,
  PresentmentsClient,
  WebhookReceiver,
  createCheckoutClient,
  createClient,
  parseWebhookPayload,
  verifyWebhookSignature
};
