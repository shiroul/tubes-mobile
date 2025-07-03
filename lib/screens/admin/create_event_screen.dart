import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../models/disaster_event.dart';
import '../../helpers/cloudinary_helper.dart';
import '../../helpers/image_picker_helper.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/custom_app_header.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String type = '', details = '', city = '', province = '';
  GeoPoint? coordinates;
  bool isSubmitting = false;
  String? locationError;
  File? _image;
  String? cityName;
  String? provinceName;
  String severityLevel = 'sedang'; // NEW: default value

  final List<String> categories = [
    'Medis',
    'Logistik',
    'Evakuasi',
    'Media',
    'Bantuan Umum',
  ];
  List<String> selectedCategories = [];
  Map<String, int> volunteerCounts = {};

  Future<void> getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            locationError = 'Izin lokasi ditolak.';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          locationError = 'Izin lokasi ditolak permanen.';
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      GeoPoint geo = GeoPoint(pos.latitude, pos.longitude);
      String? city, province;
      try {
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        for (final place in placemarks) {
          if ((place.locality != null && place.locality!.isNotEmpty) && (place.administrativeArea != null && place.administrativeArea!.isNotEmpty)) {
            city = place.locality;
            province = place.administrativeArea;
            break;
          }
        }
        if ((city == null || city.isEmpty) && placemarks.isNotEmpty) {
          city = placemarks.first.subAdministrativeArea ?? '';
        }
        if ((province == null || province.isEmpty) && placemarks.isNotEmpty) {
          province = placemarks.first.administrativeArea ?? '';
        }
      } catch (e) {}
      setState(() {
        coordinates = geo;
        cityName = city;
        provinceName = province;
        locationError = null;
      });
    } catch (e) {
      setState(() {
        locationError = 'Tidak dapat mengambil lokasi. Pastikan GPS aktif dan izin lokasi diberikan.';
      });
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate() || coordinates == null) return;
    setState(() => isSubmitting = true);
    final String cityFinal = (cityName != null && cityName!.isNotEmpty) ? cityName! : '-';
    final String provinceFinal = (provinceName != null && provinceName!.isNotEmpty) ? provinceName! : '-';
    String? imageUrl;
    if (_image != null) {
      imageUrl = await CloudinaryHelper.uploadImage(_image!);
    }
    final event = DisasterEvent(
      type: type,
      details: details,
      coordinates: coordinates!,
      city: cityFinal,
      province: provinceFinal,
      requiredVolunteers: Map<String, int>.from(volunteerCounts),
      severityLevel: severityLevel,
      status: 'active',
      timestamp: Timestamp.now(), // Set timestamp on creation
    );
    final eventRef = await FirebaseFirestore.instance.collection('events').add(event.toMap());
    if (imageUrl != null) {
      await eventRef.update({'media': [imageUrl]});
    }
    setState(() => isSubmitting = false);
    
    // Navigate to confirmation screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/confirmation_event',
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppHeader(
        title: 'Buat Event Bencana',
        showProfileIcon: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            GestureDetector(
              onTap: () async {
                final file = await ImagePickerHelper.pickImageWithSource(context);
                if (file != null) setState(() => _image = file);
              },
              child: _image == null
                  ? Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                            SizedBox(height: 8),
                            Text('Upload Foto Lokasi', style: TextStyle(color: Colors.grey[600]))
                          ],
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_image!, width: double.infinity, height: 160, fit: BoxFit.cover),
                    ),
            ),
            SizedBox(height: 20),
            TextFormField(decoration: InputDecoration(labelText: 'Tipe Bencana'), onChanged: (v) => type = v, validator: (v) => v!.isEmpty ? 'Wajib' : null),
            TextFormField(decoration: InputDecoration(labelText: 'Detail Bencana'), onChanged: (v) => details = v, validator: (v) => v!.isEmpty ? 'Wajib' : null),
            SizedBox(height: 10),
            Text('Kategori & Jumlah Relawan Dibutuhkan', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: categories.map((cat) => FilterChip(
                label: Text(cat),
                selected: selectedCategories.contains(cat),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      selectedCategories.add(cat);
                    } else {
                      selectedCategories.remove(cat);
                      volunteerCounts.remove(cat);
                    }
                  });
                },
              )).toList(),
            ),
            ...selectedCategories.map((cat) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(child: Text(cat)),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Jumlah'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        setState(() {
                          volunteerCounts[cat] = int.tryParse(v) ?? 0;
                        });
                      },
                      validator: (v) {
                        if (selectedCategories.contains(cat) && (v == null || v.isEmpty || int.tryParse(v) == null || int.parse(v) <= 0)) {
                          return 'Isi jumlah';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            )),
            SizedBox(height: 20),
            // NEW: Severity Level Dropdown
            Row(
              children: [
                Text('Tingkat Keparahan:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                DropdownButton<String>(
                  value: severityLevel,
                  items: [
                    DropdownMenuItem(value: 'parah', child: Text('Parah')),
                    DropdownMenuItem(value: 'sedang', child: Text('Sedang')),
                    DropdownMenuItem(value: 'ringan', child: Text('Ringan')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => severityLevel = val);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            locationError != null
              ? Text(locationError!, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
              : coordinates == null
                ? Text('Mengambil lokasi...')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lokasi: ${cityName ?? '-'}, ${provinceName ?? '-'}'),
                      Text('Koordinat: ${coordinates!.latitude}, ${coordinates!.longitude}'),
                    ],
                  ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: isSubmitting ? null : submit, child: Text('Buat Event')),
          ]),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }
}
