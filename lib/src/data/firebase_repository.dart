import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirebaseRepository implements DataBaseRepository {
  final fs = FirebaseFirestore.instance;
  final storage = FlutterSecureStorage();

  Future<String?> loadUserId() async {
    String? storedValue = await storage.read(key: 'userId');
    return storedValue;
  }

  @override
  Future<void> addDaily(String data) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    final counterDocRef = fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter');

    final counterSnapshot = await counterDocRef.get();

    int currentCounter = counterSnapshot.get('taskIdCounter') ?? 0;
    int taskIdCounter = currentCounter + 1;

    final docRef =
        fs.collection('users').doc(userId).collection('dailyTasks').doc();
    final Task task = Task(
      taskIdCounter.toString() + userId,
      'Daily',
      data,
      null,
      null,
      null,
      false,
    );
    await docRef.set(task.toMap());

    await fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter')
        .update({'taskIdCounter': taskIdCounter});
  }

  @override
  Future<void> addWeekly(String data, day) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final counterDocRef = fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter');

    final counterSnapshot = await counterDocRef.get();

    int currentCounter = counterSnapshot.get('taskIdCounter') ?? 0;
    int taskIdCounter = currentCounter + 1;

    final docRef =
        fs.collection('users').doc(userId).collection('weeklyTasks').doc();
    final Task task = Task(
      taskIdCounter.toString() + userId,
      'Weekly',
      data,
      null,
      null,
      day,
      false,
    );
    await docRef.set(task.toMap());

    await fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter')
        .update({'taskIdCounter': taskIdCounter});
  }

  @override
  Future<void> addDeadline(String data, date, time) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    final counterDocRef = fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter');

    final counterSnapshot = await counterDocRef.get();

    int currentCounter = counterSnapshot.get('taskIdCounter') ?? 0;
    int taskIdCounter = currentCounter + 1;
///
    final String taskId = '${taskIdCounter}_$userId';
///
    final docRef =
        fs.collection('users').doc(userId).collection('deadlineTasks').doc();
    final Task task = Task(
      taskId,
      'Deadline',
      data,
      date,
      time,
      null,
      false,
    );
    await docRef.set(task.toMap());

    await fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter')
        .update({'taskIdCounter': taskIdCounter});
  }

  @override
  Future<void> addQuest(String data) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final counterDocRef = fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter');

    final counterSnapshot = await counterDocRef.get();

    int currentCounter = counterSnapshot.get('taskIdCounter') ?? 0;
    int taskIdCounter = currentCounter + 1;

    final docRef =
        fs.collection('users').doc(userId).collection('questTasks').doc();
    final Task task = Task(
      taskIdCounter.toString() + userId,
      'Quest',
      data,
      null,
      null,
      null,
      false,
    );
    await docRef.set(task.toMap());

    await fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter')
        .update({'taskIdCounter': taskIdCounter});
  }

  @override
  Future<void> addPrize(int prizeId, String prizeUrl) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docRef =
        fs.collection('users').doc(userId).collection('prizesWon').doc();

    final Prizes prize = Prizes(prizeId: prizeId, prizeUrl: prizeUrl);
    await docRef.set(prize.toMap());
  }

  @override
  Future<void> completeDeadline(String dataTaskId) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('deadlineTasks')
            .where('taskId', isEqualTo: dataTaskId.toString())
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'isDone': true});
      await query.docs.first.reference.delete();
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }
  }

  @override
  Future<void> completeQuest(String dataTaskId) async {}

  @override
  Future<void> deleteDaily(String dataTaskId) async {}

  @override
  Future<void> deleteWeekly(String dataTaskId) async {}

  @override
  Future<void> deleteDeadline(String dataTaskId) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('deadlineTasks')
            .where('taskId', isEqualTo: dataTaskId.toString())
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.delete();
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }
  }

  // @override
  // Future<void> deleteQuest(int dataTaskId) async {}

  // @override
  // Future<void> editDaily(int dataTaskId, String data) async {}

  // @override
  // Future<void> editWeekly(int dataTaskId, String data, day) async {}

  // @override
  // Future<void> editDeadline(int dataTaskId, String data, date, time) async {}

  // @override
  // Future<void> editQuest(int dataTaskID, String data) async {}

//   @override
//   Future<Settings> setSettings(
//     bool? dataAppSkinColor,
//     String dataLanguage,
//     String dataLocation,
//     TimeOfDay dataStartOfDay,
//     Weekday dataStartOfWeek,
//   ) async {}

//   @override
//   Future<List<Task>> getDailyTasks() async {}

//   @override
//   Future<List<Task>> getWeeklyTasks() async {}

//   @override
//   Future<List<Task>> getDeadlineTasks() async {}

//   @override
//   Future<List<Task>> getQuestTasks() async {}

//   @override
//   Future<List<Prizes>> getPrizes() async {}

//   @override
//   Future<Settings?> getSettings() async {}

//   @override
//   Future<void> setAppUser(
//     String userId,
//     userName,
//     email,
//     password,
//     bool isPowerUser,
//   ) async {}

//   @override
//   Future<String?> getAppUser() async {}

//   @override
//   Future<void> toggleDaily(int dataTaskId, bool dataIsDone) async {}

//   @override
//   Future<void> toggleWeekly(int dataTaskId, bool dataIsDone) async {}
// }



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
}