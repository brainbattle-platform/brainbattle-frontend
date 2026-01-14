/// Safe JSON numeric parsing utilities
/// 
/// Backend may return JSON numbers as int or double (e.g., accuracy: 1 vs 1.0).
/// These helpers safely convert any numeric type to the desired type.
class JsonNum {
  /// Convert dynamic value to double, handling both int and double from JSON
  /// Returns null if value is not a number
  static double? asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return null;
  }

  /// Convert dynamic value to int, handling both int and double from JSON
  /// Returns null if value is not a number
  static int? asInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return null;
  }

  /// Convert dynamic value to double with fallback
  /// Returns fallback if value is null or not a number
  static double asDoubleOr(dynamic v, double fallback) {
    return asDouble(v) ?? fallback;
  }

  /// Convert dynamic value to int with fallback
  /// Returns fallback if value is null or not a number
  static int asIntOr(dynamic v, int fallback) {
    return asInt(v) ?? fallback;
  }
}

