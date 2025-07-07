import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../helpers/image_picker_helper.dart';
import '../../helpers/cloudinary_helper.dart';
import '../../services/services.dart';

class RegisterScreen extends StatefulWidget {
  final String? prefillEmail;
  final String? prefillName;
  final String? prefillPhone;
  
  const RegisterScreen({
    super.key, 
    this.prefillEmail, 
    this.prefillName, 
    this.prefillPhone
  });

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Basic info controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emergencyController = TextEditingController();
  
  // Skills data
  final List<String> skills = [
    'Medis',
    'Logistik',
    'Evakuasi',
    'Media',
    'Bantuan Umum',
  ];
  Set<String> selectedSkills = {};
  
  // Form keys
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  
  String? errorMessage;
  bool isLoading = false;
  File? _pickedImage;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefillEmail != null) emailController.text = widget.prefillEmail!;
    if (widget.prefillName != null) nameController.text = widget.prefillName!;
    if (widget.prefillPhone != null) phoneController.text = widget.prefillPhone!;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emergencyController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _isEmailOrPhoneExists(String email, String phone) async {
    try {
      final userData = await UserService.getUserByEmail(email);
      if (userData != null) return true;
      
      final phoneData = await UserService.getUserByPhone(phone);
      if (phoneData != null) return true;
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _registerWithEmail() async {
    setState(() { isLoading = true; });
    try {
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();
      
      if (password != confirmPassword) {
        setState(() { errorMessage = 'Password tidak cocok'; });
        return;
      }
      
      if (await _isEmailOrPhoneExists(email, phone)) {
        setState(() { errorMessage = 'Email atau No. HP sudah terdaftar.'; });
        return;
      }
      
      User? currentUser = AuthService.currentUser;
      if (currentUser == null) {
        currentUser = await AuthService.signUpWithEmailAndPassword(email, password);
      }
      
      // Create basic user profile
      if (currentUser != null) {
        await AuthService.createUserProfile(
          uid: currentUser.uid,
          name: nameController.text.trim(),
          email: email,
          phone: phone,
          emergencyContact: '', // Will be filled in next step
          skills: [], // Will be filled in next step
        );
      }
      
      setState(() { 
        errorMessage = null; 
        _currentPage = 1;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
    } catch (e) {
      setState(() { errorMessage = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _pickProfileImage() async {
    final file = await ImagePickerHelper.pickImageWithSource(context);
    if (file != null) {
      setState(() {
        _pickedImage = file;
        _uploadingImage = true;
      });
      
      try {
        final imageUrl = await CloudinaryHelper.uploadImage(file);
        final user = AuthService.currentUser;
        
        if (user != null && imageUrl != null) {
          await UserService.updateUserProfile(
            userId: user.uid,
            updates: {
              'profileImageUrl': imageUrl,
            },
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Foto profil berhasil diunggah!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengunggah foto profil.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah foto profil: $e')),
        );
      } finally {
        setState(() { _uploadingImage = false; });
      }
    }
  }

  Future<void> _finishRegistration() async {
    if (selectedSkills.isEmpty) {
      setState(() { errorMessage = 'Pilih minimal satu keahlian.'; });
      return;
    }
    if (emergencyController.text.trim().isEmpty) {
      setState(() { errorMessage = 'Nomor darurat wajib diisi.'; });
      return;
    }
    
    setState(() { isLoading = true; });
    
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        await UserService.updateUserProfile(
          userId: user.uid,
          updates: {
            'skills': selectedSkills.toList(),
            'emergencyContact': emergencyController.text.trim(),
          },
        );
      }
      
      setState(() { 
        errorMessage = null; 
        isLoading = false;
      });
      
      Navigator.pushNamed(context, '/briefing');
    } catch (e) {
      setState(() { 
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Dasar',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Nama wajib diisi' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Email wajib diisi' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'No. HP',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'No. HP wajib diisi' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) => value == null || value.length < 6 ? 'Password minimal 6 karakter' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
                if (value != passwordController.text) return 'Password tidak cocok';
                return null;
              },
            ),
            SizedBox(height: 24),
            if (errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () {
                  if (_formKey1.currentState!.validate()) {
                    _registerWithEmail();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Lanjutkan', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sudah punya akun? '),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signin'),
                  child: Text(
                    'Sign In di sini',
                    style: TextStyle(
                      color: Colors.red,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Keahlian & Profil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            
            // Profile image section
            Center(
              child: GestureDetector(
                onTap: _uploadingImage ? null : _pickProfileImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
                      child: _pickedImage == null ? Icon(Icons.add_a_photo, size: 40) : null,
                    ),
                    if (_uploadingImage)
                      CircularProgressIndicator(strokeWidth: 2),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Tap untuk menambah foto profil (opsional)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            SizedBox(height: 32),
            
            Text(
              'Pilih Keahlian Anda:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) => FilterChip(
                label: Text(
                  skill,
                  style: TextStyle(
                    color: selectedSkills.contains(skill) ? Colors.white : Colors.grey[700],
                    fontWeight: selectedSkills.contains(skill) ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: selectedSkills.contains(skill),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedSkills.add(skill);
                    } else {
                      selectedSkills.remove(skill);
                    }
                  });
                },
                selectedColor: Colors.blue,
                backgroundColor: Colors.grey[100],
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: selectedSkills.contains(skill) ? Colors.blue : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                showCheckmark: false,
              )).toList(),
            ),
            SizedBox(height: 24),
            
            TextFormField(
              controller: emergencyController,
              decoration: InputDecoration(
                labelText: 'Nomor Darurat',
                border: OutlineInputBorder(),
                helperText: 'Nomor yang bisa dihubungi dalam keadaan darurat',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Nomor darurat wajib diisi' : null,
            ),
            SizedBox(height: 24),
            
            if (errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              ),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() { _currentPage = 0; });
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300), 
                        curve: Curves.easeInOut
                      );
                    },
                    child: Text('Kembali'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _finishRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Selesai', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrasi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentPage >= 0 ? Colors.red : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentPage >= 1 ? Colors.red : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // Disable swipe navigation
              onPageChanged: (page) => setState(() { _currentPage = page; }),
              children: [
                _buildBasicInfoPage(),
                _buildSkillsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
