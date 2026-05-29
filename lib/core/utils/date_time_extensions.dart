extension DateTimeExt on DateTime {
  String toServerFormat() {
    return toUtc().toIso8601String();
  }
}
