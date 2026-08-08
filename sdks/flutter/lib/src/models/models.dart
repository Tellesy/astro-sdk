// ignore_for_file: invalid_annotation_target

class AstroError implements Exception {
  final String code;
  final String message;
  final String? detail;
  final int statusCode;

  const AstroError({
    required this.code,
    required this.message,
    required this.statusCode,
    this.detail,
  });

  @override
  String toString() => '[$code] $message (HTTP $statusCode)';
}

// ─── Shared ──────────────────────────────────────────────────────────────────

class Destination {
  final String type;
  final String value;

  const Destination({required this.type, required this.value});

  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}

class Pagination {
  final String? nextCursor;
  final bool hasMore;

  const Pagination({this.nextCursor, required this.hasMore});

  factory Pagination.fromJson(Map<String, dynamic> j) => Pagination(
        nextCursor: j['next_cursor'] as String?,
        hasMore: j['has_more'] as bool? ?? false,
      );
}

// ─── Payments ────────────────────────────────────────────────────────────────

class PaymentSession {
  final String sessionId;
  final String status;
  final int amount;
  final String currency;
  final Destination? destination;
  final String? description;
  final String? reference;
  final String? merchantReference;
  final String checkoutUrl;
  final String? paymentUrl;
  final String? checkoutSessionToken;
  final String createdAt;
  final String expiresAt;
  final String? completedAt;
  final String? settlementType;

  const PaymentSession({
    required this.sessionId,
    required this.status,
    required this.amount,
    required this.currency,
    this.destination,
    this.description,
    this.reference,
    this.merchantReference,
    required this.checkoutUrl,
    this.paymentUrl,
    this.checkoutSessionToken,
    required this.createdAt,
    required this.expiresAt,
    this.completedAt,
    this.settlementType,
  });

  factory PaymentSession.fromJson(Map<String, dynamic> j) => PaymentSession(
        sessionId: j['session_id'] as String,
        status: j['status'] as String,
        amount: j['amount'] as int,
        currency: j['currency'] as String,
        destination: j['destination'] == null
            ? null
            : Destination(
                type: (j['destination'] as Map)['type'] as String,
                value: (j['destination'] as Map)['value'] as String,
              ),
        description: j['description'] as String?,
        reference: j['reference'] as String?,
        merchantReference: j['merchant_reference'] as String?,
        checkoutUrl: j['checkout_url'] as String,
        paymentUrl: j['payment_url'] as String?,
        checkoutSessionToken: j['checkout_session_token'] as String?,
        createdAt: j['created_at'] as String,
        expiresAt: j['expires_at'] as String,
        completedAt: j['completed_at'] as String?,
        settlementType: j['settlement_type'] as String?,
      );
}

class CreateRefundRequest {
  final int amount;
  final String currency;
  final String? reason;
  final String merchantReference;
  final Map<String, String>? metadata;

  const CreateRefundRequest({
    required this.amount,
    required this.currency,
    required this.merchantReference,
    this.reason,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'merchant_reference': merchantReference,
        if (reason != null) 'reason': reason,
        if (metadata != null) 'metadata': metadata,
      };
}

class Refund {
  final String refundId;
  final String sessionId;
  final String status;
  final int amount;
  final String currency;
  final String? merchantReference;
  final String? reason;
  final String? rail;
  final String? reversalReference;
  final String? failureReason;
  final String? failureMessage;
  final String createdAt;
  final String? completedAt;

  const Refund({
    required this.refundId,
    required this.sessionId,
    required this.status,
    required this.amount,
    required this.currency,
    this.merchantReference,
    this.reason,
    this.rail,
    this.reversalReference,
    this.failureReason,
    this.failureMessage,
    required this.createdAt,
    this.completedAt,
  });

  factory Refund.fromJson(Map<String, dynamic> j) => Refund(
        refundId: j['refund_id'] as String,
        sessionId: (j['session_id'] ?? j['payment_session_id']) as String,
        status: j['status'] as String,
        amount: j['amount'] as int,
        currency: j['currency'] as String,
        merchantReference: j['merchant_reference'] as String?,
        reason: j['reason'] as String?,
        rail: (j['rail'] ?? j['route_used']) as String?,
        reversalReference: (j['reversal_reference'] ?? j['bank_refund_ref'] ?? j['lypay_ref']) as String?,
        failureReason: (j['failure_reason'] ?? j['error_code']) as String?,
        failureMessage: (j['failure_message'] ?? j['error_message']) as String?,
        createdAt: j['created_at'] as String,
        completedAt: (j['completed_at'] ?? j['processed_at']) as String?,
      );
}

class RefundListResponse {
  final List<Refund> data;
  final int total;
  final int? page;
  final int? limit;

