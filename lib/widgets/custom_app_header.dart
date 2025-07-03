import 'package:flutter/material.dart';
import 'lina_logo.dart';

class CustomAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogo;
  final bool showProfileIcon;
  final VoidCallback? onProfileTap;
  final List<Widget>? actions;

  const CustomAppHeader({
    super.key,
    required this.title,
    this.showLogo = true, // Default to true, will be overridden for Dashboard
    this.showProfileIcon = true,
    this.onProfileTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // Special case: if title is "Dashboard", show text instead of logo
    final isDashboard = title == 'Dashboard';
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (showLogo && !isDashboard) ...[
            LinaLogo(
              fontSize: 18,
              subtitleFontSize: 8,
              padding: EdgeInsets.symmetric(vertical: 4),
              showSubtitle: true,
              showHeart: true,
              heartSize: 24,
              letterSpacing: 1.0,
              horizontal: true,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          ] else ...[
            Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      actions: actions ?? [
        if (showProfileIcon)
          Container(
            margin: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: IconButton(
                icon: Icon(Icons.person, color: Colors.grey[700]),
                onPressed: onProfileTap ?? () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
