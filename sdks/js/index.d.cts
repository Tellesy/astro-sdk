type Currency = 'LYD' | 'USD' | 'EUR' | 'GBP' | string;
type PaymentStatus = 'PENDING' | 'OTP_SENT' | 'PUSH_SENT' | 'PROCESSING' | 'SETTLEMENT_PENDING' | 'RECONCILIATION_REQUIRED' | 'CONFIRMED' | 'COMPLETED' | 'FAILED' | 'EXPIRED' | 'CANCELLED';
type MandateStatus = 'PENDING_CONSENT' | 'ACTIVE' | 'PAUSED' | 'CANCELLED' | 'EXPIRED';
type ConsentStatus = 'PENDING' | 'ACTIVE' | 'REVOKED' | 'EXPIRED';
type PaymentOrderStatus = 'PENDING' | 'COMPLETED' | 'FAILED' | 'REJECTED' | 'PENDING_SCA';
interface Destination {
    type: 'iban' | 'alias';
    value: string;
}
interface Pagination {
    next_cursor?: string;
    has_more: boolean;
}
interface AstroConfig {
    baseUrl: string;
    merchantKey?: string;
    bankKey?: string;
    adminKey?: string;
    timeout?: number;
}
interface AstroError {
    code: string;
    message: string;
    detail?: string;
    request_id?: string;
}
type WebhookEvent = 'payment.completed' | 'payment.settlement_pending' | 'payment.reconciliation_required' | 'payment.failed' | 'payment.expired' | 'refund.created' | 'refund.processing' | 'refund.completed' | 'refund.failed' | 'mandate.activated' | 'mandate.cancelled' | 'mandate.charge.completed' | 'mandate.charge.failed' | 'consent.granted' | 'consent.revoked' | 'consent.expired' | 'payment_order.completed' | 'payment_order.failed' | 'payment_order.pending_sca' | 'payment_order.rejected' | 'presentment.created' | 'presentment.claimed' | 'presentment.expired' | 'presentment.cancelled' | 'credit_assessment.completed' | 'finance_offer.created' | 'finance_offer.accepted' | 'finance_contract.active' | 'finance_contract.cancelled' | 'finance_contract.failed' | 'repayment.completed' | 'repayment.failed';
interface WebhookPayload<T = unknown> {
    id?: string;
    event_id?: string;
    event: WebhookEvent;
    api_version: string;
    timestamp: string;
    data: T;
}

declare class AstroRequestError extends Error {
    readonly code: string;
    readonly detail?: string;
    readonly requestId?: string;
    readonly status: number;
    constructor(status: number, error: AstroError);
}
declare class HttpClient {
    private baseUrl;
    private defaultHeaders;
    private timeout;
    constructor(config: AstroConfig);
    setMerchantKey(key: string): void;
    setBankKey(key: string): void;
    setAdminKey(key: string): void;
    setSessionToken(token: string): void;
    clearSessionToken(): void;
    request<T>(method: string, path: string, body?: unknown, extraHeaders?: Record<string, string>): Promise<T>;
    get<T>(path: string, params?: Record<string, string | number | undefined>, headers?: Record<string, string>): Promise<T>;
    post<T>(path: string, body?: unknown, headers?: Record<string, string>): Promise<T>;
    patch<T>(path: string, body?: unknown): Promise<T>;
    delete<T>(path: string): Promise<T>;
}

