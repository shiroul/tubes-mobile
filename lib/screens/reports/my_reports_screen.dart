import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/report.dart';
import '../../widgets/report_card.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/custom_app_header.dart';
import '../../repositories/report_repository.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // DEBUG: Print current user UID
    print('[MyReportsScreen] Current user UID: \'${user?.uid}\'');
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Laporan Saya')),
        body: Center(child: Text('Tidak ada data user.')),
      );
    }
    final repo = ReportRepository();
    return Scaffold(
      appBar: CustomAppHeader(
        title: 'Laporan Saya',
        showLogo: false,
        showProfileIcon: true,
      ),
      body: StreamBuilder<List<ReportModel>>(
        stream: repo.reportsByUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada laporan.'));
          }
          final reports = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, i) {
              final report = reports[i];
              return ReportCard(report: report);
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }
}
