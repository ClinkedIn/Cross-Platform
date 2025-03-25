class ForgotPasswordResponse {
  final bool success;
  final String message;

  ForgotPasswordResponse({required this.success, required this.message});

  // Factory constructor to convert JSON to a ForgotPasswordResponse object
  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {  // factory constructor is a special type of constructor that does not always create a new instance of a class.
    return ForgotPasswordResponse(
      success: json['success'],
      message: json['message'],
    );
  }
}
