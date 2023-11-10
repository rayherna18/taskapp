import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const firebaseConfig = FirebaseOptions(
    apiKey:
        "AIzaSyDxERoZ14OADWZ4uKaXp9H-RR1EGEUHJ3o", // Replace with actual apiKey
    appId:
        "1:88169992530:android:7096adbfbee0c8525d6a8b", // Replace with actual appId
    messagingSenderId: "88169992530", // Replace with actual messagingSenderId
    projectId: "taskapp-619da", // Replace with actual projectId
  );
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          foregroundColor: Color.fromARGB(255, 19, 19, 19),
          elevation: 0,
          iconTheme: IconThemeData(color: Color.fromARGB(255, 19, 19, 19)),
        ),
      ),
      title: 'Tasks',
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Registration successful, navigate to the login page.
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        ),
      );
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Login successful, navigate to the TaskListScreen.
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TaskListScreen(title: 'Task List'),
        ),
      );
    } catch (e) {
      print('Error during login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Task Attack',
        textAlign: TextAlign.center,
      )),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          const Text(
            'Let\'s get Productive!',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                color: Colors.black),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.black),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            cursorColor: Colors.black,
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.black),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            obscureText: true,
            cursorColor: Colors.black,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _register,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 15, 15, 15)),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(32),
                    )),
                child: const Text('Register'),
              ),
              const SizedBox(width: 32),
              ElevatedButton(
                onPressed: _login,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 15, 15, 15)),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(32),
                    )),
                child: const Text('Login'),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Successful Registration')),
      body: const Center(
        child: Text('You are now registered.'),
      ),
    );
  }
}
