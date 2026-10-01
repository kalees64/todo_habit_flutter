import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app/app.dart';
import 'core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications engine
  await NotificationService.instance.initialize();

  // Initialize Google Mobile Ads SDK
  try {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: [
          '99AC9A384103D35DB7A1A467FCA3A997', // Connected test device
        ],
      ),
    );
  } catch (e) {
    debugPrint('MobileAds initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: TaskFlowApp(),
    ),
  );
}