  const RefundListResponse({
    required this.data,
    required this.total,
    this.page,
    this.limit,
  });

  factory RefundListResponse.fromJson(Map<String, dynamic> j) => RefundListResponse(
        data: (j['data'] as List).map((e) => Refund.fromJson(e as Map<String, dynamic>)).toList(),
        total: j['total'] as int? ?? (j['data'] as List).length,
        page: j['page'] as int?,
        limit: j['limit'] as int?,
      );
}

class Mandate {
  final String mandateId;
  final String status;
  final String? payerAlias;
  final int amountLimit;
  final String currency;
  final String frequency;
  final String description;
  final String? consentUrl;
  final String? consentedAt;
  final String? cancelledAt;
  final String? cancelledBy;
  final String? merchantReference;
  final String createdAt;

  const Mandate({
    required this.mandateId,
    required this.status,
    this.payerAlias,
    required this.amountLimit,
    required this.currency,
    required this.frequency,
    required this.description,
    this.consentUrl,
    this.consentedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.merchantReference,
    required this.createdAt,
  });

  factory Mandate.fromJson(Map<String, dynamic> j) => Mandate(
        mandateId: j['mandate_id'] as String,
        status: j['status'] as String,
        payerAlias: j['payer_alias'] as String?,
        amountLimit: j['amount_limit'] as int,
        currency: j['currency'] as String,
        frequency: j['frequency'] as String,
        description: j['description'] as String,
        consentUrl: j['consent_url'] as String?,
        consentedAt: j['consented_at'] as String?,
        cancelledAt: j['cancelled_at'] as String?,
        cancelledBy: j['cancelled_by'] as String?,
        merchantReference: j['merchant_reference'] as String?,
        createdAt: j['created_at'] as String,
      );
}

class MandateListResponse {
  final List<Mandate> data;
  final int total;
  final int page;
  final int limit;

  const MandateListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory MandateListResponse.fromJson(Map<String, dynamic> j) => MandateListResponse(
        data: (j['data'] as List).map((e) => Mandate.fromJson(e as Map<String, dynamic>)).toList(),
        total: j['total'] as int,
        page: j['page'] as int,
        limit: j['limit'] as int,
      );
}

class MandateCharge {
  final String chargeId;
  final String mandateId;
  final String status;
  final int amount;
  final String currency;
  final String description;
  final String? merchantReference;
  final String? errorCode;
  final String? errorMessage;
  final String createdAt;
  final String? executedAt;

  const MandateCharge({
    required this.chargeId,
    required this.mandateId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.description,
    this.merchantReference,
    this.errorCode,
    this.errorMessage,
    required this.createdAt,
    this.executedAt,
  });

  factory MandateCharge.fromJson(Map<String, dynamic> j) => MandateCharge(
        chargeId: j['charge_id'] as String,
        mandateId: j['mandate_id'] as String,
        status: j['status'] as String,
        amount: j['amount'] as int,
        currency: j['currency'] as String,
        description: j['description'] as String,
        merchantReference: j['merchant_reference'] as String?,
        errorCode: j['error_code'] as String?,
        errorMessage: j['error_message'] as String?,
        createdAt: j['created_at'] as String,
        executedAt: j['executed_at'] as String?,
      );
}

class MandateChargeListResponse {
  final List<MandateCharge> data;
  final int total;
  final int page;
  final int limit;

  const MandateChargeListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory MandateChargeListResponse.fromJson(Map<String, dynamic> j) => MandateChargeListResponse(
        data: (j['data'] as List).map((e) => MandateCharge.fromJson(e as Map<String, dynamic>)).toList(),
        total: j['total'] as int,
        page: j['page'] as int,
        limit: j['limit'] as int,
      );
}

// ─── Presented Payments ─────────────────────────────────────────────────────

class PresentedPaymentCapabilitiesResponse {
  final String operatorId;
  final String deploymentRole;
  final PresentedPaymentCapabilities presentedPayments;

