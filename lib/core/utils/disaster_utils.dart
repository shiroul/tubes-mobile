import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Utility class for disaster-related functionality
class DisasterUtils {
  /// Get icon for disaster type
  static IconData getDisasterIcon(String type) {
    switch (type.toLowerCase()) {
      case 'banjir':
        return Icons.waves;
      case 'gempa bumi':
        return Icons.terrain;
      case 'kebakaran':
        return Icons.local_fire_department;
      case 'tanah longsor':
        return Icons.landscape;
      case 'angin puting beliung':
        return Icons.tornado;
      case 'tsunami':
        return Icons.water;
      case 'gunung berapi':
        return Icons.volcano;
      default:
        return Icons.warning;
    }
  }

  /// Get color for disaster type
  static Color getDisasterTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'banjir':
        return Colors.blue[600]!;
      case 'gempa bumi':
        return Colors.brown[600]!;
      case 'kebakaran':
        return AppColors.error;
      case 'tanah longsor':
        return AppColors.warning;
      case 'angin puting beliung':
        return Colors.grey[600]!;
      case 'tsunami':
        return Colors.blue[800]!;
      case 'gunung berapi':
        return Colors.red[800]!;
      default:
        return Colors.grey[600]!;
    }
  }

  /// Get color for severity level
  static Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'parah':
        return AppColors.severityHigh;
      case 'sedang':
        return AppColors.severityMedium;
      case 'ringan':
        return AppColors.severityLow;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get display text for severity level
  static String getSeverityDisplayText(String severity) {
    switch (severity.toLowerCase()) {
      case 'parah':
        return 'PARAH';
      case 'sedang':
        return 'SEDANG';
      case 'ringan':
        return 'RINGAN';
      default:
        return severity.toUpperCase();
    }
  }

  /// Get severity level priority for sorting (lower number = higher priority)
  static int getSeverityPriority(String severity) {
    switch (severity.toLowerCase()) {
      case 'parah':
        return 0;
      case 'sedang':
        return 1;
      case 'ringan':
        return 2;
      default:
        return 3;
    }
  }
}
