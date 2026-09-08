package et.wavemart.app

import android.content.ComponentCallbacks2
import android.os.Bundle
import android.util.Log
import androidx.activity.enableEdgeToEdge
import androidx.credentials.ClearCredentialStateRequest
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.CreateRestoreCredentialRequest
import androidx.credentials.GetRestoreCredentialOption
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity: FlutterFragmentActivity() {
    private val TAG = "WavemartMainActivity"
    private val RESTORE_CHANNEL = "et.wavemart.app/restore_credentials"
    private val MEMORY_CHANNEL = "et.wavemart.app/memory"

    private var memoryMethodChannel: MethodChannel? = null
    private val activityScope = CoroutineScope(Dispatchers.Main)

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        memoryMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEMORY_CHANNEL)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RESTORE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "createRestoreCredential" -> {
                    val credentialData = call.argument<String>("credentialData")
                    if (credentialData.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "credentialData must not be empty", null)
                        return@setMethodCallHandler
                    }

                    activityScope.launch {
                        try {
                            val credentialManager = CredentialManager.create(this@MainActivity)
                            val request = CreateRestoreCredentialRequest(credentialData)
                            credentialManager.createCredential(this@MainActivity, request)
                            result.success(true)
                        } catch (e: Exception) {
                            Log.w(TAG, "Failed to create restore credential via CredentialManager", e)
                            // Fallback: save to local SharedPreferences marked for backup
                            try {
                                val prefs = getSharedPreferences("wavemart_restore_backup", MODE_PRIVATE)
                                prefs.edit().putString("restore_token", credentialData).apply()
                                result.success(true)
                            } catch (fallbackError: Exception) {
                                result.error("CREATE_FAILED", e.message, null)
                            }
                        }
                    }
                }
                "getRestoreCredential" -> {
                    activityScope.launch {
                        try {
                            val credentialManager = CredentialManager.create(this@MainActivity)
                            val option = GetRestoreCredentialOption()
                            val request = GetCredentialRequest.Builder()
                                .addCredentialOption(option)
                                .build()

                            val response = credentialManager.getCredential(this@MainActivity, request)
                            val credential = response.credential
                            val data = credential.data.getString("androidx.credentials.BUNDLE_KEY_RESTORE_KEY")
                                ?: credential.data.getString("credential")

                            if (!data.isNullOrBlank()) {
                                result.success(data)
                            } else {
                                // Fallback: check backup prefs
                                val prefs = getSharedPreferences("wavemart_restore_backup", MODE_PRIVATE)
                                val fallbackToken = prefs.getString("restore_token", null)
                                result.success(fallbackToken)
                            }
                        } catch (e: Exception) {
                            Log.d(TAG, "No restore credential available or error fetching: ${e.message}")
                            // Check fallback prefs if any
                            val prefs = getSharedPreferences("wavemart_restore_backup", MODE_PRIVATE)
                            val fallbackToken = prefs.getString("restore_token", null)
                            result.success(fallbackToken)
                        }
                    }
                }
                "clearRestoreCredential" -> {
                    activityScope.launch {
                        try {
                            val credentialManager = CredentialManager.create(this@MainActivity)
                            credentialManager.clearCredentialState(ClearCredentialStateRequest())
                        } catch (e: Exception) {
                            Log.w(TAG, "Error clearing credential state: ${e.message}")
                        }
                        try {
                            val prefs = getSharedPreferences("wavemart_restore_backup", MODE_PRIVATE)
                            prefs.edit().remove("restore_token").apply()
                        } catch (_: Exception) {}
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        // Notify Flutter when app UI is hidden or memory is low
        if (level >= ComponentCallbacks2.TRIM_MEMORY_UI_HIDDEN) {
            try {
                memoryMethodChannel?.invokeMethod("onTrimMemory", mapOf("level" to level))
            } catch (e: Exception) {
                Log.w(TAG, "Failed to send onTrimMemory to Flutter engine", e)
            }
        }
    }
}

