class AppValidators {
  // Regex patterns
  static final _mobileRegex = RegExp(r'^[0-9]{10}$');
  static final _emailRegex =
  RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

  /// Validate if field is not empty
  static String? validateEmpty(
      String? value, {
        String fieldName = "Field",
        String? customMessage,
      }) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) {
      return customMessage ?? "$fieldName is required";
    }
    return null;
  }

  /// Validate mobile number (default 10 digits)
  static String? validateMobile(
      String? value, {
        int length = 10,
        String? customMessage,
      }) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) {
      return "Mobile number is required";
    }
    final pattern = RegExp(r'^[0-9]{' + length.toString() + r'}$');
    if (!pattern.hasMatch(trimmed)) {
      return customMessage ?? "Enter a valid $length-digit mobile number";
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(
      String? value, {
        String? customMessage,
      }) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) {
      return "Email is required";
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return customMessage ?? "Enter a valid email address";
    }
    return null;
  }

  /// Validate vehicle registration number (e.g., DL 01 AB 2345)
  static String? validateVehicleNumber(String? value) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) {
      return "Vehicle Number is required";
    }
    final compact = trimmed.replaceAll(RegExp(r'[\s-]'), '');
    if (compact.length < 6 || compact.length > 13) {
      return "Vehicle Number must be 6 to 13 characters";
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z0-9]+$').hasMatch(compact)) {
      return "Enter a valid vehicle number (e.g. DL 01 AB 2345)";
    }
    return null;
  }

  /// Validate 4-digit vehicle model year
  static String? validateModelYear(String? value) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) {
      return "Model Year is required";
    }
    if (!RegExp(r'^\d{4}$').hasMatch(trimmed)) {
      return "Model Year must be a 4-digit year";
    }
    final year = int.tryParse(trimmed);
    final maxYear = DateTime.now().year + 1;
    if (year == null || year < 1980 || year > maxYear) {
      return "Enter a valid year between 1980 and $maxYear";
    }
    return null;
  }

  /// Validate alphanumeric certificate / document / device ID number
  static String? validateDocumentNumber(
    String? value, {
    required String fieldName,
    bool isRequired = true,
    int minLength = 5,
    int maxLength = 25,
  }) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty) {
      return isRequired ? "$fieldName is required" : null;
    }
    if (trimmed.length < minLength || trimmed.length > maxLength) {
      return "$fieldName must be $minLength to $maxLength characters";
    }
    if (!RegExp(r'^(?=.*[A-Za-z0-9])[A-Za-z0-9\-_/]+$').hasMatch(trimmed)) {
      return "Enter a valid $fieldName (letters, numbers, -, /)";
    }
    return null;
  }
}
