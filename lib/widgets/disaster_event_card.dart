import 'package:flutter/material.dart';
import '../models/disaster_event.dart';

class DisasterEventCard extends StatelessWidget {
  final DisasterEvent event;
  final String eventId;
  final VoidCallback? onTap;
  final bool showDetailButton;
  final bool isCompact;

  const DisasterEventCard({
    super.key,
    required this.event,
    required this.eventId,
    this.onTap,
    this.showDetailButton = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconForDisasterType(event.type);
    final iconColor = _getColorForSeverity(event.severityLevel);
    final severityColor = _getColorForSeverity(event.severityLevel);
    final timeAgo = _getTimeAgo(event.timestamp.toDate());

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: isCompact ? 4 : 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              severityColor.withOpacity(0.05),
            ],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon, title, and severity badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disaster icon with circular background
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: iconColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        iconData,
                        color: iconColor,
                        size: isCompact ? 20 : 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Title and location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.type,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isCompact ? 16 : 18,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              // Severity badge
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: severityColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: severityColor.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _getSeverityText(event.severityLevel),
                                  style: TextStyle(
                                    color: severityColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.city,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (!isCompact) ...[
                  SizedBox(height: 12),
                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.grey[300]!,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  // Info rows
                  _buildInfoRow(
                    Icons.schedule,
                    'Waktu',
                    timeAgo,
                    Colors.blue[600]!,
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.people_alt,
                    'Keahlian dibutuhkan',
                    event.requiredVolunteers.keys.isNotEmpty 
                        ? event.requiredVolunteers.keys.join(", ")
                        : 'Belum ditentukan',
                    Colors.green[600]!,
                  ),
                ],
                
                if (showDetailButton && !isCompact) ...[
                  SizedBox(height: 16),
                  // Detail button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: iconColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: onTap,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Lihat Detail',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForDisasterType(String type) {
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

  Color _getColorForSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'berat':
        return Colors.red[600]!;
      case 'sedang':
        return Colors.orange[600]!;
      case 'ringan':
        return Colors.blue[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getSeverityText(String severity) {
    switch (severity.toLowerCase()) {
      case 'berat':
        return 'PARAH';
      case 'sedang':
        return 'SEDANG';
      case 'ringan':
        return 'RINGAN';
      default:
        return 'UNKNOWN';
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
