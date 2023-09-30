import 'dart:math';
import 'package:flutter/material.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.title});
  final String title;

  @override
  State<TaskListScreen> createState() => _TaskListScreen();
}

class _TaskListScreen extends State<TaskListScreen> {
  List<Task> tasks = [];

  void addTask() {
    setState(() {
      tasks.add(Task(
          title: 'New Task',
          tileColor:
              Colors.primaries[Random().nextInt(Colors.primaries.length)]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Color.fromARGB(255, 32, 32, 32),
              ),
            ),
            IconButton(
              iconSize: 50,
              icon: const Icon(Icons.add_box),
              color: Colors.black,
              onPressed: () {
                addTask();
              },
            ),
          ],
        ),
      ),
      body: TaskList(
        addTaskCallBack: addTask,
        tasks: tasks,
      ),
    );
  }
}

class Task {
  final String title;
  final Color tileColor;

  Task({required this.title, Color? tileColor})
      : tileColor = tileColor ?? Colors.transparent;
}

class TaskList extends StatefulWidget {
  final VoidCallback addTaskCallBack;
  final List<Task> tasks;

  const TaskList(
      {super.key, required this.addTaskCallBack, required this.tasks});

  @override
  // ignore: library_private_types_in_public_api
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        return TaskItem(
          title: task.title,
          tileColor: task.tileColor,
          onRemove: () {
            setState(() {
              widget.tasks.removeAt(index);
            });
          },
        );
      },
    );
  }
}

class TaskItem extends StatefulWidget {
  final String title;
  final Color tileColor;
  final VoidCallback onRemove;

  const TaskItem(
      {super.key,
      required this.title,
      required this.tileColor,
      required this.onRemove});

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  Icon checked = const Icon(Icons.check_box_outline_blank_rounded);
  bool isChecked = false;

  String status = 'incomplete';
  bool isComplete = false;

  void changeCheck() {
    if (isChecked) {
      setState(() {
        checked = const Icon(Icons.check_box_outline_blank_rounded);
      });
    } else {
      setState(() {
        checked = const Icon(Icons.check_box_rounded);
      });
    }
    isChecked = !isChecked;
  }

  void changeStatus() {
    if (isComplete) {
      setState(() {
        status = 'incomplete';
      });
    } else {
      setState(() {
        status = 'complete';
      });
    }
    isComplete = !isComplete;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: 4),
      tileColor: widget.tileColor,
      leading: IconButton(
        icon: checked,
        onPressed: () {
          changeStatus();
          changeCheck();
        },
        color: const Color.fromARGB(255, 255, 255, 255),
        iconSize: 40,
      ),
      title: SizedBox(
        width: double.infinity,
        height: 50,
        child: TextFormField(
          style: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          initialValue: widget.title,
          maxLines: 3,
          decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              labelText: status,
              labelStyle: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255), fontSize: 15),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: () {
          widget.onRemove();
        },
        iconSize: 40,
        color: const Color.fromARGB(255, 255, 255, 255),
        splashColor: const Color.fromARGB(255, 12, 9, 9),
      ),
    );
  }
}
