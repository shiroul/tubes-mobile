import 'package:flutter/material.dart';
import '../../widgets/disaster_event_card.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../repositories/event_repository.dart';
import 'event_detail_screen.dart';

class AllEventsScreen extends StatelessWidget {
  const AllEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventRepo = EventRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text('Semua Bencana Aktif'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<EventWithId>>(
        stream: eventRepo.watchActiveEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green[400],
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ada bencana aktif',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Saat ini kondisi aman,\\ntidak ada bencana yang dilaporkan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final events = snapshot.data!;
          
          // Sort by severity and time
          final severityOrder = {'tinggi': 0, 'sedang': 1, 'rendah': 2};
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

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final eventWithId = events[index];
              return DisasterEventCard(
                event: eventWithId.event,
                eventId: eventWithId.id,
                isCompact: false, // Use full card for better visibility
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisasterDetailPage(eventId: eventWithId.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }
}
