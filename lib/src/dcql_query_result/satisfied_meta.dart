import '../dcql_meta/dcql_meta.dart';

/// Records the actual values that satisfied a meta constraint in a query.
class SatisfiedMeta {
  /// The meta constraint from the query that was satisfied.
  final DcqlMeta expected;

  /// The actual values from the credential that satisfied the constraint.
  final List<String> actual;

  /// Creates a new [SatisfiedMeta] instance.
  SatisfiedMeta({required this.expected, required this.actual});
}
