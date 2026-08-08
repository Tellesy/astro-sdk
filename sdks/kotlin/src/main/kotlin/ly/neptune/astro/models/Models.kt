package ly.neptune.astro.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class AstroError(
    val code: String,
    val message: String,
    val detail: String? = null,
    @SerialName("request_id") val requestId: String? = null
)

@Serializable
data class Destination(
    val type: String,
    val value: String
)

@Serializable
data class Pagination(
    @SerialName("next_cursor") val nextCursor: String? = null,
    @SerialName("has_more") val hasMore: Boolean
)

// ─── Payments ────────────────────────────────────────────────────────────────

@Serializable
data class CreateSessionRequest(
    val amount: Long,
    val currency: String,
    val destination: Destination? = null,
    @SerialName("payer_alias") val payerAlias: String? = null,
    @SerialName("payer_iban") val payerIban: String? = null,
    val description: String,
    val reference: String? = null,
    @SerialName("merchant_reference") val merchantReference: String,
    @SerialName("redirect_url") val redirectUrl: String? = null,
    @SerialName("cancel_url") val cancelUrl: String? = null,
    @SerialName("webhook_url") val webhookUrl: String? = null,
    val metadata: Map<String, String>? = null
)

@Serializable
data class PaymentSession(
    @SerialName("session_id") val sessionId: String,
    val status: String,
    val amount: Long,
    val currency: String,
    val destination: Destination? = null,
    val description: String? = null,
    val reference: String? = null,
    @SerialName("merchant_reference") val merchantReference: String? = null,
    @SerialName("checkout_url") val checkoutUrl: String,
    @SerialName("payment_url") val paymentUrl: String? = null,
    @SerialName("checkout_session_token") val checkoutSessionToken: String? = null,
    @SerialName("redirect_url") val redirectUrl: String? = null,
    @SerialName("created_at") val createdAt: String,
    @SerialName("expires_at") val expiresAt: String,
    @SerialName("completed_at") val completedAt: String? = null,
    @SerialName("settlement_type") val settlementType: String? = null
)

@Serializable
data class ListSessionsResponse(
    val sessions: List<PaymentSession>,
    val pagination: Pagination
)

@Serializable
data class CreateRefundRequest(
    val amount: Long,
    val currency: String,
    val reason: String? = null,
    @SerialName("merchant_reference") val merchantReference: String,
    val metadata: Map<String, String>? = null
)

@Serializable
data class Refund(
    @SerialName("refund_id") val refundId: String,
    @SerialName("session_id") val sessionId: String,
    val status: String,
    val amount: Long,
    val currency: String,
    @SerialName("merchant_reference") val merchantReference: String? = null,
    val reason: String? = null,
    val rail: String? = null,
    @SerialName("reversal_reference") val reversalReference: String? = null,
    @SerialName("failure_reason") val failureReason: String? = null,
    @SerialName("failure_message") val failureMessage: String? = null,
    @SerialName("created_at") val createdAt: String,
    @SerialName("completed_at") val completedAt: String? = null
)

@Serializable
data class RefundListResponse(
    val data: List<Refund>,
    val total: Int,
    val page: Int? = null,
    val limit: Int? = null
)

@Serializable
data class CreateMandateRequest(
    @SerialName("payer_alias") val payerAlias: String? = null,
    @SerialName("payer_iban") val payerIban: String? = null,
    @SerialName("amount_limit") val amountLimit: Long,
    val currency: String,
    val frequency: String,
    val description: String,
    @SerialName("consent_redirect_url") val consentRedirectUrl: String,
    @SerialName("merchant_reference") val merchantReference: String? = null,
    val metadata: Map<String, String>? = null
)

@Serializable
data class Mandate(
    @SerialName("mandate_id") val mandateId: String,
    val status: String,
    @SerialName("payer_alias") val payerAlias: String? = null,
    @SerialName("amount_limit") val amountLimit: Long,
    val currency: String,
    val frequency: String,
    val description: String,
    @SerialName("consent_url") val consentUrl: String? = null,
    @SerialName("consented_at") val consentedAt: String? = null,
    @SerialName("cancelled_at") val cancelledAt: String? = null,
    @SerialName("cancelled_by") val cancelledBy: String? = null,
    @SerialName("merchant_reference") val merchantReference: String? = null,
    @SerialName("created_at") val createdAt: String
)

@Serializable
data class MandateListResponse(
    val data: List<Mandate>,
    val total: Long,
    val page: Int,
    val limit: Int
)

@Serializable
data class ChargeMandateRequest(
    val amount: Long,
    val description: String,
    @SerialName("merchant_reference") val merchantReference: String? = null
)

