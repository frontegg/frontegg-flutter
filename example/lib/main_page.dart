import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';
import 'package:frontegg_flutter_example/login_page.dart';
import 'package:frontegg_flutter_example/user_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return Scaffold(
      body: Center(
        child: StreamBuilder<FronteggState>(
          stream: frontegg.stateChanged,
          builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
            if (snapshot.hasData) {
              final state = snapshot.data!;
              if (state.isAuthenticated && state.user != null) {
                return const UserPage();
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
