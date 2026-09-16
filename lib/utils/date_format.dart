/// Formats [date] as `YYYY-MM-DD`.
///
/// Deliberately dependency-free (no `intl`) so it needs no package and is easy
/// to unit test.
String formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
