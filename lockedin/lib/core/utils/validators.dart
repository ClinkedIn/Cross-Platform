class Validators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email) ? null : 'Invalid email format';
  }

  static String? validatePassword(String? password) {
    if (password == null || password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
