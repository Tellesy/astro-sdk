import Foundation

// MARK: - Config & Error

public struct AstroConfig {
    public let baseURL: URL
    public var merchantKey: String?
    public var bankKey: String?
    public var adminKey: String?
    public var timeout: TimeInterval

    public init(
        baseURL: URL,
        merchantKey: String? = nil,
        bankKey: String? = nil,
        adminKey: String? = nil,
        timeout: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.merchantKey = merchantKey
        self.bankKey = bankKey
        self.adminKey = adminKey
        self.timeout = timeout
    }
}

public struct AstroError: LocalizedError {
    public let statusCode: Int
    public let code: String
    public let detail: String?
    public var errorDescription: String?

    public init(statusCode: Int, code: String, message: String, detail: String? = nil) {
        self.statusCode = statusCode
        self.code = code
        self.detail = detail
        self.errorDescription = "[\(code)] \(message)"
    }
}

// MARK: - Shared

public struct Destination: Codable {
    public let type: String
    public let value: String
    public init(type: String, value: String) {
        self.type = type
        self.value = value
    }
}

public struct Pagination: Codable {
    public let nextCursor: String?
    public let hasMore: Bool
    enum CodingKeys: String, CodingKey {
        case nextCursor = "next_cursor"
        case hasMore = "has_more"
    }
}

// MARK: - Payments

public struct PaymentSession: Codable {
    public let sessionId: String
    public let status: String
    public let amount: Int
    public let currency: String
    public let destination: Destination?
    public let description: String?
    public let reference: String?
    public let merchantReference: String?
    public let checkoutUrl: String
    public let paymentUrl: String?
    public let checkoutSessionToken: String?
    public let createdAt: String
    public let expiresAt: String
    public let completedAt: String?
    public let settlementType: String?
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case status, amount, currency, destination, description, reference
        case merchantReference = "merchant_reference"
        case checkoutUrl = "checkout_url"
        case paymentUrl = "payment_url"
        case checkoutSessionToken = "checkout_session_token"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
        case completedAt = "completed_at"
        case settlementType = "settlement_type"
    }
}

public struct CreateSessionRequest: Codable {
    public let amount: Int
    public let currency: String
    public let destination: Destination?
    public let payerAlias: String?
    public let payerIban: String?
    public let description: String
    public let reference: String?
    public let merchantReference: String
    public let redirectUrl: String?
    public let cancelUrl: String?
    public let webhookUrl: String?
    enum CodingKeys: String, CodingKey {
        case amount, currency, destination, description, reference
        case payerAlias = "payer_alias"
        case payerIban = "payer_iban"
        case merchantReference = "merchant_reference"
        case redirectUrl = "redirect_url"
        case cancelUrl = "cancel_url"
        case webhookUrl = "webhook_url"
    }
    public init(
        amount: Int, currency: String, description: String, merchantReference: String,
        destination: Destination? = nil, payerAlias: String? = nil, payerIban: String? = nil,
        reference: String? = nil, redirectUrl: String? = nil, cancelUrl: String? = nil, webhookUrl: String? = nil
    ) {
        self.amount = amount; self.currency = currency; self.destination = destination
        self.payerAlias = payerAlias; self.payerIban = payerIban
        self.description = description; self.reference = reference; self.merchantReference = merchantReference
        self.redirectUrl = redirectUrl; self.cancelUrl = cancelUrl; self.webhookUrl = webhookUrl
    }
}

public struct CreateRefundRequest: Codable {
    public let amount: Int
    public let currency: String
    public let reason: String?
    public let merchantReference: String
    public let metadata: [String: String]?
    enum CodingKeys: String, CodingKey {
        case amount, currency, reason, metadata
        case merchantReference = "merchant_reference"
    }
    public init(
        amount: Int,
        currency: String,
        merchantReference: String,
        reason: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.amount = amount
        self.currency = currency
        self.merchantReference = merchantReference
        self.reason = reason
        self.metadata = metadata
    }
}

