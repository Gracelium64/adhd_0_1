import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/prizes/domain/prizes.dart';
import 'package:adhd_0_1/src/features/settings/domain/settings.dart';

class MockDataRepository implements DataBaseRepository {
  List<Task> dailyTasks = [
    Task(001, 'Daily', 'Daily 1', null, null, null, false),
    Task(002, 'Daily', 'Daily 2', null, null, null, false),
    Task(003, 'Daily', 'Daily 3', null, null, null, false),
    Task(004, 'Daily', 'Daily 4', null, null, null, false),
    Task(005, 'Daily', 'Daily 5', null, null, null, false),
    Task(006, 'Daily', 'Daily 6', null, null, null, false),
    Task(007, 'Daily', 'Daily 7', null, null, null, false),
    Task(008, 'Daily', 'Daily 8', null, null, null, false),
    Task(009, 'Daily', 'Daily 9', null, null, null, false),
    Task(010, 'Daily', 'Daily 10', null, null, null, false),
    Task(011, 'Daily', 'Daily 11', null, null, null, false),
  ];
  List<Task> weeklyTasks = [
    Task(012, 'Weekly', 'Weekly 1', null, null, 'Mon', false),
    Task(013, 'Weekly', 'Weeklysdf 2', null, null, 'Mon', false),
    Task(014, 'Weekly', 'Weekly 3', null, null, '', false),
    Task(015, 'Weekly', 'Weekly 4', null, null, '', false),
    Task(016, 'Weekly', 'Weekly 5', null, null, '', false),
    Task(017, 'Weekly', 'Weekly 6', null, null, 'Thu', false),
    Task(018, 'Weekly', 'Weekly 7', null, null, 'Fri', false),
    Task(019, 'Weekly', 'Weekly 8', null, null, '', false),
  ];
  List<Task> deadlineTasks = [
    Task(020, 'Deadline', 'Overlays', '18/05/25', '16:15', null, false),
    Task(021, 'Deadline', 'Theming', '18/05/25', '16:15', null, false),
    Task(022, 'Deadline', 'ListView.builder', '18/05/25', '16:15', null, false),
    Task(
      023,
      'Deadline',
      'Add Task Button functionality',
      '18/05/25',
      '16:15',
      null,
      false,
    ),
    Task(
      024,
      'Deadline',
      'NavigationBar Highlight',
      '18/05/25',
      '16:15',
      null,
      false,
    ),
    Task(
      025,
      'Deadline',
      'setLimit of 36 characters for task',
      '18/05/25',
      '16:15',
      null,
      false,
    ),
  ];
  List<Task> questTasks = [
    Task(025, 'Quest', 'Quest 1', null, null, null, false),
    Task(026, 'Quest', 'Quest 2', null, null, null, false),
    Task(027, 'Quest', 'Quest 3', null, null, null, false),
    Task(028, 'Quest', 'Quest 4', null, null, null, false),
    Task(029, 'Quest', 'Quest 5', null, null, null, false),
  ];
  List<Prizes> prizesWon = [
    Prizes(prizeId: 015, prizeUrl: 'assets/img/prizes/Sticker15.png'),
    Prizes(prizeId: 016, prizeUrl: 'assets/img/prizes/Sticker16.png'),
    Prizes(prizeId: 017, prizeUrl: 'assets/img/prizes/Sticker17.png'),
    Prizes(prizeId: 018, prizeUrl: 'assets/img/prizes/Sticker18.png'),
    Prizes(prizeId: 019, prizeUrl: 'assets/img/prizes/Sticker19.png'),
    Prizes(prizeId: 020, prizeUrl: 'assets/img/prizes/Sticker20.png'),
    Prizes(prizeId: 021, prizeUrl: 'assets/img/prizes/Sticker21.png'),
    Prizes(prizeId: 022, prizeUrl: 'assets/img/prizes/Sticker22.png'),
    Prizes(prizeId: 023, prizeUrl: 'assets/img/prizes/Sticker23.png'),
    Prizes(prizeId: 024, prizeUrl: 'assets/img/prizes/Sticker24.png'),
    Prizes(prizeId: 025, prizeUrl: 'assets/img/prizes/Sticker25.png'),
    Prizes(prizeId: 026, prizeUrl: 'assets/img/prizes/Sticker26.png'),
    Prizes(prizeId: 027, prizeUrl: 'assets/img/prizes/Sticker27.png'),
    Prizes(prizeId: 028, prizeUrl: 'assets/img/prizes/Sticker28.png'),
    Prizes(prizeId: 029, prizeUrl: 'assets/img/prizes/Sticker29.png'),
    Prizes(prizeId: 030, prizeUrl: 'assets/img/prizes/Sticker30.png'),
    Prizes(prizeId: 031, prizeUrl: 'assets/img/prizes/Sticker31.png'),
    Prizes(prizeId: 032, prizeUrl: 'assets/img/prizes/Sticker32.png'),
    Prizes(prizeId: 033, prizeUrl: 'assets/img/prizes/Sticker33.png'),
  ];
  int taskIdCounter = 0;
  int dailyCompleted = 0;
  int weeklyCompleted = 0;
  int deadlineCompleted = 0;
  int questCompleted = 0;

