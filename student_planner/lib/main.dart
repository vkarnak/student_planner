import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_planner/providers/ai_provider.dart';
import 'package:student_planner/providers/event_provider.dart';
import 'package:student_planner/screens/edit_task_screen.dart';
import 'package:student_planner/screens/forgot_password_screen.dart';
import 'package:student_planner/screens/schedule_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 🔐 Providers
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/profile_provider.dart';

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
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
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

            home: auth.token == null ? LoginScreen() : HomeScreen(),

            routes: {
              "/login": (_) => LoginScreen(),
              "/forgot-password": (_) => ForgotPasswordScreen(),
              "/home": (_) => HomeScreen(),
              "/register": (_) => RegisterScreen(),
              "/add": (_) => AddTaskScreen(),
              "/edit": (_) => EditTaskScreen(),
              "/add_event": (_) => AddEventScreen(),
              "/edit_event": (_) => EditEventScreen(),
              "/schedule": (_) => ScheduleScreen(),
              "/calendar": (_) => CalendarScreen(),
              "/profile": (_) => ProfileScreen(),
            },

            supportedLocales: [Locale('ru', 'RU')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          );
        },
      ),
    );
  }
}