  const PresentedPaymentCapabilitiesResponse({
    required this.operatorId,
    required this.deploymentRole,
    required this.presentedPayments,
  });

  factory PresentedPaymentCapabilitiesResponse.fromJson(Map<String, dynamic> j) =>
      PresentedPaymentCapabilitiesResponse(
        operatorId: j['operator_id'] as String,
        deploymentRole: j['deployment_role'] as String,
        presentedPayments: PresentedPaymentCapabilities.fromJson(
          j['presented_payments'] as Map<String, dynamic>,
        ),
      );
}

class PresentedPaymentCapabilities {
  final List<String> supportedChannels;
  final List<String> supportedModes;
  final List<String> supportedIntents;
  final Map<String, bool> enabled;
  final bool hostedAuthRequired;
  final List<String> notes;

  const PresentedPaymentCapabilities({
    required this.supportedChannels,
    required this.supportedModes,
    required this.supportedIntents,
    required this.enabled,
    required this.hostedAuthRequired,
    required this.notes,
  });

  factory PresentedPaymentCapabilities.fromJson(Map<String, dynamic> j) =>
      PresentedPaymentCapabilities(
        supportedChannels: List<String>.from(j['supported_channels'] as List),
        supportedModes: List<String>.from(j['supported_modes'] as List),
        supportedIntents: List<String>.from(j['supported_intents'] as List),
        enabled: Map<String, bool>.from(j['enabled'] as Map),
        hostedAuthRequired: j['hosted_auth_required'] as bool,
        notes: List<String>.from(j['notes'] as List? ?? const []),
      );
}

class PresentmentPayload {
  final String type;
  final String uri;
  final String? qrPayload;
  final String? nfcPayload;
  final String? claimToken;

  const PresentmentPayload({
    required this.type,
    required this.uri,
    this.qrPayload,
    this.nfcPayload,
    this.claimToken,
  });

  factory PresentmentPayload.fromJson(Map<String, dynamic> j) => PresentmentPayload(
        type: j['type'] as String,
        uri: j['uri'] as String,
        qrPayload: j['qr_payload'] as String?,
        nfcPayload: j['nfc_payload'] as String?,
        claimToken: j['claim_token'] as String?,
      );
}

class AuthSurface {
  final String type;
  final String? url;
  final String? sessionId;
  final String? expiresAt;

  const AuthSurface({
    required this.type,
    this.url,
    this.sessionId,
    this.expiresAt,
  });

  factory AuthSurface.fromJson(Map<String, dynamic> j) => AuthSurface(
        type: j['type'] as String,
        url: j['url'] as String?,
        sessionId: j['session_id'] as String?,
        expiresAt: j['expires_at'] as String?,
      );
}

class Presentment {
  final String presentmentId;
  final String status;
  final String channel;
  final String mode;
  final String intent;
  final String amountMode;
  final int? amount;
  final String currency;
  final String description;
  final String? merchantReference;
  final PresentmentPayload? presentmentPayload;
  final String? paymentSessionId;
  final String? paymentUrl;
  final String? mandateId;
  final String? mandateConsentUrl;
  final AuthSurface? authSurface;
  final List<String> supportedAuthMethods;
  final String? claimedAt;
  final String? cancelledAt;
  final String expiresAt;
  final String createdAt;
  final String updatedAt;

