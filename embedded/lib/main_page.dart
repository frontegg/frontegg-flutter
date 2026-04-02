import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import 'e2e_test_mode.dart';
import 'login_page.dart';
import 'user_page.dart';

/// Main page
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return Scaffold(
      body: StreamBuilder<FronteggState>(
        stream: frontegg.stateChanged,
        builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
          late final Widget main;
          if (snapshot.hasData) {
            final state = snapshot.data!;
            if (state.isAuthenticated && state.user != null) {
              main = Semantics(
                label: 'UserPageRoot',
                child: const UserPage(),
              );
            } else if (state.initializing) {
              main = const Center(child: CircularProgressIndicator());
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
