package shadowapp.grace6424.adhd01

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        Log.d("AlarmReceiver", "Alarm fired, showing notification and scheduling next")
    // Show the quote saved by Flutter (NotificationHelper reads from prefs)
    NotificationHelper.showDailyQuote(context)
        AlarmScheduler.scheduleNext(context)
    }
}