interface CreateSessionParams {
    payer_alias?: string;
    payer_iban?: string;
    amount: number;
    currency: Currency;
    destination?: Destination;
    description?: string;
    reference?: string;
    merchant_reference?: string;
    redirect_url?: string;
    cancel_url?: string;
    webhook_url?: string;
    metadata?: Record<string, string>;
}
interface WriteOptions {
    idempotencyKey?: string;
}
interface FeePreview {
    bank_handle: string;
    gross_amount: number;
    gateway_fee: number;
    bank_cut: number;
    net_amount: number;
    fee_type: string;
    fee_value: number;
    flat_fee: number;
}
interface PaymentSession {
    session_id: string;
    status: PaymentStatus;
    amount: number;
    currency: Currency;
    destination?: Destination | null;
    description?: string;
    reference?: string;
    merchant_reference?: string;
    checkout_url: string;
    payment_url?: string;
    checkout_session_token?: string;
    redirect_url?: string;
    transfer_reference?: string;
    settlement_type?: string;
    lypay_ref?: string;
    creditor_bank_handle?: string;
    settlement_pending_at?: string;
    error_code?: string;
    error_message?: string;
    created_at: string;
    expires_at: string;
    confirmed_at?: string;
    completed_at?: string;
    gateway_fee?: number;
    metadata?: unknown;
}
interface ListSessionsParams {
    status?: PaymentStatus;
    limit?: number;
    cursor?: string;
    from_date?: string;
    to_date?: string;
}
interface ListSessionsResponse {
    sessions: PaymentSession[];
    pagination: Pagination;
}
interface ListMandatesParams {
    status?: string;
    page?: number;
    limit?: number;
}
interface CreateMandateParams {
    payer_alias?: string;
    payer_iban?: string;
    amount_limit?: number;
    frequency?: 'ON_DEMAND' | 'DAILY' | 'WEEKLY' | 'MONTHLY' | string;
    consent_redirect_url?: string;
    merchant_reference?: string;
    metadata?: Record<string, unknown>;
    /**
     * Legacy aliases retained for older integrations.
     */
    customer_alias?: string;
    amount?: number;
    currency: Currency;
    interval?: 'daily' | 'weekly' | 'monthly' | 'yearly';
    description: string;
    start_date?: string;
    end_date?: string;
    max_amount?: number;
    webhook_url?: string;
}
interface Mandate {
    mandate_id: string;
    status: string;
    payer_alias?: string;
    amount_limit?: number;
    frequency?: string;
    consent_url?: string;
    consented_at?: string;
    cancelled_at?: string;
    cancelled_by?: string;
    merchant_reference?: string;
    /**
     * Legacy aliases retained for older integrations.
     */
    customer_alias?: string;
    amount?: number;
    currency: Currency;
    interval?: string;
    description: string;
    start_date?: string;
    end_date?: string;
    created_at: string;
}
interface ChargeMandateParams {
    amount: number;
    description: string;
    merchant_reference?: string;
    /**
     * Legacy alias retained for older integrations.
     */
    reference?: string;
}
interface MandateCharge {
    charge_id: string;
    mandate_id: string;
    status: string;
    amount: number;
    currency: Currency;
    description?: string;
    merchant_reference?: string;
    error_code?: string;
    error_message?: string;
    created_at: string;
    executed_at?: string;
}
interface ListMandatesResponse {
    data: Mandate[];
    total: number;
    page?: number;
    limit?: number;
}
interface ListMandateChargesResponse {
    data: MandateCharge[];
    total: number;
    page?: number;
    limit?: number;
}
interface CreateRefundParams {
    amount: number;
    currency: Currency;
    reason?: string;
    merchant_reference: string;
    metadata?: Record<string, unknown>;
}
interface RefundListResponse {
    data: Refund[];
    total: number;
    page?: number;
    limit?: number;
}
interface Refund {
    refund_id: string;
    session_id: string;
    status: 'CREATED' | 'PROCESSING' | 'COMPLETED' | 'FAILED' | string;
    amount: number;
    currency: Currency;
    merchant_reference?: string;
    reason?: string;
    rail?: string;
    reversal_reference?: string;
    failure_reason?: string;
    failure_message?: string;
    created_at: string;
    processing_at?: string;
    completed_at?: string;
    failed_at?: string;
}
declare class PaymentsClient {
    private http;
    constructor(http: HttpClient);
    createSession(params: CreateSessionParams, options?: WriteOptions): Promise<PaymentSession>;
    getSession(sessionId: string): Promise<PaymentSession>;
    listSessions(params?: ListSessionsParams): Promise<ListSessionsResponse>;
    previewFee(bankHandle: string, amount: number): Promise<FeePreview>;
    cancelSession(sessionId: string): Promise<void>;
    createRefund(sessionId: string, params: CreateRefundParams, options?: WriteOptions): Promise<Refund>;
    listRefunds(sessionId: string): Promise<RefundListResponse>;
    getRefund(refundId: string): Promise<Refund>;
    createMandate(params: CreateMandateParams, options?: WriteOptions): Promise<Mandate>;
    listMandates(params?: ListMandatesParams): Promise<ListMandatesResponse>;
    getMandate(mandateId: string): Promise<Mandate>;
    cancelMandate(mandateId: string): Promise<Mandate>;
    chargeMandate(mandateId: string, params: ChargeMandateParams, options?: WriteOptions): Promise<MandateCharge>;
    listMandateCharges(mandateId: string, params?: {
        page?: number;
        limit?: number;
    }): Promise<ListMandateChargesResponse>;
}

