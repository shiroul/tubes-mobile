import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../reports/report_detail_screen.dart';

/// A section displaying pending reports for admin review
class AdminReportsSection extends StatelessWidget {
  const AdminReportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'Laporan Menunggu Review',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        
        // Reports Stream
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reports')
              .snapshots(),
          builder: (context, reportSnapshot) {
            if (reportSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!reportSnapshot.hasData || reportSnapshot.data!.docs.isEmpty) {
              return _buildNoReportsCard();
            }
            
            final allDocs = reportSnapshot.data!.docs;
            final pendingReports = _filterPendingReports(allDocs);
            
            if (pendingReports.isEmpty) {
              return _buildNoReportsCard();
            }
            
            return _buildReportsList(pendingReports, context);
          },
        ),
        const SizedBox(height: 16),
        
        // View All Reports Button
        _buildViewAllReportsButton(context),
      ],
    );
  }

  /// Filters documents to get only pending reports
  List<QueryDocumentSnapshot> _filterPendingReports(List<QueryDocumentSnapshot> allDocs) {
    return allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'pending';
      return status == 'pending';
    }).toList();
  }

  /// Builds the card shown when there are no pending reports
  Widget _buildNoReportsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Expanded(child: Text('Tidak ada laporan yang menunggu review')),
          ],
        ),
      ),
    );
  }

  /// Builds the list of pending reports
  Widget _buildReportsList(List<QueryDocumentSnapshot> pendingReports, BuildContext context) {
    return Column(
      children: pendingReports.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _buildReportCard(doc.id, data, context);
      }).toList(),
    );
  }

  /// Builds a single report card
  Widget _buildReportCard(String reportId, Map<String, dynamic> data, BuildContext context) {
    final media = data['media'] as List?;
    final location = data['location'] as Map<String, dynamic>?;
    final city = location?['city'] ?? '-';
    final province = location?['province'] ?? '-';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildReportLeading(media),
        title: Text('${data['type'] ?? 'Laporan'} - ${data['details'] ?? 'Tanpa deskripsi'}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lokasi: $city, $province'),
            const SizedBox(height: 4),
            _buildPendingStatusBadge(),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(reportId: reportId),
            ),
          );
        },
      ),
    );
  }

  /// Builds the leading widget for a report (image or icon)
  Widget _buildReportLeading(List? media) {
    if (media != null && media.isNotEmpty) {
      return CircleAvatar(backgroundImage: NetworkImage(media[0]));
    }
    return const Icon(Icons.report, color: Colors.orange);
  }

  /// Builds the pending status badge
  Widget _buildPendingStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  /// Builds the "View All Reports" button
  Widget _buildViewAllReportsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/admin_all_reports');
        },
        icon: const Icon(Icons.list_alt),
        label: const Text('Lihat Semua Laporan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