  Settings? userSettings = Settings(
    appSkinColor: true,
    language: 'English',
    location: 'Berlin',
    startOfDay: 0715,
    startOfWeek: 2,
  );

  @override
  void addDaily(String data) {
    dailyTasks.add(Task(taskIdCounter, 'Daily', data, null, null, null, false));
    taskIdCounter++;
  }

  @override
  void addWeekly(String data, day) {
    weeklyTasks.add(
      Task(taskIdCounter, 'Weekly', data, null, null, day, false),
    );
    taskIdCounter++;
  }

  @override
  void addDeadline(String data, date, time) {
    deadlineTasks.add(
      Task(taskIdCounter, 'Deadline', data, date, time, null, false),
    );
    taskIdCounter++;
  }

  @override
  void addQuest(String data) {
    questTasks.add(Task(taskIdCounter, 'Quest', data, null, null, null, false));
    taskIdCounter++;
  }

  @override
  void addPrize(int prizeId, String prizeUrl) {
    prizesWon.add(Prizes(prizeId: prizeId, prizeUrl: prizeUrl));
  }

  @override
  void completeDaily(int dataTaskId) {
    for (int i = 0; i < dailyTasks.length; i++) {
      if (dailyTasks[i].taskId == dataTaskId) {
        dailyTasks[i].isDone = true;
        dailyCompleted++;
      }
    }
  }

  @override
  void completeWeekly(int dataTaskId) {
    for (int i = 0; i < weeklyTasks.length; i++) {
      if (weeklyTasks[i].taskId == dataTaskId) {
        weeklyTasks[i].isDone = true;
        dailyCompleted++;
      }
    }
  }

  @override
  void completeDeadline(int dataTaskId) {
    for (int i = 0; i < deadlineTasks.length; i++) {
      if (deadlineTasks[i].taskId == dataTaskId) {
        deadlineTasks[i].isDone = true;
        weeklyCompleted++;
        deadlineTasks.remove(deadlineTasks[i]);
      }
    }
  }

  @override
  void completeQuest(int dataTaskId) {
    for (int i = 0; i < questTasks.length; i++) {
      if (questTasks[i].taskId == dataTaskId) {
        questTasks[i].isDone = true;
        weeklyCompleted++;
        questTasks.remove(questTasks[i]);
      }
    }
  }

  @override
  void deleteDaily(int dataTaskId) {
    for (int i = 0; i < dailyTasks.length; i++) {
      if (dailyTasks[i].taskId == dataTaskId) {
        dailyTasks.remove(dailyTasks[i]);
      }
    }
  }

  @override
  void deleteWeekly(int dataTaskId) {
    for (int i = 0; i < weeklyTasks.length; i++) {
      if (weeklyTasks[i].taskId == dataTaskId) {
        weeklyTasks.remove(weeklyTasks[i]);
      }
    }
  }

