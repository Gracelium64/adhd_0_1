package shadowapp.grace6424.adhd01

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class WeatherReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Read saved message and show notification via NotificationHelper
        val prefs = context.getSharedPreferences(AlarmScheduler.PREFS, Context.MODE_PRIVATE)
        val body = prefs.getString(AlarmScheduler.KEY_NEXT_WEATHER_MSG, null)
        if (body != null) {
            NotificationHelper.showWeatherNowWithBody(context, body)
        }
        // Reschedule next day's weather if the app saved a start-of-day
        val start = prefs.getString(AlarmScheduler.KEY_START_OF_DAY, null)
        if (start != null) {
            val parts = start.split(":")
            if (parts.size == 2) {
                try {
                    val hour = parts[0].toInt()
                    val minute = parts[1].toInt()
                    AlarmScheduler.scheduleWeather(context, hour, minute, -60, false)
                } catch (e: Exception) {
                    // ignore
                }
            }
        }
    }
}
