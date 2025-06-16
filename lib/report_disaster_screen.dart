import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportDisasterScreen extends StatefulWidget {
  const ReportDisasterScreen({super.key});

  @override
  State<ReportDisasterScreen> createState() => _ReportDisasterScreenState();
}

class _ReportDisasterScreenState extends State<ReportDisasterScreen> {
  Position? _position;
  bool _loading = false;
  String? _error;
  final _formKey = GlobalKey<FormState>();
  String? _jenisBencana;
  final _deskripsiController = TextEditingController();
  final _alamatController = TextEditingController();

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Izin lokasi ditolak.';
            _loading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Izin lokasi ditolak permanen.';
          _loading = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _position = pos;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal mendapatkan lokasi.';
        _loading = false;
      });
    }
  }

  Future<void> _openInMaps() async {
    if (_position == null) return;
    final url = 'https://www.google.com/maps/search/?api=1&query=${_position!.latitude},${_position!.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
      );
    }
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Laporkan Bencana')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _jenisBencana,
                decoration: InputDecoration(labelText: 'Jenis Bencana'),
                items: [
                  'Banjir', 'Gempa Bumi', 'Kebakaran', 'Tanah Longsor', 'Angin Puting Beliung', 'Lainnya'
                ].map((jenis) => DropdownMenuItem(value: jenis, child: Text(jenis))).toList(),
                onChanged: (val) => setState(() => _jenisBencana = val),
                validator: (val) => val == null ? 'Pilih jenis bencana' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(labelText: 'Deskripsi Bencana'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat Bencana'),
                validator: (val) => val == null || val.isEmpty ? 'Alamat wajib diisi' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loading ? null : _getLocation,
                icon: Icon(Icons.my_location),
                label: Text('Ambil Lokasi Saya'),
              ),
              if (_loading) ...[
                SizedBox(height: 16),
                Center(child: CircularProgressIndicator()),
              ],
              if (_error != null) ...[
                SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Colors.red)),
              ],
              if (_position != null) ...[
                SizedBox(height: 8),
                Text('Lokasi Anda:'),
                Text('Lat: ${_position!.latitude}, Lng: ${_position!.longitude}'),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _openInMaps,
                  icon: Icon(Icons.map),
                  label: Text('Buka di Maps'),
                ),
              ],
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_position == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ambil lokasi terlebih dahulu.')),
                      );
                      return;
                    }
                    // Save report to Firestore
                    await FirebaseFirestore.instance.collection('reports').add({
                      'jenisBencana': _jenisBencana,
                      'deskripsi': _deskripsiController.text.trim(),
                      'alamat': _alamatController.text.trim(),
                      'latitude': _position!.latitude,
                      'longitude': _position!.longitude,
                      'timestamp': FieldValue.serverTimestamp(),
                      'userId': FirebaseAuth.instance.currentUser?.uid,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Laporan berhasil dikirim!')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
