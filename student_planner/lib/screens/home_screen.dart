import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/task_provider.dart';
import '../providers/event_provider.dart';
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

  bool isOverdue(Task task) {
    if (task.deadline == null) return false;
    final deadline = DateTime.parse(task.deadline!);
    return deadline.isBefore(DateTime.now()) && task.status != "done";
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
      Provider.of<EventProvider>(context, listen: false).loadEvents();
    });
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

  // ================= FORMAT =================

  String formatTime(DateTime d) {
    return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }

  String formatDate(DateTime d) {
    return "${d.day}.${d.month}";
  }

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
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _focusedDay = picked;
      });
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    final now = DateTime.now();

    final activeTasks = taskProvider.tasks
        .where((t) => t.status != "done")
        .toList();

    final overdueTasks = activeTasks.where((t) {
      if (t.deadline == null) return false;
      return DateTime.parse(t.deadline!).isBefore(now);
    }).toList();

    final upcomingTasks = activeTasks.where((t) {
      if (t.deadline == null) return false;
      return DateTime.parse(t.deadline!).isAfter(now);
    }).toList();

    final futureEvents = eventProvider.events
        .where((e) => e.start.isAfter(now))
        .toList();

    overdueTasks.sort(
      (a, b) =>
          DateTime.parse(a.deadline!).compareTo(DateTime.parse(b.deadline!)),
    );

    upcomingTasks.sort(
      (a, b) =>
          DateTime.parse(a.deadline!).compareTo(DateTime.parse(b.deadline!)),
    );

    futureEvents.sort((a, b) => a.start.compareTo(b.start));

    final items = _selectedDay == null
        ? [...overdueTasks, ...upcomingTasks, ...futureEvents].take(5).toList()
        : getItemsForDay(_selectedDay!);

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
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
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
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _focusedDay = DateTime.now();
                                          _selectedDay = DateTime.now();
                                        });
                                      },
                                      child: Text("Today"),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: pickMonthYear,
                                          child: Text(
                                            "${monthName(_focusedDay.month)} ${_focusedDay.year}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                              ),
                              Expanded(
                                child: TableCalendar(
                                  firstDay: DateTime.utc(1900, 1, 1),
                                  lastDay: DateTime.utc(2500, 12, 31),
                                  focusedDay: _focusedDay,
                                  headerVisible: false,
                                  calendarFormat: CalendarFormat.month,
                                  startingDayOfWeek: StartingDayOfWeek.monday,
                                  rowHeight: 46,
                                  daysOfWeekHeight: 20,
                                  selectedDayPredicate: (day) =>
                                      isSameDay(_selectedDay, day),
                                  onDaySelected: (selected, focused) {
                                    setState(() {
                                      if (isSameDay(_selectedDay, selected)) {
                                        _selectedDay = null; // 👈 снимаем выбор
                                      } else {
                                        _selectedDay = selected;
                                      }

                                      _focusedDay = focused;
                                    });
                                  },
                                  eventLoader: (day) => getItemsForDay(day),
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
                                Navigator.pushNamed(context, "/add_event");
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
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedDay == null
                                  ? "Upcoming"
                                  : "Selected Day",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: items.isEmpty
                                  ? Center(child: Text("No items"))
                                  : ListView.builder(
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        final item = items[index];

                                        if (item is Task) {
                                          final overdue = isOverdue(item);

                                          return ListTile(
                                            leading: Icon(
                                              overdue
                                                  ? Icons.warning
                                                  : Icons.check_circle,
                                              color: overdue
                                                  ? Colors.red
                                                  : getTaskColor(item),
                                            ),
                                            title: Text(
                                              item.title,
                                              style: TextStyle(
                                                color: overdue
                                                    ? Colors.red
                                                    : null,
                                                fontWeight: overdue
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            subtitle: Text(
                                              item.deadline != null
                                                  ? formatDate(
                                                      DateTime.parse(
                                                        item.deadline!,
                                                      ),
                                                    )
                                                  : "No deadline",
                                              style: TextStyle(
                                                color: overdue
                                                    ? Colors.red
                                                    : null,
                                              ),
                                            ),
                                          );
                                        }

                                        final e = item as Event;

                                        return ListTile(
                                          leading: Icon(
                                            Icons.event,
                                            color: getEventColor(e.color),
                                          ),
                                          title: Text(e.title),
                                          subtitle: Text(
                                            "${formatDate(e.start)} "
                                            "${formatTime(e.start)} - ${formatTime(e.end)}",
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
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
                Expanded(
                  child: Card(
                    margin: EdgeInsets.all(16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: ListView.builder(
                        itemCount: taskProvider.tasks.length,
                        itemBuilder: (context, index) {
                          return TaskTile(taskProvider.tasks[index]);
                        },
                      ),
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
