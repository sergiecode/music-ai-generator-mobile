/// Configuration for the Music AI Generator Mobile App
/// Created by Sergie Code
class AppConfig {
  // Backend API Configuration
  // Update these URLs based on your setup:
  
  // For Android emulator (default)
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:8000';
  
  // For iOS simulator
  static const String iosSimulatorBaseUrl = 'http://127.0.0.1:8000';
  
  // For physical device (replace with your computer's IP)
  static const String physicalDeviceBaseUrl = 'http://192.168.1.100:8000';
  
  // Production URL (when deploying to production)
  static const String productionBaseUrl = 'https://your-production-domain.com';
  
  // Current environment
  static const bool isProduction = false;
  
  // Request timeouts
  static const Duration healthCheckTimeout = Duration(seconds: 10);
  static const Duration generationTimeout = Duration(seconds: 30);
  static const Duration statusCheckTimeout = Duration(seconds: 10);
  
  // Polling configuration
  static const Duration pollInterval = Duration(seconds: 2);
  
  // UI Configuration
  static const double minDuration = 5;
  static const double maxDuration = 300;
  static const double defaultDuration = 30;
  
  // Get the appropriate base URL based on current platform and environment
  static String getBaseUrl() {
    if (isProduction) {
      return productionBaseUrl;
    }
    
    // For development, return Android emulator URL by default
    // Users can modify music_service.dart to use different URLs
    return androidEmulatorBaseUrl;
  }
}
