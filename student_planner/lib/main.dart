import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/event_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/settings_provider.dart';

import 'services/notification_service.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/edit_task_screen.dart';
import 'screens/edit_event_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await NotificationService.requestPermission();

  runApp(const MyApp());
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
        ChangeNotifierProvider(create: (_) => ProfileProvider()),

        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),

        ChangeNotifierProvider(create: (_) => AiProvider()),
      ],

      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Student Planner',

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
              fontFamily: 'Segoe UI',
            ),

            home: auth.token == null ? const LoginScreen() : const HomeScreen(),

            routes: {
              "/login": (_) => const LoginScreen(),
              "/forgot-password": (_) => const ForgotPasswordScreen(),
              "/home": (_) => const HomeScreen(),
              "/register": (_) => const RegisterScreen(),
              "/add": (_) => const AddTaskScreen(),
              "/edit": (_) => const EditTaskScreen(),
              "/add_event": (_) => const AddEventScreen(),
              "/edit_event": (_) => const EditEventScreen(),
              "/profile": (_) => ProfileScreen(),
            },

            supportedLocales: const [Locale('en', 'GB')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          );
        },
      ),
    );
  }
}
