import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () =>
          Provider.of<ScheduleProvider>(context, listen: false).loadSchedule(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context);

    final filtered = provider.items.where((task) {
      if (task.deadline == null || task.deadline!.isEmpty) return false;

      final deadline = DateTime.parse(task.deadline!);

      return deadline.year == selectedDate.year &&
          deadline.month == selectedDate.month &&
          deadline.day == selectedDate.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Calendar")),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.subtract(Duration(days: 1));
                    });
                  },
                ),

                Text(
                  "${selectedDate.toLocal()}".split(' ')[0],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.add(Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ),

          Divider(),

          provider.isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : filtered.isEmpty
              ? Expanded(child: Center(child: Text("No tasks")))
              : Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final task = filtered[index];

                      return ListTile(
                        leading: Icon(Icons.check_box, color: Colors.green),

                        title: Text(task.title),

                        subtitle: Text(task.status),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
