class Task {
  final int taskId;
  final String taskCatagory;
  String taskDesctiption;
  String? deadlineDate;
  String? deadlineTime;
  String? dayOfWeek;
   bool isDone;

  Task(
    this.taskId,
       this.taskCatagory,
       this.taskDesctiption, 
       this.deadlineDate,
       this.deadlineTime,
       this.dayOfWeek,
       this.isDone,
      );
}