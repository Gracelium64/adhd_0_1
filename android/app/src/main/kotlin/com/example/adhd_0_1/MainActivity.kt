package shadowapp.grace6424.adhd01

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.app.AlarmManager
import android.content.Intent
import android.provider.Settings
import android.net.Uri

class MainActivity : FlutterActivity() {
	private val channel = "shadowapp.grace6424.adhd01/alarm"

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
					"scheduleAlarm" -> {
						val hour = call.argument<Int>("hour") ?: 7
						val minute = call.argument<Int>("minute") ?: 15
						AlarmScheduler.schedule(applicationContext, hour, minute, nextOnly = false)
						result.success(null)
					}
					else -> result.notImplemented()
				}
			}
	}
}
