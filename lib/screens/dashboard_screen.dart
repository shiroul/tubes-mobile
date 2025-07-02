import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../widgets/disaster_event_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'events/event_detail_screen.dart';
import 'reports/report_detail_screen.dart';
import '../repositories/event_repository.dart';
import '../repositories/participation_repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final eventRepo = EventRepository();
    final partRepo = ParticipationRepository();
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
        ],
      ),
      body: user == null
          ? Center(child: Text('Tidak ada data user.'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('Data user tidak ditemukan.'));
                }
                final userProfile = UserProfile.fromMap(user.uid, snapshot.data!.data() as Map<String, dynamic>);
                final skills = userProfile.skills;
                final role = (snapshot.data!.data() as Map<String, dynamic>)['role'] ?? 'relawan';
                return Scaffold(
                  body: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Profile Section
                            Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: userProfile.profileImageUrl != null
                                      ? NetworkImage(userProfile.profileImageUrl!)
                                      : null,
                                  child: userProfile.profileImageUrl == null
                                      ? Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(userProfile.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email: ${user.email ?? '-'}'),
                                    Text('No. HP: ${userProfile.phone}'),
                                    SizedBox(height: 4),
                                    Text('Keahlian: ${skills.isNotEmpty ? skills.join(", ") : '-'}'),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/profile');
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            // Aktif Bencana Section (same for all roles)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.emergency,
                                      color: Colors.red[600],
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Aktif Bencana Alam',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            StreamBuilder<List<EventWithId>>(
                              stream: eventRepo.watchActiveEvents(),
                              builder: (context, eventSnapshot) {
                                if (eventSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                if (!eventSnapshot.hasData || eventSnapshot.data!.isEmpty) {
                                  return Container(
                                    padding: EdgeInsets.all(20),
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
                                        SizedBox(height: 12),
                                        Text(
                                          'Tidak ada bencana aktif',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
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
                                final events = eventSnapshot.data!;
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
                                final topEvents = events.take(3).toList();
                                return Column(
                                  children: topEvents.map((eventWithId) {
                                    return DisasterEventCard(
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
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            SizedBox(height: 24),
                            // Role-based section
                            if (role == 'admin') ...[
                              Text('Laporan Menunggu Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('reports')
                                    .snapshots(),
                                builder: (context, reportSnapshot) {
                                  print('Dashboard: Report snapshot state: ${reportSnapshot.connectionState}');
                                  print('Dashboard: Has data: ${reportSnapshot.hasData}');
                                  if (reportSnapshot.hasData) {
                                    print('Dashboard: Number of docs: ${reportSnapshot.data!.docs.length}');
                                    for (var doc in reportSnapshot.data!.docs) {
                                      final data = doc.data() as Map<String, dynamic>;
                                      print('Dashboard: Report ID: ${doc.id}, Status: ${data['status']}, Type: ${data['type']}');
                                    }
                                  }
                                  
                                  if (reportSnapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                  if (!reportSnapshot.hasData || reportSnapshot.data!.docs.isEmpty) {
                                    print('Dashboard: No data or empty docs');
                                    return Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.info, color: Colors.blue),
                                                SizedBox(width: 8),
                                                Expanded(child: Text('Tidak ada laporan ditemukan')),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Debug: Snapshot hasData: ${reportSnapshot.hasData}, Docs length: ${reportSnapshot.hasData ? reportSnapshot.data!.docs.length : 0}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  
                                  // Filter reports that are pending or don't have a status (default to pending)
                                  final allDocs = reportSnapshot.data!.docs;
                                  print('Dashboard: Total docs: ${allDocs.length}');
                                  
                                  // Show all reports for debugging
                                  if (allDocs.isNotEmpty) {
                                    print('Dashboard: Showing all reports for debugging...');
                                    return Column(
                                      children: [
                                        // Debug info
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'DEBUG: Ditemukan ${allDocs.length} laporan total di database',
                                                      style: TextStyle(
                                                        color: Colors.blue[700],
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        // Show all reports
                                        ...allDocs.map((doc) {
                                          final data = doc.data() as Map<String, dynamic>;
                                          final media = data['media'] as List?;
                                          final location = data['location'] as Map<String, dynamic>?;
                                          final city = location?['city'] ?? '-';
                                          final province = location?['province'] ?? '-';
                                          final status = data['status'] ?? 'no-status';
                                          
                                          return Card(
                                            child: ListTile(
                                              leading: media != null && media.isNotEmpty
                                                  ? CircleAvatar(backgroundImage: NetworkImage(media[0]))
                                                  : Icon(Icons.report, color: Colors.orange),
                                              title: Text('${data['type'] ?? '-'} (Status: $status)'),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Deskripsi: ${data['details'] ?? '-'}'),
                                                  Text('Lokasi: $city, $province'),
                                                  SizedBox(height: 4),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: status == 'pending' ? Colors.orange[100] : Colors.grey[100],
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: status == 'pending' ? Colors.orange[300]! : Colors.grey[300]!,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      status == 'pending' ? 'MENUNGGU REVIEW' : status.toUpperCase(),
                                                      style: TextStyle(
                                                        color: status == 'pending' ? Colors.orange[700] : Colors.grey[700],
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ReportDetailScreen(reportId: doc.id),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    );
                                  }
                                  
                                  // This section will only run if no reports found (shouldn't happen with debug above)
                                  if (allDocs.isEmpty) {
                                    return Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text('Tidak ada laporan yang menunggu review'),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  
                                  return Container(); // Fallback
                                },
                              ),
                              SizedBox(height: 16),
                              // View All Reports Button for Admin
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/admin_all_reports');
                                  },
                                  icon: Icon(Icons.list_alt),
                                  label: Text('Lihat Semua Laporan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Partisipasi Saya Section (for relawan)
                              Text('Partisipasi Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              StreamBuilder<List<Map<String, dynamic>>>(
                                stream: partRepo.participationsByUser(user.uid),
                                builder: (context, partSnapshot) {
                                  if (partSnapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                  if (!partSnapshot.hasData || partSnapshot.data!.isEmpty) {
                                    return Text('Belum ada partisipasi');
                                  }
                                  final parts = partSnapshot.data!;
                                  return Column(
                                    children: parts.map((part) {
                                      return Card(
                                        child: ListTile(
                                          leading: Icon(Icons.check_circle, color: Colors.green),
                                          title: Text(part['eventTitle'] ?? '-'),
                                          subtitle: Text('Status: ${part['status'] ?? '-'}'),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                            SizedBox(height: 24),
                            // Announcements Section (Mocked for now)
                            Text('Pengumuman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Card(
                              color: Colors.yellow[100],
                              child: ListTile(
                                leading: Icon(Icons.announcement, color: Colors.orange),
                                title: Text('Tetap waspada dan jaga kesehatan selama bertugas!'),
                              ),
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
                );
              },
            ),
    );
  }
}
