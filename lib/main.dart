import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_main/pages/splash_screen.dart';
import 'firebase_options.dart'; // сгенерирован автоматически
import 'pages/home.dart';
import 'pages/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TickitApp());
}

class TickitApp extends StatefulWidget {
  const TickitApp({Key? key}) : super(key: key);

  @override
  State<TickitApp> createState() => _TickitAppState();
}

class _TickitAppState extends State<TickitApp> {
  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tickit',
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
        home: SplashScreen(isDark: isDark, toggleTheme: toggleTheme),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const MainScreen({Key? key, required this.isDark, required this.toggleTheme}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 1;

  final String userUid = 'demoUser123';

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (selectedIndex) {
      case 0:
        body = Center(child: Text("Achievements (to be announced later)", style: TextStyle(fontSize: 24)));
        break;
      case 1:
        body = Home(uid: userUid);
        break;
      case 2:
        body = Profile(uid: userUid, isDark: widget.isDark, toggleTheme: widget.toggleTheme);
        break;
      default:
        body = Home(uid: userUid);
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (idx) => setState(() => selectedIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Achievements'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
