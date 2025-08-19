class Task {
  final String taskId;
  final String taskCatagory;
  String taskDesctiption;
  String? deadlineDate;
  String? deadlineTime;
  String? dayOfWeek;
  bool isDone;
  int? orderIndex; // for persistent custom ordering within a list/category

  Task(
    this.taskId,
    this.taskCatagory,
    this.taskDesctiption,
    this.deadlineDate,
    this.deadlineTime,
    this.dayOfWeek,
    this.isDone, {
    this.orderIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'taskCatagory': taskCatagory,
      'taskDesctiption': taskDesctiption,
      'deadlineDate': deadlineDate,
      'deadlineTime': deadlineTime,
      'dayOfWeek': dayOfWeek,
      'isDone': isDone,
      'orderIndex': orderIndex,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      json['taskId'],
      json['taskCatagory'],
      json['taskDesctiption'],
      json['deadlineDate'],
      json['deadlineTime'],
      json['dayOfWeek'],
      json['isDone'],
      orderIndex: json['orderIndex'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'taskCatagory': taskCatagory,
      'taskDesctiption': taskDesctiption,
      'deadlineDate': deadlineDate,
      'deadlineTime': deadlineTime,
      'dayOfWeek': dayOfWeek,
      'isDone': isDone,
      'orderIndex': orderIndex,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      map['taskId'],
      map['taskCatagory'],
      map['taskDesctiption'],
      map['deadlineDate'],
      map['deadlineTime'],
      map['dayOfWeek'],
      map['isDone'],
      orderIndex: map['orderIndex'],
    );
  }
}
