import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_planner/screens/add_event_screen.dart';
import 'package:student_planner/screens/add_task_screen.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/task_provider.dart';
import '../providers/event_provider.dart';
import '../providers/ai_provider.dart';

import '../models/task.dart';
import '../models/event.dart';

import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
      Provider.of<EventProvider>(context, listen: false).loadEvents();
      Provider.of<AiProvider>(context, listen: false).loadSuggestions();
    });
  }

  // ================= FORMAT =================

  String formatTime(DateTime d) =>
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";

  String formatDate(DateTime d) => "${d.day}.${d.month}";

  String monthName(int m) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[m];
  }

  Future<void> pickMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(1900),
      lastDate: DateTime(2500),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() => _focusedDay = picked);
    }
  }

  bool isOverdue(Task task) {
    if (task.deadline == null) return false;
    final d = DateTime.parse(task.deadline!);
    return d.isBefore(DateTime.now()) && task.status != "done";
  }

  // ================= ITEMS =================

  List<dynamic> getItemsForDay(DateTime day) {
    final tasks = Provider.of<TaskProvider>(context, listen: false).tasks;
    final events = Provider.of<EventProvider>(context, listen: false).events;

    final dayTasks = tasks.where((t) {
      if (t.deadline == null) return false;
      final d = DateTime.parse(t.deadline!);
      return d.year == day.year && d.month == day.month && d.day == day.day;
    });

    final dayEvents = events.where((e) {
      return e.start.year == day.year &&
          e.start.month == day.month &&
          e.start.day == day.day;
    });

    return [...dayTasks, ...dayEvents];
  }

  // ================= COLORS =================

  Color getTaskColor(Task task) {
    switch (task.priority) {
      case 4:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color getEventColor(String? color) {
    if (color == "ai") return Colors.purple;

    switch (color) {
      case "red":
        return Colors.red;
      case "green":
        return Colors.green;
      case "orange":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final ai = Provider.of<AiProvider>(context);

    final items = _selectedDay == null
        ? [...taskProvider.tasks, ...eventProvider.events]
        : getItemsForDay(_selectedDay!);

    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Row(
        children: [
          // ================= LEFT =================
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
                          Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.chevron_left),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = DateTime(
                                          _focusedDay.year,
                                          _focusedDay.month - 1,
                                        );
                                      });
                                    },
                                  ),

                                  // TODAY
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _focusedDay = DateTime.now();
                                        _selectedDay = DateTime.now();
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Today",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Center(
                                      child: InkWell(
                                        onTap: pickMonthYear,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "${monthName(_focusedDay.month)} ${_focusedDay.year}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(Icons.arrow_drop_down),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  IconButton(
                                    icon: Icon(Icons.chevron_right),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = DateTime(
                                          _focusedDay.year,
                                          _focusedDay.month + 1,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),

                              Expanded(
                                child: TableCalendar(
                                  firstDay: DateTime.utc(1900, 1, 1),
                                  lastDay: DateTime.utc(2500, 12, 31),
                                  focusedDay: _focusedDay,
                                  headerVisible: false,
                                  startingDayOfWeek: StartingDayOfWeek.monday,
                                  selectedDayPredicate: (day) =>
                                      isSameDay(_selectedDay, day),
                                  onDaySelected: (selected, focused) {
                                    setState(() {
                                      _selectedDay =
                                          isSameDay(_selectedDay, selected)
                                          ? null
                                          : selected;
                                      _focusedDay = focused;
                                    });
                                  },
                                  eventLoader: getItemsForDay,
                                  calendarBuilders: CalendarBuilders(
                                    markerBuilder: (context, day, items) {
                                      if (items.isEmpty) return null;

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: items.take(3).map((item) {
                                          Color color = item is Task
                                              ? getTaskColor(item)
                                              : getEventColor(
                                                  (item as Event).color,
                                                );

                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 1,
                                            ),
                                            width: 10,
                                            height: 3,
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: FloatingActionButton(
                              mini: true,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEventScreen(),
                                  ),
                                );
                              },
                              child: Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // ================= LIST =================
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];

                          if (item is Task) {
                            final overdue = isOverdue(item);

                            return ListTile(
                              leading: Icon(
                                Icons.circle,
                                size: 10,
                                color: overdue
                                    ? Colors.red
                                    : getTaskColor(item),
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  color: overdue ? Colors.red : null,
                                  fontWeight: overdue ? FontWeight.bold : null,
                                ),
                              ),
                              subtitle: item.deadline != null
                                  ? Text(
                                      formatDate(
                                        DateTime.parse(item.deadline!),
                                      ),
                                    )
                                  : null,
                            );
                          }

                          final e = item as Event;

                          return ListTile(
                            leading: Icon(
                              Icons.calendar_today,
                              color: getEventColor(e.color),
                            ),
                            title: Text(e.title),
                            subtitle: Text(
                              "${formatDate(e.start)} ${formatTime(e.start)}",
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                "/edit_event",
                                arguments: e,
                              );
                            },
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                eventProvider.deleteEvent(e.id!);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= RIGHT =================
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // TASKS
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Card(
                        margin: EdgeInsets.all(16),
                        child: ListView.builder(
                          itemCount: taskProvider.tasks.length,
                          itemBuilder: (context, index) {
                            return TaskTile(taskProvider.tasks[index]);
                          },
                        ),
                      ),

                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddTaskScreen(),
                              ),
                            );
                          },
                          child: Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                ),

                // AI
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: ai.suggestions.isEmpty
                        ? Center(child: Text("💡 No suggestions"))
                        : ListView.builder(
                            itemCount: ai.suggestions.length,
                            itemBuilder: (context, index) {
                              final s = ai.suggestions[index];

                              return ListTile(
                                leading: Icon(
                                  Icons.lightbulb,
                                  color: Colors.purple,
                                ),
                                title: Text(s.title),
                                subtitle: Text(
                                  "${formatDate(s.start)} ${formatTime(s.start)}",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.green,
                                      ),
                                      onPressed: () async {
                                        await eventProvider.addEvent(
                                          Event(
                                            title: s.title,
                                            start: s.start,
                                            end: s.end,
                                            color: "ai",
                                          ),
                                        );
                                        ai.removeSuggestion(s);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        ai.removeSuggestion(s);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
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
