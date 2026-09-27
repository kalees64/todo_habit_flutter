import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications engine
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: TaskFlowApp(),
    ),
  );
}