  const Presentment({
    required this.presentmentId,
    required this.status,
    required this.channel,
    required this.mode,
    required this.intent,
    required this.amountMode,
    this.amount,
    required this.currency,
    required this.description,
    this.merchantReference,
    this.presentmentPayload,
    this.paymentSessionId,
    this.paymentUrl,
    this.mandateId,
    this.mandateConsentUrl,
    this.authSurface,
    required this.supportedAuthMethods,
    this.claimedAt,
    this.cancelledAt,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Presentment.fromJson(Map<String, dynamic> j) => Presentment(
        presentmentId: j['presentment_id'] as String,
        status: j['status'] as String,
        channel: j['channel'] as String,
        mode: j['mode'] as String,
        intent: j['intent'] as String,
        amountMode: j['amount_mode'] as String,
        amount: j['amount'] as int?,
        currency: j['currency'] as String,
        description: j['description'] as String,
        merchantReference: j['merchant_reference'] as String?,
        presentmentPayload: j['presentment_payload'] == null
            ? null
            : PresentmentPayload.fromJson(j['presentment_payload'] as Map<String, dynamic>),
        paymentSessionId: j['payment_session_id'] as String?,
        paymentUrl: j['payment_url'] as String?,
        mandateId: j['mandate_id'] as String?,
        mandateConsentUrl: j['mandate_consent_url'] as String?,
        authSurface: j['auth_surface'] == null
            ? null
            : AuthSurface.fromJson(j['auth_surface'] as Map<String, dynamic>),
        supportedAuthMethods: List<String>.from(j['supported_auth_methods'] as List? ?? const []),
        claimedAt: j['claimed_at'] as String?,
        cancelledAt: j['cancelled_at'] as String?,
        expiresAt: j['expires_at'] as String,
        createdAt: j['created_at'] as String,
        updatedAt: j['updated_at'] as String,
      );
}

class PresentmentStatusResponse {
  final String presentmentId;
  final String status;
  final String? paymentSessionId;
  final String? paymentUrl;
  final String? mandateId;
  final String? mandateConsentUrl;
  final AuthSurface? authSurface;
  final String expiresAt;
  final String updatedAt;

  const PresentmentStatusResponse({
    required this.presentmentId,
    required this.status,
    this.paymentSessionId,
    this.paymentUrl,
    this.mandateId,
    this.mandateConsentUrl,
    this.authSurface,
    required this.expiresAt,
    required this.updatedAt,
  });

  factory PresentmentStatusResponse.fromJson(Map<String, dynamic> j) => PresentmentStatusResponse(
        presentmentId: j['presentment_id'] as String,
        status: j['status'] as String,
        paymentSessionId: j['payment_session_id'] as String?,
        paymentUrl: j['payment_url'] as String?,
        mandateId: j['mandate_id'] as String?,
        mandateConsentUrl: j['mandate_consent_url'] as String?,
        authSurface: j['auth_surface'] == null
            ? null
            : AuthSurface.fromJson(j['auth_surface'] as Map<String, dynamic>),
        expiresAt: j['expires_at'] as String,
        updatedAt: j['updated_at'] as String,
      );
}

// ─── Alias ───────────────────────────────────────────────────────────────────

class AliasProfile {
  final String aliasUsername;
  final bool isActive;
  final String bankHandle;
  final String createdAt;

  const AliasProfile({
    required this.aliasUsername,
    required this.isActive,
    required this.bankHandle,
    required this.createdAt,
  });

  factory AliasProfile.fromJson(Map<String, dynamic> j) => AliasProfile(
        aliasUsername: j['alias_username'] as String,
        isActive: j['is_active'] as bool,
        bankHandle: j['bank_handle'] as String,
        createdAt: j['created_at'] as String,
      );
}

class LinkedAccount {
  final String iban;
  final String currency;
  final String? accountName;
  final String bankHandle;
  final bool isDefault;

  const LinkedAccount({
    required this.iban,
    required this.currency,
    this.accountName,
    required this.bankHandle,
    required this.isDefault,
  });

  factory LinkedAccount.fromJson(Map<String, dynamic> j) => LinkedAccount(
        iban: j['iban'] as String,
        currency: j['currency'] as String,
        accountName: j['account_name'] as String?,
        bankHandle: j['bank_handle'] as String,
        isDefault: j['is_default'] as bool? ?? false,
      );
}

class AliasAvailability {
  final String aliasUsername;
  final String status;
  final bool available;

  const AliasAvailability({
    required this.aliasUsername,
    required this.status,
    required this.available,
  });

  factory AliasAvailability.fromJson(Map<String, dynamic> j) => AliasAvailability(
        aliasUsername: j['alias_username'] as String,
        status: j['status'] as String,
        available: j['available'] as bool? ?? false,
      );
}

class RenameAliasRequest {
  final String currentAliasUsername;
  final String newAliasUsername;
  final String nationalId;

  const RenameAliasRequest({
    required this.currentAliasUsername,
    required this.newAliasUsername,
    required this.nationalId,
  });

  Map<String, dynamic> toJson() => {
        'current_alias_username': currentAliasUsername,
        'new_alias_username': newAliasUsername,
        'national_id': nationalId,
      };
}

class RenameAliasResult {
  final String aliasUsername;
  final String previousAliasUsername;
  final String retiredHandle;
  final bool previousRetired;
  final bool reauthenticationRequired;
  final String nextStep;
  final String message;

  const RenameAliasResult({
    required this.aliasUsername,
    required this.previousAliasUsername,
    required this.retiredHandle,
    required this.previousRetired,
    required this.reauthenticationRequired,
    required this.nextStep,
    required this.message,
  });

  factory RenameAliasResult.fromJson(Map<String, dynamic> j) => RenameAliasResult(
        aliasUsername: j['alias_username'] as String,
        previousAliasUsername: j['previous_alias_username'] as String,
        retiredHandle: j['retired_handle'] as String,
        previousRetired: j['previous_retired'] as bool,
        reauthenticationRequired: j['reauthentication_required'] as bool,
        nextStep: j['next_step'] as String,
        message: j['message'] as String,
      );
}

// ─── Open Banking ────────────────────────────────────────────────────────────

class Consent {
  final String consentId;
  final String status;
  final String bankHandle;
  final List<String> scopes;
  final String redirectUri;
  final String consentUrl;
  final String createdAt;
  final String expiresAt;

  const Consent({
    required this.consentId,
    required this.status,
    required this.bankHandle,
    required this.scopes,
    required this.redirectUri,
    required this.consentUrl,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Consent.fromJson(Map<String, dynamic> j) => Consent(
        consentId: j['consent_id'] as String,
        status: j['status'] as String,
        bankHandle: j['bank_handle'] as String,
        scopes: List<String>.from(j['scopes'] as List),
        redirectUri: j['redirect_uri'] as String,
        consentUrl: j['consent_url'] as String,
        createdAt: j['created_at'] as String,
        expiresAt: j['expires_at'] as String,
      );
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String scope;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.scope,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> j) => TokenResponse(
        accessToken: j['access_token'] as String,
        refreshToken: j['refresh_token'] as String,
        tokenType: j['token_type'] as String,
        expiresIn: j['expires_in'] as int,
        scope: j['scope'] as String,
      );
}

class OBAccount {
  final String accountId;
  final String iban;
  final String currency;
  final String accountType;
  final String? displayName;

  const OBAccount({
    required this.accountId,
    required this.iban,
    required this.currency,
    required this.accountType,
    this.displayName,
  });

  factory OBAccount.fromJson(Map<String, dynamic> j) => OBAccount(
        accountId: j['account_id'] as String,
        iban: j['iban'] as String,
        currency: j['currency'] as String,
        accountType: j['account_type'] as String,
        displayName: j['display_name'] as String?,
      );
}

class OBTransaction {
  final String transactionId;
  final int amount;
  final String currency;
  final String direction;
  final String? narrative;
  final String? reference;
  final String valueDate;
  final String bookingDate;

  const OBTransaction({
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.direction,
    this.narrative,
    this.reference,
    required this.valueDate,
    required this.bookingDate,
  });

  factory OBTransaction.fromJson(Map<String, dynamic> j) => OBTransaction(
        transactionId: j['transaction_id'] as String,
        amount: j['amount'] as int,
        currency: j['currency'] as String,
        direction: j['direction'] as String,
        narrative: j['narrative'] as String?,
        reference: j['reference'] as String?,
        valueDate: j['value_date'] as String,
        bookingDate: j['booking_date'] as String,
      );
}

// ─── Identity ────────────────────────────────────────────────────────────────

class ResolveResult {
  final String nptHandle;
  final String iban;
  final String bankHandle;
  final String currency;

  const ResolveResult({
    required this.nptHandle,
    required this.iban,
    required this.bankHandle,
    required this.currency,
  });

  factory ResolveResult.fromJson(Map<String, dynamic> j) => ResolveResult(
        nptHandle: j['npt_handle'] as String,
        iban: j['iban'] as String,
        bankHandle: j['bank_handle'] as String,
        currency: j['currency'] as String,
      );
}

class BankEntry {
  final String bankHandle;
  final String displayName;
  final String country;
  final bool obEnabled;

  const BankEntry({
    required this.bankHandle,
    required this.displayName,
    required this.country,
    required this.obEnabled,
  });

  factory BankEntry.fromJson(Map<String, dynamic> j) => BankEntry(
        bankHandle: j['bank_handle'] as String,
        displayName: j['display_name'] as String,
        country: j['country'] as String,
        obEnabled: j['ob_enabled'] as bool? ?? false,
      );
}
