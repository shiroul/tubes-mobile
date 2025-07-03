import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import '../../models/report.dart';
import '../../helpers/image_picker_helper.dart';
import '../../helpers/cloudinary_helper.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/custom_app_header.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  GeoPoint? _coordinates;
  String? _cityName;
  String? _provinceName;
  String? _locationError;
  File? _image;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  String? _jenisBencana;
  final _deskripsiController = TextEditingController();
  final _alamatController = TextEditingController();

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _locationError = null;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Izin lokasi ditolak.';
            _loading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Izin lokasi ditolak permanen.';
          _loading = false;
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
        _coordinates = geo;
        _cityName = city;
        _provinceName = province;
        _loading = false;
        _locationError = null;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Tidak dapat mengambil lokasi. Pastikan GPS aktif dan izin lokasi diberikan.';
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
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
      backgroundColor: Colors.grey[50],
      appBar: CustomAppHeader(
        title: 'Lapor Bencana',
        showProfileIcon: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Upload Card - TOP OF SCREEN
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.camera_alt, color: Colors.blue[600], size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Foto Lokasi Bencana',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () async {
                                final file = await ImagePickerHelper.pickImageWithSource(context);
                                if (file != null) setState(() => _image = file);
                              },
                              child: Container(
                                width: double.infinity,
                                height: _image == null ? 160 : 200,
                                decoration: BoxDecoration(
                                  color: _image == null ? Colors.grey[100] : null,
                                  border: Border.all(
                                    color: _image == null ? Colors.grey[300]! : Colors.blue[200]!,
                                    width: 2,
                                    style: _image == null ? BorderStyle.none : BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _image == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.add_a_photo,
                                              size: 32,
                                              color: Colors.blue[600],
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Tambah Foto',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Ketuk untuk mengambil/memilih foto',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.file(
                                              _image!,
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.edit, color: Colors.white, size: 20),
                                                onPressed: () async {
                                                  final file = await ImagePickerHelper.pickImageWithSource(context);
                                                  if (file != null) setState(() => _image = file);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Disaster Details Card - FORM FIELDS
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Detail Bencana',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _jenisBencana,
                              decoration: InputDecoration(
                                labelText: 'Jenis Bencana',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.warning_amber, color: Colors.orange[600]),
                              ),
                              items: [
                                'Banjir', 'Gempa Bumi', 'Kebakaran', 'Tanah Longsor', 'Angin Puting Beliung', 'Lainnya'
                              ].map((jenis) => DropdownMenuItem(
                                value: jenis, 
                                child: Text(jenis),
                              )).toList(),
                              onChanged: (val) => setState(() => _jenisBencana = val),
                              validator: (val) => val == null ? 'Pilih jenis bencana' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _deskripsiController,
                              decoration: InputDecoration(
                                labelText: 'Deskripsi Bencana',
                                hintText: 'Jelaskan kondisi bencana secara detail...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.description, color: Colors.blue[600]),
                              ),
                              maxLines: 4,
                              validator: (val) => val == null || val.isEmpty ? 'Deskripsi wajib diisi' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _alamatController,
                              decoration: InputDecoration(
                                labelText: 'Alamat Bencana',
                                hintText: 'Masukkan alamat lengkap lokasi bencana',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.location_on, color: Colors.green[600]),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Alamat wajib diisi' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Location Card - AT BOTTOM BEFORE SUBMIT
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.gps_fixed, color: Colors.green[600], size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Lokasi GPS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            if (_loading)
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      'Mengambil lokasi GPS...',
                                      style: TextStyle(color: Colors.blue[700]),
                                    ),
                                  ],
                                ),
                              ),
                            if (_locationError != null)
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.error, color: Colors.red[600], size: 20),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Error Lokasi',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _locationError!,
                                      style: TextStyle(color: Colors.red[600]),
                                    ),
                                    SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _getLocation,
                                        icon: Icon(Icons.refresh, size: 18),
                                        label: Text('Coba Lagi'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red[600],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_coordinates != null)
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Lokasi Berhasil Diambil',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.location_city, size: 16, color: Colors.grey[600]),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Lokasi: ${_cityName ?? '-'}, ${_provinceName ?? '-'}',
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.gps_fixed, size: 16, color: Colors.grey[600]),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Koordinat: ${_coordinates!.latitude.toStringAsFixed(6)}, ${_coordinates!.longitude.toStringAsFixed(6)}',
                                                  style: TextStyle(fontSize: 12),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          final url = 'https://www.google.com/maps/search/?api=1&query=${_coordinates!.latitude},${_coordinates!.longitude}';
                                          if (await canLaunchUrl(Uri.parse(url))) {
                                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.map, size: 18),
                                        label: Text('Lihat di Google Maps'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.blue[600],
                                          backgroundColor: Colors.blue[50],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Submit Button - INSIDE CONTAINER BELOW LOCATION
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_coordinates == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.error, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Tunggu sampai lokasi GPS berhasil diambil'),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            
                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Mengirim laporan...'),
                                  ],
                                ),
                              ),
                            );
                            
                            try {
                              String? imageUrl;
                              if (_image != null) {
                                imageUrl = await CloudinaryHelper.uploadImage(_image!);
                              }
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                // Close loading dialog
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('User tidak terautentikasi. Silakan login kembali.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              final reportDetails = _deskripsiController.text.trim();
                              final alamat = _alamatController.text.trim();
                              final combinedDetails = 'Alamat: $alamat\n\nDeskripsi: $reportDetails';
                              
                              final report = ReportModel(
                                id: '',
                                uid: user.uid,
                                type: _jenisBencana ?? '-',
                                details: combinedDetails,
                                coordinates: _coordinates!,
                                city: _cityName ?? '-',
                                province: _provinceName ?? '-',
                                media: imageUrl != null ? [imageUrl] : [],
                                timestamp: Timestamp.now(),
                              );
                              await FirebaseFirestore.instance.collection('reports').add(report.toMap());
                              
                              // Close loading dialog
                              Navigator.pop(context);
                              
                              // Navigate to confirmation screen or dashboard as fallback
                              try {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/confirmation_report',
                                  (route) => false,
                                );
                              } catch (navError) {
                                // Fallback to dashboard if confirmation route fails
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/dashboard',
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              // Close loading dialog
                              Navigator.pop(context);
                              
                              print('Error submitting report: $e'); // Debug log
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal mengirim laporan: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(Icons.send, size: 20),
                        label: Text(
                          'Kirim Laporan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }
}
