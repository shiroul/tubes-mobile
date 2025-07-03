import 'package:flutter/material.dart';
import '../../../repositories/participation_repository.dart';

/// A section displaying the current user's participation information
class UserParticipationSection extends StatelessWidget {
  final String userId;
  
  const UserParticipationSection({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final partRepo = ParticipationRepository();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.volunteer_activism, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Partisipasi Saya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        
        // Participation Stream
        StreamBuilder<ParticipationData?>(
          stream: partRepo.getCurrentUserParticipation(userId),
          builder: (context, partSnapshot) {
            if (partSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard();
            }
            
            if (!partSnapshot.hasData || partSnapshot.data == null) {
              return _buildNoParticipationCard();
            }
            
            final participation = partSnapshot.data!;
            return _buildParticipationCard(participation);
          },
        ),
      ],
    );
  }

  /// Builds the loading state card
  Widget _buildLoadingCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Mengambil data partisipasi...'),
          ],
        ),
      ),
    );
  }

  /// Builds the card shown when user has no participation
  Widget _buildNoParticipationCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey[400],
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum Ada Partisipasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Anda belum terdaftar dalam event relawan manapun',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the participation information card
  Widget _buildParticipationCard(ParticipationData participation) {
    final statusColor = _getStatusColor(participation.status);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.volunteer_activism,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participation.eventTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(participation.status, statusColor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Details section
            _buildDetailsSection(participation),
          ],
        ),
      ),
    );
  }

  /// Builds the status badge
  Widget _buildStatusBadge(String status, Color statusColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the details section with role and location
  Widget _buildDetailsSection(ParticipationData participation) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.work_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Peran: ${participation.selectedRole}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  participation.eventLocation,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Gets the color for the participation status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}
