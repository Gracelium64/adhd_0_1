class SubTask {
  final String subTaskId;
  String description;
  bool isDone;
  int? orderIndex;

  SubTask({
    required this.subTaskId,
    required this.description,
    required this.isDone,
    this.orderIndex,
  });

  Map<String, dynamic> toJson() => {
    'subTaskId': subTaskId,
    'description': description,
    'isDone': isDone,
    'orderIndex': orderIndex,
  };

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      subTaskId: json['subTaskId'] as String,
      description: (json['description'] as String?) ?? '',
      isDone: (json['isDone'] as bool?) ?? false,
      orderIndex: json['orderIndex'] as int?,
    );
  }
}

class Task {
  final String taskId;
  final String taskCatagory;
  String taskDesctiption;
  String? deadlineDate;
  String? deadlineTime;
  String? dayOfWeek;
  bool isDone;
  int? orderIndex; // for persistent custom ordering within a list/category
  final List<SubTask> subTasks;

  Task(
    this.taskId,
    this.taskCatagory,
    this.taskDesctiption,
    this.deadlineDate,
    this.deadlineTime,
    this.dayOfWeek,
    this.isDone, {
    this.orderIndex,
    List<SubTask>? subTasks,
  }) : subTasks = subTasks ?? <SubTask>[];

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
      'subTasks': subTasks.map((s) => s.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawSubTasks = json['subTasks'];
    return Task(
      json['taskId'],
      json['taskCatagory'],
      json['taskDesctiption'],
      json['deadlineDate'],
      json['deadlineTime'],
      json['dayOfWeek'],
      json['isDone'],
      orderIndex: json['orderIndex'],
      subTasks:
          rawSubTasks is List
              ? rawSubTasks
                  .whereType<Map<String, dynamic>>()
                  .map(SubTask.fromJson)
                  .toList()
              : <SubTask>[],
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
      'subTasks': subTasks.map((s) => s.toJson()).toList(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final rawSubTasks = map['subTasks'];
    return Task(
      map['taskId'],
      map['taskCatagory'],
      map['taskDesctiption'],
      map['deadlineDate'],
      map['deadlineTime'],
      map['dayOfWeek'],
      map['isDone'],
      orderIndex: map['orderIndex'],
      subTasks:
          rawSubTasks is List
              ? rawSubTasks
                  .whereType<Map<String, dynamic>>()
                  .map(SubTask.fromJson)
                  .toList()
              : <SubTask>[],
    );
  }
}
