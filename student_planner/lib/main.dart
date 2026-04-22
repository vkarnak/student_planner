import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🔐 Providers
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/suggestion_provider.dart'; // ✅ ДОБАВИЛИ

// 🔔 Services
import 'services/notification_service.dart';

// 📱 Screens
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/edit_event_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/suggestion_screen.dart'; // ✅ ДОБАВИЛИ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SuggestionProvider()),
      ],

      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Student Planner',

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),

            // 🔥 лучше так (чтобы не было мигания)
            home: auth.token == null ? LoginScreen() : HomeScreen(),

            routes: {
              "/home": (_) => HomeScreen(),
              "/register": (_) => RegisterScreen(),
              "/add": (_) => AddTaskScreen(),
              "/add_event": (_) => AddEventScreen(),
              "/edit_event": (_) => EditEventScreen(),
              "/calendar": (_) => CalendarScreen(),
              "/profile": (_) => ProfileScreen(),
              "/suggestions": (_) => SuggestionScreen(),
            },
          );
        },
      ),
    );
  }
}
