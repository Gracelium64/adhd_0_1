import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:adhd_0_1/src/navigation/notification_router.dart';

class AwesomeNotifService {
  AwesomeNotifService._();
  static final AwesomeNotifService instance = AwesomeNotifService._();

  static const String dailyChannelKey = 'daily_quote_channel_v3';
  static const String deadlineChannelKey = 'deadline_alerts_channel_v4';
  static const String dailyGroupKey = 'group_daily_quote';
  static const String deadlineGroupKey = 'group_deadline_alerts';

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      // null uses default app icon
      null,
      [
        NotificationChannel(
          channelKey: dailyChannelKey,
          channelName: 'Daily Quotes',
          channelDescription: 'Daily tip of the day notification at startOfDay',
          importance: NotificationImportance.Max,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          ledColor: null,
          playSound: true,
          enableVibration: true,
          // Ensure iOS/Android use our bundled sound (include extension for iOS)
          soundSource: 'resource://raw/my_sound.wav',
        ),
        NotificationChannel(
          channelKey: deadlineChannelKey,
          channelName: 'Task Deadlines',
          channelDescription:
              'Alerts for deadlines due today/tomorrow and weekly tasks for today',
          importance: NotificationImportance.Max,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          ledColor: null,
          playSound: true,
          enableVibration: true,
          // Ensure iOS/Android use our bundled sound (include extension for iOS)
          soundSource: 'resource://raw/my_sound.wav',
        ),
      ],
      debug: false,
    );

    // Request permissions as needed
    await AwesomeNotifications().isNotificationAllowed().then((
      isAllowed,
    ) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Wire tap actions to open the Dailys tab when payload requests it
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (received) async {
        final route = received.payload?['route'];
        if (route == 'dailys') {
          NotificationRouter.instance.openDailys();
        }
        // If a deadline notification was tapped, dismiss it so it goes away
        try {
          if (received.channelKey == deadlineChannelKey &&
              received.id != null) {
            await AwesomeNotifications().dismiss(received.id!);
          }
        } catch (_) {}
      },
    );

    // Android 12+ exact alarm/battery optimizations are out of scope here, left to existing native helpers
  }

  Future<void> showPersistent({
    required String channelKey,
    required int id,
    required String title,
    required String body,
    Map<String, String>? payload,
    String? groupKey,
    bool locked = true,
    bool autoDismissible = false,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
        payload: payload,
        autoDismissible: autoDismissible,
        locked: locked,
        groupKey: groupKey,
      ),
    );
  }

  Future<void> dismiss(int id) async {
    await AwesomeNotifications().dismiss(id);
  }

  Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> schedulePersistentAt({
    required String channelKey,
    required int id,
    required DateTime when,
    required String title,
    required String body,
    Map<String, String>? payload,
    String? groupKey,
    bool locked = true,
    bool autoDismissible = false,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
        payload: payload,
        autoDismissible: autoDismissible,
        locked: locked,
        groupKey: groupKey,
      ),
      schedule: NotificationCalendar.fromDate(
        date: when,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  Future<void> scheduleDailyRepeating({
    required int id,
    required int hour,
    required int minute,
    int second = 0,
    required String title,
    required String body,
    Map<String, String>? payload,
    String channelKey = dailyChannelKey,
    String? groupKey,
    bool locked = false,
    bool autoDismissible = true,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
        payload: payload,
        autoDismissible: autoDismissible,
        locked: locked,
        groupKey: groupKey,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: second,
        repeats: true,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }
}
