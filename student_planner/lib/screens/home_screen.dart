import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_planner/providers/settings_provider.dart';
import 'package:student_planner/screens/add_event_screen.dart';
import 'package:student_planner/screens/add_task_screen.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/task_provider.dart';
import '../providers/event_provider.dart';
import '../providers/ai_provider.dart';

import '../models/task.dart';
import '../models/event.dart';

//import '../widgets/task_tile.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final taskProvider = context.read<TaskProvider>();
      final eventProvider = context.read<EventProvider>();
      final aiProvider = context.read<AiProvider>();

      await taskProvider.loadTasks();
      await eventProvider.loadEvents();

      final settingsProvider = context.read<SettingsProvider>();
      aiProvider.bind(taskProvider, eventProvider, settingsProvider);
    });
  }

  String formatTime(DateTime d) =>
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";

  String formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

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

  List<dynamic> getItemsForDay(DateTime day) {
    final tasks = Provider.of<TaskProvider>(context, listen: false).tasks;
    final events = Provider.of<EventProvider>(context, listen: false).events;

    final dayTasks = tasks.where((t) {
      if (t.deadline == null) return false;
      if (t.status == "done") return false;

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

  Widget buildInnerCard({required Widget child, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(22),

          hoverColor: Colors.indigo.withOpacity(0.04),
          splashColor: Colors.indigo.withOpacity(0.08),

          onTap: onTap,

          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFF),

              borderRadius: BorderRadius.circular(22),

              border: Border.all(color: Colors.black12),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),

              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),

              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),

                      border: Border.all(color: Colors.black12),
                    ),

                    child: IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),

                      iconSize: 28,

                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                          );
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),

                        onTap: pickMonthYear,

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(18),

                            border: Border.all(color: Colors.black12),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Text(
                                "${monthName(_focusedDay.month)} ${_focusedDay.year}",

                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(width: 6),

                              const Icon(Icons.expand_more_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),

                      border: Border.all(color: Colors.black12),
                    ),

                    child: IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),

                      iconSize: 28,

                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                          );
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),

                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: IconButton(
                      icon: const Icon(
                        Icons.today_rounded,
                        color: Color(0xFF4B5BD7),
                      ),

                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime.now();
                          _selectedDay = DateTime.now();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TableCalendar(
                firstDay: DateTime.utc(1900),
                lastDay: DateTime.utc(2100),
                startingDayOfWeek: StartingDayOfWeek.monday,
                availableGestures: AvailableGestures.horizontalSwipe,
                rowHeight: 52,
                daysOfWeekHeight: 28,
                focusedDay: _focusedDay,
                headerVisible: false,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = isSameDay(_selectedDay, selected)
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: items.take(3).map((item) {
                        Color color = item is Task
                            ? getTaskColor(item)
                            : getEventColor((item as Event).color);

                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 1),
                          width: 14,
                          height: 4,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                calendarStyle: CalendarStyle(
                  outsideTextStyle: TextStyle(color: Colors.grey.shade400),
                  defaultTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF4B5BD7),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF4B5BD7),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Color(0xFF4B5BD7),
                    fontWeight: FontWeight.w700,
                  ),
                  cellMargin: const EdgeInsets.all(6),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
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

            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF4B5BD7),

            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Colors.black12),
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEventScreen()),
              );
            },

            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(List items, EventProvider eventProvider) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item is Task) {
          final overdue = isOverdue(item);

          return buildInnerCard(
            onTap: () {
              Navigator.pushNamed(context, "/edit", arguments: item);
            },

            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: overdue ? Colors.red : getTaskColor(item),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,

                          color: item.status == "done"
                              ? Colors.black45
                              : overdue
                              ? Colors.red
                              : Colors.black87,

                          decoration: item.status == "done"
                              ? TextDecoration.lineThrough
                              : null,

                          decorationThickness: 3,
                          decorationColor: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 4),

                      if (item.deadline != null)
                        Text(
                          "Due: ${formatDate(DateTime.parse(item.deadline!))}",
                          style: TextStyle(
                            color: overdue ? Colors.red : Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),

                        onPressed: () {
                          Provider.of<TaskProvider>(
                            context,
                            listen: false,
                          ).deleteTask(item.id!);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      icon: Icon(
                        item.status == "done"
                            ? Icons.check_circle
                            : Icons.check_circle_outline,

                        color: item.status == "done"
                            ? Colors.green
                            : Colors.grey,
                      ),

                      onPressed: () {
                        Provider.of<TaskProvider>(
                          context,
                          listen: false,
                        ).toggleDone(item);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final e = item as Event;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => {
            Navigator.pushNamed(context, "/edit_event", arguments: e),
          },

          child: buildInnerCard(
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: getEventColor(e.color),
                  size: 20,
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${formatDate(e.start)} "
                        "${formatTime(e.start)}- ${formatTime(e.end)}",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 22),
                    onPressed: () {
                      eventProvider.deleteEvent(e.id!);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasks(TaskProvider taskProvider) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),

          child: ListView.builder(
            itemCount: taskProvider.tasks.length,

            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];

              final overdue = isOverdue(task);

              return buildInnerCard(
                onTap: () {
                  Navigator.pushNamed(context, "/edit", arguments: task);
                },

                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,

                      decoration: BoxDecoration(
                        color: overdue ? Colors.red : getTaskColor(task),

                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            task.title,

                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,

                              color: task.status == "done"
                                  ? Colors.black45
                                  : overdue
                                  ? Colors.red
                                  : Colors.black87,

                              decoration: task.status == "done"
                                  ? TextDecoration.lineThrough
                                  : null,

                              decorationThickness: 3,
                              decorationColor: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 4),

                          if (task.deadline != null)
                            Text(
                              "Due: ${formatDate(DateTime.parse(task.deadline!))}",

                              style: TextStyle(
                                color: overdue
                                    ? Colors.red
                                    : Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),

                            onPressed: () {
                              taskProvider.deleteTask(task.id!);
                            },
                          ),
                        ),

                        const SizedBox(width: 8),

                        IconButton(
                          icon: Icon(
                            task.status == "done"
                                ? Icons.check_circle
                                : Icons.check_circle_outline,

                            color: task.status == "done"
                                ? Colors.green
                                : Colors.grey,
                          ),

                          onPressed: () {
                            taskProvider.toggleDone(task);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        Positioned(
          bottom: 24,
          right: 24,

          child: FloatingActionButton(
            mini: true,

            backgroundColor: const Color(0xFF4B5BD7),

            foregroundColor: Colors.white,

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddTaskScreen()),
              );
            },

            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildAI(
    AiProvider ai,
    TaskProvider taskProvider,
    EventProvider eventProvider,
  ) {
    final filtered = ai.suggestions.where((s) {
      final task = taskProvider.tasks.any(
        (t) => t.title == s.title && t.status == "done",
      );

      return !task;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "💡 No suggestions",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      itemCount: filtered.length,

      itemBuilder: (context, index) {
        final s = filtered[index];

        final overdue = taskProvider.tasks.any((t) {
          if (t.deadline == null) return false;
          if (t.status == "done") return false;

          final taskTitle = t.title.toLowerCase().trim();

          final suggestionTitle = s.title.toLowerCase();

          final related = suggestionTitle.contains(taskTitle);

          if (!related) return false;

          return DateTime.parse(t.deadline!).isBefore(DateTime.now());
        });

        return buildInnerCard(
          onTap: () {
            Navigator.pushNamed(context, "/edit_event", arguments: s);
          },

          child: Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: overdue ? Colors.red : Colors.purple,
                size: 22,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      s.title,

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,

                        color: overdue ? Colors.red : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${formatDate(s.start)} "
                      "${formatTime(s.start)} - ${formatTime(s.end)}",

                      style: TextStyle(
                        color: overdue ? Colors.red : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),

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
                  ),
                  const SizedBox(width: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),

                      onPressed: () {
                        ai.removeSuggestion(s);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final ai = Provider.of<AiProvider>(context);

    final isMobile = MediaQuery.of(context).size.width < 700;

    final items = _selectedDay == null
        ? [
            ...taskProvider.tasks.where((t) => t.status != "done"),
            ...eventProvider.events,
          ]
        : getItemsForDay(_selectedDay!);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 145, 159, 239),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black87,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(
                Icons.account_circle,
                size: 34,
                color: Color(0xFF4B5BD7),
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/profile");
              },
            ),
          ),
        ],
      ),

      body: isMobile
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      height: 420,
                      child: Card(child: _buildCalendar()),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      height: 260,
                      child: Card(child: _buildItemsList(items, eventProvider)),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      height: 300,
                      child: Card(child: _buildTasks(taskProvider)),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      height: 260,
                      child: Card(
                        child: _buildAI(ai, taskProvider, eventProvider),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(flex: 3, child: Card(child: _buildCalendar())),
                        SizedBox(height: 10),
                        Expanded(
                          flex: 2,
                          child: Card(
                            child: _buildItemsList(items, eventProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            Card(
                              margin: EdgeInsets.all(16),
                              child: _buildTasks(taskProvider),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Card(
                          margin: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: _buildAI(ai, taskProvider, eventProvider),
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
