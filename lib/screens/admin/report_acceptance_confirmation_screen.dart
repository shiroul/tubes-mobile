import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportAcceptanceConfirmationScreen extends StatefulWidget {
  final String reportId;
  final Map<String, dynamic> eventData;
  final Map<String, int> volunteerSummary;
  final String severity;

  const ReportAcceptanceConfirmationScreen({
    super.key,
    required this.reportId,
    required this.eventData,
    required this.volunteerSummary,
    required this.severity,
  });

  @override
  State<ReportAcceptanceConfirmationScreen> createState() => _ReportAcceptanceConfirmationScreenState();
}

class _ReportAcceptanceConfirmationScreenState extends State<ReportAcceptanceConfirmationScreen> {
  bool isProcessing = false;

  Color _getSeverityColorWidget() {
    switch (widget.severity) {
      case 'ringan':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'parah':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _confirmAcceptance() async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      // Create event from report
      final docRef = await FirebaseFirestore.instance.collection('events').add(widget.eventData);

      // Update report status to 'accepted' instead of deleting it
      await FirebaseFirestore.instance.collection('reports').doc(widget.reportId).update({
        'status': 'accepted',
        'eventId': docRef.id,
        'processedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Navigate to the simple confirmation screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/confirmation_report_accepted',
          (route) => false,
        );
      }
    } catch (e) {
      print('Error creating event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Gagal memproses laporan: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Konfirmasi Penerimaan'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fact_check,
                        size: 48,
                        color: Colors.green[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Konfirmasi Penerimaan Laporan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Event bencana akan dibuat berdasarkan konfigurasi berikut',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Event Details Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Event Bencana',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow('Jenis Bencana', widget.eventData['type']),
                    _buildDetailRow('Lokasi', '${widget.eventData['location']['city']}, ${widget.eventData['location']['province']}'),
                    _buildDetailRow('Detail', widget.eventData['details']),
                    
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Tingkat Keparahan: ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getSeverityColorWidget().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _getSeverityColorWidget(), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getSeverityColorWidget(),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                widget.severity.toUpperCase(),
                                style: TextStyle(
                                  color: _getSeverityColorWidget(),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Volunteer Requirements Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kebutuhan Relawan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    if (widget.volunteerSummary.isEmpty)
                      Text(
                        'Tidak ada kebutuhan relawan yang ditentukan',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    else
                      ...widget.volunteerSummary.entries.map((entry) => Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.value} orang',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : () {
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
                      'Kembali',
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
                    onPressed: isProcessing ? null : _confirmAcceptance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Memproses...'),
                            ],
                          )
                        : Text(
                            'Konfirmasi & Buat Event',
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
