package shadowapp.grace6424.adhd01

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.content.edit

object AlarmScheduler {
    private const val PREFS = "adhd_prefs"
    private const val KEY_START_OF_DAY = "startOfDay" // format HH:MM

    fun saveStartOfDay(context: Context, hh: Int, mm: Int) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit {
            putString(KEY_START_OF_DAY, String.format("%02d:%02d", hh, mm))
        }
    }

    fun scheduleFromPrefs(context: Context) {
        val pref = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val t = pref.getString(KEY_START_OF_DAY, null) ?: return
        val parts = t.split(":")
        val hh = parts.getOrNull(0)?.toIntOrNull() ?: 7
        val mm = parts.getOrNull(1)?.toIntOrNull() ?: 15
        schedule(context, hh, mm, nextOnly = false)
    }

    fun scheduleNext(context: Context) {
        val pref = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val t = pref.getString(KEY_START_OF_DAY, null) ?: "07:15"
        val parts = t.split(":")
        val hh = parts.getOrNull(0)?.toIntOrNull() ?: 7
        val mm = parts.getOrNull(1)?.toIntOrNull() ?: 15
        schedule(context, hh, mm, nextOnly = true)
    }

    fun schedule(context: Context, hour: Int, minute: Int, nextOnly: Boolean) {
        saveStartOfDay(context, hour, minute)
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AlarmReceiver::class.java)
        val pi = PendingIntent.getBroadcast(
            context,
            2001,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val now = System.currentTimeMillis()
        val cal = java.util.Calendar.getInstance().apply {
            timeInMillis = now
            set(java.util.Calendar.HOUR_OF_DAY, hour)
            set(java.util.Calendar.MINUTE, minute)
            set(java.util.Calendar.SECOND, 0)
            set(java.util.Calendar.MILLISECOND, 0)
        }
        var trigger = cal.timeInMillis
        if (trigger <= now) trigger += 24 * 60 * 60 * 1000 // next day

        Log.d("AlarmScheduler", "Scheduling alarm at ${java.util.Date(trigger)} nextOnly=$nextOnly")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, trigger, pi)
        } else {
            am.setExact(AlarmManager.RTC_WAKEUP, trigger, pi)
        }

        if (!nextOnly && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            // Optional: also set a repeating inexact alarm as a backup
            am.setInexactRepeating(
                AlarmManager.RTC_WAKEUP,
                trigger + 24 * 60 * 60 * 1000,
                AlarmManager.INTERVAL_DAY,
                pi
            )
        }
    }
}
