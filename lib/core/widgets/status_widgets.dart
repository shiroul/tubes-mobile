import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/status_utils.dart';

/// Common status badge widget
class StatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = StatusUtils.getReportStatusColor(status);
    final displayText = StatusUtils.getReportStatusDisplayText(status);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Availability status badge for volunteers
class AvailabilityBadge extends StatelessWidget {
  final dynamic availability;
  final bool isSmall;

  const AvailabilityBadge({
    super.key,
    required this.availability,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = StatusUtils.getAvailabilityColor(availability);
    final backgroundColor = StatusUtils.getAvailabilityBackgroundColor(availability);
    final borderColor = StatusUtils.getAvailabilityBorderColor(availability);
    final displayText = StatusUtils.getAvailabilityDisplayText(availability);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            availability == true || (availability is String && availability.toLowerCase() != 'not available') 
                ? Icons.check_circle 
                : Icons.cancel,
            size: isSmall ? 10 : 12,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              fontSize: isSmall ? 9 : 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Role badge for users
class RoleBadge extends StatelessWidget {
  final String role;
  final bool isSmall;

  const RoleBadge({
    super.key,
    required this.role,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = StatusUtils.getRoleColor(role);
    final displayName = StatusUtils.getRoleDisplayName(role);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        displayName,
        style: TextStyle(
          fontSize: isSmall ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Generic chip widget for displaying tags
class AppChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isSmall;

  const AppChip({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.info;
    final chipBackgroundColor = backgroundColor ?? 
        (isSelected ? chipColor.withValues(alpha: 0.2) : Colors.grey[100]);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8 : 12,
          vertical: isSmall ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: chipBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: isSmall ? 14 : 16,
                color: isSelected ? chipColor : AppColors.textSecondary,
              ),
              SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: isSmall ? 11 : 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? chipColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
