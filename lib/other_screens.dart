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
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc ut laoreet dictum, massa erat cursus enim, nec dictum sem urna at sapien. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Etiam euismod, urna eu tincidunt consectetur, nisi nisl aliquam enim, nec dictum sem urna at sapien. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vivamus euismod, urna eu tincidunt consectetur, nisi nisl aliquam enim, nec dictum sem urna at sapien. Etiam euismod, urna eu tincidunt consectetur, nisi nisl aliquam enim, nec dictum sem urna at sapien. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vivamus euismod, urna eu tincidunt consectetur, nisi nisl aliquam enim, nec dictum sem urna at sapien. Etiam euismod, urna eu tincidunt consectetur, nisi nisl aliquam enim, nec dictum sem urna at sapien. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vivamus euismod, urna eu tincidunt consectetur, nisi nisl aliquam enim, nec dictum sem urna at sapien. Etiam euismod, urna eu tincidunt consectetur, nisi nisl aliquam enim, nec dictum sem urna at sapien. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vivamus euismod, urna eu tincidunt consectetur, nisi nisl aliquam enim, nec dictum sem urna at sapien.',
                      textAlign: TextAlign.justify,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

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
              Icon(Icons.check, size: 100, color: Colors.green),
              SizedBox(height: 16),
              Text(
                'Registrasi Selesai',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('Anda telah berhasil melakukan registrasi akun.'),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Selesai'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
