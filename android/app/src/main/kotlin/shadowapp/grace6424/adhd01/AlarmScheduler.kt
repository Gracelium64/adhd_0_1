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
    private const val KEY_NEXT_QUOTE = "nextQuote"
    private const val KEY_DEADLINE_OFFSET_SEC = "deadlineOffsetSec"
    private const val KEY_NEXT_DEADLINE_MSG = "nextDeadlineMsg"

    fun saveStartOfDay(context: Context, hh: Int, mm: Int) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit {
            putString(KEY_START_OF_DAY, String.format("%02d:%02d", hh, mm))
        }
    }

    fun saveNextQuote(context: Context, quote: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit {
            putString(KEY_NEXT_QUOTE, quote)
        }
    }

    fun scheduleFromPrefs(context: Context) {
        val pref = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val t = pref.getString(KEY_START_OF_DAY, null) ?: return
        val parts = t.split(":")
        val hh = parts.getOrNull(0)?.toIntOrNull() ?: 7
        val mm = parts.getOrNull(1)?.toIntOrNull() ?: 15
        // On boot, schedule a one-shot for the next occurrence; AlarmReceiver will chain the next day
        schedule(context, hh, mm, nextOnly = true)
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

        // Do not set an additional repeating backup to avoid duplicates with Flutter plugin
    }

    fun cancel(context: Context) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AlarmReceiver::class.java)
        val pi = PendingIntent.getBroadcast(
            context,
            2001,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        am.cancel(pi)
    }

    // ===== Deadline alarm (5–30s after start-of-day) =====
    fun scheduleDeadline(context: Context, hour: Int, minute: Int, offsetSec: Int, nextOnly: Boolean) {
        // Persist for chaining from receivers/boot
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit {
            putString(KEY_START_OF_DAY, String.format("%02d:%02d", hour, minute))
            putInt(KEY_DEADLINE_OFFSET_SEC, offsetSec)
        }
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, DeadlineReceiver::class.java)
        val pi = PendingIntent.getBroadcast(
            context,
            2101,
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
        var trigger = cal.timeInMillis + offsetSec * 1000L
        if (trigger <= now) trigger += 24 * 60 * 60 * 1000 // next day

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, trigger, pi)
        } else {
            am.setExact(AlarmManager.RTC_WAKEUP, trigger, pi)
        }
    }

    fun scheduleNextDeadline(context: Context) {
        val pref = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val t = pref.getString(KEY_START_OF_DAY, null) ?: return
        val parts = t.split(":")
        val hh = parts.getOrNull(0)?.toIntOrNull() ?: 7
        val mm = parts.getOrNull(1)?.toIntOrNull() ?: 15
        val offset = pref.getInt(KEY_DEADLINE_OFFSET_SEC, 10)
        scheduleDeadline(context, hh, mm, offset, nextOnly = true)
    }

    fun cancelDeadline(context: Context) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, DeadlineReceiver::class.java)
        val pi = PendingIntent.getBroadcast(
            context,
            2101,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        am.cancel(pi)
    }

    fun saveNextDeadlineMessage(context: Context, msg: String?) {
        // Commit synchronously so immediate reads (e.g., show now) see the value
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit(commit = true) {
            if (msg == null) remove(KEY_NEXT_DEADLINE_MSG) else putString(KEY_NEXT_DEADLINE_MSG, msg)
        }
    }

    fun getPrefsSnapshot(context: Context): HashMap<String, Any?> {
        val pref = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val map = HashMap<String, Any?>()
        map["startOfDay"] = pref.getString(KEY_START_OF_DAY, null)
        map["deadlineOffsetSec"] = if (pref.contains(KEY_DEADLINE_OFFSET_SEC)) pref.getInt(KEY_DEADLINE_OFFSET_SEC, 0) else null
        val msg = pref.getString(KEY_NEXT_DEADLINE_MSG, null)
        map["nextDeadlineMsgPreview"] = msg?.let { it.substring(0, kotlin.math.min(120, it.length)) }
        return map
    }

    // Debug: schedule deadline notification in N seconds from now (native path)
    fun scheduleDeadlineIn(context: Context, seconds: Int) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, DeadlineReceiver::class.java)
        val pi = PendingIntent.getBroadcast(
            context,
            2102,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val trigger = System.currentTimeMillis() + seconds * 1000L
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, trigger, pi)
        } else {
            am.setExact(AlarmManager.RTC_WAKEUP, trigger, pi)
        }
    }
}
