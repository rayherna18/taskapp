import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TaskListScreen(title: 'Task List'),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key, required this.title});
  final String title;

  @override
  State<TaskListScreen> createState() => _TaskListScreen();
}

class _TaskListScreen extends State<TaskListScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  List<Task> tasks = [];

  Future<void> addTask() async {
    try {
      DocumentReference taskReference = await tasksCollection.add({
        'title': 'New Task',
        'tileColor':
            Colors.primaries[Random().nextInt(Colors.primaries.length)].value,
        'subTasks': []
      });

      DocumentSnapshot taskSnapshot = await taskReference.get();
      setState(() {
        tasks.add(Task.fromSnapshot(taskSnapshot));
      });
    } catch (e) {
      print('Error adding task: $e');
    }
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

  factory Task.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    return Task(
      title: data?['title'] ?? 'No Title',
      tileColor: Color(data?['tileColor'] ?? Colors.transparent.value),
    );
  }
}

class TaskList extends StatefulWidget {
  final VoidCallback addTaskCallBack;
  final List<Task> tasks;

  const TaskList(
      {Key? key, required this.addTaskCallBack, required this.tasks});

  @override
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
      {Key? key,
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
            fontSize: 10,
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
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 15,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
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
