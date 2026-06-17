import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';

/// Centralized form validation utilities for the app.
///
/// Provides reusable validators for common input types:
/// - Names, emails, phone numbers
/// - Passwords with strength checks
/// - Prices, seats, dates
/// - License plates
/// - Generic required/length/pattern validators
class FormValidators {
  FormValidators._();

  // ── Reactive Forms Bridge ───────────────────────────────────────

  /// Bridges a classic `String? Function(String?)` validator to a
  /// reactive_forms [Validator]. Returns `{errorKey: errorMessage}` on
  /// failure so [validationMessages] can extract the message with
  /// `(error) => error as String`.
  static Validator<dynamic> reactive(
    String? Function(String?) validator,
    String errorKey,
  ) {
    return Validators.delegate((control) {
      final error = validator(control.value as String?);
      return error != null ? {errorKey: error} : null;
    });
  }

  // ── Generic ─────────────────────────────────────────────────────────

  /// Validates that the value is not null or empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length.
  static String? Function(String?) minLength(int min, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.trim().length < min) {
        return '${fieldName ?? 'Value'} must be at least $min characters';
      }
      return null;
    };
  }

  /// Validates maximum length.
  static String? Function(String?) maxLength(int max, [String? fieldName]) {
    return (String? value) {
      if (value != null && value.trim().length > max) {
        return '${fieldName ?? 'Value'} must be at most $max characters';
      }
      return null;
    };
  }

  // ── Name ────────────────────────────────────────────────────────────

  /// Validates a person's full name.
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (trimmed.length > 60) {
      return 'Name is too long';
    }
    if (RegExp('[0-9]').hasMatch(trimmed)) {
      return 'Name cannot contain numbers';
    }
    if (!RegExp(r"^[\p{L}\s\-'.]+$", unicode: true).hasMatch(trimmed)) {
      return 'Name contains invalid characters';
    }
    return null;
  }

  // ── Email ───────────────────────────────────────────────────────────

  /// Validates an email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final trimmed = value.trim().toLowerCase();
    if (!RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$',
    ).hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // ── Phone ───────────────────────────────────────────────────────────

  /// Validates a phone number string (digits only).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional by default
    }
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 6) {
      return 'Phone number is too short';
    }
    if (digits.length > 15) {
      return 'Phone number is too long';
    }
    return null;
  }

  /// Validates an international phone number from IntlPhoneInput.
  static String? intlPhone(PhoneNumber? phoneNumber) {
    if (phoneNumber == null) return null;
    if (phoneNumber.number.isEmpty) return null; // Optional field
    final digits = phoneNumber.number.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 6) {
      return 'Phone number is too short';
    }
    if (digits.length > 15) {
      return 'Phone number is too long';
    }
    return null;
  }

  /// Validates a required international phone number.
  static String? intlPhoneRequired(PhoneNumber? phoneNumber) {
    if (phoneNumber == null || phoneNumber.number.isEmpty) {
      return 'Phone number is required';
    }
    return intlPhone(phoneNumber);
  }

  // ── Password ────────────────────────────────────────────────────────

  /// Validates password strength.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp('[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter';
    }
    if (!RegExp('[a-z]').hasMatch(value)) {
      return 'Include at least one lowercase letter';
    }
    if (!RegExp('[0-9]').hasMatch(value)) {
      return 'Include at least one number';
    }
    return null;
  }

  /// Returns a password confirmation validator.
  static String? Function(String?) confirmPassword(
    String Function() getPassword,
  ) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != getPassword()) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  /// Returns password strength score 0-4.
  static int passwordStrength(String password) {
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp('[A-Z]').hasMatch(password)) score++;
    if (RegExp('[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score;
  }

  // ── Price ───────────────────────────────────────────────────────────

  /// Validates a price value (must be positive).
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Please enter a valid price';
    }
    if (parsed <= 0) {
      return 'Price must be greater than 0';
    }
    if (parsed > 9999) {
      return 'Price seems too high';
    }
    return null;
  }

  // ── Seats ───────────────────────────────────────────────────────────

  /// Validates seat count.
  static String? seats(int? value, {int min = 1, int max = 8}) {
    if (value == null) return 'Please select number of seats';
    if (value < min) return 'Minimum $min seat${min > 1 ? 's' : ''}';
    if (value > max) return 'Maximum $max seats';
    return null;
  }

  // ── Date ────────────────────────────────────────────────────────────

  /// Validates that a date is in the future.
  static String? futureDate(DateTime? date) {
    if (date == null) return 'Date is required';
    if (date.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }
    return null;
  }

  /// Validates minimum age from date of birth.
  static String? minimumAge(DateTime? dob, {int minAge = 18}) {
    if (dob == null) return 'Date of birth is required';
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }
    return null;
  }

  // ── Vehicle ─────────────────────────────────────────────────────────

  /// Validates a license plate.
  static String? licensePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'License plate is required';
    }
    final trimmed = value.trim().toUpperCase();
    if (trimmed.length < 2) {
      return 'License plate is too short';
    }
    if (trimmed.length > 12) {
      return 'License plate is too long';
    }
    if (!RegExp(r'^[A-Z0-9\-\s]+$').hasMatch(trimmed)) {
      return 'Invalid license plate format';
    }
    return null;
  }

  /// Validates a vehicle year.
  static String? vehicleYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Year is required';
    }
    final year = int.tryParse(value.trim());
    if (year == null) return 'Please enter a valid year';
    if (year < 1980) return 'Vehicle is too old';
    if (year > DateTime.now().year) return 'Invalid year';
    return null;
  }

  // ── City ────────────────────────────────────────────────────────────

  /// Validates a city name.
  static String? city(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    if (value.trim().length < 2) {
      return 'City name is too short';
    }
    if (value.trim().length > 100) {
      return 'City name is too long';
    }
    if (RegExp('[0-9]').hasMatch(value)) {
      return 'City name cannot contain numbers';
    }
    return null;
  }

  // ── Compose ─────────────────────────────────────────────────────────

  /// Composes multiple validators into a single validator.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
