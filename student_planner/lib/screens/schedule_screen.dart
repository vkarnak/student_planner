import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../models/task.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Smart Schedule")),

      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : provider.items.isEmpty
          ? Center(child: Text("No optimized schedule yet"))
          : ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final task = provider.items[index];

                return ListTile(
                  leading: Icon(Icons.auto_awesome, color: Colors.purple),

                  title: Text(task.title),

                  subtitle: Text("Priority: ${task.priority}"),
                );
              },
            ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "optimize",
            onPressed: () async {
              await provider.optimize();

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Schedule optimized 🚀")));
            },
            child: Icon(Icons.refresh),
          ),

          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "auto",
            backgroundColor: Colors.purple,
            onPressed: () async {
              await provider.autoDistribute();

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Tasks redistributed 🤖")));
            },
            child: Icon(Icons.auto_fix_high),
          ),
        ],
      ),
    );
  }
}
