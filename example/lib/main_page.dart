import 'package:flutter/material.dart';
import 'package:frontegg/models/frontegg_state.dart';
import 'package:frontegg/utils.dart';
import 'package:frontegg_flutter_example/user_page.dart';

import 'login_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return Scaffold(
      body: Center(
        child: StreamBuilder<FronteggState>(
          stream: frontegg.onStateChanged,
          builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
            if (snapshot.hasData) {
              final state = snapshot.data!;
              if (state.isAuthenticated && state.user != null) {
                return UserPage(
                  user: state.user!,
                );
              } else if (state.initializing) {
                return const CircularProgressIndicator();
              } else {
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
