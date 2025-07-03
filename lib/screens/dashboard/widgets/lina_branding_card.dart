import 'package:flutter/material.dart';
import '../../../widgets/lina_logo.dart';

/// A card displaying the LINA branding with logo and tagline
class LinaBrandingCard extends StatelessWidget {
  const LinaBrandingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const LinaLogo(
        fontSize: 32,
        subtitleFontSize: 12,
        heartSize: 50,
        padding: EdgeInsets.zero,
        horizontal: true,
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
