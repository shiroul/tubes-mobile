import 'package:flutter/material.dart';

class LinaLogo extends StatelessWidget {
  final double? fontSize;
  final double? subtitleFontSize;
  final Color? titleColor;
  final Color? subtitleColor;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool showSubtitle;
  final double? letterSpacing;
  final bool showHeart;
  final double? heartSize;
  final bool horizontal; // New property for horizontal layout

  const LinaLogo({
    super.key,
    this.fontSize,
    this.subtitleFontSize,
    this.titleColor,
    this.subtitleColor,
    this.padding,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.showSubtitle = true,
    this.letterSpacing,
    this.showHeart = true,
    this.heartSize,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultHeartSize = heartSize ?? (fontSize ?? 24) * 1.2;
    
    if (horizontal) {
      // Horizontal layout: heart on left, text on right
      return Container(
        padding: padding ?? EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showHeart) ...[
              Container(
                width: defaultHeartSize,
                height: defaultHeartSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'lib/src/heart.png',
                    width: defaultHeartSize,
                    height: defaultHeartSize,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red[600],
                          size: defaultHeartSize * 0.6,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 16),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LINA',
                  style: TextStyle(
                    fontSize: fontSize ?? 24,
                    fontWeight: FontWeight.bold,
                    color: titleColor ?? Colors.blue[800],
                  ),
                ),
                if (showSubtitle)
                  Text(
                    'PEDULI BENCANA',
                    style: TextStyle(
                      fontSize: subtitleFontSize ?? 12,
                      color: subtitleColor ?? Colors.grey[600],
                      letterSpacing: letterSpacing ?? 1.5,
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Vertical layout: heart on top, text below
      return Container(
        padding: padding ?? EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            if (showHeart) ...[
              Container(
                width: defaultHeartSize,
                height: defaultHeartSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'lib/src/heart.png',
                    width: defaultHeartSize,
                    height: defaultHeartSize,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red[600],
                          size: defaultHeartSize * 0.6,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
            Text(
              'LINA',
              style: TextStyle(
                fontSize: fontSize ?? 24,
                fontWeight: FontWeight.bold,
                color: titleColor ?? Colors.blue[800],
              ),
            ),
            if (showSubtitle)
              Text(
                'PEDULI BENCANA',
                style: TextStyle(
                  fontSize: subtitleFontSize ?? 12,
                  color: subtitleColor ?? Colors.grey[600],
                  letterSpacing: letterSpacing ?? 1.5,
                ),
              ),
          ],
        ),
      );
    }
  }
}
