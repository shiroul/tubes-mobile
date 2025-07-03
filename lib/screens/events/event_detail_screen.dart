import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/confirmation_screen.dart';

class DisasterDetailPage extends StatelessWidget {
  final String eventId;
  const DisasterDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Bencana')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Data bencana tidak ditemukan.'));
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
          final requiredVolunteers = data['requiredVolunteers'] as Map<String, dynamic>? ?? {};
          final ts = data['reportedAt'] as Timestamp?;
          final timeStr = ts != null ? _timeAgo(ts.toDate()) : '-';
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
                // Info Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        SizedBox(height: 8),
                        Text('Lokasi: $city, $province'),
                        if (coords != null) Text('Koordinat: ${coords.latitude}, ${coords.longitude}'),
                        SizedBox(height: 8),
                        Text('Waktu: $timeStr'),
                        SizedBox(height: 12),
                        Text('Detail:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details),
                        SizedBox(height: 12),
                        Text('Kebutuhan Relawan:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...requiredVolunteers.entries.map((e) => Text('• ${e.value} ${e.key}')),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
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
                // Action Button (role-based)
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).get(),
                  builder: (context, userSnap) {
                    bool isAdmin = false;
                    if (userSnap.hasData && userSnap.data!.exists) {
                      final userData = userSnap.data!.data() as Map<String, dynamic>;
                      isAdmin = userData['role'] == 'admin';
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: isAdmin
                          ? ElevatedButton.icon(
                              icon: Icon(Icons.verified, color: Colors.white),
                              label: Text('Bencana Teratasi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                _showResolveConfirmationBottomSheet(context, eventId, type);
                              },
                            )
                          : ElevatedButton.icon(
                              icon: Icon(Icons.volunteer_activism),
                              label: Text('Daftar Jadi Relawan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                await _checkAvailabilityAndRegister(context, eventId);
                              },
                            ),
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

  void _showResolveConfirmationBottomSheet(BuildContext context, String eventId, String disasterType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Warning icon and title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Konfirmasi Penyelesaian',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Confirmation message
            Text(
              'Apakah Anda yakin ingin menandai bencana "$disasterType" sebagai teratasi?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 12),
            
            // Additional info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tindakan ini akan mengubah status bencana menjadi "Selesai" dan tidak dapat dibatalkan.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Don't close the bottom sheet immediately
                      try {
                        // Step 1: Update event status to completed
                        await FirebaseFirestore.instance.collection('events').doc(eventId).update({
                          'status': 'completed',
                          'resolvedAt': FieldValue.serverTimestamp(),
                        });
                        
                        // Step 2: Find all volunteer registrations for this event
                        final volunteerRegistrations = await FirebaseFirestore.instance
                            .collection('volunteer_registrations')
                            .where('eventId', isEqualTo: eventId)
                            .get();
                        
                        // Step 3: Update availability status for all registered volunteers
                        final batch = FirebaseFirestore.instance.batch();
                        
                        for (final registration in volunteerRegistrations.docs) {
                          final registrationData = registration.data();
                          final userId = registrationData['userId'];
                          
                          if (userId != null) {
                            // Update user's availability back to 'available'
                            final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
                            batch.update(userRef, {
                              'availability': 'available',
                            });
                          }
                          
                          // Step 4: Delete the volunteer registration record
                          batch.delete(registration.reference);
                        }
                        
                        // Execute all updates and deletions in a batch
                        await batch.commit();
                        
                        // Close bottom sheet after successful update
                        Navigator.pop(context);
                        
                        // Small delay to ensure context is still valid
                        await Future.delayed(Duration(milliseconds: 100));
                        
                        if (context.mounted) {
                          // Navigate to confirmation screen for disaster resolution
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmationScreen.disasterResolved(),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        // Close bottom sheet on error too
                        Navigator.pop(context);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Gagal mengubah status bencana: $e'),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Ya, Tandai Selesai',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAvailabilityAndRegister(BuildContext context, String eventId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anda harus login terlebih dahulu')),
      );
      return;
    }

    try {
      // Get user's current availability status
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data pengguna tidak ditemukan')),
        );
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final availability = userData['availability'] ?? 'available';

      if (availability == 'active duty') {
        // Show dialog/modal for active duty status
        _showActiveDutyDialog(context);
      } else {
        // Proceed to volunteer registration screen
        Navigator.pushNamed(
          context,
          '/volunteer_registration',
          arguments: {'eventId': eventId},
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memeriksa status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showActiveDutyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Sedang Bertugas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anda saat ini sedang bertugas di event bencana lain.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selesaikan tugas Anda saat ini terlebih dahulu sebelum mendaftar ke event baru.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: Text(
                'Mengerti',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
