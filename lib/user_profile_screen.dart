import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isEditingName = false;
  final nameController = TextEditingController();
  bool notificationsEnabled = true;
  final List<String> allSkills = [
    'Medis',
    'Logistik',
    'Evakuasi',
    'Penyelamatan',
    'Dapur Umum',
  ];
  Set<String> selectedSkills = {};

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profil')),
        body: Center(child: Text('Tidak ada data user.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Data user tidak ditemukan.'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          nameController.text = data['name'] ?? '';
          selectedSkills = Set<String>.from((data['skills'] as List?)?.cast<String>() ?? []);
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  child: Icon(Icons.person, size: 48),
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.person),
                title: isEditingName
                    ? TextField(
                        controller: nameController,
                        autofocus: true,
                        onSubmitted: (value) async {
                          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'name': value.trim()});
                          setState(() => isEditingName = false);
                        },
                      )
                    : Text(data['name'] ?? '-', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Nama'),
                trailing: IconButton(
                  icon: Icon(isEditingName ? Icons.check : Icons.edit),
                  onPressed: () async {
                    if (isEditingName) {
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'name': nameController.text.trim()});
                    }
                    setState(() => isEditingName = !isEditingName);
                  },
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.email),
                title: Text(data['email'] ?? '-'),
                subtitle: Text('Email'),
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text(data['phone'] ?? '-'),
                subtitle: Text('No. HP'),
              ),
              Divider(),
              Text('Keahlian', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: allSkills.map((skill) {
                  final isSelected = selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: isSelected,
                    onSelected: (selected) async {
                      setState(() {
                        if (selected) {
                          selectedSkills.add(skill);
                        } else {
                          selectedSkills.remove(skill);
                        }
                      });
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                        'skills': selectedSkills.toList(),
                      });
                    },
                  );
                }).toList(),
              ),
              Divider(),
              SwitchListTile(
                value: notificationsEnabled,
                onChanged: (val) => setState(() => notificationsEnabled = val),
                title: Text('Notifikasi'),
                secondary: Icon(Icons.notifications),
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Ganti Password'),
                onTap: () {
                  // TODO: Implement change password
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fitur ganti password coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
