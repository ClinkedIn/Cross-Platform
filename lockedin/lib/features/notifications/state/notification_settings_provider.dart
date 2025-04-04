import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettings {
  final bool allowUserNotifications;
  final bool allowNetworkUpdates;

  NotificationSettings({
    required this.allowUserNotifications,
    required this.allowNetworkUpdates,
  });

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

class NotificationSettingsNotifier extends StateNotifier<Map<String, NotificationSettings>> {
  NotificationSettingsNotifier() : super({});

  NotificationSettings getSettingsForUser(String username) {
    return state[username] ?? NotificationSettings(allowUserNotifications: true, allowNetworkUpdates: true);
  }

  void toggleUserNotifications(String username, bool value) {
    state = {
      ...state,
      username: getSettingsForUser(username).copyWith(allowUserNotifications: value),
    };
  }

  void toggleNetworkUpdates(String username, bool value) {
    state = {
      ...state,
      username: getSettingsForUser(username).copyWith(allowNetworkUpdates: value),
    };
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, Map<String, NotificationSettings>>(
  (ref) => NotificationSettingsNotifier(),
);