/**
 * CheckoutClient — customer-facing session flow.
 *
 * This client is used exclusively by the hosted checkout page (astro-ui)
 * and the official astro-web-sdk embedded checkout. It uses X-Session-Token
 * for authentication, NOT a merchant API key.
 *
 * These endpoints are BLOCKED for merchant API keys by the CheckoutGuardFilter
 * on the server. Merchants can only create sessions and poll status.
 */
interface ResolvePayerParams {
    payer_alias?: string;
    payer_iban?: string;
}
interface ResolvePayerResult {
    resolved: boolean;
    bank_handle: string;
    bank_name: string;
    account_name_masked?: string;
    iban_masked: string;
    auth_modes: string[];
}
interface SelectAuthParams {
    auth_mode: 'OTP' | 'PUSH';
}
interface SelectAuthResult {
    auth_mode: 'OTP' | 'PUSH';
    phone_masked?: string;
    otp_expires_in_seconds?: number;
    push_sent_to?: string;
}
interface ConfirmParams {
    otp_code?: string;
    push_id?: string;
}
interface ConfirmResult {
    status: string;
    transfer_ref?: string;
    redirect_url?: string;
    message?: string;
}
declare class CheckoutClient {
    private http;
    constructor(http: HttpClient);
    private sessionHeaders;
    /**
     * Resolve payer identity from alias or IBAN.
     * Returns masked phone + available accounts for the customer to select from.
     */
    resolvePayer(sessionId: string, params: ResolvePayerParams, sessionToken?: string): Promise<ResolvePayerResult>;
    /**
     * Customer selects authentication method (OTP or PUSH).
     * The bank will send an OTP SMS or push notification.
     */
    selectAuth(sessionId: string, params: SelectAuthParams, sessionToken?: string): Promise<SelectAuthResult>;
    /**
     * Customer confirms payment with OTP code or push approval.
     * On success returns COMPLETED status and the bank transfer reference.
     */
    confirm(sessionId: string, params: ConfirmParams, sessionToken?: string): Promise<ConfirmResult>;
}

interface AliasProfile {
    alias_username: string;
    is_active: boolean;
    bank_handle: string;
    customer_id?: string;
    created_at: string;
}
interface LinkedAccount {
    iban: string;
    currency: Currency;
    account_name?: string;
    bank_handle: string;
    is_default: boolean;
}
interface AliasAccountsResponse {
    alias_username: string;
    accounts: LinkedAccount[];
}
type AliasAvailabilityStatus = 'AVAILABLE' | 'TAKEN' | 'RETIRED' | 'INVALID' | 'UNKNOWN';
interface AliasAvailability {
    alias_username: string;
    status: AliasAvailabilityStatus;
    available: boolean;
}
interface RenameAliasParams {
    current_alias_username: string;
    new_alias_username: string;
    national_id: string;
}
interface RenameAliasResult {
    alias_username: string;
    previous_alias_username: string;
    retired_handle: string;
    previous_retired: true;
    reauthentication_required: true;
    next_step: string;
    message: string;
}
declare class AliasClient {
    private http;
    constructor(http: HttpClient);
    get(username: string): Promise<AliasProfile>;
    getAccounts(username: string): Promise<AliasAccountsResponse>;
    deactivate(username: string): Promise<void>;
    /** Bank-server only. UNKNOWN means Identity could not be consulted; never treat it as available. */
    availability(username: string): Promise<AliasAvailability>;
    /** Bank-server only. A successful rename permanently retires the previous NPT name. */
    rename(params: RenameAliasParams): Promise<RenameAliasResult>;
    resolve(alias: string): Promise<{
        iban: string;
        bank_handle: string;
        currency: Currency;
    }>;
}

