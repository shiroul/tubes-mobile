import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'register_screen1.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isLoading = false;

  Future<void> _signInWithEmail() async {
    setState(() { isLoading = true; });
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      setState(() { errorMessage = null; });
      Navigator.pushNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() { errorMessage = e.message ?? 'Email atau password salah.'; });
    } catch (e) {
      setState(() { errorMessage = 'Terjadi kesalahan. Coba lagi.'; });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { isLoading = true; });
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Force account picker every time
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() { isLoading = false; });
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // New user, redirect to RegisterScreen1 with prefilled info
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterScreen1(
              prefillEmail: user?.email ?? '',
              prefillName: user?.displayName ?? '',
              prefillPhone: user?.phoneNumber ?? '',
            ),
          ),
        );
      } else {
        setState(() { errorMessage = null; isLoading = false; });
        Navigator.pushNamed(context, '/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      setState(() { errorMessage = e.message ?? 'Gagal login dengan Google.'; isLoading = false; });
    } catch (e) {
      setState(() { errorMessage = 'Terjadi kesalahan Google Sign-In.'; isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                    SizedBox(height: 24),
                    if (errorMessage != null)
                      Text(errorMessage!, style: TextStyle(color: Colors.red)),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _signInWithEmail();
                        } else {
                          setState(() { errorMessage = 'Mohon lengkapi semua data dengan benar.'; });
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Sign In'),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: Icon(Icons.login),
                      label: Text('Sign In with Google'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum punya akun? '),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register1'),
                          child: Text(
                            'Registrasi di sini',
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
