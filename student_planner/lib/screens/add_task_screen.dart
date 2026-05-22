import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final title = TextEditingController();
  final description = TextEditingController();

  DateTime? selectedDeadline;
  Duration selectedDuration = Duration(hours: 1);

  int priority = 3;
  int difficulty = 2;

  String? error;
  bool isLoading = false;

  String formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}."
        "${d.month.toString().padLeft(2, '0')}."
        "${d.year}";
  }

  Future<void> pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDeadline = picked);
    }
  }

  Future<void> pickDuration() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: selectedDuration.inHours,
        minute: selectedDuration.inMinutes % 60,
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDuration = Duration(hours: picked.hour, minutes: picked.minute);
      });
    }
  }

  Color getPriorityColor() {
    switch (priority) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void createTask() async {
    if (title.text.isEmpty || selectedDeadline == null) {
      setState(() => error = "Fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final provider = Provider.of<TaskProvider>(context, listen: false);

    final task = Task(
      title: title.text,
      description: description.text,
      deadline: selectedDeadline!.toIso8601String(),
      duration: selectedDuration.inMinutes,
      priority: priority,
      difficulty: difficulty,
      status: "pending",
    );

    await provider.addTask(task);

    setState(() => isLoading = false);

    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 500;

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
                        "New Task",
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
                          hint: "Task title",
                          icon: Icons.title,
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
                                    "Deadline",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    selectedDeadline == null
                                        ? "Not selected"
                                        : formatDate(selectedDeadline!),

                                    style: TextStyle(
                                      color: selectedDeadline == null
                                          ? Colors.grey
                                          : Colors.black87,
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  OutlinedButton.icon(
                                    onPressed: pickDeadline,

                                    icon: const Icon(
                                      Icons.calendar_today_outlined,
                                    ),

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
                                    "Duration",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    "${selectedDuration.inHours}h "
                                    "${selectedDuration.inMinutes % 60}m",
                                  ),

                                  const SizedBox(height: 14),

                                  OutlinedButton.icon(
                                    onPressed: pickDuration,

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

                      DropdownButtonFormField<int>(
                        initialValue: priority,

                        decoration: fieldDecoration(
                          hint: "Priority",
                          icon: Icons.flag_outlined,
                        ),

                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              "Low",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),

                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              "Medium",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),

                          DropdownMenuItem(
                            value: 3,
                            child: Text(
                              "High",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),

                          DropdownMenuItem(
                            value: 4,
                            child: Text(
                              "Urgent",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],

                        onChanged: (v) {
                          setState(() {
                            priority = v!;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      DropdownButtonFormField<int>(
                        initialValue: difficulty,

                        decoration: fieldDecoration(
                          hint: "Difficulty",
                          icon: Icons.psychology_outlined,
                        ),

                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Easy")),

                          DropdownMenuItem(value: 2, child: Text("Medium")),

                          DropdownMenuItem(value: 3, child: Text("Hard")),

                          DropdownMenuItem(value: 4, child: Text("Very Hard")),
                        ],

                        onChanged: (v) {
                          setState(() {
                            difficulty = v!;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

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
                                onPressed: createTask,

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

                                child: const Text("Create Task"),
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
