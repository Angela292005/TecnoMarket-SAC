class AppDateUtils {
  /// Convierte un objeto DateTime a formato dd/MM/yyyy
  static String format(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  /// Convierte una cadena dd/MM/yyyy a DateTime
  static DateTime? parse(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      final parts = dateStr.trim().split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  /// Retorna la fecha de hoy formateada como dd/MM/yyyy
  static String today() {
    return format(DateTime.now());
  }
}
