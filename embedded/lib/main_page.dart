import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import 'login_page.dart';
import 'user_page.dart';

/// Main page
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return Scaffold(
      body: Center(
        child: StreamBuilder<FronteggState>(
          stream: frontegg.stateChanged,
          builder:
              (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
            if (snapshot.hasData) {
              final state = snapshot.data!;
              if (state.isAuthenticated && state.user != null) {
                return Semantics(
                  label: 'UserPageRoot',
                  child: const UserPage(),
                );
              } else if (state.initializing) {
                return const CircularProgressIndicator();
              } else {
                return Semantics(
                  label: 'LoginPageRoot',
                  child: const LoginPage(),
                );
              }
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
