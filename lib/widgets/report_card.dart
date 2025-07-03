import 'package:flutter/material.dart';
import '../models/report.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;
  const ReportCard({Key? key, required this.report, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: report.media.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(report.media[0], width: 56, height: 56, fit: BoxFit.cover),
              )
            : Icon(Icons.report, size: 40, color: Colors.orange),
        title: Text(report.type, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Lokasi: ${report.city}, ${report.province}'),
            Text('Tanggal: ${report.timestamp != null ? (report.timestamp!.toDate().toLocal().toString().split(".")[0]) : '-'}'),
            Text('Status: ${report.status}'),
          ],
        ),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}
