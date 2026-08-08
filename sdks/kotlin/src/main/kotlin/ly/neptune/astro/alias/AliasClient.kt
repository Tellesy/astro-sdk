package ly.neptune.astro.alias

import ly.neptune.astro.HttpEngine
import ly.neptune.astro.models.*

class AliasClient internal constructor(private val engine: HttpEngine) {

    suspend fun getProfile(alias: String): AliasProfile =
        engine.get("/alias/$alias")

    suspend fun getAccounts(alias: String): AliasAccountsResponse =
        engine.get("/alias/$alias/accounts")

    suspend fun deactivate(alias: String): AliasProfile =
        engine.post("/alias/$alias/deactivate")

    /** Bank-server only. UNKNOWN is a registry transport state, not availability. */
    suspend fun availability(alias: String): AliasAvailability =
        engine.get("/alias/$alias/availability")

    /** Bank-server only. Identity permanently retires the previous NPT name. */
    suspend fun rename(request: RenameAliasRequest): RenameAliasResult =
        engine.patch("/alias/rename", request)

    suspend fun resolve(alias: String): ResolveResult =
        engine.get("/identity/resolve", mapOf("alias" to alias))
}
