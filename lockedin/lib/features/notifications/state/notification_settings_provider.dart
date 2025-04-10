import 'package:flutter_riverpod/flutter_riverpod.dart';
/// Model class to store notification settings for a specific user.
class NotificationSettings {
  final bool allowUserNotifications;
  final bool allowNetworkUpdates;

  NotificationSettings({
    required this.allowUserNotifications,
    required this.allowNetworkUpdates,
  });

  /// Returns a new [NotificationSettings] instance with updated values.
  /// Keeps existing values if not explicitly overridden.
  NotificationSettings copyWith({
    bool? allowUserNotifications,
    bool? allowNetworkUpdates,
  }) {
    return NotificationSettings(
      allowUserNotifications: allowUserNotifications ?? this.allowUserNotifications,
      allowNetworkUpdates: allowNetworkUpdates ?? this.allowNetworkUpdates,
    );
  }
}
/// A [StateNotifier] that manages notification settings for multiple users.
/// Uses a Map&lt;String, NotificationSettings&gt; where the key is the username.
class NotificationSettingsNotifier extends StateNotifier<Map<String, NotificationSettings>> {
  NotificationSettingsNotifier() : super({});

  /// Retrieves the current settings for a specific user.
  /// Returns default settings if user is not in the map.
  NotificationSettings getSettingsForUser(String username) {
    return state[username] ?? NotificationSettings(allowUserNotifications: true, allowNetworkUpdates: true);
  }

  /// Updates the user's setting for allowing notifications from other users.
  void toggleUserNotifications(String username, bool value) {
    state = {
      ...state,
      username: getSettingsForUser(username).copyWith(allowUserNotifications: value),
    };
  }

  /// Updates the user's setting for allowing network update notifications.
  void toggleNetworkUpdates(String username, bool value) {
    state = {
      ...state,
      username: getSettingsForUser(username).copyWith(allowNetworkUpdates: value),
    };
  }
}
/// Riverpod provider that exposes the [NotificationSettingsNotifier] to the app.
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, Map<String, NotificationSettings>>(
  (ref) => NotificationSettingsNotifier(),
);
