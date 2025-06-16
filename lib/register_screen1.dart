import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen1 extends StatefulWidget {
  final String? prefillEmail;
  final String? prefillName;
  final String? prefillPhone;
  const RegisterScreen1({super.key, this.prefillEmail, this.prefillName, this.prefillPhone});

  @override
  _RegisterScreen1State createState() => _RegisterScreen1State();
}

class _RegisterScreen1State extends State<RegisterScreen1> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefillEmail != null) emailController.text = widget.prefillEmail!;
    if (widget.prefillName != null) nameController.text = widget.prefillName!;
    if (widget.prefillPhone != null) phoneController.text = widget.prefillPhone!;
  }

  Future<bool> _isEmailOrPhoneExists(String email, String phone) async {
    final emailQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (emailQuery.docs.isNotEmpty) return true;
    final phoneQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();
    return phoneQuery.docs.isNotEmpty;
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
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        currentUser = userCredential.user;
      }
      await FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).set({
        'name': nameController.text.trim(),
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'provider': currentUser?.providerData.first.providerId ?? 'email',
        'role': 'relawan', // Always set role to relawan
      }, SetOptions(merge: true));
      setState(() { errorMessage = null; });
      Navigator.pushNamed(context, '/register2');
    } on FirebaseAuthException catch (e) {
      setState(() { errorMessage = e.message; });
    } catch (e) {
      setState(() { errorMessage = 'Terjadi kesalahan. Coba lagi.'; });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _registerWithGoogle() async {
    setState(() { isLoading = true; });
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      final email = user?.email ?? emailController.text.trim();
      final phone = user?.phoneNumber ?? phoneController.text.trim();
      if (await _isEmailOrPhoneExists(email, phone)) {
        setState(() { errorMessage = 'Email atau No. HP sudah terdaftar.'; });
        return;
      }
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'name': user?.displayName ?? nameController.text.trim(),
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'provider': 'google',
        'role': 'relawan', // Always set role to relawan
      });
      setState(() { errorMessage = null; });
      Navigator.pushNamed(context, '/register2');
    } on FirebaseAuthException catch (e) {
      setState(() { errorMessage = e.message ?? 'Gagal registrasi dengan Google.'; });
    } catch (e) {
      setState(() { errorMessage = 'Terjadi kesalahan Google Sign-In.'; });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrasi Akun')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Nama'),
                    validator: (value) => value == null || value.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty ? 'Email wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'No. HP'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty ? 'No. HP wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value == null || value.isEmpty ? 'Password wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Konfirmasi Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
                      if (value != passwordController.text) return 'Password tidak cocok';
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  if (errorMessage != null)
                    Text(errorMessage!, style: TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _registerWithEmail();
                      } else {
                        setState(() { errorMessage = 'Mohon lengkapi semua data dengan benar.'; });
                      }
                    },
                    child: Text('Sign Up'),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _registerWithGoogle,
                    icon: Icon(Icons.login),
                    label: Text('Sign Up with Google'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
