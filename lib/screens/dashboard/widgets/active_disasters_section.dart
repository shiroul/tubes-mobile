import 'package:flutter/material.dart';
import '../../../widgets/disaster_event_card.dart';
import '../../../repositories/event_repository.dart';
import '../../events/event_detail_screen.dart';

/// A section displaying active disaster events
class ActiveDisastersSection extends StatelessWidget {
  const ActiveDisastersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final eventRepo = EventRepository();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning,
                  color: Colors.red[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Laporan Aktif',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Events Stream
        StreamBuilder<List<EventWithId>>(
          stream: eventRepo.watchActiveEvents(),
          builder: (context, eventSnapshot) {
            if (eventSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!eventSnapshot.hasData || eventSnapshot.data!.isEmpty) {
              return _buildNoActiveDisasters();
            }
            
            final events = eventSnapshot.data!;
            final sortedEvents = _sortEventsBySeverity(events);
            final topEvents = sortedEvents.take(3).toList();
            
            return Column(
              children: topEvents.map((eventWithId) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: DisasterEventCard(
                    event: eventWithId.event,
                    eventId: eventWithId.id,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisasterDetailPage(eventId: eventWithId.id),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// Builds the widget shown when there are no active disasters
  Widget _buildNoActiveDisasters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green[400],
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada bencana aktif',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saat ini kondisi aman, tidak ada bencana yang dilaporkan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Sorts events by severity level and timestamp
  List<EventWithId> _sortEventsBySeverity(List<EventWithId> events) {
    final severityOrder = {'parah': 0, 'sedang': 1, 'ringan': 2};
    
    events.sort((a, b) {
      final sa = severityOrder[a.event.severityLevel] ?? 3;
      final sb = severityOrder[b.event.severityLevel] ?? 3;
      
      if (sa != sb) return sa.compareTo(sb);
      
      final ta = (a.event as dynamic).timestamp;
      final tb = (b.event as dynamic).timestamp;
      
      if (ta != null && tb != null) {
        return (tb.millisecondsSinceEpoch).compareTo(ta.millisecondsSinceEpoch);
      }
      
      return 0;
    });
    
    return events;
  }
}
