import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import 'e2e_test_mode.dart';
import 'login_page.dart';
import 'no_connection_page.dart';
import 'user_page.dart';

/// Main page
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: StreamBuilder<FronteggState>(
        stream: frontegg.stateChanged,
        builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
          late final Widget main;
          if (snapshot.hasData) {
            final state = snapshot.data!;
            // Match Swift `MyApp`: global loader while `isLoading` — do not show
            // NoConnection or Login until loading finishes, or cold start can briefly
            // show NoConnection (isOfflineMode) without LoginPageRoot and break E2E.
            if (state.initializing || state.isLoading) {
              main = const Center(child: CircularProgressIndicator());
            } else if (state.isAuthenticated && state.user != null) {
              main = Semantics(
                label: 'UserPageRoot',
                child: const UserPage(),
              );
            } else if (state.isAuthenticated && state.user == null) {
              main = Semantics(
                label: 'AuthenticatedOfflineRoot',
                child: Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Authenticated (offline)',
                            style: textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'User details will load when connectivity is restored.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF7A7C81),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (state.isOfflineMode) {
              main = const NoConnectionPage();
            } else {
              main = Semantics(
                label: 'LoginPageRoot',
                child: const LoginPage(),
              );
            }
          } else {
            main = const Center(child: SizedBox());
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Center(child: main),
              if (E2ETestMode.isEnabled &&
                  E2ETestMode.forceNetworkPathOffline &&
                  snapshot.hasData)
                Positioned(
                  left: 0,
                  top: 0,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0,
                      child: Semantics(
                        label: snapshot.data!.isAuthenticated
                            ? 'AuthenticatedOfflineModeEnabled'
                            : 'UnauthenticatedOfflineModeEnabled',
                        child: const Text(
                          '0',
                          style: TextStyle(fontSize: 1, height: 0.01),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
