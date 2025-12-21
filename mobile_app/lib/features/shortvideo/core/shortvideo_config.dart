/// Configuration for ShortVideo module
class ShortVideoConfig {
  /// Force mock mode (bypass remote API)
  static const bool forceMock = bool.fromEnvironment(
    'FORCE_SHORTS_MOCK',
    defaultValue: false,
  );

  /// Remote API timeout in milliseconds
  static const int remoteTimeoutMs = 1200;

  /// Screenshot mode (disable autoplay, show full UI)
  static const bool screenshotMode = bool.fromEnvironment(
    'SCREENSHOT_MODE',
    defaultValue: false,
  );
}

