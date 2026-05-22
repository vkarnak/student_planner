import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../models/suggestion.dart';

import '../providers/ai_provider.dart';
import '../providers/event_provider.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController title;
  late TextEditingController description;

  DateTime? selectedDate;

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool isLoading = false;
  String? error;

  late Event original;

  Suggestion? originalSuggestion;
  bool isSuggestion = false;

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments;

      if (args is Suggestion) {
        isSuggestion = true;
        originalSuggestion = args;

        original = Event(
          id: args.taskId,
          title: args.title,
          start: args.start,
          end: args.end,
          description: "",
          color: "ai",
        );
      } else {
        original = args as Event;
      }

      title = TextEditingController(text: original.title);

      description = TextEditingController(text: original.description ?? "");

      selectedDate = original.start;

      startTime = TimeOfDay(
        hour: original.start.hour,
        minute: original.start.minute,
      );

      endTime = TimeOfDay(hour: original.end.hour, minute: original.end.minute);

      _isInit = true;
    }

    super.didChangeDependencies();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('en', 'GB'),
      initialDate: selectedDate!,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime!,
    );

    if (picked != null) {
      setState(() => startTime = picked);
    }
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime!,
    );

    if (picked != null) {
      setState(() => endTime = picked);
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Not selected";

    return DateFormat('dd.MM.yyyy').format(date);
  }

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(icon),

      filled: true,
      fillColor: const Color(0xFFF8F9FF),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.indigo.shade200),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
    );
  }

  Widget buildPickerCard({
    required String title,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.indigo.shade100),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),

          const SizedBox(height: 10),

          Text(value),

          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: onTap,

            icon: Icon(icon),

            label: const Text("Select"),
          ),
        ],
      ),
    );
  }

  void save() async {
    if (selectedDate == null || startTime == null) {
      setState(() => error = "Fill all fields");
      return;
    }

    if (!isSuggestion && title.text.isEmpty) {
      setState(() => error = "Fill all fields");
      return;
    }

    final start = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    DateTime end;

    if (isSuggestion) {
      final duration = original.end.difference(original.start);

      end = start.add(duration);
    } else {
      end = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        endTime!.hour,
        endTime!.minute,
      );
    }

    if (!isSuggestion && end.isBefore(start)) {
      setState(() {
        error = "End time must be after start time";
      });

      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final updated = Event(
      id: original.id,
      title: title.text,
      start: start,
      end: end,
      description: description.text,
      color: original.color,
    );

    if (isSuggestion) {
      await Provider.of<AiProvider>(
        context,
        listen: false,
      ).updateSuggestion(originalSuggestion!, start);
    } else {
      await Provider.of<EventProvider>(
        context,
        listen: false,
      ).updateEvent(updated);
    }

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 145, 159, 239),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),

              child: Card(
                color: Colors.white,
                elevation: 10,
                shadowColor: Colors.black26,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(32),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Align(
                        alignment: Alignment.centerLeft,

                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),

                            border: Border.all(color: Colors.black12),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),

                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Colors.black87,
                            ),

                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),

                      Text(
                        isSuggestion ? "Edit Suggestion" : "Edit Event",

                        style: TextStyle(
                          fontSize: isMobile ? 30 : 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (!isSuggestion) ...[
                        TextField(
                          controller: title,

                          decoration: fieldDecoration(
                            hint: "Event title",
                            icon: Icons.event_outlined,
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextField(
                          controller: description,
                          maxLines: 3,

                          decoration: fieldDecoration(
                            hint: "Description",
                            icon: Icons.notes,
                          ),
                        ),

                        const SizedBox(height: 22),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: buildPickerCard(
                          title: "Date",
                          value: formatDate(selectedDate),
                          onTap: pickDate,
                          icon: Icons.calendar_month_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: buildPickerCard(
                              title: "Start Time",
                              value: startTime == null
                                  ? "Not selected"
                                  : startTime!.format(context),

                              onTap: pickStartTime,

                              icon: Icons.schedule_outlined,
                            ),
                          ),

                          if (!isSuggestion) const SizedBox(width: 14),

                          if (!isSuggestion)
                            Expanded(
                              child: buildPickerCard(
                                title: "End Time",
                                value: endTime == null
                                    ? "Not selected"
                                    : endTime!.format(context),

                                onTap: pickEndTime,

                                icon: Icons.schedule_outlined,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),

                          child: Text(
                            error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        height: isMobile ? 52 : 56,

                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: save,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4B5BD7),

                                  foregroundColor: Colors.white,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),

                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                child: const Text("Save"),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