type OBScope = 'accounts:read' | 'balances:read' | 'transactions:read' | 'payments:write';
interface CreateConsentParams {
    bank_handle: string;
    scopes: OBScope[];
    redirect_uri: string;
    state: string;
    code_challenge: string;
    code_challenge_method: 'S256';
    expiry_days?: number;
}
interface Consent {
    consent_id: string;
    status: ConsentStatus;
    bank_handle: string;
    scopes: OBScope[];
    redirect_uri: string;
    consent_url: string;
    created_at: string;
    expires_at: string;
}
interface TokenResponse {
    access_token: string;
    refresh_token: string;
    token_type: 'Bearer';
    expires_in: number;
    scope: string;
}
interface OBAccount {
    account_id: string;
    iban: string;
    currency: Currency;
    account_type: 'CURRENT' | 'SAVINGS' | string;
    display_name?: string;
}
interface OBBalance {
    account_id: string;
    available: number;
    current: number;
    currency: Currency;
    as_of: string;
}
interface OBTransaction {
    transaction_id: string;
    amount: number;
    currency: Currency;
    direction: 'DEBIT' | 'CREDIT';
    narrative?: string;
    reference?: string;
    value_date: string;
    booking_date: string;
}
interface OBTransactionsResponse {
    account_id: string;
    transactions: OBTransaction[];
}
interface CreatePaymentOrderParams {
    source_account_id: string;
    destination: Destination;
    amount: number;
    currency: Currency;
    description?: string;
    reference?: string;
}
interface PaymentOrder {
    order_id: string;
    status: PaymentOrderStatus;
    amount: number;
    currency: Currency;
    destination: Destination;
    description?: string;
    reference?: string;
    sca_url?: string;
    created_at: string;
}
interface BankCapabilities {
    bank_handle: string;
    ob_enabled: boolean;
    ob_scopes_supported: OBScope[];
    sca_exemption_limit: number;
    max_consent_expiry_days: number;
}
declare class OpenBankingClient {
    private http;
    constructor(http: HttpClient);
    getBankCapabilities(bankHandle: string): Promise<BankCapabilities>;
    createConsent(params: CreateConsentParams): Promise<Consent>;
    getConsent(consentId: string): Promise<Consent>;
    revokeConsent(consentId: string): Promise<void>;
    exchangeCode(params: {
        code: string;
        redirect_uri: string;
        consent_id: string;
        code_verifier: string;
    }): Promise<TokenResponse>;
    refreshToken(params: {
        refresh_token: string;
        consent_id: string;
    }): Promise<TokenResponse>;
    revokeToken(token: string): Promise<void>;
    getAccounts(consentId: string): Promise<{
        accounts: OBAccount[];
    }>;
    getBalances(accountId: string, consentId: string): Promise<OBBalance>;
    getTransactions(accountId: string, consentId: string, params?: {
        fromDate?: string;
        toDate?: string;
        count?: number;
    }): Promise<OBTransactionsResponse>;
    createPaymentOrder(params: CreatePaymentOrderParams, consentId: string): Promise<PaymentOrder>;
    getPaymentOrder(orderId: string): Promise<PaymentOrder>;
}

interface IdentityProfile {
    npt_handle: string;
    customer_display_name: string;
    default_bank_handle: string;
    default_iban: string;
    created_at: string;
}
interface IdentityAccount {
    bank_handle: string;
    iban: string;
    currency: Currency;
    is_default: boolean;
    linked_at: string;
}
interface ClaimHandleParams {
    npt_handle: string;
    iban: string;
    customer_display_name: string;
    bank_customer_ref: string;
}
interface ResolveResult {
    npt_handle: string;
    iban: string;
    bank_handle: string;
    currency: Currency;
}
interface BankEntry {
    bank_handle: string;
    display_name: string;
    country: string;
    ob_enabled: boolean;
}
interface RegistryInfo {
    operator: string;
    source_url: string;
    version: string;
    total_handles: number;
    total_banks: number;
}
declare class IdentityClient {
    private http;
    constructor(http: HttpClient);
    resolve(alias: string): Promise<ResolveResult>;
    getProfile(handle: string): Promise<IdentityProfile>;
    claimHandle(params: ClaimHandleParams): Promise<{
        npt_handle: string;
        bank_key: string;
    }>;
    getAccounts(handle: string): Promise<{
        accounts: IdentityAccount[];
    }>;
    linkAccount(handle: string, params: {
        iban: string;
        currency: Currency;
        bank_handle: string;
    }): Promise<IdentityAccount>;
    setDefaultAccount(handle: string, bankHandle: string): Promise<void>;
    deleteIdentity(handle: string): Promise<void>;
    listBanks(): Promise<{
        banks: BankEntry[];
    }>;
    getRegistryInfo(): Promise<RegistryInfo>;
}