public struct Refund: Codable {
    public let refundId: String
    public let sessionId: String
    public let status: String
    public let amount: Int
    public let currency: String
    public let merchantReference: String?
    public let reason: String?
    public let rail: String?
    public let reversalReference: String?
    public let failureReason: String?
    public let failureMessage: String?
    public let createdAt: String
    public let completedAt: String?
    enum CodingKeys: String, CodingKey {
        case refundId = "refund_id"
        case sessionId = "session_id"
        case status, amount, currency, reason, rail
        case merchantReference = "merchant_reference"
        case reversalReference = "reversal_reference"
        case failureReason = "failure_reason"
        case failureMessage = "failure_message"
        case createdAt = "created_at"
        case completedAt = "completed_at"
    }
}

public struct RefundListResponse: Codable {
    public let data: [Refund]
    public let total: Int
    public let page: Int?
    public let limit: Int?
}

public struct Mandate: Codable {
    public let mandateId: String
    public let status: String
    public let payerAlias: String?
    public let amountLimit: Int
    public let currency: String
    public let frequency: String
    public let description: String
    public let consentUrl: String?
    public let consentedAt: String?
    public let cancelledAt: String?
    public let cancelledBy: String?
    public let merchantReference: String?
    public let createdAt: String
    enum CodingKeys: String, CodingKey {
        case mandateId = "mandate_id"
        case status
        case payerAlias = "payer_alias"
        case amountLimit = "amount_limit"
        case currency, frequency, description
        case consentUrl = "consent_url"
        case consentedAt = "consented_at"
        case cancelledAt = "cancelled_at"
        case cancelledBy = "cancelled_by"
        case merchantReference = "merchant_reference"
        case createdAt = "created_at"
    }
}

public struct CreateMandateRequest: Codable {
    public let payerAlias: String?
    public let payerIban: String?
    public let amountLimit: Int
    public let currency: String
    public let frequency: String
    public let description: String
    public let consentRedirectUrl: String
    public let merchantReference: String?
    public let metadata: [String: String]?
    enum CodingKeys: String, CodingKey {
        case payerAlias = "payer_alias"
        case payerIban = "payer_iban"
        case amountLimit = "amount_limit"
        case currency, frequency, description, metadata
        case consentRedirectUrl = "consent_redirect_url"
        case merchantReference = "merchant_reference"
    }
    public init(
        payerAlias: String? = nil,
        payerIban: String? = nil,
        amountLimit: Int,
        currency: String,
        frequency: String,
        description: String,
        consentRedirectUrl: String,
        merchantReference: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.payerAlias = payerAlias
        self.payerIban = payerIban
        self.amountLimit = amountLimit
        self.currency = currency
        self.frequency = frequency
        self.description = description
        self.consentRedirectUrl = consentRedirectUrl
        self.merchantReference = merchantReference
        self.metadata = metadata
    }
}

public struct MandateListResponse: Codable {
    public let data: [Mandate]
    public let total: Int
    public let page: Int
    public let limit: Int
}

public struct ChargeMandateRequest: Codable {
    public let amount: Int
    public let description: String
    public let merchantReference: String?
    enum CodingKeys: String, CodingKey {
        case amount, description
        case merchantReference = "merchant_reference"
    }
    public init(amount: Int, description: String, merchantReference: String? = nil) {
        self.amount = amount
        self.description = description
        self.merchantReference = merchantReference
    }
}

public struct MandateCharge: Codable {
    public let chargeId: String
    public let mandateId: String
    public let status: String
    public let amount: Int
    public let currency: String
    public let description: String
    public let merchantReference: String?
    public let errorCode: String?
    public let errorMessage: String?
    public let createdAt: String
    public let executedAt: String?
    enum CodingKeys: String, CodingKey {
        case chargeId = "charge_id"
        case mandateId = "mandate_id"
        case status, amount, currency, description
        case merchantReference = "merchant_reference"
        case errorCode = "error_code"
        case errorMessage = "error_message"
        case createdAt = "created_at"
        case executedAt = "executed_at"
    }
}

public struct MandateChargeListResponse: Codable {
    public let data: [MandateCharge]
    public let total: Int
    public let page: Int
    public let limit: Int
}

// MARK: - Presented Payments

public struct PresentedPaymentCapabilitiesResponse: Codable {
    public let operatorId: String
    public let deploymentRole: String
    public let presentedPayments: PresentedPaymentCapabilities
    enum CodingKeys: String, CodingKey {
        case operatorId = "operator_id"
        case deploymentRole = "deployment_role"
        case presentedPayments = "presented_payments"
    }
}

