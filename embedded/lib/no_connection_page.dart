import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import 'e2e_test_mode.dart';
import 'widgets/frontegg_app_bar.dart';

/// Shown when the native SDK reports offline / no-connection for unauthenticated users.
/// Parity with Swift `NoConnectionPage` (identifiers: NoConnectionPageRoot, RetryConnectionButton).
class NoConnectionPage extends StatelessWidget {
  const NoConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'NoConnectionPageRoot',
      child: Scaffold(
        appBar: const FronteggAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 88,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 20),
                Text(
                  'No Connection',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "It looks like you're offline.\nPlease check your internet connection and try again.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Semantics(
                  label: 'RetryConnectionButton',
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        frontegg.refreshToken();
                      },
                      child: const Text('Retry'),
                    ),
                  ),
                ),
                if (E2ETestMode.isEnabled) ...[
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: 0,
                    child: Semantics(
                      label: 'NoConnectionPageSeenEver',
                      child: const Text('1'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
