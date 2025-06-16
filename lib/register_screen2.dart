import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen2 extends StatefulWidget {
  RegisterScreen2({super.key});

  @override
  _RegisterScreen2State createState() => _RegisterScreen2State();
}

class _RegisterScreen2State extends State<RegisterScreen2> {
  final List<String> skills = [
    'Medis',
    'Logistik',
    'Evakuasi',
    'Penyelamatan',
    'Dapur Umum',
  ];
  final Set<String> selectedSkills = {};
  String? errorMessage;

  Future<void> _saveSkillsAndContinue() async {
    if (selectedSkills.isEmpty) {
      setState(() { errorMessage = 'Pilih minimal satu keahlian.'; });
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'skills': selectedSkills.toList(),
      }, SetOptions(merge: true));
    }
    setState(() { errorMessage = null; });
    Navigator.pushNamed(context, '/briefing');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Keahlian Relawan')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih keahlian yang Anda miliki:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: skills.map((skill) {
                final isSelected = selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedSkills.add(skill);
                      } else {
                        selectedSkills.remove(skill);
                      }
                    });
                  },
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _saveSkillsAndContinue,
                child: Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
