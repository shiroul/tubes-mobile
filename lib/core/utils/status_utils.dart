import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Utility class for status-related functionality
class StatusUtils {
  /// Get color for report status
  static Color getReportStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'ditolak':
      case 'rejected':
        return AppColors.error;
      case 'diterima':
      case 'approved':
      case 'accepted':
        return AppColors.success;
      case 'active':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get display text for report status
  static String getReportStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'MENUNGGU';
      case 'ditolak':
      case 'rejected':
        return 'DITOLAK';
      case 'diterima':
      case 'approved':
      case 'accepted':
        return 'DITERIMA';
      case 'active':
        return 'AKTIF';
      default:
        return status.toUpperCase();
    }
  }

  /// Get color for volunteer availability status
  static Color getAvailabilityColor(dynamic availability) {
    if (availability is bool) {
      return availability ? AppColors.availableGreen : AppColors.unavailableRed;
    } else if (availability is String) {
      switch (availability.toLowerCase()) {
        case 'active duty':
          return AppColors.activeDutyOrange;
        case 'available':
          return AppColors.availableGreen;
        default:
          return AppColors.unavailableRed;
      }
    }
    return AppColors.unavailableRed;
  }

  /// Get background color for volunteer availability status
  static Color getAvailabilityBackgroundColor(dynamic availability) {
    if (availability is bool) {
      return availability ? AppColors.successLight : AppColors.errorLight;
    } else if (availability is String) {
      switch (availability.toLowerCase()) {
        case 'active duty':
          return AppColors.warningLight;
        case 'available':
          return AppColors.successLight;
        default:
          return AppColors.errorLight;
      }
    }
    return AppColors.errorLight;
  }

  /// Get border color for volunteer availability status
  static Color getAvailabilityBorderColor(dynamic availability) {
    final mainColor = getAvailabilityColor(availability);
    return mainColor.withValues(alpha: 0.3);
  }

  /// Get display text for volunteer availability
  static String getAvailabilityDisplayText(dynamic availability) {
    if (availability is bool) {
      return availability ? 'TERSEDIA' : 'TIDAK TERSEDIA';
    } else if (availability is String) {
      switch (availability.toLowerCase()) {
        case 'active duty':
          return 'TUGAS AKTIF';
        case 'available':
          return 'TERSEDIA';
        default:
          return 'TIDAK TERSEDIA';
      }
    }
    return 'TIDAK TERSEDIA';
  }

  /// Get color for user role
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.adminRole;
      case 'relawan':
        return AppColors.volunteerRole;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get display name for user role
  static String getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'relawan':
        return 'Relawan';
      default:
        return role;
    }
  }
}