type PresentmentChannel = 'QR' | 'NFC' | 'APP_HANDOFF';
type PresentmentMode = 'MERCHANT_PRESENTED';
type PresentmentIntent = 'ONE_TIME_PAYMENT' | 'MANDATE_APPROVAL';
type PresentmentAmountMode = 'FIXED' | 'OPEN';
type PresentmentFrequency = 'ON_DEMAND' | 'DAILY' | 'WEEKLY' | 'MONTHLY';
type PresentmentStatus = 'CREATED' | 'PAYMENT_SESSION_CREATED' | 'MANDATE_SESSION_CREATED' | 'CANCELLED' | 'EXPIRED';
interface PresentedPaymentCapabilities {
    operator_id: string;
    deployment_role: 'GATEWAY' | 'BANK' | 'WALLET' | string;
    presented_payments: {
        supported_channels: PresentmentChannel[];
        supported_modes: PresentmentMode[];
        supported_intents: PresentmentIntent[];
        enabled: Record<string, boolean>;
        hosted_auth_required: boolean;
        notes: string[];
    };
}
interface CreatePresentmentParams {
    channel: PresentmentChannel;
    mode: PresentmentMode;
    intent: PresentmentIntent;
    amount_mode: PresentmentAmountMode;
    amount?: number;
    currency: Currency;
    description: string;
    /**
     * Required when intent is MANDATE_APPROVAL. The amount becomes the mandate
     * amount limit and the customer approves this frequency in hosted SCA.
     */
    frequency?: PresentmentFrequency;
    merchant_reference?: string;
    payer_alias?: string;
    payer_iban?: string;
    supported_auth_methods?: Array<'OTP' | 'PUSH'>;
    expires_in_seconds?: number;
    metadata?: Record<string, unknown>;
}
interface PresentmentWriteOptions {
    idempotencyKey?: string;
}
interface ClaimPresentmentParams {
    claim_token?: string;
    payer_alias?: string;
    payer_iban?: string;
    amount?: number;
    redirect_url?: string;
    cancel_url?: string;
}
interface PresentmentPayload {
    type: 'OPENWAVE_QR_URI' | 'OPENWAVE_NFC_URI' | 'OPENWAVE_APP_HANDOFF_URI' | string;
    uri: string;
    qr_payload?: string;
    nfc_payload?: string;
    claim_token?: string;
}
interface AuthSurface {
    type: 'HOSTED_CHECKOUT' | 'HOSTED_MANDATE_CONSENT' | 'SECURE_SDK_SHEET' | 'BANK_APP';
    url?: string;
    session_id?: string;
    expires_at?: string;
}
interface PresentmentCustomerReview {
    title: string;
    merchant?: {
        merchant_id: string;
        display_name: string;
        reference?: string;
    };
    merchant_name?: string;
    description: string;
    amount_mode: PresentmentAmountMode;
    amount?: number;
    currency: Currency;
    intent: PresentmentIntent;
    channel: PresentmentChannel;
    mode: PresentmentMode;
    payer_alias?: string;
    payer_iban_masked?: string;
    payer_display?: string;
    supported_auth_methods: string[];
    recurrence?: Record<string, unknown>;
    recurring_terms?: Record<string, unknown>;
    fee_disclosure: string;
    expires_at: string;
}
interface Presentment {
    presentment_id: string;
    merchant_id?: number;
    merchant_name?: string;
    status: PresentmentStatus;
    channel: PresentmentChannel;
    mode: PresentmentMode;
    intent: PresentmentIntent;
    amount_mode: PresentmentAmountMode;
    amount?: number;
    currency: Currency;
    description: string;
    merchant_reference?: string;
    presentment_payload: PresentmentPayload;
    payment_session_id?: string;
    payment_url?: string;
    mandate_id?: string;
    mandate_consent_url?: string;
    payer_alias?: string;
    payer_iban_masked?: string;
    customer_review: PresentmentCustomerReview;
    auth_surface?: AuthSurface;
    supported_auth_methods: string[];
    metadata?: unknown;
    claimed_at?: string;
    cancelled_at?: string;
    expires_at: string;
    created_at: string;
    updated_at: string;
}
interface PresentmentStatusResponse {
    presentment_id: string;
    status: PresentmentStatus;
    payment_session_id?: string;
    payment_url?: string;
    mandate_id?: string;
    mandate_consent_url?: string;
    customer_review: PresentmentCustomerReview;
    auth_surface?: AuthSurface;
    expires_at: string;
    updated_at: string;
}
interface ListPresentmentsResponse {
    data: Presentment[];
    total: number;
    page?: number;
    limit?: number;
}
declare class PresentmentsClient {
    private http;
    constructor(http: HttpClient);
    capabilities(): Promise<PresentedPaymentCapabilities>;
    create(params: CreatePresentmentParams, options?: PresentmentWriteOptions): Promise<Presentment>;
    get(presentmentId: string): Promise<Presentment>;
    list(params?: {
        status?: PresentmentStatus;
        page?: number;
        limit?: number;
    }): Promise<ListPresentmentsResponse>;
    claim(presentmentId: string, params: ClaimPresentmentParams): Promise<Presentment>;
    cancel(presentmentId: string): Promise<Presentment>;
    status(presentmentId: string): Promise<PresentmentStatusResponse>;
}

