import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'achievements.dart';

class AchievementsScreen extends StatelessWidget {
  final String uid;

  const AchievementsScreen({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Achievements"), centerTitle: true),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No user data found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final completedTasks = data['completedTasks'] ?? 0;
          final achievements = getUserAchievements(completedTasks);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: achievements.isEmpty
                ? const Center(child: Text("No achievements yet. Keep completing tasks!"))
                : ListView.builder(
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.deepOrange),
                  title: Text(ach.title, style: const TextStyle(fontSize: 18)),
                  subtitle: Text(ach.description),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
