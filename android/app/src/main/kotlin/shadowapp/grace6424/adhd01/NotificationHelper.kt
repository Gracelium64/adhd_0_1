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

object NotificationHelper {
    private const val CHANNEL_ID = "daily_quote_channel_v2"
    private const val CHANNEL_NAME = "Daily Quotes"
    private const val CHANNEL_DESC = "Daily tip of the day notification at startOfDay"
    private const val DL_CHANNEL_ID = "deadline_alerts_channel_v3"
    private const val DL_CHANNEL_NAME = "Task Deadlines"
    private const val DL_CHANNEL_DESC = "Alerts for deadlines due today/tomorrow and weekly tasks for today"
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

            val dlChannel = NotificationChannel(DL_CHANNEL_ID, DL_CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH).apply {
                description = DL_CHANNEL_DESC
                setSound(soundUri, attrs)
                enableVibration(true)
            }
            nm.createNotificationChannel(dlChannel)
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
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
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
        val saved = prefs.getString(KEY_NEXT_DEADLINE_MSG, null)
        if (saved != null) {
            prefs.edit().remove(KEY_NEXT_DEADLINE_MSG).apply()
        }
        val text = saved ?: "Deadlines due today or tomorrow, or weekly tasks today."
        val soundUri = Uri.parse("android.resource://${context.packageName}/raw/my_sound")
        val notification = NotificationCompat.Builder(context, DL_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Today's focus")
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(contentIntent)
            .setSound(soundUri)
            .setAutoCancel(true)
            .build()
        nm.notify(11001, notification)
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
        val soundUri = Uri.parse("android.resource://${context.packageName}/raw/my_sound")
        val notification = NotificationCompat.Builder(context, DL_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Today's focus")
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(contentIntent)
            .setSound(soundUri)
            .setAutoCancel(true)
            .build()
        nm.notify(11001, notification)
    }
}
