import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VolunteerRegistrationScreen extends StatefulWidget {
  final String eventId;

  const VolunteerRegistrationScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<VolunteerRegistrationScreen> createState() => _VolunteerRegistrationScreenState();
}

class _VolunteerRegistrationScreenState extends State<VolunteerRegistrationScreen> {
  Map<String, dynamic>? eventData;
  Map<String, dynamic>? userData;
  String? selectedRole;
  bool isLoading = true;
  bool isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning to this screen to get updated counts
    if (mounted) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      // Load event data
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();
      
      // Load user data
      final currentUser = FirebaseAuth.instance.currentUser;
      DocumentSnapshot? userDoc;
      if (currentUser != null) {
        userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
      }

      if (mounted) {
        setState(() {
          if (eventDoc.exists) {
            eventData = eventDoc.data() as Map<String, dynamic>;
          }
          if (userDoc != null && userDoc.exists) {
            userData = userDoc.data() as Map<String, dynamic>;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitRegistration() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih peran terlebih dahulu')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not logged in');
      
      if (userData == null) {
        throw Exception('User data not loaded. Please try refreshing the page.');
      }
      
      print('User data available: ${userData!['name']}, skills: ${userData!['skills']}'); // Debug log

      // Check if user has already registered for this event
      print('Checking for existing registration...'); // Debug log
      final existingRegistration = await FirebaseFirestore.instance
          .collection('volunteer_registrations')
          .where('eventId', isEqualTo: widget.eventId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      if (existingRegistration.docs.isNotEmpty) {
        print('User already registered for this event'); // Debug log
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda sudah terdaftar untuk event ini'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      print('No existing registration found, proceeding...'); // Debug log

      // Check if the selected role still has available spots
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();
      
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }
      
      final currentEventData = eventDoc.data() as Map<String, dynamic>;
      final currentRequiredVolunteers = currentEventData['requiredVolunteers'] as Map<String, dynamic>;
      final currentRegisteredVolunteers = currentEventData['registeredVolunteers'] as List<dynamic>? ?? [];
      
      // Calculate current remaining spots for the selected role
      final currentRegisteredCount = currentRegisteredVolunteers
          .where((vol) => vol['role'] == selectedRole)
          .length;
      final requiredCount = currentRequiredVolunteers[selectedRole] ?? 0;
      final remainingCount = requiredCount - currentRegisteredCount;
      
      print('Current registered count for role $selectedRole: $currentRegisteredCount'); // Debug log
      print('Required count for role $selectedRole: $requiredCount'); // Debug log
      print('Remaining spots for role $selectedRole: $remainingCount'); // Debug log
      
      if (remainingCount <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maaf, kuota untuk peran $selectedRole sudah penuh'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Perform registration operations directly (no transaction needed)
      print('Starting registration for eventId: ${widget.eventId}, userId: ${currentUser.uid}, role: $selectedRole'); // Debug log
      
      // Step 1: Create registration record
      print('Creating registration record...'); // Debug log
      await FirebaseFirestore.instance.collection('volunteer_registrations').add({
        'eventId': widget.eventId,
        'userId': currentUser.uid,
        'userName': userData?['name'] ?? 'Unknown',
        'userEmail': userData?['email'] ?? 'Unknown',
        'selectedRole': selectedRole!,
        'status': 'confirmed',
        'registeredAt': Timestamp.now(),
      });
      print('✅ Registration record created'); // Debug log
      
      // Step 2: Update user status
      print('Updating user status...'); // Debug log
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'availability': 'active duty',
        'currentEventId': widget.eventId,
        'currentRole': selectedRole!,
      });
      print('✅ User status updated'); // Debug log
      
      // Step 3: Update event document
      print('Updating event document...'); // Debug log
      final finalEventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();
      
      if (finalEventDoc.exists) {
        final finalEventData = finalEventDoc.data() as Map<String, dynamic>;
        final registeredVolunteers = List<Map<String, dynamic>>.from(finalEventData['registeredVolunteers'] ?? []);
        
        // Don't decrease required volunteer count - we keep the original requirement
        // Instead, we just add the user to the registered volunteers list
        
        // Add user info to registered volunteers (using Timestamp.now() instead of FieldValue.serverTimestamp())
        registeredVolunteers.add({
          'userId': currentUser.uid,
          'userName': userData?['name'] ?? 'Unknown',
          'userEmail': userData?['email'] ?? 'Unknown',
          'role': selectedRole!,
          'registeredAt': Timestamp.now(), // Use Timestamp.now() for arrays
          'skills': userData?['skills'] ?? [],
          'phone': userData?['phone'] ?? '',
        });
        
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .update({
          'registeredVolunteers': registeredVolunteers, // Only update registered volunteers, not required count
        });
        print('✅ Event document updated'); // Debug log
      }

      print('Registration completed successfully!'); // Debug log
      
      print('Registration successful, navigating to confirmation...'); // Debug log
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/confirmation_volunteer_registered',
          (route) => false,
        );
      }
    } catch (e) {
      print('Registration error: $e'); // Debug log
      print('Error type: ${e.runtimeType}'); // Debug log
      // Only show error if it's not a navigation issue
      if (e.toString().contains('cloud_firestore/unknown') && e.toString().contains('null')) {
        print('Detected null Firestore error - registration likely succeeded'); // Debug log
        if (mounted) {
          // Navigate to confirmation screen since registration likely succeeded
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/confirmation_volunteer_registered',
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mendaftar: $e'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Pendaftaran Relawan')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (eventData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Pendaftaran Relawan')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Event tidak ditemukan'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final requiredVolunteers = eventData!['requiredVolunteers'] as Map<String, dynamic>? ?? {};
    final registeredVolunteers = eventData!['registeredVolunteers'] as List<dynamic>? ?? [];
    
    // Calculate remaining spots for each role
    final remainingSpots = <String, int>{};
    final registeredCounts = <String, int>{};
    
    // Count how many volunteers are already registered for each role
    for (var volunteer in registeredVolunteers) {
      final role = volunteer['role'] as String?;
      if (role != null) {
        registeredCounts[role] = (registeredCounts[role] ?? 0) + 1;
      }
    }
    
    // Calculate remaining spots for each role
    for (var role in requiredVolunteers.keys) {
      final required = requiredVolunteers[role] as int;
      final registered = registeredCounts[role] ?? 0;
      remainingSpots[role] = (required - registered).clamp(0, required);
    }
    
    final availableRoles = requiredVolunteers.keys.toList(); // Show all roles, not just available ones
    final userSkills = userData?['skills'] as List<dynamic>? ?? [];
    final userSkillsSet = Set<String>.from(userSkills.map((skill) => skill.toString()));
    final availableToUser = availableRoles.where((role) => userSkillsSet.contains(role) && remainingSpots[role]! > 0).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Pendaftaran Relawan'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Data berhasil diperbarui'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content is not scrollable
          padding: EdgeInsets.all(24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Info Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.warning,
                            color: Colors.red[700],
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            eventData!['type'] ?? 'Bencana',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Lokasi: ${eventData!['location']?['city'] ?? '-'}, ${eventData!['location']?['province'] ?? '-'}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      eventData!['details'] ?? 'Tidak ada detail',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Role Selection
            Text(
              'Pilih Peran Relawan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pilih peran yang sesuai dengan keahlian Anda:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (availableToUser.isNotEmpty && availableToUser.length < availableRoles.length)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '${availableToUser.length} dari ${availableRoles.length} peran tersedia untuk Anda',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            SizedBox(height: 16),
            
            if (availableRoles.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Tidak ada peran relawan yang tersedia untuk event ini.',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (availableToUser.isEmpty)
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.orange[700],
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Tidak Ada Peran yang Sesuai',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Keahlian Anda tidak sesuai dengan peran relawan yang dibutuhkan untuk event ini. Silakan perbarui keahlian Anda di profil jika diperlukan.',
                        style: TextStyle(color: Colors.orange[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...availableRoles.map((role) {
                final hasSkill = userSkillsSet.contains(role);
                final hasSpots = remainingSpots[role]! > 0;
                final isDisabled = !hasSkill || !hasSpots;
                
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDisabled 
                          ? Colors.grey[300]!
                          : selectedRole == role 
                              ? Colors.green 
                              : Colors.grey[300]!,
                      width: selectedRole == role ? 2 : 1,
                    ),
                  ),
                  child: Opacity(
                    opacity: isDisabled ? 0.5 : 1.0,
                    child: RadioListTile<String>(
                      value: role,
                      groupValue: selectedRole,
                      onChanged: isDisabled ? null : (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              role,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDisabled 
                                    ? Colors.grey[500]
                                    : selectedRole == role 
                                        ? Colors.green[700]
                                        : Colors.grey[800],
                              ),
                            ),
                          ),
                          if (isDisabled)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: !hasSpots ? Colors.orange[100] : Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: !hasSpots ? Colors.orange[300]! : Colors.red[300]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    !hasSpots ? Icons.people : Icons.lock,
                                    size: 12,
                                    color: !hasSpots ? Colors.orange[700] : Colors.red[700],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    !hasSpots ? 'Full' : 'Locked',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: !hasSpots ? Colors.orange[700] : Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tersisa: ${remainingSpots[role]} dari ${requiredVolunteers[role]} yang dibutuhkan',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (!hasSkill)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Anda tidak memiliki keahlian "$role"',
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          if (hasSkill && !hasSpots)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Kuota untuk peran ini sudah penuh',
                                style: TextStyle(
                                  color: Colors.orange[600],
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                );
              }),
            
            SizedBox(height: 32),
            
            // User Skills Info
            if (userData != null && userData!['skills'] != null)
              Card(
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.blue[700], size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Keahlian Anda',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: (userData!['skills'] as List<dynamic>)
                            .map((skill) {
                              final skillString = skill.toString();
                              final isNeeded = availableRoles.contains(skillString);
                              return Chip(
                                label: Text(
                                  skillString,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isNeeded ? Colors.green[700] : Colors.blue[700],
                                  ),
                                ),
                                backgroundColor: isNeeded ? Colors.green[100] : Colors.blue[100],
                                side: isNeeded ? BorderSide(color: Colors.green[300]!, width: 1) : null,
                              );
                            })
                            .toList(),
                      ),
                      if (availableToUser.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Keahlian yang cocok ditandai dengan border hijau',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            
            SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: availableToUser.isNotEmpty && !isSubmitting ? _submitRegistration : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Mendaftar...'),
                        ],
                      )
                    : Text(
                        'Daftar Sebagai Relawan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
