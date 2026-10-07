/// Form validation utilities for Trend Curve.
class AppValidators {
  AppValidators._();

  static String? requiredField(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? number(String? value, [String message = 'Please enter a valid number']) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', ''));
    if (parsed == null) {
      return message;
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    final numError = number(value);
    if (numError != null) return numError;
    final parsed = double.parse(value!.trim().replaceAll(',', ''));
    if (parsed <= 0) {
      return 'Value must be greater than zero';
    }
    return null;
  }
}
