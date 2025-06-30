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

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'taskCatagory': taskCatagory,
    'taskDesctiption': taskDesctiption,
    'deadlineDate': deadlineDate,
    'deadlineTime': deadlineTime,
    'dayOfWeek': dayOfWeek,
    'isDone': isDone,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    json['taskId'],
    json['taskCatagory'],
    json['taskDesctiption'],
    json['deadlineDate'],
    json['deadlineTime'],
    json['dayOfWeek'],
    json['isDone'],
  );
}