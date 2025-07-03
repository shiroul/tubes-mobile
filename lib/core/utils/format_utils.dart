/// Utility class for date and time formatting
class DateUtils {
  /// Convert DateTime to "time ago" format in Indonesian
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 30) return '${diff.inDays} hari lalu';
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months bulan lalu';
    }
    final years = (diff.inDays / 365).floor();
    return '$years tahun lalu';
  }

  /// Format DateTime to Indonesian date format (dd MMMM yyyy)
  static String formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format DateTime to Indonesian date and time format (dd MMMM yyyy, HH:mm)
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format time only (HH:mm)
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Utility class for string operations
class StringUtils {
  /// Generate initials from a full name
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length > 1 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }

  /// Capitalize first letter of each word
  static String toTitleCase(String text) {
    return text
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Check if string is null or empty
  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// Format location string from city and province
  static String formatLocation(String? city, String? province) {
    if (isNullOrEmpty(city) && isNullOrEmpty(province)) return 'Lokasi tidak diketahui';
    if (isNullOrEmpty(city)) return province ?? 'Lokasi tidak diketahui';
    if (isNullOrEmpty(province)) return city ?? 'Lokasi tidak diketahui';
    return '$city, $province';
  }
}

/// Utility class for validations
class ValidationUtils {
  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength (minimum 6 characters)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Validate phone number (Indonesian format)
  static bool isValidPhoneNumber(String phone) {
    // Remove all non-digits
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Indonesian phone number
    // Should start with 08 or +628 and have 10-13 total digits
    return RegExp(r'^(08|628)\d{8,11}$').hasMatch(digits);
  }

  /// Check if string contains only numbers
  static bool isNumeric(String str) {
    return RegExp(r'^\d+$').hasMatch(str);
  }
}
