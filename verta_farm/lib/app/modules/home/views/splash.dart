import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/thresholds_service.dart';
import '../../../services/websocket_service.dart';
import '../../../services/control_service.dart';
import '../../../controllers/main_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../routes/app_pages.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late ThresholdsService _thresholdsService;
  late WebSocketService _webSocketService;
  late ControlService _controlService;
  late DashboardController _dashboardController;

  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // Ensure main controllers are available
      Get.put(MainController(), permanent: true);
      Get.put(DashboardController(), permanent: true);

      _dashboardController = Get.find<DashboardController>();
      _thresholdsService = Get.put(ThresholdsService(), permanent: true);
      _webSocketService = Get.put(WebSocketService(), permanent: true);
      _controlService = Get.put(ControlService(), permanent: true);

      setState(() => _status = 'Connecting realtime...');
      // Connect WebSocket (id fixed in service url)
      _webSocketService.connect();

      setState(() => _status = 'Loading thresholds...');
      await _thresholdsService.refreshThresholds('esp32-001');

      setState(() => _status = 'Requesting device status...');
      await _controlService.requestStatus('esp32-001');

      // Give a short window to receive realtime updates
      await Future.delayed(const Duration(seconds: 2));

      final bool online = _dashboardController.isWebSocketConnected;
      setState(() => _status = online ? 'Device Online' : 'Device Offline');

      // Navigate based on device status
      Future.delayed(const Duration(milliseconds: 800), () {
        Get.offAllNamed(Routes.MAIN);
      });
    } catch (e) {
      setState(() => _status = 'Startup failed: $e');
      // Navigate anyway after brief delay
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed(Routes.MAIN);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/vertaFram.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Verta Farm',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _status,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
