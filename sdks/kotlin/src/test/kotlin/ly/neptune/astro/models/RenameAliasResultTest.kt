package ly.neptune.astro.models

import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class RenameAliasResultTest {
    @Test
    fun `rename result preserves retirement and forced reauthentication metadata`() {
        val result = Json.decodeFromString<RenameAliasResult>(
            """{"alias_username":"ahmed.ali","previous_alias_username":"ahmed","retired_handle":"ahmed","previous_retired":true,"reauthentication_required":true,"next_step":"Sign in again with ahmed.ali.","message":"Alias renamed."}"""
        )

        assertEquals("ahmed", result.retiredHandle)
        assertTrue(result.previousRetired)
        assertTrue(result.reauthenticationRequired)
        assertEquals("Sign in again with ahmed.ali.", result.nextStep)
    }
}