  @override
  void deleteDeadline(int dataTaskId) {
    for (int i = 0; i < deadlineTasks.length; i++) {
      if (deadlineTasks[i].taskId == dataTaskId) {
        deadlineTasks.remove(deadlineTasks[i]);
      }
    }
  }

  @override
  void deleteQuest(int dataTaskId) {
    for (int i = 0; i < questTasks.length; i++) {
      if (questTasks[i].taskId == dataTaskId) {
        questTasks.remove(questTasks[i]);
      }
    }
  }

  @override
  void editDaily(int dataTaskId, String data) {
    for (int i = 0; i < dailyTasks.length; i++) {
      if (dailyTasks[i].taskId == dataTaskId) {
        dailyTasks[i].taskDesctiption = data;
      }
    }
  }

  @override
  void editWeekly(int dataTaskId, String data, day) {
    for (int i = 0; i < weeklyTasks.length; i++) {
      if (weeklyTasks[i].taskId == dataTaskId) {
        weeklyTasks[i].taskDesctiption = data;
        weeklyTasks[i].dayOfWeek = day;
      }
    }
  }

  @override
  void editDeadline(int dataTaskId, String data, date, time) {
    for (int i = 0; i < deadlineTasks.length; i++) {
      if (deadlineTasks[i].taskId == dataTaskId) {
        deadlineTasks[i].taskDesctiption = data;
        deadlineTasks[i].deadlineDate = date;
        deadlineTasks[i].deadlineTime = time;
      }
    }
  }

  @override
  void editQuest(int dataTaskID, String data) {
    for (int i = 0; i < questTasks.length; i++) {
      if (questTasks[i].taskId == dataTaskID) {
        questTasks[i].taskDesctiption = data;
      }
    }
  }

  @override
  Settings setSettings(
    bool? dataAppSkinColor,
    String dataLanguage,
    String dataLocation,
    int dataStartOfDay,
    int dataStartOfWeek,
  ) {
    return userSettings = Settings(
      appSkinColor: dataAppSkinColor,
      language: dataLanguage,
      location: dataLocation,
      startOfDay: dataStartOfDay,
      startOfWeek: dataStartOfWeek,
    );
  }

  // @override
  // int getCompletedDailyTasks() {
  //   return dailyCompleted;
  // }

  // @override
  // int getCompletedWeeklyTasks() {
  //   return weeklyCompleted;
  // }

  // @override
  // int getCompletedDeadlineTasks() {
  //   return deadlineCompleted;
  // }

  // @override
  // int getCompletedQuestTasks() {
  //   return questCompleted;
  // }

  @override
  List<Task> getDailyTasks() {
    return dailyTasks;
  }

  @override
  List<Task> getWeeklyTasks() {
    return weeklyTasks;
  }

  @override
  List<Task> getDeadlineTasks() {
    return deadlineTasks;
  }

  @override
  List<Task> getQuestTasks() {
    return questTasks;
  }

  @override
  List<Prizes> getPrizes() {
    return prizesWon;
  }

  @override
  Settings? getSettings() {
    return userSettings;
  }

  // @override
  // int getTaskIdCounter() {
  //   return taskIdCounter;
  // }
}



