class DeadlineTask {
  final int taskId;
  final String taskDesctiption;
  final String deadlineDate;
  final String deadlineTime;
  final bool isDone;

  DeadlineTask({
    required this.taskId,
    required this.taskDesctiption,
    required this.deadlineDate,
    required this.deadlineTime,
    required this.isDone,
  });
}
