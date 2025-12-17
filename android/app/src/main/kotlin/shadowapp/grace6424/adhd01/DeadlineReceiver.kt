package shadowapp.grace6424.adhd01

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class DeadlineReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        Log.d("DeadlineReceiver", "Deadline alarm fired, showing notification and scheduling next")
        NotificationHelper.showDeadlineAlert(context)
        AlarmScheduler.scheduleNextDeadline(context)
    }
}
