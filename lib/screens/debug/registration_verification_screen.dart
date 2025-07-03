import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationVerificationScreen extends StatefulWidget {
  const RegistrationVerificationScreen({super.key});

  @override
  State<RegistrationVerificationScreen> createState() => _RegistrationVerificationScreenState();
}

class _RegistrationVerificationScreenState extends State<RegistrationVerificationScreen> {
  String testResults = 'No tests run yet';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verifikasi Pendaftaran'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Event tidak ditemukan'));
          }
          
          final eventData = snapshot.data!.data() as Map<String, dynamic>;
          final requiredVolunteers = eventData['requiredVolunteers'] as Map<String, dynamic>? ?? {};
          final registeredVolunteers = eventData['registeredVolunteers'] as List<dynamic>? ?? [];
          
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kebutuhan Relawan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...requiredVolunteers.entries.map((entry) => 
                          Text('${entry.key}: ${entry.value} orang')
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Relawan Terdaftar (${registeredVolunteers.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        if (registeredVolunteers.isEmpty)
                          Text('Belum ada relawan yang terdaftar')
                        else
                          ...registeredVolunteers.map((volunteer) {
                            final vol = volunteer as Map<String, dynamic>;
                            return ListTile(
                              title: Text(vol['userName'] ?? 'Unknown'),
                              subtitle: Text('Role: ${vol['role']} | Email: ${vol['userEmail']}'),
                              leading: Icon(Icons.person),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Kembali'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
