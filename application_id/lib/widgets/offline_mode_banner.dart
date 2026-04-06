import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OfflineModeBanner extends StatelessWidget {
  const OfflineModeBanner({super.key, required this.visible});

  final bool visible;

  static const _redForeground = Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Offline Mode',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _redForeground,
          ),
        ),
      ),
    );
  }
}