@Serializable
data class MandateCharge(
    @SerialName("charge_id") val chargeId: String,
    @SerialName("mandate_id") val mandateId: String,
    val status: String,
    val amount: Long,
    val currency: String,
    val description: String,
    @SerialName("merchant_reference") val merchantReference: String? = null,
    @SerialName("error_code") val errorCode: String? = null,
    @SerialName("error_message") val errorMessage: String? = null,
    @SerialName("created_at") val createdAt: String,
    @SerialName("executed_at") val executedAt: String? = null
)

@Serializable
data class MandateChargeListResponse(
    val data: List<MandateCharge>,
    val total: Long,
    val page: Int,
    val limit: Int
)

// ─── Presented Payments ─────────────────────────────────────────────────────

@Serializable
data class PresentedPaymentCapabilitiesResponse(
    @SerialName("operator_id") val operatorId: String,
    @SerialName("deployment_role") val deploymentRole: String,
    @SerialName("presented_payments") val presentedPayments: PresentedPaymentCapabilities
)

@Serializable
data class PresentedPaymentCapabilities(
    @SerialName("supported_channels") val supportedChannels: List<String>,
    @SerialName("supported_modes") val supportedModes: List<String>,
    @SerialName("supported_intents") val supportedIntents: List<String>,
    val enabled: Map<String, Boolean>,
    @SerialName("hosted_auth_required") val hostedAuthRequired: Boolean,
    val notes: List<String>
)

@Serializable
data class CreatePresentmentRequest(
    val channel: String,
    val mode: String,
    val intent: String,
    @SerialName("amount_mode") val amountMode: String,
    val amount: Long? = null,
    val currency: String,
    val description: String,
    val frequency: String? = null,
    @SerialName("merchant_reference") val merchantReference: String? = null,
    @SerialName("payer_alias") val payerAlias: String? = null,
    @SerialName("payer_iban") val payerIban: String? = null,
    @SerialName("supported_auth_methods") val supportedAuthMethods: List<String> = listOf("OTP", "PUSH"),
    @SerialName("expires_in_seconds") val expiresInSeconds: Long? = null,
    val metadata: Map<String, String>? = null
)

@Serializable
data class ClaimPresentmentRequest(
    @SerialName("claim_token") val claimToken: String? = null,
    @SerialName("payer_alias") val payerAlias: String? = null,
    @SerialName("payer_iban") val payerIban: String? = null,
    val amount: Long? = null,
    @SerialName("redirect_url") val redirectUrl: String? = null,
    @SerialName("cancel_url") val cancelUrl: String? = null
)

@Serializable
data class PresentmentPayload(
    val type: String,
    val uri: String,
    @SerialName("qr_payload") val qrPayload: String? = null,
    @SerialName("nfc_payload") val nfcPayload: String? = null,
    @SerialName("claim_token") val claimToken: String? = null
)

@Serializable
data class AuthSurface(
    val type: String,
    val url: String? = null,
    @SerialName("session_id") val sessionId: String? = null,
    @SerialName("expires_at") val expiresAt: String? = null
)

@Serializable
data class Presentment(
    @SerialName("presentment_id") val presentmentId: String,
    val status: String,
    val channel: String,
    val mode: String,
    val intent: String,
    @SerialName("amount_mode") val amountMode: String,
    val amount: Long? = null,
    val currency: String,
    val description: String,
    @SerialName("merchant_reference") val merchantReference: String? = null,
    @SerialName("presentment_payload") val presentmentPayload: PresentmentPayload? = null,
    @SerialName("payment_session_id") val paymentSessionId: String? = null,
    @SerialName("payment_url") val paymentUrl: String? = null,
    @SerialName("mandate_id") val mandateId: String? = null,
    @SerialName("mandate_consent_url") val mandateConsentUrl: String? = null,
    @SerialName("auth_surface") val authSurface: AuthSurface? = null,
    @SerialName("supported_auth_methods") val supportedAuthMethods: List<String> = emptyList(),
    @SerialName("claimed_at") val claimedAt: String? = null,
    @SerialName("cancelled_at") val cancelledAt: String? = null,
    @SerialName("expires_at") val expiresAt: String,
    @SerialName("created_at") val createdAt: String,
    @SerialName("updated_at") val updatedAt: String
)

@Serializable
data class PresentmentsListResponse(
    val data: List<Presentment> = emptyList(),
    val presentments: List<Presentment> = emptyList(),
    val total: Int? = null,
    val page: Int? = null,
    val limit: Int? = null
)

