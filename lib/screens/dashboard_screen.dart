import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/disaster_event_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_header.dart';
import '../widgets/lina_logo.dart';
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
      backgroundColor: Colors.grey[50],
      appBar: CustomAppHeader(
        title: 'Dashboard',
        showProfileIcon: true,
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
                final role = (snapshot.data!.data() as Map<String, dynamic>)['role'] ?? 'relawan';
                return Scaffold(
                  body: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // LINA Branding Card
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: LinaLogo(
                                fontSize: 32,
                                subtitleFontSize: 12,
                                heartSize: 50,
                                padding: EdgeInsets.zero,
                                horizontal: true,
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Volunteer Statistics Card
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 10,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Relawan Terdaftar',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Center(child: CircularProgressIndicator()),
                                        SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                }

                                if (!userSnapshot.hasData) {
                                  return Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 10,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Relawan Terdaftar',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Center(
                                          child: Text(
                                            'Tidak dapat memuat data',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                }

                                final users = userSnapshot.data!.docs;
                                
                                // Count total registered users
                                final totalRegistered = users.length;
                                
                                // Count active duty users
                                final activeUsers = users.where((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  final availability = data['availability'];
                                  return availability is String && availability.toLowerCase() == 'active duty';
                                }).length;
                                
                                // Count available users (registered minus active)
                                final availableUsers = totalRegistered - activeUsers;

                                return Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Relawan Terdaftar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildStatColumn('$totalRegistered', 'Terdaftar', Colors.blue[600]!),
                                          _buildStatColumn('$activeUsers', 'Aktif', Colors.green[600]!),
                                          _buildStatColumn('$availableUsers', 'Tersedia', Colors.orange[600]!),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Center(
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context, '/volunteers');
                                          },
                                          child: Text(
                                            'Detail',
                                            style: TextStyle(
                                              color: Colors.blue[600],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Active Disasters Section
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
                                      Icons.warning,
                                      color: Colors.red[600],
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
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
                                final topEvents = events.take(3).toList();
                                return Column(
                                  children: topEvents.map((eventWithId) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12),
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
                                  if (reportSnapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                  if (!reportSnapshot.hasData || reportSnapshot.data!.docs.isEmpty) {
                                    return Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.green),
                                            SizedBox(width: 8),
                                            Expanded(child: Text('Tidak ada laporan yang menunggu review')),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  
                                  final allDocs = reportSnapshot.data!.docs;
                                  
                                  // Filter reports that are pending
                                  final pendingReports = allDocs.where((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    final status = data['status'] ?? 'pending';
                                    return status == 'pending';
                                  }).toList();
                                  
                                  if (pendingReports.isEmpty) {
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
                                  
                                  return Column(
                                    children: pendingReports.map((doc) {
                                      final data = doc.data() as Map<String, dynamic>;
                                      final media = data['media'] as List?;
                                      final location = data['location'] as Map<String, dynamic>?;
                                      final city = location?['city'] ?? '-';
                                      final province = location?['province'] ?? '-';
                                      final status = data['status'] ?? 'pending';
                                      
                                      return Card(
                                        margin: EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          leading: media != null && media.isNotEmpty
                                              ? CircleAvatar(backgroundImage: NetworkImage(media[0]))
                                              : Icon(Icons.report, color: Colors.orange),
                                          title: Text('${data['type'] ?? 'Laporan'} - ${data['details'] ?? 'Tanpa deskripsi'}'),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Lokasi: $city, $province'),
                                              SizedBox(height: 4),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange[100],
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.orange[300]!),
                                                ),
                                                child: Text(
                                                  'MENUNGGU REVIEW',
                                                  style: TextStyle(
                                                    color: Colors.orange[700],
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
                                    }).toList(),
                                  );
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
                              Container(
                                margin: EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.volunteer_activism, color: Colors.blue[600], size: 20),
                                    SizedBox(width: 8),
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
                              StreamBuilder<ParticipationData?>(
                                stream: partRepo.getCurrentUserParticipation(user.uid),
                                builder: (context, partSnapshot) {
                                  if (partSnapshot.connectionState == ConnectionState.waiting) {
                                    return Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 2,
                                      child: Padding(
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
                                  
                                  if (!partSnapshot.hasData || partSnapshot.data == null) {
                                    return Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 2,
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.grey[400],
                                              size: 48,
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Belum Ada Partisipasi',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(height: 4),
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
                                  
                                  final participation = partSnapshot.data!;
                                  final statusColor = participation.status == 'confirmed' 
                                      ? Colors.green 
                                      : participation.status == 'pending'
                                          ? Colors.orange
                                          : Colors.red;
                                  
                                  return Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 2,
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.volunteer_activism,
                                                  color: statusColor,
                                                  size: 20,
                                                ),
                                              ),
                                              SizedBox(width: 12),
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
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: statusColor.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(color: statusColor.withOpacity(0.3)),
                                                          ),
                                                          child: Text(
                                                            participation.status.toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: statusColor,
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
                                          SizedBox(height: 12),
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.work_outline, size: 16, color: Colors.grey[600]),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Peran: ${participation.selectedRole}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                                    SizedBox(width: 8),
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
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
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

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
