import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/Quest/presentation/widgets/quest_task_widget.dart';
import 'package:flutter/material.dart';

class Quest extends StatefulWidget {
  final DataBaseRepository repository;

  const Quest(this.repository, {super.key});

  @override
  State<Quest> createState() => _QuestState();
}

class _QuestState extends State<Quest> {
late Future<List<Task>> myList;

  @override
  void initState() {
    super.initState();
    myList = widget.repository.getQuestTasks();
  }


  @override
  Widget build(BuildContext context) {
    OverlayPortalController overlayController = OverlayPortalController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(child: FutureBuilder<List<Task>>(
        future: myList, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
return Text('No data available');
          }

          final data = snapshot.data!;
      
      
      
      
      return Column(
        children: [
          SubTitle(sub: 'Quest'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 0, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  height: 492,
                  width: 304,
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final task = data[index];
                      return QuestTaskWidget(
                        taskDesctiption: task.taskDesctiption,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              overlayController.toggle();
            },
            child: OverlayPortal(
              controller: overlayController,
              overlayChildBuilder: (BuildContext context) {
                return AddTaskWidget(
                  widget.repository,
                  overlayController,
                  taskType: TaskType.quest,
                );
              },
              child: AddTaskButton(),
            ),
          ),
          SizedBox(height: 40),
        ],
      );
        },

      ))
    );
  }
}
