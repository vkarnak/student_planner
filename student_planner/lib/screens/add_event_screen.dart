import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/event_provider.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final title = TextEditingController();
  final description = TextEditingController();

  String selectedColor = "blue";

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String? error;
  bool isLoading = false;

  Color getEventColor(String color) {
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

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => startTime = picked);
    }
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => endTime = picked);
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Not selected";

    return "${date.day.toString().padLeft(2, '0')}."
        "${date.month.toString().padLeft(2, '0')}."
        "${date.year}";
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

  Widget buildColorDot(String color) {
    final isSelected = selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),

        margin: const EdgeInsets.symmetric(horizontal: 8),

        width: isSelected ? 30 : 24,
        height: isSelected ? 30 : 24,

        decoration: BoxDecoration(
          color: getEventColor(color),
          shape: BoxShape.circle,

          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.transparent,
            width: 2,
          ),

          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: getEventColor(color).withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  void createEvent() async {
    if (title.text.isEmpty ||
        selectedDate == null ||
        startTime == null ||
        endTime == null) {
      setState(() => error = "Fill all required fields");
      return;
    }

    final start = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    final end = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (end.isBefore(start)) {
      setState(() {
        error = "End time must be after start time";
      });

      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final provider = Provider.of<EventProvider>(context, listen: false);

    final event = Event(
      title: title.text,
      description: description.text,
      start: start,
      end: end,
      color: selectedColor,
    );

    final success = await provider.addEvent(event);

    setState(() => isLoading = false);

    if (!success) {
      setState(() => error = "Failed to create event");
      return;
    }

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
                        "Create Event",
                        style: TextStyle(
                          fontSize: isMobile ? 30 : 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),

                      const SizedBox(height: 8),

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

                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FF),

                          borderRadius: BorderRadius.circular(20),

                          border: Border.all(color: Colors.indigo.shade100),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              "Event Color",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                buildColorDot("blue"),
                                buildColorDot("red"),
                                buildColorDot("green"),
                                buildColorDot("orange"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(18),

                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FF),

                                borderRadius: BorderRadius.circular(20),

                                border: Border.all(
                                  color: Colors.indigo.shade100,
                                ),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const Text(
                                    "Date",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(formatDate(selectedDate)),

                                  const SizedBox(height: 14),

                                  OutlinedButton.icon(
                                    onPressed: pickDate,

                                    icon: const Icon(
                                      Icons.calendar_month_outlined,
                                    ),

                                    label: const Text("Select"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(18),

                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FF),

                                borderRadius: BorderRadius.circular(20),

                                border: Border.all(
                                  color: Colors.indigo.shade100,
                                ),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const Text(
                                    "Start Time",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    startTime == null
                                        ? "Not selected"
                                        : startTime!.format(context),
                                  ),

                                  const SizedBox(height: 14),

                                  OutlinedButton.icon(
                                    onPressed: pickStartTime,

                                    icon: const Icon(Icons.schedule_outlined),

                                    label: const Text("Select"),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(18),

                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FF),

                                borderRadius: BorderRadius.circular(20),

                                border: Border.all(
                                  color: Colors.indigo.shade100,
                                ),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const Text(
                                    "End Time",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    endTime == null
                                        ? "Not selected"
                                        : endTime!.format(context),
                                  ),

                                  const SizedBox(height: 14),

                                  OutlinedButton.icon(
                                    onPressed: pickEndTime,

                                    icon: const Icon(Icons.schedule_outlined),

                                    label: const Text("Select"),
                                  ),
                                ],
                              ),
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
                                onPressed: createEvent,

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

                                child: const Text("Create Event"),
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