@Serializable
data class PresentmentStatusResponse(
    @SerialName("presentment_id") val presentmentId: String,
    val status: String,
    @SerialName("payment_session_id") val paymentSessionId: String? = null,
    @SerialName("payment_url") val paymentUrl: String? = null,
    @SerialName("mandate_id") val mandateId: String? = null,
    @SerialName("mandate_consent_url") val mandateConsentUrl: String? = null,
    @SerialName("auth_surface") val authSurface: AuthSurface? = null,
    @SerialName("expires_at") val expiresAt: String,
    @SerialName("updated_at") val updatedAt: String
)

// ─── Alias ───────────────────────────────────────────────────────────────────

@Serializable
data class AliasProfile(
    @SerialName("alias_username") val aliasUsername: String,
    @SerialName("is_active") val isActive: Boolean,
    @SerialName("bank_handle") val bankHandle: String,
    @SerialName("created_at") val createdAt: String
)

@Serializable
data class LinkedAccount(
    val iban: String,
    val currency: String,
    @SerialName("account_name") val accountName: String? = null,
    @SerialName("bank_handle") val bankHandle: String,
    @SerialName("is_default") val isDefault: Boolean
)

@Serializable
data class AliasAccountsResponse(
    @SerialName("alias_username") val aliasUsername: String,
    val accounts: List<LinkedAccount>
)

@Serializable
data class AliasAvailability(
    @SerialName("alias_username") val aliasUsername: String,
    val status: String,
    val available: Boolean
)

@Serializable
data class RenameAliasRequest(
    @SerialName("current_alias_username") val currentAliasUsername: String,
    @SerialName("new_alias_username") val newAliasUsername: String,
    @SerialName("national_id") val nationalId: String
)

@Serializable
data class RenameAliasResult(
    @SerialName("alias_username") val aliasUsername: String,
    @SerialName("previous_alias_username") val previousAliasUsername: String,
    @SerialName("retired_handle") val retiredHandle: String,
    @SerialName("previous_retired") val previousRetired: Boolean,
    @SerialName("reauthentication_required") val reauthenticationRequired: Boolean,
    @SerialName("next_step") val nextStep: String,
    val message: String
)

// ─── Open Banking ────────────────────────────────────────────────────────────

@Serializable
data class CreateConsentRequest(
    @SerialName("bank_handle") val bankHandle: String,
    val scopes: List<String>,
    @SerialName("redirect_uri") val redirectUri: String,
    val state: String,
    @SerialName("code_challenge") val codeChallenge: String,
    @SerialName("code_challenge_method") val codeChallengeMethod: String = "S256",
    @SerialName("expiry_days") val expiryDays: Int? = null
)

@Serializable
data class Consent(
    @SerialName("consent_id") val consentId: String,
    val status: String,
    @SerialName("bank_handle") val bankHandle: String,
    val scopes: List<String>,
    @SerialName("redirect_uri") val redirectUri: String,
    @SerialName("consent_url") val consentUrl: String,
    @SerialName("created_at") val createdAt: String,
    @SerialName("expires_at") val expiresAt: String
)

@Serializable
data class TokenResponse(
    @SerialName("access_token") val accessToken: String,
    @SerialName("refresh_token") val refreshToken: String,
    @SerialName("token_type") val tokenType: String,
    @SerialName("expires_in") val expiresIn: Int,
    val scope: String
)

@Serializable
data class OBAccount(
    @SerialName("account_id") val accountId: String,
    val iban: String,
    val currency: String,
    @SerialName("account_type") val accountType: String,
    @SerialName("display_name") val displayName: String? = null
)

@Serializable
data class OBBalance(
    @SerialName("account_id") val accountId: String,
    val available: Long,
    val current: Long,
    val currency: String,
    @SerialName("as_of") val asOf: String
)

@Serializable
data class OBTransaction(
    @SerialName("transaction_id") val transactionId: String,
    val amount: Long,
    val currency: String,
    val direction: String,
    val narrative: String? = null,
    val reference: String? = null,
    @SerialName("value_date") val valueDate: String,
    @SerialName("booking_date") val bookingDate: String
)

@Serializable
data class OBTransactionsResponse(
    @SerialName("account_id") val accountId: String,
    val transactions: List<OBTransaction>
)

// ─── Identity ────────────────────────────────────────────────────────────────

@Serializable
data class ResolveResult(
    @SerialName("npt_handle") val nptHandle: String,
    val iban: String,
    @SerialName("bank_handle") val bankHandle: String,
    val currency: String
)

@Serializable
data class BankEntry(
    @SerialName("bank_handle") val bankHandle: String,
    @SerialName("display_name") val displayName: String,
    val country: String,
    @SerialName("ob_enabled") val obEnabled: Boolean
)

// ─── Webhooks ────────────────────────────────────────────────────────────────

@Serializable
data class WebhookPayload<T>(
    val event: String,
    @SerialName("api_version") val apiVersion: String,
    val timestamp: String,
    val data: T
)
