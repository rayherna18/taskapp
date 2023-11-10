// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TaskListScreen(title: 'Task List'),
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
  FirebaseAuth auth = FirebaseAuth.instance;

  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot =
            await tasksCollection.where('userId', isEqualTo: user.uid).get();
        setState(() {
          tasks =
              querySnapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList();
        });
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  Future<void> addTask() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        // Optimistic Update
        Task newTask = Task(
          id: DateTime.now().toString(), // Use a unique identifier
          title: 'Task Description',
          description: '',
          status: false,
        );

        setState(() {
          tasks.add(newTask);
        });

        // Perform asynchronous Firestore operation
        DocumentReference newTaskReference = await tasksCollection.add({
          'userId': user.uid,
          'title': newTask.title,
          'description': newTask.description,
          'status': newTask.status,
        });

        // Update the task locally with the Firestore-generated ID
        newTask.id = newTaskReference.id;
        setState(() {
          tasks[tasks.indexOf(newTask)] = newTask;
        });
      }
    } catch (e) {
      print('Error adding task: $e');
      // Roll back the local state
      setState(() {
        tasks.removeLast();
      });
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await tasksCollection.doc(task.id).update({
        'title': task.title,
        'description': task.description,
        'status': task.status,
      });
      await fetchTasks(); // Wait for fetchTasks to complete
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      await tasksCollection.doc(task.id).delete();
      await fetchTasks();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Goes back to login screen
    } catch (e) {
      print('Error signing out: $e');
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
            Row(
              children: [
                IconButton(
                  iconSize: 50,
                  icon: const Icon(Icons.add_box),
                  color: Colors.black,
                  onPressed: () {
                    addTask();
                  },
                ),
                IconButton(
                  iconSize: 50,
                  icon: const Icon(Icons.logout_rounded),
                  color: Colors.black,
                  onPressed: () {
                    signOut();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: TaskList(
        updateTaskCallBack: updateTask,
        deleteTaskCallBack: deleteTask,
        tasks: tasks,
      ),
    );
  }
}

class Task {
  String id; // Change this to String
  String title;
  final Color tileColor;
  String description;
  bool status;

  Task({
    required this.id,
    required this.title,
    Color? tileColor,
    required this.description,
    required this.status,
  }) : tileColor = tileColor ?? Colors.transparent;

  factory Task.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return Task(
      id: snapshot.id,
      title: data['title'] ?? 'Task Description',
      tileColor: Color(data['tileColor'] ?? Colors.transparent.value),
      description: data['description'] ?? '',
      status: data['status'] ?? false,
    );
  }
}

class TaskList extends StatefulWidget {
  final Function(Task) updateTaskCallBack;
  final Function(Task) deleteTaskCallBack;
  final List<Task> tasks;

  const TaskList({
    Key? key,
    required this.updateTaskCallBack,
    required this.deleteTaskCallBack,
    required this.tasks,
  });

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
          task: task,
          updateTaskCallBack: widget.updateTaskCallBack,
          deleteTaskCallBack: widget.deleteTaskCallBack,
        );
      },
    );
  }
}

class TaskItem extends StatefulWidget {
  final Task task;
  final Function(Task) updateTaskCallBack;
  final Function(Task) deleteTaskCallBack;

  const TaskItem({
    Key? key,
    required this.task,
    required this.updateTaskCallBack,
    required this.deleteTaskCallBack,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  Icon checked = const Icon(Icons.check_box_outline_blank_rounded);
  bool isChecked = false;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    isChecked = widget.task.status;
    updateCheckIcon();
    descriptionController =
        TextEditingController(text: widget.task.description);
  }

  void updateCheckIcon() {
    checked = isChecked
        ? const Icon(Icons.check_box_rounded)
        : const Icon(Icons.check_box_outline_blank_rounded);
  }

  void changeCheck() {
    setState(() {
      isChecked = !isChecked;
      updateCheckIcon();
    });
    widget.task.status = isChecked;
    widget.updateTaskCallBack(widget.task);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: 4),
      tileColor: widget.task.tileColor,
      leading: IconButton(
        icon: checked,
        onPressed: changeCheck,
        color: const Color.fromARGB(255, 45, 214, 3),
        iconSize: 40,
      ),
      title: SizedBox(
        width: double.infinity,
        height: 50,
        child: TextFormField(
          style: const TextStyle(
            color: Color.fromARGB(255, 19, 19, 19),
            fontSize: 16,
          ),
          controller: descriptionController,
          maxLines: 3,
          onChanged: (value) {
            widget.task.description =
                value; // Update description instead of title
            widget.updateTaskCallBack(widget.task);
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            labelText: 'Task Description', // Update the labelText
            labelStyle: TextStyle(
              color: Color.fromARGB(255, 19, 19, 19),
              fontSize: 15,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: () {
          widget.deleteTaskCallBack(widget.task);
        },
        iconSize: 40,
        color: const Color.fromARGB(255, 231, 10, 10),
        splashColor: const Color.fromARGB(255, 12, 9, 9),
      ),
    );
  }
}
