import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String buttonText;
  final String routeName;

  const ConfirmationScreen({
    super.key,
    this.title = 'Berhasil',
    this.message = 'Operasi berhasil dilakukan.',
    this.icon = Icons.check_circle,
    this.iconColor = Colors.green,
    this.buttonText = 'Selesai',
    this.routeName = '/dashboard',
  });

  // Factory constructors for different confirmation types
  factory ConfirmationScreen.registration() {
    return ConfirmationScreen(
      title: 'Registrasi Selesai',
      message: 'Anda telah berhasil melakukan registrasi akun.',
      icon: Icons.check_circle,
      iconColor: Colors.green,
      buttonText: 'Selesai',
      routeName: '/dashboard',
    );
  }

  factory ConfirmationScreen.reportSubmitted() {
    return ConfirmationScreen(
      title: 'Laporan Terkirim',
      message: 'Laporan bencana Anda telah berhasil dikirim dan akan segera ditinjau oleh admin.',
      icon: Icons.send_outlined,
      iconColor: Colors.blue,
      buttonText: 'Bencana Aktif',
      routeName: '/all-events',
    );
  }

  factory ConfirmationScreen.eventCreated() {
    return ConfirmationScreen(
      title: 'Event Dibuat',
      message: 'Bencana aktif telah berhasil dibuat dan dipublikasikan.',
      icon: Icons.event_available,
      iconColor: Colors.orange,
      buttonText: 'Bencana Aktif',
      routeName: '/all-events',
    );
  }

  factory ConfirmationScreen.disasterResolved() {
    return ConfirmationScreen(
      title: 'Bencana Teratasi',
      message: 'Bencana telah berhasil ditandai sebagai teratasi. Terima kasih atas kerja keras tim dalam menangani situasi ini.',
      icon: Icons.verified,
      iconColor: Colors.green,
      buttonText: 'Bencana Aktif',
      routeName: '/all-events',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 80,
                  color: iconColor,
                ),
              ),
              SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    routeName,
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/dashboard',
                  (route) => false,
                ),
                child: Text(
                  'Kembali ke Dashboard',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
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
