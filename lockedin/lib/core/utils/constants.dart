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
  static const String createPostEndpoint = '/posts';
  //static const String unlikePostEndpoint = '/posts/%s/unlike'; // %s will be replaced with the postId
  
}
