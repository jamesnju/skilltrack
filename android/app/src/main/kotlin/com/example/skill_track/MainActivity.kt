package com.example.skill_track

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.example.skill_track/focus_mode"

    private val preferencesName = "focustech_focus_mode"
    private val savedFilterKey = "previous_interruption_filter"
    private val changedByAppKey = "dnd_changed_by_app"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            when (call.method) {

                "hasDndAccess" -> {
                    result.success(
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                            notificationManager.isNotificationPolicyAccessGranted
                    )
                }

                "openDndSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(
                            Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS
                        )
                        startActivity(intent)
                    }

                    result.success(null)
                }

                "enableDnd" -> {

                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                        result.success(false)

                    } else if (!notificationManager.isNotificationPolicyAccessGranted) {
                        result.success(false)

                    } else {
                        try {
                            val prefs = getSharedPreferences(
                                preferencesName,
                                Context.MODE_PRIVATE
                            )

                            // Save the existing DND setting only once.
                            if (!prefs.getBoolean(changedByAppKey, false)) {

                                prefs.edit()
                                    .putInt(
                                        savedFilterKey,
                                        notificationManager.currentInterruptionFilter
                                    )
                                    .putBoolean(changedByAppKey, true)
                                    .apply()
                            }

                            notificationManager.setInterruptionFilter(
                                NotificationManager.INTERRUPTION_FILTER_NONE
                            )

                            result.success(true)

                        } catch (exception: SecurityException) {
                            result.error(
                                "DND_PERMISSION",
                                exception.message,
                                null
                            )
                        } catch (exception: Exception) {
                            result.error(
                                "DND_ERROR",
                                exception.message,
                                null
                            )
                        }
                    }
                }

                "restoreDnd" -> {

                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                        result.success(true)

                    } else if (!notificationManager.isNotificationPolicyAccessGranted) {
                        result.success(false)

                    } else {
                        try {
                            val prefs = getSharedPreferences(
                                preferencesName,
                                Context.MODE_PRIVATE
                            )

                            if (prefs.getBoolean(changedByAppKey, false)) {

                                val previousFilter = prefs.getInt(
                                    savedFilterKey,
                                    NotificationManager.INTERRUPTION_FILTER_ALL
                                )

                                notificationManager.setInterruptionFilter(
                                    previousFilter
                                )

                                prefs.edit()
                                    .remove(savedFilterKey)
                                    .putBoolean(changedByAppKey, false)
                                    .apply()
                            }

                            result.success(true)

                        } catch (exception: SecurityException) {
                            result.error(
                                "DND_PERMISSION",
                                exception.message,
                                null
                            )
                        } catch (exception: Exception) {
                            result.error(
                                "DND_ERROR",
                                exception.message,
                                null
                            )
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}