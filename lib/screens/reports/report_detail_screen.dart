import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../admin/event_configuration_screen.dart';

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
          final type = data['type'] ?? '-';
          final details = data['details'] ?? '-';
          final location = data['location'] ?? {};
          final city = location['city'] ?? '-';
          final province = location['province'] ?? '-';
          final coords = location['coordinates'];
          LatLng? latLng;
          if (coords != null && coords.latitude != null && coords.longitude != null) {
            latLng = LatLng(coords.latitude, coords.longitude);
          }
          final ts = data['timestamp'] as Timestamp?;
          final timeStr = ts != null ? _timeAgo(ts.toDate()) : '-';
          final status = data['status'] ?? 'pending';
          final media = data['media'] as List?;
          String? photoUrl;
          if (media != null && media.isNotEmpty && media.first is String) {
            photoUrl = media.first;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Map Card
                if (latLng != null)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: latLng,
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: latLng,
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.location_on, color: Colors.red, size: 40),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (latLng != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.directions),
                      label: Text('Buka di Maps'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      onPressed: () async {
                        final url = 'https://www.google.com/maps/search/?api=1&query=${latLng!.latitude},${latLng.longitude}';
                        final uri = Uri.parse(url);
                        try {
                          final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
                          );
                        }
                      },
                    ),
                  ),
                SizedBox(height: 16),
                // Info Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(type, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
                              ),
                              child: Text(
                                _getStatusText(status),
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Lokasi: $city, $province'),
                        if (coords != null) Text('Koordinat: ${coords.latitude}, ${coords.longitude}'),
                        SizedBox(height: 8),
                        Text('Waktu: $timeStr'),
                        SizedBox(height: 12),
                        Text('Detail:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Photo Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(photoUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                        )
                      : Container(
                          height: 180,
                          alignment: Alignment.center,
                          child: Icon(Icons.photo, size: 48, color: Colors.grey),
                        ),
                ),
                SizedBox(height: 16),
                // Action Buttons (Admin only)
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).get(),
                  builder: (context, userSnap) {
                    bool isAdmin = false;
                    if (userSnap.hasData && userSnap.data!.exists) {
                      final userData = userSnap.data!.data() as Map<String, dynamic>;
                      isAdmin = userData['role'] == 'admin';
                    }
                    if (!isAdmin || status == 'ditolak' || status == 'active') {
                      return SizedBox.shrink(); // Hide buttons for non-admin users or already processed reports
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _navigateToEventConfiguration(context, data, location),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Terima Laporan'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            onPressed: () {
                              _showRejectConfirmation(context);
                            },
                            child: Text('Tolak'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'ditolak':
        return Colors.red;
      case 'diterima':
        return Colors.green;
      case 'active':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'MENUNGGU';
      case 'ditolak':
        return 'DITOLAK';
      case 'diterima':
        return 'DITERIMA';
      case 'active':
        return 'AKTIF';
      default:
        return status.toUpperCase();
    }
  }

  void _navigateToEventConfiguration(BuildContext context, Map<String, dynamic> data, Map<String, dynamic> location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventConfigurationScreen(
          reportId: reportId,
          reportData: data,
          location: location,
        ),
      ),
    );
  }

  void _showRejectConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              
              // Icon
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 32,
                  color: Colors.red[600],
                ),
              ),
              SizedBox(height: 16),
              
              // Title
              Text(
                'Tolak Laporan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              
              // Description
              Text(
                'Apakah Anda yakin ingin menolak laporan ini? Status laporan akan diubah menjadi "ditolak" dan laporan akan disimpan untuk referensi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rejectReport(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Ya, Tolak',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _rejectReport(BuildContext bottomSheetContext) async {
    // Get a reference to the main screen context from route
    final navigator = Navigator.of(bottomSheetContext);
    
    // Close bottom sheet first
    navigator.pop();
    
    // Use the bottom sheet context's parent to show dialog
    final mainContext = navigator.context;
    if (!mainContext.mounted) return;
    
    // Show loading dialog on the main screen
    showDialog(
      context: mainContext,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menolak laporan...'),
            ],
          ),
        ),
      ),
    );
    
    try {
      // Update report status in Firestore
      await FirebaseFirestore.instance.collection('reports').doc(reportId).update({
        'status': 'ditolak'
      });
      
      // Close loading dialog
      if (mainContext.mounted && Navigator.canPop(mainContext)) {
        Navigator.pop(mainContext);
      }
      
      // Navigate back and show success message
      if (mainContext.mounted) {
        Navigator.pop(mainContext);
        ScaffoldMessenger.of(mainContext).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Laporan berhasil ditolak'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mainContext.mounted && Navigator.canPop(mainContext)) {
        Navigator.pop(mainContext);
      }
      
      // Show error message
      if (mainContext.mounted) {
        ScaffoldMessenger.of(mainContext).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Gagal menolak laporan: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
