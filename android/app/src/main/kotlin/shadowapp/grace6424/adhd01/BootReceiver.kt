package shadowapp.grace6424.adhd

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED ||
            intent?.action == Intent.ACTION_LOCKED_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Device rebooted, rescheduling daily quote and deadline alert")
            AlarmScheduler.scheduleFromPrefs(context)
            AlarmScheduler.scheduleNextDeadline(context)
        }
    }
}
