import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventConfigurationScreen extends StatefulWidget {
  final String reportId;
  final Map<String, dynamic> reportData;
  final Map<String, dynamic> location;

  const EventConfigurationScreen({
    super.key,
    required this.reportId,
    required this.reportData,
    required this.location,
  });

  @override
  State<EventConfigurationScreen> createState() => _EventConfigurationScreenState();
}

class _EventConfigurationScreenState extends State<EventConfigurationScreen> {
  // Available volunteer roles
  final List<String> volunteerRoles = [
    'Medis',
    'Logistik',
    'Evakuasi',
    'Media',
    'Bantuan Umum'
  ];

  // Controllers for volunteer counts
  Map<String, TextEditingController> volunteerControllers = {};
  String selectedSeverity = 'sedang';

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    for (String role in volunteerRoles) {
      volunteerControllers[role] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in volunteerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _acceptReport() {
    // Validate that at least one volunteer type is required
    bool hasVolunteers = false;
    Map<String, int> requiredVolunteers = {};
    
    volunteerControllers.forEach((role, controller) {
      int count = int.tryParse(controller.text) ?? 0;
      if (count > 0) {
        requiredVolunteers[role] = count;
        hasVolunteers = true;
      }
    });

    if (!hasVolunteers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Masukkan minimal satu kebutuhan relawan'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Prepare event data for confirmation
    final eventData = {
      'type': widget.reportData['type'] ?? '-',
      'details': widget.reportData['details'] ?? '-',
      'location': {
        'coordinates': widget.location['coordinates'],
        'city': widget.location['city'] ?? '-',
        'province': widget.location['province'] ?? '-',
      },
      'media': widget.reportData['media'] ?? [],
      'requiredVolunteers': requiredVolunteers,
      'severityLevel': selectedSeverity,
      'status': 'active',
      'reportedAt': FieldValue.serverTimestamp(),
    };

    // Navigate to confirmation screen
    Navigator.pushNamed(
      context,
      '/report_acceptance_confirmation',
      arguments: {
        'reportId': widget.reportId,
        'eventData': eventData,
        'volunteerSummary': requiredVolunteers,
        'severity': selectedSeverity,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konfigurasi Event Bencana'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Report Summary Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Laporan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Jenis: ${widget.reportData['type'] ?? '-'}'),
                    Text('Lokasi: ${widget.location['city'] ?? '-'}, ${widget.location['province'] ?? '-'}'),
                    SizedBox(height: 8),
                    Text(
                      'Detail:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(widget.reportData['details'] ?? '-'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Description
            Text(
              'Tentukan jumlah relawan yang dibutuhkan dan tingkat keparahan untuk event bencana ini.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Volunteer Requirements Section
            Text(
              'Kebutuhan Relawan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            
            // Volunteer inputs
            ...volunteerRoles.map((role) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      role,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: volunteerControllers[role],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            
            SizedBox(height: 32),
            
            // Severity Level Section
            Text(
              'Tingkat Keparahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: selectedSeverity,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              items: [
                DropdownMenuItem(
                  value: 'ringan',
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Ringan'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'sedang',
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Sedang'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'parah',
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Parah'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedSeverity = value;
                  });
                }
              },
            ),
            
            SizedBox(height: 48),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
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
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _acceptReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Terima Laporan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
