package shadowapp.grace6424.adhd01

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.app.AlarmManager
import android.content.Intent
import android.provider.Settings
import android.net.Uri
import android.os.PowerManager
import io.flutter.plugin.common.MethodChannel.Result
import android.app.NotificationManager
import android.content.pm.ApplicationInfo

class MainActivity : FlutterActivity() {
	private val channel = "shadowapp.grace6424.adhd/alarm"
	private var pendingRoute: String? = null

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"hasExactAlarmPermission" -> {
						val am = getSystemService(ALARM_SERVICE) as AlarmManager
						val allowed = if (Build.VERSION.SDK_INT >= 31) {
							am.canScheduleExactAlarms()
						} else {
							true
						}
						result.success(allowed)
					}
					"requestExactAlarmPermission" -> {
						if (Build.VERSION.SDK_INT >= 31) {
							// Try the request action first
							try {
								val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
									data = Uri.parse("package:" + packageName)
									addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
								}
								startActivity(intent)
							} catch (_: Exception) {
								// Fallback to app details settings if above fails
								try {
									val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
										data = Uri.fromParts("package", packageName, null)
										addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
									}
									startActivity(fallback)
								} catch (_: Exception) {}
							}
						}
						result.success(null)
					}
					"saveStartOfDay" -> {
						val hour = call.argument<Int>("hour") ?: 7
						val minute = call.argument<Int>("minute") ?: 15
						AlarmScheduler.saveStartOfDay(applicationContext, hour, minute)
						result.success(null)
					}
						"saveNextQuote" -> {
							val quote = call.argument<String>("quote") ?: ""
							AlarmScheduler.saveNextQuote(applicationContext, quote)
							result.success(null)
						}
					"scheduleAlarm" -> {
						val hour = call.argument<Int>("hour") ?: 7
						val minute = call.argument<Int>("minute") ?: 15
						AlarmScheduler.schedule(applicationContext, hour, minute, nextOnly = false)
						result.success(null)
					}
					"scheduleNextAlarm" -> {
						val hour = call.argument<Int>("hour") ?: 7
						val minute = call.argument<Int>("minute") ?: 15
						AlarmScheduler.schedule(applicationContext, hour, minute, nextOnly = true)
						result.success(null)
					}
					"scheduleNextDeadlineAlarm" -> {
						val hour = call.argument<Int>("hour") ?: 7
						val minute = call.argument<Int>("minute") ?: 15
						val offsetSec = call.argument<Int>("offsetSec") ?: 10
						AlarmScheduler.scheduleDeadline(applicationContext, hour, minute, offsetSec, nextOnly = true)
						result.success(null)
					}
					"saveNextDeadlineMessage" -> {
						val msg = call.argument<String>("message")
						AlarmScheduler.saveNextDeadlineMessage(applicationContext, msg)
						result.success(null)
					}
					"saveNextWeatherMessage" -> {
						val msg = call.argument<String>("message")
						AlarmScheduler.saveNextWeatherMessage(applicationContext, msg)
						result.success(null)
					}
					"saveNextWeatherPrefs" -> {
						val lat = call.argument<Double>("lat") ?: 0.0
						val lon = call.argument<Double>("lon") ?: 0.0
						val label = call.argument<String>("label")
						val timezone = call.argument<String>("timezone")
						AlarmScheduler.saveNextWeatherPrefs(applicationContext, lat, lon, label, timezone)
						result.success(null)
					}
					"scheduleWeather" -> {
						val hour = call.argument<Int>("hour") ?: 7
						val minute = call.argument<Int>("minute") ?: 14
						val offsetSec = call.argument<Int>("offsetSec") ?: -60
						AlarmScheduler.scheduleWeather(applicationContext, hour, minute, offsetSec, nextOnly = false)
						result.success(null)
					}
					"scheduleWeatherIn" -> {
						val seconds = call.argument<Int>("seconds") ?: 300
						AlarmScheduler.scheduleWeatherIn(applicationContext, seconds)
						result.success(null)
					}
					"showDeadlineNow" -> {
						NotificationHelper.showDeadlineAlert(applicationContext)
						result.success(null)
					}
					"showDeadlineNowWithBody" -> {
						val body = call.argument<String>("body") ?: "Deadlines due today or tomorrow, or weekly tasks today."
						NotificationHelper.showDeadlineAlertWithBody(applicationContext, body)
						result.success(null)
					}
					"showWeatherNowWithBody" -> {
						val body = call.argument<String>("body") ?: "Weather"
						NotificationHelper.showWeatherNowWithBody(applicationContext, body)
						result.success(null)
					}
					"scheduleDeadlineIn" -> {
						val sec = call.argument<Int>("seconds") ?: 10
						AlarmScheduler.scheduleDeadlineIn(applicationContext, sec)
						result.success(null)
					}
					"debugPrefsSnapshot" -> {
						val snapshot = AlarmScheduler.getPrefsSnapshot(applicationContext)
						result.success(snapshot)
					}
					"diagnosticSnapshot" -> {
						val map = HashMap<String, Any?>()
						val pkg = packageName
						map["packageName"] = pkg
						map["sdkInt"] = Build.VERSION.SDK_INT
						try {
							val info: ApplicationInfo = applicationInfo
							map["targetSdk"] = info.targetSdkVersion
						} catch (_: Exception) {}

						// Notifications enabled
						try {
							val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
							val areEnabled = if (Build.VERSION.SDK_INT >= 24) nm.areNotificationsEnabled() else true
							map["areNotificationsEnabled"] = areEnabled

							if (Build.VERSION.SDK_INT >= 26) {
								val ch = nm.getNotificationChannel("deadline_alerts_channel_v3")
								map["channelExists"] = (ch != null)
								if (ch != null) {
									map["channelId"] = ch.id
									map["channelName"] = ch.name?.toString()
									map["channelImportance"] = ch.importance
									map["channelDesc"] = ch.description
									map["channelSoundUri"] = ch.sound?.toString()
									map["channelCanBypassDnd"] = ch.canBypassDnd()
									map["channelVibrationEnabled"] = (ch.vibrationPattern != null)
									map["channelAudioUsage"] = ch.audioAttributes?.usage
									map["channelAudioContentType"] = ch.audioAttributes?.contentType
								}
							}
						} catch (_: Exception) {}

						// Exact alarm permission (Android 12+)
						try {
							val am = getSystemService(ALARM_SERVICE) as AlarmManager
							val exactAllowed = if (Build.VERSION.SDK_INT >= 31) am.canScheduleExactAlarms() else true
							map["canScheduleExactAlarms"] = exactAllowed
						} catch (_: Exception) {}

						// Battery optimizations
						try {
							val pm = getSystemService(POWER_SERVICE) as PowerManager
							map["isIgnoringBatteryOptimizations"] = pm.isIgnoringBatteryOptimizations(pkg)
						} catch (_: Exception) {}

						// Verify custom sound resource exists
						try {
							val resId = resources.getIdentifier("my_sound", "raw", pkg)
							map["rawMySoundExists"] = (resId != 0)
						} catch (_: Exception) {}

						result.success(map)
					}
					"openDeadlineChannelSettings" -> {
						try {
							val intent = Intent(android.provider.Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS).apply {
								putExtra(android.provider.Settings.EXTRA_APP_PACKAGE, packageName)
								putExtra(android.provider.Settings.EXTRA_CHANNEL_ID, "deadline_alerts_channel_v3")
								addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
							}
							startActivity(intent)
							result.success(null)
						} catch (_: Exception) {
							result.error("ERR_CHANNEL_SETTINGS", "Unable to open channel settings", null)
						}
					}
					"cancelAlarm" -> {
						AlarmScheduler.cancel(applicationContext)
						result.success(null)
					}
					"cancelDeadlineAlarm" -> {
						AlarmScheduler.cancelDeadline(applicationContext)
						result.success(null)
					}
					"openAppNotificationSettings" -> {
						try {
							val intent = Intent().apply {
								action = Settings.ACTION_APP_NOTIFICATION_SETTINGS
								putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
								addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
							}
							startActivity(intent)
							result.success(null)
						} catch (_: Exception) {
							try {
								val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
									data = Uri.fromParts("package", packageName, null)
									addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
								}
								startActivity(fallback)
								result.success(null)
							} catch (_: Exception) {
								result.error("ERR_SETTINGS", "Unable to open settings", null)
							}
						}
					}
					"isIgnoringBatteryOptimizations" -> {
						val pm = getSystemService(POWER_SERVICE) as PowerManager
						val ignoring = pm.isIgnoringBatteryOptimizations(packageName)
						result.success(ignoring)
					}
					"requestIgnoreBatteryOptimizations" -> {
						try {
							val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
								data = Uri.parse("package:" + packageName)
								addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
							}
							startActivity(intent)
							result.success(null)
						} catch (_: Exception) {
							result.error("ERR_BATTERY", "Unable to open battery optimization screen", null)
						}
					}
						"getInitialRouteFromIntent" -> {
							val r = intent?.getStringExtra("route") ?: pendingRoute
							pendingRoute = null
							result.success(r)
						}
					else -> result.notImplemented()
				}
			}
	}

	override fun onNewIntent(intent: Intent) {
		super.onNewIntent(intent)
		setIntent(intent)
		// When app is resumed via notification tap, push a route hint for Flutter side
		pendingRoute = intent.getStringExtra("route")
	}
}
