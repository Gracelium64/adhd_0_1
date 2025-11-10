import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:flutter/material.dart';

/// Maintains mutable form state for a subtask row while editing or creating.
class SubTaskFormDraft {
  SubTaskFormDraft({
    this.id,
    String initialDescription = '',
    bool initialIsDone = false,
  }) : controller = TextEditingController(text: initialDescription),
       isDone = initialIsDone;

  factory SubTaskFormDraft.empty() => SubTaskFormDraft();

  factory SubTaskFormDraft.fromSubTask(SubTask subTask) => SubTaskFormDraft(
    id: subTask.subTaskId,
    initialDescription: subTask.description,
    initialIsDone: subTask.isDone,
  );

  final String? id;
  final TextEditingController controller;
  bool isDone;
  bool removed = false;

  String get description => controller.text.trim();

  void dispose() => controller.dispose();
}