type CreditAssessmentPurpose = 'BNPL' | 'REVOLVING_CREDIT' | 'MURABAHA_INSTALLMENT';
type CreditAssessmentStatus = 'PENDING' | 'COMPLETED' | 'DECLINED' | 'EXPIRED' | 'REVOKED';
type FinanceProductType = 'BNPL_INSTALLMENT' | 'REVOLVING_CREDIT_DRAW' | 'MURABAHA_INSTALLMENT';
type FinanceOfferStatus = 'CREATED' | 'ACCEPTED' | 'EXPIRED' | 'CANCELLED';
type FinanceContractStatus = 'PENDING_ACTIVATION' | 'ACTIVE' | 'CANCELLED' | 'FAILED';
interface Tenor {
    unit: 'DAY' | 'WEEK' | 'MONTH' | 'YEAR' | string;
    value: number;
}
interface DataWindow {
    from?: string;
    to?: string;
}
interface RepaymentInstallment {
    installmentNumber: number;
    dueDate: string;
    amount: number;
    currency: Currency;
}
interface RepaymentInstallmentStatus extends RepaymentInstallment {
    status: string;
    paidAt?: string;
}
interface MurabahaTerms {
    assetDescription: string;
    cashPrice: number;
    profitAmount: number;
    totalSalePrice: number;
    downPayment?: number;
    shariaProfileReference?: string;
    contractDisclosureUrl?: string;
}
interface FinanceCapabilities {
    supportedProducts: FinanceProductType[];
    requiredScopes: string[];
    repaymentMechanisms: string[];
    hostedAcceptanceRequired: boolean;
    decisionProvider: string;
    notes: string[];
}
interface CreateCreditAssessmentParams {
    consentId: string;
    purpose: CreditAssessmentPurpose;
    requestedAmount: number;
    currency: Currency;
    tenor: Tenor;
    dataWindow?: DataWindow;
    selectedAccountIds: string[];
    metadata?: Record<string, unknown>;
}
interface RefreshCreditAssessmentParams {
    dataWindow?: DataWindow;
    selectedAccountIds?: string[];
}
interface CreditAssessment {
    assessmentId: string;
    status: CreditAssessmentStatus;
    purpose: CreditAssessmentPurpose;
    consentId: string;
    bankHandle: string;
    customerAlias?: string;
    requestedAmount: number;
    currency: Currency;
    tenor: Tenor;
    dataWindow?: DataWindow;
    selectedAccountIds: string[];
    incomeSummary?: unknown;
    recurringObligations?: unknown;
    spendingCategories?: unknown;
    debtServiceIndicators?: unknown;
    affordability?: unknown;
    riskScore?: unknown;
    reasonCodes?: unknown;
    modelMetadata?: unknown;
    correlationId: string;
    expiresAt?: string;
    createdAt: string;
    updatedAt: string;
}
interface CreateFinanceOfferParams {
    assessmentId: string;
    productType: FinanceProductType;
    amount: number;
    currency: Currency;
    tenor: Tenor;
    financeCost?: number;
    repaymentSchedulePreview?: RepaymentInstallment[];
    disclosureUrl?: string;
    merchantReference?: string;
    financierPayerAlias?: string;
    financierPayerIban?: string;
    paymentRedirectUrl?: string;
    paymentCancelUrl?: string;
    murabahaTerms?: MurabahaTerms;
    metadata?: Record<string, unknown>;
}
interface AcceptFinanceOfferParams {
    customerAcceptedDisclosure?: boolean;
    repaymentMandateId?: string;
}
interface FinanceOffer {
    offerId: string;
    assessmentId: string;
    productType: FinanceProductType;
    status: FinanceOfferStatus;
    amount: number;
    currency: Currency;
    tenor: Tenor;
    financeCost: number;
    repaymentSchedulePreview: unknown;
    disclosureUrl?: string;
    acceptUrl?: string;
    acceptanceSessionToken?: string;
    merchantReference?: string;
    financierPayerAlias?: string;
    financierPayerIbanMasked?: string;
    murabahaTerms?: unknown;
    acceptedAt?: string;
    expiresAt?: string;
    createdAt: string;
    updatedAt: string;
}
interface FinanceContract {
    contractId: string;
    offerId: string;
    productType: FinanceProductType;
    status: FinanceContractStatus;
    amount: number;
    currency: Currency;
    paymentSessionId?: string;
    paymentUrl?: string;
    repaymentMandateId?: string;
    activatedAt?: string;
    cancelledAt?: string;
    createdAt: string;
    updatedAt: string;
}
interface RepaymentSchedule {
    contractId: string;
    installments: RepaymentInstallmentStatus[];
    total: number;
}
declare class FinanceAssessmentsClient {
    private http;
    constructor(http: HttpClient);
    create(params: CreateCreditAssessmentParams): Promise<CreditAssessment>;
    list(): Promise<CreditAssessment[]>;
    get(assessmentId: string): Promise<CreditAssessment>;
    refresh(assessmentId: string, params?: RefreshCreditAssessmentParams): Promise<CreditAssessment>;
    revoke(assessmentId: string): Promise<void>;
}
declare class FinanceOffersClient {
    private http;
    constructor(http: HttpClient);
    create(params: CreateFinanceOfferParams): Promise<FinanceOffer>;
    list(): Promise<FinanceOffer[]>;
    get(offerId: string): Promise<FinanceOffer>;
    accept(offerId: string, financeSessionToken: string, params?: AcceptFinanceOfferParams): Promise<FinanceContract>;
}
declare class FinanceContractsClient {
    private http;
    constructor(http: HttpClient);
    get(contractId: string): Promise<FinanceContract>;
    repaymentSchedule(contractId: string): Promise<RepaymentSchedule>;
    cancel(contractId: string): Promise<FinanceContract>;
}
declare class FinanceClient {
    private http;
    readonly assessments: FinanceAssessmentsClient;
    readonly offers: FinanceOffersClient;
    readonly contracts: FinanceContractsClient;
    constructor(http: HttpClient);
    capabilities(): Promise<FinanceCapabilities>;
}

