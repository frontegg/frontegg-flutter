import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import '../theme.dart';

class FronteggAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FronteggAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return AppBar(
      elevation: 5,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: Row(
          children: [
            Image.asset(
              'assets/frontegg-logo.png',
              height: 24,
            ),
            const SizedBox(width: 16),
            Image.asset(
              'assets/flutter-icon.png',
              height: 24,
              width: 24,
            ),
          ],
        ),
      ),
      leadingWidth: 200,
      actions: [
        StreamBuilder(
          stream: frontegg.stateChanged,
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            }
            final state = snapshot.data!;
            if (state.isAuthenticated) {
              return Padding(
                padding: const EdgeInsets.only(right: 24),
                child: ElevatedButton(
                  onPressed: () {
                    frontegg.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
                    backgroundColor: backgroundColor,
                    foregroundColor: textColor,
                    maximumSize: const Size(120, 32),
                    minimumSize: const Size(40, 32),
                  ),
                  child: const Text("Logout"),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
