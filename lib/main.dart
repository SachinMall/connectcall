import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.initialize();
  } catch (_) {}

  final isDarkMode = GetStorage().read('isDarkMode') ?? false;

  runApp(
    ConnectCallApp(
      initialThemeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    ),
  );
}

class ConnectCallApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const ConnectCallApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ConnectCall',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: initialThemeMode,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
