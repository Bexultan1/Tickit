import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'achievements.dart';

class Home extends StatefulWidget {
  final String uid;

  const Home({Key? key, required this.uid}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, dynamic>> todoList = [];
  final TextEditingController _textController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodosFromFirestore();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadTodosFromFirestore() async {
    setState(() {
      isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('uid', isEqualTo: widget.uid)
          .get();

      final todos = querySnapshot.docs
          .map((doc) => {
        'id': doc.id,
        'item': doc['item'],
      })
          .toList();

      setState(() {
        todoList.clear();
        todoList.addAll(todos);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tasks: $e')),
      );
    }
  }

  Future<void> _addTodo() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('items').add({
        'item': text,
        'uid': widget.uid,
        'createdAt': Timestamp.now(),
      });

      setState(() {
        todoList.add({'id': doc.id, 'item': text});
      });
      _textController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: $e')),
      );
    }
  }

  Future<void> updateUserProgressOnTaskComplete() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'completedTasks': 1,
        'points': 10,
        'level': 1,
        'lastReset': Timestamp.now(),
      });
      return;
    }

    final data = snapshot.data()!;
    int completedTasks = (data['completedTasks'] ?? 0) + 1;
    int points = (data['points'] ?? 0) + 10;

    int level = calculateLevel(points);

    await userDoc.update({
      'completedTasks': completedTasks,
      'points': points,
      'level': level,
    });
  }

  int calculateLevel(int points) {
    if (points < 100) return 1;
    if (points < 300) return 2;
    if (points < 600) return 3;
    if (points < 1000) return 4;
    return 5;
  }

  Future<void> _removeTodoAt(int index) async {
    final todo = todoList[index];
    try {
      await FirebaseFirestore.instance.collection('items').doc(todo['id']).delete();

      await updateUserProgressOnTaskComplete();

      setState(() {
        todoList.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }

  void _showAddDialog() {
    _textController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("New Task"),
        content: TextField(
          controller: _textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter task title',
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepOrange.shade400,
            ),
            onPressed: () async {
              await _addTodo();
              Navigator.of(context).pop();
            },
            child: const Text("Add"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> _showAchievementsDialog() async {
    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("There is no user data for achievements")),
      );
      return;
    }

    final data = userDoc.data()!;
    final completedTasks = data['completedTasks'] ?? 0;
    final achievements = getUserAchievements(completedTasks);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("achievements"),
        content: achievements.isEmpty
            ? const Text("There are no achievements yet")
            : SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: achievements
                .map((ach) => ListTile(
              leading: const Icon(Icons.star, color: Colors.deepOrange),
              title: Text(ach.title),
              subtitle: Text(ach.description),
            ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tickit"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'achievements',
            onPressed: _showAchievementsDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : todoList.isEmpty
          ? Center(
        child: Text(
          "No tasks yet. Tap '+' to add.",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          final item = todoList[index];
          return Dismissible(
            key: ValueKey(item['id']),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red.shade400,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _removeTodoAt(index),
            child: Card(
              margin:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: ListTile(
                title: Text(
                  item['item'],
                  style: const TextStyle(fontSize: 18),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade400),
                  onPressed: () => _removeTodoAt(index),
                  tooltip: 'Delete task',
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
