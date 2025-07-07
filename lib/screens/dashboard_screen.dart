import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_header.dart';
import '../services/services.dart';
import 'dashboard/widgets/lina_branding_card.dart';
import 'dashboard/widgets/volunteer_stats_card.dart';
import 'dashboard/widgets/active_disasters_section.dart';
import 'dashboard/widgets/admin_reports_section.dart';
import 'dashboard/widgets/user_participation_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppHeader(
        title: 'Dashboard',
        showProfileIcon: true,
      ),
      body: user == null
          ? const Center(child: Text('Tidak ada data user.'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Data user tidak ditemukan.'));
                }
                
                final role = (snapshot.data!.data() as Map<String, dynamic>)['role'] ?? 'relawan';
                
                return Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // LINA Branding Card
                        const LinaBrandingCard(),
                        const SizedBox(height: 24),
                        
                        // Volunteer Statistics Card
                        const VolunteerStatsCard(),
                        const SizedBox(height: 24),
                        
                        // Active Disasters Section
                        const ActiveDisastersSection(),
                        const SizedBox(height: 24),
                        
                        // Role-based sections
                        if (role == 'admin') ...[
                          const AdminReportsSection(),
                        ] else ...[
                          UserParticipationSection(userId: user.uid),
                        ],
                      ],
                    ),
                  ),
                  bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
                );
              },
            ),
    );
  }
}
