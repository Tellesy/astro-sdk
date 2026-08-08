package ly.neptune.astro

import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.cio.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import ly.neptune.astro.models.AstroError
import ly.neptune.astro.payments.PaymentsClient
import ly.neptune.astro.alias.AliasClient
import ly.neptune.astro.openbanking.OpenBankingClient
import ly.neptune.astro.identity.IdentityClient
import ly.neptune.astro.presentments.PresentmentsClient
import ly.neptune.astro.webhooks.WebhookVerifier

data class AstroConfig(
    val baseUrl: String,
    val merchantKey: String? = null,
    val bankKey: String? = null,
    val adminKey: String? = null,
    val timeoutMs: Long = 30_000
)

class AstroRequestException(
    val status: Int,
    val code: String,
    message: String,
    val detail: String? = null,
    val requestId: String? = null
) : Exception("[$code] $message")

internal class HttpEngine(private val config: AstroConfig) {

    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    val client = HttpClient(CIO) {
        install(ContentNegotiation) { json(json) }
        engine {
            requestTimeout = config.timeoutMs
        }
    }

    private fun HttpRequestBuilder.applyAuth() {
        config.merchantKey?.let { header("Authorization", "Bearer $it") }
        config.bankKey?.let { header("X-OpenWave-Bank-Key", it) }
        config.adminKey?.let { header("X-OpenWave-Admin-Key", it) }
    }

    fun baseUrl(path: String) = config.baseUrl.trimEnd('/') + path

    suspend inline fun <reified T> get(path: String, params: Map<String, String?> = emptyMap()): T {
        val response = client.get(baseUrl(path)) {
            applyAuth()
            params.forEach { (k, v) -> v?.let { parameter(k, it) } }
        }
        return handleResponse(response)
    }

    suspend inline fun <reified T> post(path: String, body: Any? = null, extraHeaders: Map<String, String> = emptyMap()): T {
        val response = client.post(baseUrl(path)) {
            applyAuth()
            extraHeaders.forEach { (k, v) -> header(k, v) }
            body?.let {
                contentType(ContentType.Application.Json)
                setBody(it)
            }
        }
        return handleResponse(response)
    }

    suspend inline fun <reified T> patch(path: String, body: Any? = null): T {
        val response = client.patch(baseUrl(path)) {
            applyAuth()
            body?.let {
                contentType(ContentType.Application.Json)
                setBody(it)
            }
        }
        return handleResponse(response)
    }

    suspend inline fun <reified T> delete(path: String): T {
        val response = client.delete(baseUrl(path)) { applyAuth() }
        return handleResponse(response)
    }

    suspend inline fun <reified T> handleResponse(response: HttpResponse): T {
        if (!response.status.isSuccess()) {
            val payload = runCatching { json.parseToJsonElement(response.bodyAsText()).jsonObject }.getOrNull()
            val errObj = (payload?.get("error") as? JsonObject) ?: payload
            throw AstroRequestException(
                status = response.status.value,
                code = errObj?.get("code")?.jsonPrimitive?.contentOrNull ?: "UNKNOWN_ERROR",
                message = errObj?.get("message")?.jsonPrimitive?.contentOrNull ?: "HTTP ${response.status.value}",
                detail = errObj?.get("detail")?.jsonPrimitive?.contentOrNull,
                requestId = errObj?.get("request_id")?.jsonPrimitive?.contentOrNull
            )
        }
        return response.body()
    }

    fun close() = client.close()
}

class AstroClient(config: AstroConfig) : AutoCloseable {

    private val engine = HttpEngine(config)

    val payments = PaymentsClient(engine)
    val alias = AliasClient(engine)
    val openBanking = OpenBankingClient(engine)
    val identity = IdentityClient(engine)
    val presentments = PresentmentsClient(engine)
    val webhooks = WebhookVerifier

    override fun close() = engine.close()
}

fun astroClient(block: AstroConfig.() -> Unit): AstroClient {
    val config = AstroConfig(baseUrl = "").apply(block)
    return AstroClient(config)
}
