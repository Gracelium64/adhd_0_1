import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:flutter/material.dart';
import 'package:adhd_0_1/src/common/domain/settings.dart';

final FirebaseFirestore fs = FirebaseFirestore.instance;

class FirestoreInitializer {
  static Future<void> initializeDefaults(String? userId) async {
    if (userId == null) return;
    await FirestoreInitializer().initializeUserCollections(userId);
  }

  Future<void> initializeUserCollections(String userId) async {
    final userRef = fs.collection('users').doc(userId);

    // Initialize taskIdCounter
    final counterRef = userRef.collection('taskIdCounter').doc('taskIdCounter');
    debugPrint("Initializing taskIdCounter for user $userId...");

    final counterSnapshot = await counterRef.get();
    if (!counterSnapshot.exists) {
      await counterRef.set({'taskIdCounter': 0});
    }

    // Initialize userSettings
    final settingsRef = userRef.collection('userSettings').doc('userSettings');
    final settingsSnapshot = await settingsRef.get();
    if (!settingsSnapshot.exists) {
      final defaultSettings = Settings(
        appSkinColor: true,
        language: 'English',
        location: 'Berlin',
        startOfDay: TimeOfDay(hour: 7, minute: 15),
        startOfWeek: Weekday.mon,
      );
      await settingsRef.set(defaultSettings.toMap());
    }

    // Initialize userStatistics
    final statsRef = userRef.collection('userSettings').doc('userStatistics');
    final statsSnapshot = await statsRef.get();
    if (!statsSnapshot.exists) {
      await statsRef.set({
        'coldStartTimeStamp': FieldValue.serverTimestamp(),
        'miao': false,
        'numberOfAppStarts': 0,
        'numberOfDaysBooted': 0,
        'numberOfEasterEggsFound': 0,
        'numberOfMinutesSpentOnApp': 0,
        'numberOfRickRolls': 0,
        'numberOfUserRecoveries': 0,
        'procentOfCompletedTasks': 0,
      });
    }

    // (Optional) Create empty subcollections if your app requires them to exist
    // Firestore doesn't require empty subcollections to be created manually
  }
}
