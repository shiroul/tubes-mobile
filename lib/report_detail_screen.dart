import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDetailScreen extends StatelessWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Laporan Bencana')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('reports').doc(reportId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Laporan tidak ditemukan.'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final lat = data['latitude'];
          final lng = data['longitude'];
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jenis Bencana', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(data['jenisBencana'] ?? '-'),
                SizedBox(height: 16),
                Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(data['deskripsi'] ?? '-'),
                SizedBox(height: 16),
                Text('Alamat', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(data['alamat'] ?? '-'),
                SizedBox(height: 16),
                Text('Lokasi', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Lat: $lat, Lng: $lng'),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: Icon(Icons.map),
                  label: Text('Buka di Maps'),
                ),
                Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Accept: move to events, delete report
                          await FirebaseFirestore.instance.collection('events').add({
                            'title': data['jenisBencana'] ?? '-',
                            'description': data['deskripsi'] ?? '-',
                            'location': data['alamat'] ?? '-',
                            'date': DateTime.now().toIso8601String(),
                            'skillsNeeded': [],
                            'isActive': true,
                            'latitude': lat,
                            'longitude': lng,
                          });
                          await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Laporan diterima dan dipindahkan ke Aktif Bencana.')),
                            );
                          }
                        },
                        child: Text('Terima Laporan'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Laporan dihapus.')),
                            );
                          }
                        },
                        child: Text('Hapus'),
                      ),
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
