/// Collects validation errors and provides utilities for checking validity.
///
/// Used throughout the DCQL library to validate query parameters, credentials,
/// and other objects according to the DCQL specification.
class ValidationResult {
  /// List of validation error messages.
  final List<String> errors = [];

  /// Returns true if there are no validation errors.
  bool get isValid => errors.isEmpty;

  /// Adds a validation error message.
  void addError(String error) {
    errors.add(error);
  }

  /// Combines errors from another [ValidationResult] into this one.
  ///
  /// If [other] is null, no changes are made.
  void combine(ValidationResult? other) {
    if (other == null) return;
    errors.addAll(other.errors);
  }
}
