package shadowapp.grace6424.adhd01

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.ExistingWorkPolicy
import androidx.work.ListenableWorker
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class WeatherWorker(appContext: Context, workerParams: WorkerParameters) : Worker(appContext, workerParams) {

    override fun doWork(): Result {
        val lat = inputData.getDouble("lat", 0.0)
        val lon = inputData.getDouble("lon", 0.0)
        val label = inputData.getString("label") ?: ""
        val timezone = inputData.getString("timezone") ?: "UTC"

        try {
            val client = OkHttpClient.Builder()
                .callTimeout(8, TimeUnit.SECONDS)
                .build()

            val url = "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=$timezone"
            val req = Request.Builder().url(url).get().build()
            val resp = client.newCall(req).execute()
            if (!resp.isSuccessful) {
                resp.close()
                return Result.retry()
            }
            val bodyStr = resp.body?.string() ?: ""
            resp.close()
            if (bodyStr.isEmpty()) return Result.retry()

            val root = JSONObject(bodyStr)
            if (!root.has("daily")) return Result.retry()
            val daily = root.getJSONObject("daily")
            val codes = daily.getJSONArray("weathercode")
            val tmax = daily.getJSONArray("temperature_2m_max")
            val tmin = daily.getJSONArray("temperature_2m_min")
            val dates = daily.getJSONArray("time")
            if (codes.length() == 0) return Result.retry()

            val code = codes.getInt(0)
            val max = tmax.getDouble(0)
            val min = tmin.getDouble(0)
            val date = dates.getString(0)


            val iconName = when (code) {
                0 -> "ic_weather_clear"
                in 1..3 -> "ic_weather_partly"
                in 45..48 -> "ic_weather_fog"
                in 51..67 -> "ic_weather_drizzle"
                in 71..77 -> "ic_weather_snow"
                in 80..82 -> "ic_weather_rain"
                in 95..99 -> "ic_weather_thunder"
                else -> "ic_weather_partly"
            }

            val summary = composeMessage(code, max, min, label)

            // Persist a preview and chosen icon for native notification
            val prefs = applicationContext.getSharedPreferences(AlarmScheduler.PREFS, Context.MODE_PRIVATE)
            prefs.edit().putString(AlarmScheduler.KEY_NEXT_WEATHER_MSG, summary).putString(AlarmScheduler.KEY_NEXT_WEATHER_ICON, iconName).apply()

            NotificationHelper.showWeatherNowWithBody(applicationContext, summary)

            return Result.success()
        } catch (e: Exception) {
            return Result.retry()
        }
    }

    private fun composeMessage(code: Int, max: Double, min: Double, label: String): String {
        val desc = when (code) {
            in 0..0 -> "Clear"
            in 1..3 -> "Mainly clear"
            in 45..48 -> "Fog"
            in 51..67 -> "Drizzle"
            in 71..77 -> "Snow"
            in 80..82 -> "Rain showers"
            in 95..99 -> "Thunderstorm"
            else -> "Weather"
        }
        val loc = if (label.isNotEmpty()) "$label: " else ""
        val temps = "High ${max.roundToInt()}°C / Low ${min.roundToInt()}°C"
        return "$loc$desc — $temps"
    }
}

// Helpers
private fun Double.roundToInt(): Int = Math.round(this).toInt()
