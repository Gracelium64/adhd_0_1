// import 'package:adhd_0_1/src/features/task_management/domain/task.dart';
// import 'package:adhd_0_1/src/data/databaserepository.dart';
// import 'package:adhd_0_1/src/features/prizes/domain/prizes.dart';
// import 'package:adhd_0_1/src/features/settings/domain/settings.dart';
// import 'package:flutter/material.dart';

// class FirebaseRepository implements DataBaseRepository {
//   @override
//   Future<void> addDaily(String data) async {}

//   @override
//   Future<void> addWeekly(String data, day) async {}

//   @override
//   Future<void> addDeadline(String data, date, time) async {}

//   @override
//   Future<void> addQuest(String data) async {}

//   @override
//   Future<void> addPrize(int prizeId, String prizeUrl) async {}

//   @override
//   Future<void> completeDeadline(int dataTaskId) async {}

//   @override
//   Future<void> completeQuest(int dataTaskId) async {}

//   @override
//   Future<void> deleteDaily(int dataTaskId) async {}

//   @override
//   Future<void> deleteWeekly(int dataTaskId) async {}

//   @override
//   Future<void> deleteDeadline(int dataTaskId) async {}

//   @override
//   Future<void> deleteQuest(int dataTaskId) async {}

//   @override
//   Future<void> editDaily(int dataTaskId, String data) async {}

//   @override
//   Future<void> editWeekly(int dataTaskId, String data, day) async {}

//   @override
//   Future<void> editDeadline(int dataTaskId, String data, date, time) async {}

//   @override
//   Future<void> editQuest(int dataTaskID, String data) async {}

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



// //                                               ▒███████
// //           ██                                 ████     ██▒
// //         ▒█▒ ██▒                           ████   █████ ██▒
// //         ██    ███▓                      ███   ████████  ██
// //       ▓██   ▓  ███                   ███▓  ███████████ ██░
// //       ███    ▓▓  ███                ███  ▓███      ███ ██
// //       ▓█▒     ▓▓▓  ▒██            ███  ▒▒██     ░░  ██ ██
// //       ██  ░    ▓▓▓▓  ███         ░██  ▓░██     ░    ██ ██░
// //       ██  ░     ▒▒▒▓▓  ██       ███ ░▓░██    ▒░    ░█  ██ 
// //       ░██  ░      ░▒▒▓▓  ██     ░██  ▓▒░█           ██ ▒█▒
// //       ░██          ▓▒░▒▓  ██    ███ ▓▒░██    ░      ██ ██ 
// //       ██  ░       ▒▓▓▓▓▓  ██  ▓██  ▓░░█           ██  █▓
// //       ██  ░           ▒▓▓ ██████░ ▓▒░▒█          ▓██ ██░
// //       ███ ░       ░            █  ▓▒░█          ░██ ▒█░
// //       ▓██            ▒            ▒▒░█         ▓██  █░
// //       ▒██  ▒▒    ▓▓▓▓▓         ░▓▓▒░▓█    ░   ███  █▓
// //         ██  ▒   ▓▓▓▒▒       █▓  ▓▒▒▒░█       ████  █▒
// //           ██   ▓▓▒▒▒▒▒ ▒   ███  ▓▒░░░░▒▓    ░███  ██
// //           ███  ▒▓▒▒    ▓  █████ ▓▒░░░░░░▒▓ ▒▓██   ██
// //           ▓██  ▒▓▓▓▓▓▓▓  ███████▓░▒▓▓▒░░░░▒▓▓▓  ░██
// //           ███  ░       ▓▓█████████▒   ▒░░░░░▒▒ ███
// //         ░██  ░▓▓█  █   ██████████▒▓▓▓▓▓▓▓▒▒░▓  █▓
// //         ███  ▓▓▒░█       ██████████       ░▓░▒░ ██
// //       ▓███  ▓▓▒░░▓       █████████    ██    ▒░▓ ░█▒
// //   ▒██████     ░▓█████▓▓ ▓███████         █ ▓░░▓░ ██                              
// // ░████████  ███▓▓   █████  ▓ ░███░     ██▓▒░░▒░▓  █▒                             
// //       ██  ▓█████▒ ░ ███░    ▒██████▓▓▒░░░░▒▓▓▓▓  █                             
// //     █████     ██████░ ███ █████    ░░░███▓▒       ██                            
// //   ███░  ███▒  █▓█████        ░███▒   ██▓   █▓▒   ░█
// //   █░ ██▒  ███    ▒█████████▓█████████   █████   ██░
// //     ▒▒   ███           ██████████████████▓     █░██
// //       ▓██▒      ░▒░                          ██░░
// //       ███       ░   ░████████▓░       ░▒▓▓▒▒   ██
// //     ██▒     ▓▓██████████████████████████████▓  ██
// //     ██▓     ▒▓░ █████████████████████████████▒   ██░
// //   ▒██ ░▓   ▒▓▒▓░ ░███████████████████████████▒    █▓
// //   ▓█  ▓▓    ▓░░ ██████████████████████████▓▒░▓  ▓  █▒
// //   ██ ▓▓██   ▓▒░░░░▒  █████████████████████▓░▒▓ ▒▓▒ ██
// // ▒██ █████  ▓▓░░░░░▒▒█░ ████████████████░ ░░▓  ███  █▒
// //   ██ ░▓▒██▒  ▓▒░░░▒  ░▒▒█▓ ██████▓██▓██░▒░░▒▓  ███  █▒
// //   ▓█  ▓▒▓▒ ▒  ▓▒░░░▒░   ░░  ██  ▒░▓▒    ░░▒▓  ████  █▒
// //   ▒██  █░  ▒█  ▓▒░░▒▒▒    ▒    ░▒     ▒▒▒▒▓  ▒░███ ░█▒
// //   ▓██    ░     ▓▓▒▒░▒▒▒  █░   █   ▒▓▓▒▒▒▒   ▓ ▒█  ██
// //     ██       ▒    ▓▓▓░░░▒▒  █████ ░▓▒▒▓▓▓▓         ██
// //     ░██     ▓▓ ▓▓    ▓███▓         ░▓       ▓▓   ███
// //       ████        ██  ██ ██▒ ███ ██▓ ██ ██      ██░
// //         ░▓███████   ▒ ██▒    ███  █ ███    █████▒
// //                 █████     ████░███     █████
// //                 ░  ▒█████▓      
