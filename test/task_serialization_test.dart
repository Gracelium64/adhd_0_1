import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';

void main() {
  test('Task toMap and fromMap roundtrip preserves fields', () {
    final t = Task(
      'id-1',
      'weekly',
      'Do the thing',
      '21/11/25',
      '12:00',
      'mon',
      false,
      orderIndex: 3,
      subTasks: [
        SubTask(
          subTaskId: 's1',
          description: 'sub',
          isDone: false,
          orderIndex: 0,
        ),
      ],
    );

    final map = t.toMap();
    final reconstructed = Task.fromMap(map);

    expect(reconstructed.taskId, equals(t.taskId));
    expect(reconstructed.taskCatagory, equals(t.taskCatagory));
    expect(reconstructed.taskDesctiption, equals(t.taskDesctiption));
    expect(reconstructed.deadlineDate, equals(t.deadlineDate));
    expect(reconstructed.deadlineTime, equals(t.deadlineTime));
    expect(reconstructed.dayOfWeek, equals(t.dayOfWeek));
    expect(reconstructed.isDone, equals(t.isDone));
    expect(reconstructed.orderIndex, equals(t.orderIndex));
    expect(reconstructed.subTasks.length, equals(1));
    expect(reconstructed.subTasks.first.subTaskId, equals('s1'));
  });
}