public struct PresentedPaymentCapabilities: Codable {
    public let supportedChannels: [String]
    public let supportedModes: [String]
    public let supportedIntents: [String]
    public let enabled: [String: Bool]
    public let hostedAuthRequired: Bool
    public let notes: [String]
    enum CodingKeys: String, CodingKey {
        case supportedChannels = "supported_channels"
        case supportedModes = "supported_modes"
        case supportedIntents = "supported_intents"
        case enabled
        case hostedAuthRequired = "hosted_auth_required"
        case notes
    }
}

public struct CreatePresentmentRequest: Codable {
    public let channel: String
    public let mode: String
    public let intent: String
    public let amountMode: String
    public let amount: Int?
    public let currency: String
    public let description: String
    public let frequency: String?
    public let merchantReference: String?
    public let payerAlias: String?
    public let payerIban: String?
    public let supportedAuthMethods: [String]
    public let expiresInSeconds: Int?
    public let metadata: [String: String]?
    enum CodingKeys: String, CodingKey {
        case channel, mode, intent, amount, currency, description, frequency, metadata
        case amountMode = "amount_mode"
        case merchantReference = "merchant_reference"
        case payerAlias = "payer_alias"
        case payerIban = "payer_iban"
        case supportedAuthMethods = "supported_auth_methods"
        case expiresInSeconds = "expires_in_seconds"
    }
}

public struct ClaimPresentmentRequest: Codable {
    public let claimToken: String?
    public let payerAlias: String?
    public let payerIban: String?
    public let amount: Int?
    public let redirectUrl: String?
    public let cancelUrl: String?
    enum CodingKeys: String, CodingKey {
        case claimToken = "claim_token"
        case payerAlias = "payer_alias"
        case payerIban = "payer_iban"
        case amount
        case redirectUrl = "redirect_url"
        case cancelUrl = "cancel_url"
    }
}

public struct PresentmentPayload: Codable {
    public let type: String
    public let uri: String
    public let qrPayload: String?
    public let nfcPayload: String?
    public let claimToken: String?
    enum CodingKeys: String, CodingKey {
        case type, uri
        case qrPayload = "qr_payload"
        case nfcPayload = "nfc_payload"
        case claimToken = "claim_token"
    }
}

public struct AuthSurface: Codable {
    public let type: String
    public let url: String?
    public let sessionId: String?
    public let expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case type, url
        case sessionId = "session_id"
        case expiresAt = "expires_at"
    }
}

public struct Presentment: Codable {
    public let presentmentId: String
    public let status: String
    public let channel: String
    public let mode: String
    public let intent: String
    public let amountMode: String
    public let amount: Int?
    public let currency: String
    public let description: String
    public let merchantReference: String?
    public let presentmentPayload: PresentmentPayload?
    public let paymentSessionId: String?
    public let paymentUrl: String?
    public let mandateId: String?
    public let mandateConsentUrl: String?
    public let authSurface: AuthSurface?
    public let supportedAuthMethods: [String]
    public let claimedAt: String?
    public let cancelledAt: String?
    public let expiresAt: String
    public let createdAt: String
    public let updatedAt: String
    enum CodingKeys: String, CodingKey {
        case presentmentId = "presentment_id"
        case status, channel, mode, intent, amount, currency, description
        case amountMode = "amount_mode"
        case merchantReference = "merchant_reference"
        case presentmentPayload = "presentment_payload"
        case paymentSessionId = "payment_session_id"
        case paymentUrl = "payment_url"
        case mandateId = "mandate_id"
        case mandateConsentUrl = "mandate_consent_url"
        case authSurface = "auth_surface"
        case supportedAuthMethods = "supported_auth_methods"
        case claimedAt = "claimed_at"
        case cancelledAt = "cancelled_at"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct PresentmentsListResponse: Codable {
    public let data: [Presentment]
    public let presentments: [Presentment]?
    public let total: Int?
    public let page: Int?
    public let limit: Int?
}

public struct PresentmentStatusResponse: Codable {
    public let presentmentId: String
    public let status: String
    public let paymentSessionId: String?
    public let paymentUrl: String?
    public let mandateId: String?
    public let mandateConsentUrl: String?
    public let authSurface: AuthSurface?
    public let expiresAt: String
    public let updatedAt: String
    enum CodingKeys: String, CodingKey {
        case presentmentId = "presentment_id"
        case status
        case paymentSessionId = "payment_session_id"
        case paymentUrl = "payment_url"
        case mandateId = "mandate_id"
        case mandateConsentUrl = "mandate_consent_url"
        case authSurface = "auth_surface"
        case expiresAt = "expires_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Alias

public struct AliasProfile: Codable {
    public let aliasUsername: String
    public let isActive: Bool
    public let bankHandle: String
    public let createdAt: String
    enum CodingKeys: String, CodingKey {
        case aliasUsername = "alias_username"
        case isActive = "is_active"
        case bankHandle = "bank_handle"
        case createdAt = "created_at"
    }
}

public struct LinkedAccount: Codable {
    public let iban: String
    public let currency: String
    public let accountName: String?
    public let bankHandle: String
    public let isDefault: Bool
    enum CodingKeys: String, CodingKey {
        case iban, currency
        case accountName = "account_name"
        case bankHandle = "bank_handle"
        case isDefault = "is_default"
    }
}

public struct AliasAvailability: Codable {
    public let aliasUsername: String
    public let status: String
    public let available: Bool
    enum CodingKeys: String, CodingKey {
        case aliasUsername = "alias_username"
        case status, available
    }
}

public struct RenameAliasRequest: Codable {
    public let currentAliasUsername: String
    public let newAliasUsername: String
    public let nationalId: String

