import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;
  final String role;
  final List<String> skills;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    required this.eventData,
    required this.role,
    required this.skills,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Map<String, int> requirements = {};
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.eventData['volunteerRequirements'] != null) {
      requirements = Map<String, int>.from(widget.eventData['volunteerRequirements']);
    }
  }

  Future<void> _setRequirements() async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
        'volunteerRequirements': requirements,
      });
      setState(() {});
    } catch (e) {
      setState(() => error = 'Gagal menyimpan kebutuhan relawan.');
    }
    setState(() => isLoading = false);
  }

  Future<void> _joinAsVolunteer(String category) async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');
      await FirebaseFirestore.instance.collection('participations').add({
        'userId': user.uid,
        'eventId': widget.eventId,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {});
    } catch (e) {
      setState(() => error = 'Gagal mendaftar sebagai relawan.');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final requirementsSet = widget.eventData['volunteerRequirements'] != null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventData['title'] ?? 'Detail Bencana')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  Text(widget.eventData['description'] ?? '-', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  Text('Lokasi: ${widget.eventData['location'] ?? '-'}'),
                  SizedBox(height: 8),
                  Text('Tanggal: ${widget.eventData['date'] ?? '-'}'),
                  SizedBox(height: 16),
                  if (error != null) ...[
                    Text(error!, style: TextStyle(color: Colors.red)),
                    SizedBox(height: 8),
                  ],
                  if (widget.role == 'admin' && !requirementsSet) ...[
                    Text('Set Kebutuhan Relawan:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...widget.skills.map((skill) => Row(
                          children: [
                            Expanded(child: Text(skill)),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                initialValue: requirements[skill]?.toString() ?? '',
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: 'Jumlah'),
                                onChanged: (val) {
                                  setState(() {
                                    final n = int.tryParse(val);
                                    if (n != null && n > 0) {
                                      requirements[skill] = n;
                                    } else {
                                      requirements.remove(skill);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        )),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: requirements.isNotEmpty ? _setRequirements : null,
                      child: Text('Simpan Kebutuhan'),
                    ),
                  ] else if (widget.role == 'relawan' && !requirementsSet) ...[
                    Text('Kebutuhan relawan belum ditentukan admin.'),
                  ] else if (widget.role == 'relawan' && requirementsSet) ...[
                    Text('Pilih kategori untuk bergabung:'),
                    ...requirements.keys.map((cat) => ListTile(
                          title: Text(cat),
                          trailing: ElevatedButton(
                            onPressed: () => _joinAsVolunteer(cat),
                            child: Text('Gabung'),
                          ),
                        )),
                  ] else if (widget.role == 'admin' && requirementsSet) ...[
                    Text('Kebutuhan Relawan:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...requirements.entries.map((e) => Text('${e.key}: ${e.value} orang')),
                  ],
                ],
              ),
            ),
    );
  }
}