type WebhookHandler<T = unknown> = (payload: WebhookPayload<T>) => void | Promise<void>;
declare function verifyWebhookSignature(rawBody: string, signature: string, secret: string): Promise<boolean>;
declare function parseWebhookPayload<T = unknown>(rawBody: string): WebhookPayload<T>;
declare class WebhookReceiver {
    private handlers;
    private secret;
    constructor(secret: string);
    on<T = unknown>(event: WebhookEvent | '*', handler: WebhookHandler<T>): this;
    handle(rawBody: string, signature: string): Promise<void>;
}

declare class AstroClient {
    readonly payments: PaymentsClient;
    /** Customer-facing checkout flow. Use with X-Session-Token — NOT a merchant API key. */
    readonly checkout: CheckoutClient;
    readonly alias: AliasClient;
    readonly openBanking: OpenBankingClient;
    readonly identity: IdentityClient;
    readonly presentments: PresentmentsClient;
    readonly finance: FinanceClient;
    readonly http: HttpClient;
    constructor(config: AstroConfig);
}
declare function createClient(config: AstroConfig): AstroClient;
/**
 * Create a checkout-only client for the customer-facing payment flow.
 * This client only exposes resolve-payer / select-auth / confirm.
 * No merchant API key is set — authentication is via X-Session-Token.
 *
 * @example
 * const checkout = createCheckoutClient({ baseUrl: 'https://pay.example.com', sessionToken: token })
 * await checkout.resolvePayer(sessionId, { payer_alias: '09XXXXXXXX' })
 */