//                                               ▒███████
//           ██                                 ████     ██▒
//         ▒█▒ ██▒                           ████   █████ ██▒
//         ██    ███▓                      ███   ████████  ██
//       ▓██   ▓  ███                   ███▓  ███████████ ██░
//       ███    ▓▓  ███                ███  ▓███      ███ ██
//       ▓█▒     ▓▓▓  ▒██            ███  ▒▒██     ░░  ██ ██
//       ██  ░    ▓▓▓▓  ███         ░██  ▓░██     ░    ██ ██░
//       ██  ░     ▒▒▒▓▓  ██       ███ ░▓░██    ▒░    ░█  ██ 
//       ░██  ░      ░▒▒▓▓  ██     ░██  ▓▒░█           ██ ▒█▒
//       ░██          ▓▒░▒▓  ██    ███ ▓▒░██    ░      ██ ██ 
//       ██  ░       ▒▓▓▓▓▓  ██  ▓██  ▓░░█           ██  █▓
//       ██  ░           ▒▓▓ ██████░ ▓▒░▒█          ▓██ ██░
//       ███ ░       ░            █  ▓▒░█          ░██ ▒█░
//       ▓██            ▒            ▒▒░█         ▓██  █░
//       ▒██  ▒▒    ▓▓▓▓▓         ░▓▓▒░▓█    ░   ███  █▓
//         ██  ▒   ▓▓▓▒▒       █▓  ▓▒▒▒░█       ████  █▒
//           ██   ▓▓▒▒▒▒▒ ▒   ███  ▓▒░░░░▒▓    ░███  ██
//           ███  ▒▓▒▒    ▓  █████ ▓▒░░░░░░▒▓ ▒▓██   ██
//           ▓██  ▒▓▓▓▓▓▓▓  ███████▓░▒▓▓▒░░░░▒▓▓▓  ░██
//           ███  ░       ▓▓█████████▒   ▒░░░░░▒▒ ███
//         ░██  ░▓▓█  █   ██████████▒▓▓▓▓▓▓▓▒▒░▓  █▓
//         ███  ▓▓▒░█       ██████████       ░▓░▒░ ██
//       ▓███  ▓▓▒░░▓       █████████    ██    ▒░▓ ░█▒
//   ▒██████     ░▓█████▓▓ ▓███████         █ ▓░░▓░ ██                              
// ░████████  ███▓▓   █████  ▓ ░███░     ██▓▒░░▒░▓  █▒                             
//       ██  ▓█████▒ ░ ███░    ▒██████▓▓▒░░░░▒▓▓▓▓  █                             
//     █████     ██████░ ███ █████    ░░░███▓▒       ██                            
//   ███░  ███▒  █▓█████        ░███▒   ██▓   █▓▒   ░█
//   █░ ██▒  ███    ▒█████████▓█████████   █████   ██░
//     ▒▒   ███           ██████████████████▓     █░██
//       ▓██▒      ░▒░                          ██░░
//       ███       ░   ░████████▓░       ░▒▓▓▒▒   ██
//     ██▒     ▓▓██████████████████████████████▓  ██
//     ██▓     ▒▓░ █████████████████████████████▒   ██░
//   ▒██ ░▓   ▒▓▒▓░ ░███████████████████████████▒    █▓
//   ▓█  ▓▓    ▓░░ ██████████████████████████▓▒░▓  ▓  █▒
//   ██ ▓▓██   ▓▒░░░░▒  █████████████████████▓░▒▓ ▒▓▒ ██
// ▒██ █████  ▓▓░░░░░▒▒█░ ████████████████░ ░░▓  ███  █▒
//   ██ ░▓▒██▒  ▓▒░░░▒  ░▒▒█▓ ██████▓██▓██░▒░░▒▓  ███  █▒
//   ▓█  ▓▒▓▒ ▒  ▓▒░░░▒░   ░░  ██  ▒░▓▒    ░░▒▓  ████  █▒
//   ▒██  █░  ▒█  ▓▒░░▒▒▒    ▒    ░▒     ▒▒▒▒▓  ▒░███ ░█▒
//   ▓██    ░     ▓▓▒▒░▒▒▒  █░   █   ▒▓▓▒▒▒▒   ▓ ▒█  ██
//     ██       ▒    ▓▓▓░░░▒▒  █████ ░▓▒▒▓▓▓▓         ██
//     ░██     ▓▓ ▓▓    ▓███▓         ░▓       ▓▓   ███
//       ████        ██  ██ ██▒ ███ ██▓ ██ ██      ██░
//         ░▓███████   ▒ ██▒    ███  █ ███    █████▒
//                 █████     ████░███     █████
//                 ░  ▒█████▓      
