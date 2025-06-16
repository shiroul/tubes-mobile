import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          // Removed logout button from AppBar
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
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final skills = (data['skills'] as List?)?.cast<String>() ?? [];
                final role = data['role'] ?? 'relawan';
                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Profile Section
                          Card(
                            child: ListTile(
                              leading: CircleAvatar(child: Icon(Icons.person)),
                              title: Text(data['name'] ?? '-', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${data['email'] ?? '-'}'),
                                  Text('No. HP: ${data['phone'] ?? '-'}'),
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
                          Text('🚨 Aktif Bencana Alam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance.collection('events').where('isActive', isEqualTo: true).get(),
                            builder: (context, eventSnapshot) {
                              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              if (!eventSnapshot.hasData || eventSnapshot.data!.docs.isEmpty) {
                                return Text('Tidak ada bencana aktif');
                              }
                              final events = eventSnapshot.data!.docs;
                              return Column(
                                children: events.map((doc) {
                                  final event = doc.data() as Map<String, dynamic>;
                                  return Card(
                                    child: ListTile(
                                      leading: Icon(Icons.warning, color: Colors.red),
                                      title: Text(event['title'] ?? '-'),
                                      subtitle: Text('Lokasi: ${event['location'] ?? '-'}\nTanggal: ${event['date'] ?? '-'}\nKeahlian dibutuhkan: ${(event['skillsNeeded'] as List?)?.join(", ") ?? '-'}'),
                                      trailing: ElevatedButton(
                                        onPressed: () {},
                                        child: Text('Lihat'),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          SizedBox(height: 24),
                          // Role-based section
                          if (role == 'admin') ...[
                            Text('Reported Bencana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance.collection('reports').orderBy('timestamp', descending: true).get(),
                              builder: (context, reportSnapshot) {
                                if (reportSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                if (!reportSnapshot.hasData || reportSnapshot.data!.docs.isEmpty) {
                                  return Text('Belum ada laporan bencana');
                                }
                                final reports = reportSnapshot.data!.docs;
                                return Column(
                                  children: reports.map((doc) {
                                    final report = doc.data() as Map<String, dynamic>;
                                    return Card(
                                      child: ListTile(
                                        leading: Icon(Icons.report, color: Colors.orange),
                                        title: Text(report['jenisBencana'] ?? '-'),
                                        subtitle: Text('Deskripsi: ${report['deskripsi'] ?? '-'}\nAlamat: ${report['alamat'] ?? '-'}'),
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
                          ] else ...[
                            // Partisipasi Saya Section (for relawan)
                            Text('Partisipasi Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('participations')
                                  .where('userId', isEqualTo: user.uid)
                                  .get(),
                              builder: (context, partSnapshot) {
                                if (partSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                if (!partSnapshot.hasData || partSnapshot.data!.docs.isEmpty) {
                                  return Text('Belum ada partisipasi');
                                }
                                final parts = partSnapshot.data!.docs;
                                return Column(
                                  children: parts.map((doc) {
                                    final part = doc.data() as Map<String, dynamic>;
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
                    if (role == 'relawan')
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/report');
                            },
                            tooltip: 'Laporkan Bencana',
                            child: Icon(Icons.add_alert),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class ReportDetailScreen extends StatelessWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Laporan Bencana'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('reports').doc(reportId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Data laporan tidak ditemukan.'));
          }
          final report = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Jenis Bencana: ${report['jenisBencana'] ?? '-'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Deskripsi: ${report['deskripsi'] ?? '-'}'),
                SizedBox(height: 8),
                Text('Alamat: ${report['alamat'] ?? '-'}'),
                SizedBox(height: 8),
                Text('Koordinat: ${report['latitude'] ?? '-'}, ${report['longitude'] ?? '-'}'),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final lat = report['latitude'];
                        final lng = report['longitude'];
                        final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                      child: Text('Lihat di Peta'),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance.collection('events').add({
                                'title': report['jenisBencana'] ?? '-',
                                'description': report['deskripsi'] ?? '-',
                                'location': report['alamat'] ?? '-',
                                'date': DateTime.now().toIso8601String(),
                                'skillsNeeded': [],
                                'isActive': true,
                                'latitude': report['latitude'],
                                'longitude': report['longitude'],
                              });
                              await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Laporan diterima dan dipindahkan ke Aktif Bencana.')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal menerima laporan: $e')),
                                );
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Laporan dihapus.')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal menghapus laporan: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
