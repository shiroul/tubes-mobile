import 'package:flutter/material.dart';

class BriefingScreen extends StatefulWidget {
  const BriefingScreen({super.key});

  @override
  State<BriefingScreen> createState() => _BriefingScreenState();
}

class _BriefingScreenState extends State<BriefingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
        setState(() {
          _isAtBottom = true;
        });
      } else {
        setState(() {
          _isAtBottom = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Briefing')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Icon(Icons.description, size: 100, color: Colors.blue),
                    SizedBox(height: 20),
                    Text(
                      'Hal - hal yang harus dilakukan relawan',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sebagai relawan LINA, Anda berperan penting dalam membantu korban bencana. Berikut adalah hal-hal yang perlu diperhatikan:\n\n'
                      '1. Keselamatan Diri dan Tim\n'
                      '• Selalu utamakan keselamatan diri dan tim\n'
                      '• Gunakan APD (Alat Pelindung Diri) yang sesuai\n'
                      '• Ikuti instruksi koordinator lapangan\n\n'
                      '2. Komunikasi\n'
                      '• Laporkan situasi secara berkala melalui aplikasi\n'
                      '• Jaga komunikasi dengan tim koordinasi\n'
                      '• Update status ketersediaan Anda\n\n'
                      '3. Bantuan yang Diberikan\n'
                      '• Sesuaikan bantuan dengan keahlian Anda\n'
                      '• Dokumentasikan aktivitas yang dilakukan\n'
                      '• Hormati privasi dan martabat korban\n\n'
                      '4. Koordinasi\n'
                      '• Hadiri briefing sebelum penugasan\n'
                      '• Ikuti protokol dan SOP yang berlaku\n'
                      '• Laporkan situasi darurat dengan segera\n\n'
                      'Dengan mematuhi panduan ini, kita dapat memberikan bantuan yang efektif dan aman bagi semua pihak.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isAtBottom
                  ? () => Navigator.pushNamed(context, '/confirmation')
                  : null,
              child: Text('Mengerti'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAtBottom ? Colors.red : Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
