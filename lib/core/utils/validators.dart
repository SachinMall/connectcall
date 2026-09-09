class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[\w\.\-+]+@[\w\-]+\.[\w\-\.]+$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name.';
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email is required.';
    if (!_emailPattern.hasMatch(trimmed)) return 'Enter a valid email address.';
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    return null;
  }

  static String? registerPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() password) {
    return (value) {
      if (value == null || value.isEmpty) return 'Please confirm your password.';
      if (value != password()) return 'Passwords do not match.';
      return null;
    };
  }
}
