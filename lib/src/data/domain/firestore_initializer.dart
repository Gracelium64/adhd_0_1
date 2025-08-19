import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore fs = FirebaseFirestore.instance;

class FirestoreInitializer {
  static Future<void> initializeDefaults(String? userId) async {
    if (userId == null) {
      debugPrint('⚠️ Skipping Firestore defaults: userId is null');
      return;
    }
    debugPrint('🧪 FirestoreInitializer.initializeDefaults(userId=$userId)');
    await FirestoreInitializer().initializeUserCollections(userId);
  }

  Future<void> initializeUserCollections(String userId) async {
    // Ensure we're signed in and stamp ownerUid on the user doc before any reads
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('⚠️ Firestore init skipped: no signed-in user');
      return;
    }

    final userRef = fs.collection('users').doc(userId);
    debugPrint('🧪 Stamping ownerUid and initializing collections for $userId');
    try {
      await userRef
          .set({'ownerUid': uid}, SetOptions(merge: true))
          .timeout(const Duration(seconds: 3));
    } on TimeoutException {
      debugPrint('⏱️ ownerUid stamp timed out; proceeding (likely offline)');
    } catch (e) {
      debugPrint('⚠️ ownerUid stamp failed: $e');
    }

    // Initialize taskIdCounter
    final counterRef = userRef.collection('taskIdCounter').doc('taskIdCounter');
    debugPrint("🧪 Initializing taskIdCounter for user $userId...");

    // Avoid pre-read; write with merge so rules allow create/update in one step
    try {
      await counterRef
          .set({'taskIdCounter': 0}, SetOptions(merge: true))
          .timeout(const Duration(seconds: 3));
    } on TimeoutException {
      debugPrint('⏱️ taskIdCounter init timed out; proceeding');
    } catch (e) {
      debugPrint('⚠️ taskIdCounter init failed: $e');
    }

    // // Initialize userSettings
    // final settingsRef = userRef.collection('userSettings').doc('userSettings');
    // final settingsSnapshot = await settingsRef.get();
    // if (!settingsSnapshot.exists) {
    //   final defaultSettings = Settings(
    //     appSkinColor: true,
    //     language: 'English',
    //     location: 'Berlin',
    //     startOfDay: TimeOfDay(hour: 7, minute: 15),
    //     startOfWeek: Weekday.mon,
    //   );
    //   await settingsRef.set(defaultSettings.toMap());
    // }

    // Initialize userStatistics
    final statsRef = userRef.collection('userSettings').doc('userStatistics');
    // Safe to read after ownerUid is stamped; if still restricted, fallback to merge write
    try {
      debugPrint('🧪 Reading userStatistics to decide create');
      final statsSnapshot = await statsRef.get().timeout(
        const Duration(seconds: 3),
      );
      if (!statsSnapshot.exists) {
        debugPrint('🧪 Creating userStatistics default doc');
        await statsRef
            .set({
              'coldStartTimeStamp': FieldValue.serverTimestamp(),
              'miao': false,
              'numberOfAppStarts': 0,
              'numberOfDaysBooted': 0,
              'numberOfEasterEggsFound': 0,
              'numberOfMinutesSpentOnApp': 0,
              'numberOfRickRolls': 0,
              'numberOfUserRecoveries': 0,
              'procentOfCompletedTasks': 0,
            })
            .timeout(const Duration(seconds: 3));
      }
    } catch (e) {
      // If rules still block reads, perform a merge write instead
      debugPrint('🧪 Read of userStatistics failed, merging defaults: $e');
      try {
        await statsRef
            .set({
              'coldStartTimeStamp': FieldValue.serverTimestamp(),
              'miao': false,
              'numberOfAppStarts': 0,
              'numberOfDaysBooted': 0,
              'numberOfEasterEggsFound': 0,
              'numberOfMinutesSpentOnApp': 0,
              'numberOfRickRolls': 0,
              'numberOfUserRecoveries': 0,
              'procentOfCompletedTasks': 0,
            }, SetOptions(merge: true))
            .timeout(const Duration(seconds: 3));
      } on TimeoutException {
        debugPrint('⏱️ userStatistics merge timed out; proceeding');
      } catch (e2) {
        debugPrint('⚠️ userStatistics merge failed: $e2');
      }
    }

    // (Optional) Create empty subcollections if your app requires them to exist
    // Firestore doesn't require empty subcollections to be created manually
  }
}
