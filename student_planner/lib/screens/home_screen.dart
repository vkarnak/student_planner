import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../providers/event_provider.dart';
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

    Future.microtask(() {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
      Provider.of<EventProvider>(context, listen: false).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    // 🔥 только ближайшие события (и ограничение)
    final events = eventProvider.upcoming.take(5).toList();

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
          // ================= LEFT SIDE =================
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // ================= CALENDAR =================
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              "Calendar (будет тут)",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // ================= EVENTS =================
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Events",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                SizedBox(height: 10),

                                Expanded(
                                  child: eventProvider.isLoading
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : events.isEmpty
                                      ? Center(child: Text("No events"))
                                      : ListView.builder(
                                          itemCount: events.length,
                                          itemBuilder: (context, index) {
                                            final e = events[index];

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,

                                                leading: Icon(
                                                  Icons.event,
                                                  color: Colors.blue,
                                                ),

                                                title: Text(e.title),

                                                subtitle: Text(
                                                  "${formatDate(e.start)} • ${formatTime(e.start)} - ${formatTime(e.end)}",
                                                ),

                                                // 🔥 ВОТ ЭТО ДОБАВИЛИ
                                                trailing: IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    final confirm = await showDialog(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: Text(
                                                          "Delete event",
                                                        ),
                                                        content: Text(
                                                          "Are you sure?",
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  ctx,
                                                                  false,
                                                                ),
                                                            child: Text(
                                                              "Cancel",
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  ctx,
                                                                  true,
                                                                ),
                                                            child: Text(
                                                              "Delete",
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );

                                                    if (confirm == true) {
                                                      await Provider.of<
                                                            EventProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          )
                                                          .deleteEvent(e.id!);

                                                      // 💬 красиво уведомляем
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Event deleted",
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),

                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    "/edit_event",
                                                    arguments: e,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),

                          // ➕ добавить событие
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: FloatingActionButton(
                              heroTag: "event_list_add",
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
                ],
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

                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            heroTag: "task_add",
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

                // ================= AI =================
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

  // ================= FORMAT =================

  String formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}";
  }

  String formatTime(DateTime d) {
    return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }
}
