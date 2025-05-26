import 'package:flutter/material.dart';

import '../utils.dart';

class Footer extends StatelessWidget {
  final bool showSignUpBanner;

  const Footer({
    super.key,
    this.showSignUpBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSignUpBanner)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: double.infinity,
                  ),
                  Text(
                    'This sample uses Frontegg\'s default credentials.\nSign up to use your own configurations',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      launchUrl('https://frontegg-prod.frontegg.com/oauth/account/sign-up');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Sign-up',
                      style: TextStyle(
                        color: Color(0xFF4461F2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (showSignUpBanner) const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  launchUrl(
                    'https://flutter-guide.frontegg.com/#/',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(64, 32),
                  maximumSize: const Size(120, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.open_in_new,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Visit Docs',
                      style: textTheme.bodySmall?.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    launchUrl(
                      'https://github.com/frontegg/frontegg-flutter',
                    );
                  },
                  icon: Image.asset(
                    'assets/github-icon.png',
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    launchUrl(
                      'https://slack.com/oauth/authorize?client_id=1234567890.1234567890&scope=identity.basic,identity.email,identity.team,identity.avatar',
                    );
                  },
                  icon: Image.asset(
                    'assets/slack-icon.png',
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
