import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/custom_app_header.dart';

class VolunteersListScreen extends StatefulWidget {
  const VolunteersListScreen({super.key});

  @override
  State<VolunteersListScreen> createState() => _VolunteersListScreenState();
}

class _VolunteersListScreenState extends State<VolunteersListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppHeader(
        title: 'Relawan',
        showProfileIcon: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.red[600],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tidak dapat memuat data relawan',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada relawan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada relawan yang terdaftar dalam sistem',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;
              final isCurrentUser = currentUserId == userId;
              
              return _buildUserCard(userData, isCurrentUser);
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> userData, bool isCurrentUser) {
    final name = userData['name'] ?? 'Nama tidak tersedia';
    final role = userData['role'] ?? 'relawan';
    
    // Handle availability - it could be bool, string, or null
    final availabilityData = userData['availability'];
    bool availability;
    String availabilityStatus = 'TIDAK TERSEDIA';
    Color availabilityColor = Colors.red[600]!;
    Color availabilityBgColor = Colors.red[50]!;
    Color availabilityBorderColor = Colors.red[300]!;
    
    if (availabilityData is bool) {
      availability = availabilityData;
      availabilityStatus = availability ? 'TERSEDIA' : 'TIDAK TERSEDIA';
      if (availability) {
        availabilityColor = Colors.green[600]!;
        availabilityBgColor = Colors.green[50]!;
        availabilityBorderColor = Colors.green[300]!;
      }
    } else if (availabilityData is String) {
      final statusLower = availabilityData.toLowerCase();
      if (statusLower == 'active duty') {
        availability = true;
        availabilityStatus = 'TUGAS AKTIF';
        availabilityColor = Colors.orange[700]!;
        availabilityBgColor = Colors.orange[50]!;
        availabilityBorderColor = Colors.orange[300]!;
      } else if (statusLower == 'available') {
        availability = true;
        availabilityStatus = 'TERSEDIA';
        availabilityColor = Colors.green[600]!;
        availabilityBgColor = Colors.green[50]!;
        availabilityBorderColor = Colors.green[300]!;
      } else {
        availability = false;
        availabilityStatus = 'TIDAK TERSEDIA';
      }
    } else {
      availability = false; // Default to false if null or other type
      availabilityStatus = 'TIDAK TERSEDIA';
    }
    
    final profileImageUrl = userData['profileImageUrl'] as String?;
    
    // Generate avatar colors based on name
    final avatarColor = _generateAvatarColor(name);
    final initials = _getInitials(name);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: isCurrentUser ? Border.all(color: Colors.blue[300]!, width: 2) : null,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: profileImageUrl != null ? null : avatarColor,
                  image: profileImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(profileImageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profileImageUrl == null
                    ? Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              // Availability status indicator
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: availability ? availabilityColor : Colors.red[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    availability ? Icons.check : Icons.close,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCurrentUser)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Text(
                    'Saya',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6),
              Row(
                children: [
                  // Role badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getRoleColor(role).withOpacity(0.3)),
                    ),
                    child: Text(
                      _getRoleDisplayName(role),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getRoleColor(role),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Availability badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: availabilityBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: availabilityBorderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          availability ? Icons.check_circle : Icons.cancel,
                          size: 12,
                          color: availabilityColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          availabilityStatus,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: availabilityColor,
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
    );
  }

  Color _generateAvatarColor(String name) {
    final colors = [
      Colors.red[400]!,
      Colors.pink[400]!,
      Colors.purple[400]!,
      Colors.deepPurple[400]!,
      Colors.indigo[400]!,
      Colors.blue[400]!,
      Colors.lightBlue[400]!,
      Colors.cyan[400]!,
      Colors.teal[400]!,
      Colors.green[400]!,
      Colors.lightGreen[400]!,
      Colors.lime[400]!,
      Colors.yellow[600]!,
      Colors.amber[400]!,
      Colors.orange[400]!,
      Colors.deepOrange[400]!,
    ];
    
    final index = name.hashCode % colors.length;
    return colors[index.abs()];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, parts[0].length > 1 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red[600]!;
      case 'relawan':
        return Colors.blue[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'ADMIN';
      case 'relawan':
        return 'RELAWAN';
      default:
        return role.toUpperCase();
    }
  }
}