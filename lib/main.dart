import 'package:expense_app/features/notifications/presentation/providers/notification_provider.dart';
import 'package:expense_app/core/providers/theme_provider.dart';
import 'package:expense_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:expense_app/core/theme/app_themes.dart';
import 'package:expense_app/app_router.dart';
import 'package:expense_app/firebase_options.dart';
import 'package:expense_app/features/notifications/data/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.init();
  debugPrint("Firebase initialized successfully");
  debugPrint("Project ID: ${Firebase.app().options.projectId}");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Expense Tracker',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
