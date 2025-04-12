class Constants {
  static const String defaultProfileImage =
      'assets/images/default_profile_photo.png';
  static const String defaultCoverPhoto =
      'assets/images/default_cover_photo.jpeg';
  static const String baseUrl = "http://10.0.2.2:3000";

  static const String loginEndpoint = '/user/login';
  static const String getUserDataEndpoint = "/user/me";
  static const String registerEndpoint = '/user/';
  static const String createUserProfileEndpoint = '/user/profile';
  static const String logoutEndpoint = '/user/logout';
  static const String feedEndpoint = '/posts';
  static const String savePostEndpoint = '/posts/%s/save'; // %s will be replaced with the postId
  static const String togglelikePostEndpoint = '/posts/%s/like'; // %s will be replaced with the postId
  //static const String unlikePostEndpoint = '/posts/%s/unlike'; // %s will be replaced with the postId
  static const String getNotificationsEndpoint = '/notifications';
  static const String markNotificationAsReadEndpoint = '/notifications/mark-read/%s'; // %s will be replaced with the notificationId
  static const String markNotificationAsUnreadEndpoint = '/notifications/mark-unread/%s'; // %s will be replaced with the notificationId
  static const String getNotificationsUnreadCountEndpoint = '/notifications/unread-count';
  static const String pauseNotificationsEndpoint = '/notifications/pause-notifications';
  static const String resumeNotificationsEndpoint = '/notifications/resume-notifications';
  static const String restoreNotificationsEndpoint = '/notifications/restore-notification/%s'; // %s will be replaced with the notificationId
  static const String deleteNotificationEndpoint = '/notifications/%s'; // %s will be replaced with the notificationId
}
