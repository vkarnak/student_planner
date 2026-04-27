import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => Provider.of<EventProvider>(context, listen: false).loadEvents(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Events")),

      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : provider.events.isEmpty
          ? Center(child: Text("No events yet"))
          : ListView.builder(
              itemCount: provider.events.length,
              itemBuilder: (context, index) {
                final e = provider.events[index];

                return ListTile(
                  title: Text(e.title),

                  subtitle: Text(
                    "${formatDate(e.start)} • ${formatTime(e.start)} - ${formatTime(e.end)}",
                  ),

                  onTap: () {
                    Navigator.pushNamed(context, "/edit_event", arguments: e);
                  },

                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text("Delete event"),
                          content: Text("Are you sure?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text("Delete"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        Provider.of<EventProvider>(
                          context,
                          listen: false,
                        ).deleteEvent(e.id!);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Event deleted")),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  // ================= FORMAT =================

  String formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
  }

  String formatTime(DateTime d) {
    return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }
}
