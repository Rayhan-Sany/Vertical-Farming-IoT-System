import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../modules/dashboard/controllers/dashboard_controller.dart';

class ControlController extends GetxController {
  // Device control states
  var pumpStatus = false.obs;
  var lightStatus = false.obs;
  var fanStatus = false.obs;
  var autoMode = true.obs;

  // Pump control
  var flowRate = 60.0.obs; // 0-100%
  var pumpMode = 'Auto'.obs; // Auto, Manual
  var isManualWatering = false.obs;
  var manualWateringTime = 30.obs; // seconds

  // Light control
  var lightMode = 'Auto'.obs; // Auto, Manual
  var lightDuration = 12.obs; // hours per day
  var lightSchedule = {'start': '06:00', 'end': '18:00'}.obs;

  // Fan control
  var fanMode = 'Auto'.obs; // Auto, Manual
  var fanSpeed = 'Medium'.obs; // Low, Medium, High

  // Auto mode configuration
  var autoWatering = true.obs;
  var autoLighting = true.obs;
  var smartMode = false.obs;

  // Schedule settings
  var scheduleEnabled = false.obs;
  var wateringSchedule = ['09:00', '16:00'].obs;

  // Live status indicators - will get real data from dashboard controller
  var temperature = 0.0.obs;
  var moisture = 'Low'.obs;
  var diseaseStatus = 'None'.obs;

  // Device status indicators
  var pumpIcon = '💧'.obs;
  var lightIcon = '💡'.obs;
  var fanIcon = '🌪️'.obs;
  var autoIcon = '🤖'.obs;

  @override
  void onInit() {
    super.onInit();
    updateIcons();
    startStatusUpdates();
    _syncWithDashboardData();
  }

  void _syncWithDashboardData() {
    // Get dashboard controller instance
    try {
      final dashboardController = Get.find<DashboardController>();

      // Sync real data from dashboard
      ever(dashboardController.temperature, (value) {
        temperature.value = value;
      });

      ever(dashboardController.waterLevel, (value) {
        if (value < 30) {
          moisture.value = 'Low';
        } else if (value < 70) {
          moisture.value = 'Medium';
        } else {
          moisture.value = 'High';
        }
      });

      ever(dashboardController.diseaseDetected, (value) {
        diseaseStatus.value = value ? 'Detected' : 'None';
      });

      ever(dashboardController.pumpStatus, (value) {
        pumpStatus.value = value;
      });

      ever(dashboardController.growLightStatus, (value) {
        lightStatus.value = value;
      });

      // Initialize with current values
      temperature.value = dashboardController.temperature.value;
      final waterLevel = dashboardController.waterLevel.value;
      if (waterLevel < 30) {
        moisture.value = 'Low';
      } else if (waterLevel < 70) {
        moisture.value = 'Medium';
      } else {
        moisture.value = 'High';
      }
      diseaseStatus.value = dashboardController.diseaseDetected.value
          ? 'Detected'
          : 'None';
      pumpStatus.value = dashboardController.pumpStatus.value;
      lightStatus.value = dashboardController.growLightStatus.value;
    } catch (e) {
      print('Dashboard controller not found, using default values: $e');
    }
  }

  void startStatusUpdates() {
    // Real data is now synced from dashboard controller
    // No need for simulated updates
  }

  // Pump Control Methods
  void togglePump() {
    try {
      final dashboardController = Get.find<DashboardController>();
      dashboardController.togglePump();
      updateIcons();
    } catch (e) {
      print('Dashboard controller not found: $e');
      pumpStatus.value = !pumpStatus.value;
      updateIcons();
    }
  }

  void setFlowRate(double value) {
    flowRate.value = value;
    if (pumpStatus.value && value == 0) {
      Fluttertoast.showToast(
        msg: 'Warning: Flow rate is 0% but pump is ON',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }

  void setPumpMode(String mode) {
    pumpMode.value = mode;
  }

  void startManualWatering() {
    if (isManualWatering.value) return;

    isManualWatering.value = true;
    pumpStatus.value = true;

    // toast removed

    Future.delayed(Duration(seconds: manualWateringTime.value), () {
      isManualWatering.value = false;
      if (pumpMode.value == 'Manual') {
        pumpStatus.value = false;
      }
      // toast removed
    });
  }

  void setManualWateringTime(int seconds) {
    manualWateringTime.value = seconds;
  }

  // Light Control Methods
  void toggleLight() {
    try {
      final dashboardController = Get.find<DashboardController>();
      dashboardController.toggleGrowLight();
      updateIcons();
    } catch (e) {
      print('Dashboard controller not found: $e');
      lightStatus.value = !lightStatus.value;
      updateIcons();
    }
  }

  void setLightMode(String mode) {
    lightMode.value = mode;
  }

  void setLightDuration(int hours) {
    lightDuration.value = hours;
  }

  void setLightSchedule(String start, String end) {
    lightSchedule.value = {'start': start, 'end': end};
  }

  // Fan Control Methods
  void toggleFan() {
    fanStatus.value = !fanStatus.value;
    updateIcons();
  }

  void setFanMode(String mode) {
    fanMode.value = mode;
  }

  void setFanSpeed(String speed) {
    fanSpeed.value = speed;
  }

  // Auto Mode Configuration
  void toggleAutoMode() {
    autoMode.value = !autoMode.value;
    updateIcons();
  }

  void toggleAutoWatering() {
    autoWatering.value = !autoWatering.value;
  }

  void toggleAutoLighting() {
    autoLighting.value = !autoLighting.value;
  }

  void toggleSmartMode() {
    smartMode.value = !smartMode.value;
  }

  // Schedule Settings
  void toggleSchedule() {
    scheduleEnabled.value = !scheduleEnabled.value;
  }

  void addWateringTime(String time) {
    if (!wateringSchedule.contains(time)) {
      wateringSchedule.add(time);
      wateringSchedule.sort();
    }
  }

  void removeWateringTime(String time) {
    wateringSchedule.remove(time);
  }

  void updateIcons() {
    pumpIcon.value = pumpStatus.value ? '💧' : '💧';
    lightIcon.value = lightStatus.value ? '💡' : '💡';
    fanIcon.value = fanStatus.value ? '🌪️' : '🌪️';
    autoIcon.value = autoMode.value ? '🤖' : '👤';
  }
}
