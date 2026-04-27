import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<TaskProvider>(context, listen: false).loadTasks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, "/profile");
            },
          ),
        ],
      ),

      body: Row(
        children: [
          // ================= LEFT (CALENDAR) =================
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                child: Stack(
                  children: [
                    // Пока заглушка
                    Center(
                      child: Text(
                        "Calendar (будет тут)",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),

                    // ➕ добавить событие
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        heroTag: "event",
                        mini: true,
                        onPressed: () {
                          Navigator.pushNamed(context, "/add_event");
                        },
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= RIGHT SIDE =================
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // ================= TASKS =================
                Expanded(
                  child: Card(
                    margin: EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: taskProvider.isLoading
                              ? Center(child: CircularProgressIndicator())
                              : taskProvider.tasks.isEmpty
                              ? Center(child: Text("No tasks"))
                              : ListView.builder(
                                  itemCount: taskProvider.tasks.length,
                                  itemBuilder: (context, index) {
                                    final task = taskProvider.tasks[index];
                                    return TaskTile(task);
                                  },
                                ),
                        ),

                        // ➕ добавить задачу
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            heroTag: "task",
                            mini: true,
                            onPressed: () {
                              Navigator.pushNamed(context, "/add");
                            },
                            child: Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= AI SUGGESTION =================
                Container(
                  margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "💡 Suggestion",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        "You have free time on Tuesday.\nDo you want to start your lab work?",
                      ),

                      SizedBox(height: 10),

                      Row(
                        children: [
                          TextButton(onPressed: () {}, child: Text("Later")),

                          SizedBox(width: 10),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/suggestions");
                            },
                            child: Text("Open"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
