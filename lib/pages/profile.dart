import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'achievements.dart';

class Profile extends StatelessWidget {
  final String uid;
  final bool isDark;
  final VoidCallback toggleTheme;

  const Profile({
    Key? key,
    required this.uid,
    required this.isDark,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          Switch(
            value: isDark,
            onChanged: (_) => toggleTheme(),
            activeColor: Colors.deepOrangeAccent,
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("There is no user data"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final completedTasks = data['completedTasks'] ?? 0;
          final points = data['points'] ?? 0;
          final level = data['level'] ?? 1;
          final achievements = getUserAchievements(completedTasks);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.deepOrange.shade200,
                  child: const Icon(Icons.person, size: 64, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  "A Productive Hero",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Text("Level: $level", style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                Text("Points: $points", style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                Text("Completed tasks: $completedTasks", style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 24),
                const Text(
                  "Achievements",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (achievements.isEmpty)
                  const Text("There are no achievements yet", style: TextStyle(fontSize: 16)),
                for (var ach in achievements)
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.deepOrange),
                    title: Text(ach.title, style: const TextStyle(fontSize: 18)),
                    subtitle: Text(ach.description),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
