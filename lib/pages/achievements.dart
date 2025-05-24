class Achievement {
  final String title;
  final String description;

  Achievement({required this.title, required this.description});
}

List<Achievement> getUserAchievements(int completedTasks) {
  List<Achievement> achievements = [];

  if (completedTasks >= 1) {
    achievements.add(Achievement(
      title: 'First Step',
      description: 'You completed your first task!',
    ));
  }
  if (completedTasks >= 10) {
    achievements.add(Achievement(
      title: 'Task Crusher',
      description: 'Completed 10 tasks. Keep going!',
    ));
  }
  if (completedTasks >= 25) {
    achievements.add(Achievement(
      title: 'Productivity Pro',
      description: '25 tasks down. You’re on fire!',
    ));
  }
  return achievements;
}
