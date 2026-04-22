import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/deadline_provider.dart';

class DeadlinesScreen extends StatelessWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeadlineProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Deadlines")),

      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final task = provider.items[index];

                Color color = task['daysLeft'] <= 1
                    ? Colors.red
                    : task['daysLeft'] <= 3
                    ? Colors.orange
                    : Colors.green;

                return ListTile(
                  leading: Icon(Icons.warning, color: color),

                  title: Text(task['title']),

                  subtitle: Text("${task['daysLeft']} days left"),
                );
              },
            ),
    );
  }
}