    public init(currentAliasUsername: String, newAliasUsername: String, nationalId: String) {
        self.currentAliasUsername = currentAliasUsername
        self.newAliasUsername = newAliasUsername
        self.nationalId = nationalId
    }

    enum CodingKeys: String, CodingKey {
        case currentAliasUsername = "current_alias_username"
        case newAliasUsername = "new_alias_username"
        case nationalId = "national_id"
    }
}

public struct RenameAliasResult: Codable {
    public let aliasUsername: String
    public let previousAliasUsername: String
    public let retiredHandle: String
    public let previousRetired: Bool
    public let reauthenticationRequired: Bool
    public let nextStep: String
    public let message: String
    enum CodingKeys: String, CodingKey {
        case aliasUsername = "alias_username"
        case previousAliasUsername = "previous_alias_username"
        case retiredHandle = "retired_handle"
        case previousRetired = "previous_retired"
        case reauthenticationRequired = "reauthentication_required"
        case nextStep = "next_step"
        case message
    }
}

// MARK: - Open Banking

public struct Consent: Codable {
    public let consentId: String
    public let status: String
    public let bankHandle: String
    public let scopes: [String]
    public let redirectUri: String
    public let consentUrl: String
    public let createdAt: String
    public let expiresAt: String
    enum CodingKeys: String, CodingKey {
        case consentId = "consent_id"
        case status
        case bankHandle = "bank_handle"
        case scopes
        case redirectUri = "redirect_uri"
        case consentUrl = "consent_url"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}

public struct TokenResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    public let expiresIn: Int
    public let scope: String
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope
    }
}

public struct OBAccount: Codable {
    public let accountId: String
    public let iban: String
    public let currency: String
    public let accountType: String
    public let displayName: String?
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case iban, currency
        case accountType = "account_type"
        case displayName = "display_name"
    }
}

public struct OBTransaction: Codable {
    public let transactionId: String
    public let amount: Int
    public let currency: String
    public let direction: String
    public let narrative: String?
    public let reference: String?
    public let valueDate: String
    public let bookingDate: String
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case amount, currency, direction, narrative, reference
        case valueDate = "value_date"
        case bookingDate = "booking_date"
    }
}

// MARK: - Identity

public struct ResolveResult: Codable {
    public let nptHandle: String
    public let iban: String
    public let bankHandle: String
    public let currency: String
    enum CodingKeys: String, CodingKey {
        case nptHandle = "npt_handle"
        case iban
        case bankHandle = "bank_handle"
        case currency
    }
}

public struct BankEntry: Codable {
    public let bankHandle: String
    public let displayName: String
    public let country: String
    public let obEnabled: Bool
    enum CodingKeys: String, CodingKey {
        case bankHandle = "bank_handle"
        case displayName = "display_name"
        case country
        case obEnabled = "ob_enabled"
    }
}
