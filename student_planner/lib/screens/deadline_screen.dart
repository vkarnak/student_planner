import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_planner/providers/deadline_provider.dart';

class DeadlinesScreen extends StatelessWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeadlineProvider>(context);
    final tasks = provider.upcoming;

    return Scaffold(
      appBar: AppBar(title: Text("Deadlines")),

      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? Center(child: Text("No deadlines 🎉"))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final days = task.daysLeft;

                Color color;
                if (days <= 1) {
                  color = Colors.red;
                } else if (days <= 3) {
                  color = Colors.orange;
                } else {
                  color = Colors.green;
                }

                return ListTile(
                  leading: Icon(Icons.warning, color: color),
                  title: Text(task.title),
                  subtitle: Text(days < 0 ? "Overdue" : "$days days left"),
                );
              },
            ),
    );
  }
}