declare function createCheckoutClient(opts: {
    baseUrl: string;
    sessionToken?: string;
    timeout?: number;
}): CheckoutClient;

export { type AcceptFinanceOfferParams, type AliasAccountsResponse, type AliasAvailability, type AliasAvailabilityStatus, AliasClient, type AliasProfile, AstroClient, type AstroConfig, type AstroError, AstroRequestError, type AuthSurface, type BankCapabilities, type BankEntry, type ChargeMandateParams, CheckoutClient, type ClaimHandleParams, type ClaimPresentmentParams, type ConfirmParams, type ConfirmResult, type Consent, type ConsentStatus, type CreateConsentParams, type CreateCreditAssessmentParams, type CreateFinanceOfferParams, type CreateMandateParams, type CreatePaymentOrderParams, type CreatePresentmentParams, type CreateRefundParams, type CreateSessionParams, type CreditAssessment, type CreditAssessmentPurpose, type CreditAssessmentStatus, type Currency, type DataWindow, type Destination, type FeePreview, FinanceAssessmentsClient, type FinanceCapabilities, FinanceClient, type FinanceContract, type FinanceContractStatus, FinanceContractsClient, type FinanceOffer, type FinanceOfferStatus, FinanceOffersClient, type FinanceProductType, HttpClient, type IdentityAccount, IdentityClient, type IdentityProfile, type LinkedAccount, type ListMandateChargesResponse, type ListMandatesParams, type ListMandatesResponse, type ListPresentmentsResponse, type ListSessionsParams, type ListSessionsResponse, type Mandate, type MandateCharge, type MandateStatus, type MurabahaTerms, type OBAccount, type OBBalance, type OBScope, type OBTransaction, type OBTransactionsResponse, OpenBankingClient, type Pagination, type PaymentOrder, type PaymentOrderStatus, type PaymentSession, type PaymentStatus, PaymentsClient, type PresentedPaymentCapabilities, type Presentment, type PresentmentAmountMode, type PresentmentChannel, type PresentmentCustomerReview, type PresentmentFrequency, type PresentmentIntent, type PresentmentMode, type PresentmentPayload, type PresentmentStatus, type PresentmentStatusResponse, type PresentmentWriteOptions, PresentmentsClient, type RefreshCreditAssessmentParams, type Refund, type RefundListResponse, type RegistryInfo, type RenameAliasParams, type RenameAliasResult, type RepaymentInstallment, type RepaymentInstallmentStatus, type RepaymentSchedule, type ResolvePayerParams, type ResolvePayerResult, type ResolveResult, type SelectAuthParams, type SelectAuthResult, type Tenor, type TokenResponse, type WebhookEvent, type WebhookHandler, type WebhookPayload, WebhookReceiver, type WriteOptions, createCheckoutClient, createClient, parseWebhookPayload, verifyWebhookSignature };
