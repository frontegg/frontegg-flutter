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
        // StreamBuilder to listen to the state of the authentication
        child: StreamBuilder<FronteggState>(
          stream: frontegg.stateChanged,
          builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
            if (snapshot.hasData) {
              final state = snapshot.data!;
              if (state.isAuthenticated && state.user != null) {
                // If the user is authenticated and the user is not null, show the user page
                return const UserPage();
              } else if (state.initializing) {
                // If the app is initializing, show a loading indicator
                return const CircularProgressIndicator();
              } else {
                // If the user is not authenticated, show the login page
                return const LoginPage();
              }
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
