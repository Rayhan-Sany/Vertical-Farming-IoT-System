class AppConfig {
  // Base HTTP API URL (without trailing slash)
  static const String baseUrl = 'http://98.70.30.33:8000/api/v1';

  // Helper to build WebSocket URL for a given device
  static String websocketUrl(String deviceId) {
    final httpBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final wsBase = httpBase.replaceFirst('http', 'ws');
    return '$wsBase/realtime/$deviceId';
  }
}
