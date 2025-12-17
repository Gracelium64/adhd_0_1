package shadowapp.grace6424.adhd

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import shadowapp.grace6424.adhd.R

object NotificationHelper {
    private const val CHANNEL_ID = "daily_quote_channel_v2"
    private const val CHANNEL_SILENT_ID = "daily_quote_channel_silent_v1"
    private const val CHANNEL_NAME = "Daily Quotes"
    private const val CHANNEL_DESC = "Daily tip of the day notification at startOfDay"
    private const val DL_CHANNEL_ID = "deadline_alerts_channel_v3"
    private const val DL_CHANNEL_SILENT_ID = "deadline_alerts_channel_silent_v1"
    private const val DL_CHANNEL_NAME = "Task Deadlines"
    private const val DL_CHANNEL_DESC = "Alerts for deadlines due today/tomorrow and weekly tasks for today"
    private const val WEATHER_CHANNEL_ID = "daily_weather_channel_v1"
    private const val WEATHER_CHANNEL_NAME = "Daily Weather"
    private const val WEATHER_CHANNEL_DESC = "Silent daily weather summary one minute before the daily quote"
    private const val PREFS = "adhd_prefs"
    private const val KEY_NEXT_QUOTE = "nextQuote"
    private const val KEY_NEXT_DEADLINE_MSG = "nextDeadlineMsg"

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val soundUri = Uri.parse("android.resource://${context.packageName}/raw/my_sound")
            val attrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH).apply {
                description = CHANNEL_DESC
                setSound(soundUri, attrs)
                enableVibration(true)
            }
            nm.createNotificationChannel(channel)

            val silentChannel = NotificationChannel(CHANNEL_SILENT_ID, "$CHANNEL_NAME (Silent)", NotificationManager.IMPORTANCE_HIGH).apply {
                description = CHANNEL_DESC
                setSound(null, null)
                enableVibration(true)
            }
            nm.createNotificationChannel(silentChannel)

            val dlChannel = NotificationChannel(DL_CHANNEL_ID, DL_CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH).apply {
                description = DL_CHANNEL_DESC
                setSound(soundUri, attrs)
                enableVibration(true)
            }
            nm.createNotificationChannel(dlChannel)

            val dlSilentChannel = NotificationChannel(DL_CHANNEL_SILENT_ID, "$DL_CHANNEL_NAME (Silent)", NotificationManager.IMPORTANCE_HIGH).apply {
                description = DL_CHANNEL_DESC
                setSound(null, null)
                enableVibration(true)
            }
            nm.createNotificationChannel(dlSilentChannel)

            // Silent weather channel (no sound, no vibration)
            val weatherChannel = NotificationChannel(WEATHER_CHANNEL_ID, WEATHER_CHANNEL_NAME, NotificationManager.IMPORTANCE_LOW).apply {
                description = WEATHER_CHANNEL_DESC
                setSound(null, null)
                enableVibration(false)
            }
            nm.createNotificationChannel(weatherChannel)
        }
    }

    fun showDailyQuote(context: Context) {
        ensureChannel(context)
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        // Prefer a previously saved quote from Flutter, fallback to provided body, then default
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val saved = prefs.getString(KEY_NEXT_QUOTE, null)
        if (saved != null) {
            prefs.edit().remove(KEY_NEXT_QUOTE).apply()
        }
        // Create an intent that opens the app when the notification is tapped
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            action = "shadowapp.grace6424.adhd.ACTION_OPEN_DAILYS"
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("route", "dailys")
        }
        val contentIntent = PendingIntent.getActivity(
            context,
            1001,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

    val text = saved ?: "Make today count."
        val notification = NotificationCompat.Builder(context, WEATHER_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Good morning")
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(contentIntent)
            .setAutoCancel(true)
            .build()
    nm.notify(1001, notification)
    }

    fun showDeadlineAlert(context: Context) {
        ensureChannel(context)
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            action = "shadowapp.grace6424.adhd.ACTION_OPEN_DAILYS"
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("route", "dailys")
        }
        val contentIntent = PendingIntent.getActivity(
            context,
            11001,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val silent = prefs.getBoolean(AlarmScheduler.KEY_SILENT_NOTIFICATION, false)
        val saved = prefs.getString(KEY_NEXT_DEADLINE_MSG, null)
        if (saved != null) {
            prefs.edit().remove(KEY_NEXT_DEADLINE_MSG).apply()
        }
        val text = saved ?: "Deadlines due today or tomorrow, or weekly tasks today."
        val channelId = if (silent) DL_CHANNEL_SILENT_ID else DL_CHANNEL_ID
        val soundUri = Uri.parse("android.resource://${context.packageName}/raw/my_sound")
        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Today's focus")
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(contentIntent)
            .setAutoCancel(true)

        if (!silent && Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            builder.setSound(soundUri)
        }

        nm.notify(11001, builder.build())
    }

    fun showDeadlineAlertWithBody(context: Context, text: String) {
        ensureChannel(context)
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            action = "shadowapp.grace6424.adhd.ACTION_OPEN_DAILYS"
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("route", "dailys")
        }
        val contentIntent = PendingIntent.getActivity(
            context,
            11001,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val silent = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getBoolean(AlarmScheduler.KEY_SILENT_NOTIFICATION, false)
        val channelId = if (silent) DL_CHANNEL_SILENT_ID else DL_CHANNEL_ID
        val soundUri = Uri.parse("android.resource://${context.packageName}/raw/my_sound")
        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Today's focus")
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(contentIntent)
            .setAutoCancel(true)

        if (!silent && Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            builder.setSound(soundUri)
        }

        nm.notify(11001, builder.build())
    }
    
    fun showWeatherNowWithBody(context: Context, body: String) {
        ensureChannel(context)
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            action = "shadowapp.grace6424.adhd.ACTION_OPEN_DAILYS"
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("route", "dailys")
        }
        val contentIntent = PendingIntent.getActivity(
            context,
            12001,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val text = body
            // Try to use a saved weather icon if available
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val iconName = prefs.getString(AlarmScheduler.KEY_NEXT_WEATHER_ICON, null)
            val smallIconRes = if (iconName != null) {
                val rid = context.resources.getIdentifier(iconName, "drawable", context.packageName)
                if (rid != 0) rid else R.mipmap.ic_launcher
            } else {
                R.mipmap.ic_launcher
            }

            val notification = NotificationCompat.Builder(context, WEATHER_CHANNEL_ID)
                .setSmallIcon(smallIconRes)
                .setContentTitle("Weather")
                .setContentText(text)
                .setStyle(NotificationCompat.BigTextStyle().bigText(text))
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setContentIntent(contentIntent)
                .setAutoCancel(true)
                .build()
        nm.notify(1201, notification)
    }
}
