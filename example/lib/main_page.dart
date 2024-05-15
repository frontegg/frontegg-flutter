import 'package:flutter/material.dart';
import 'package:frontegg/frontegg.dart';
import 'package:frontegg/models/frontegg_state.dart';
import 'package:frontegg_flutter_example/user_page.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.read<FronteggFlutter>();
    return Scaffold(
      body: Center(
        child: StreamBuilder<FronteggState>(
          stream: frontegg.onStateChanged,
          builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
            if (snapshot.hasData) {
              final state = snapshot.data!;
              print("STATE ${state.isAuthenticated}");
              frontegg.getConstants().then((value) {
                print("Constants: ${value.toMap()}");
              });
              if (state.isLoading) {
                return const CircularProgressIndicator();
              } else if (state.isAuthenticated && state.user != null) {
                return UserPage(
                  user: state.user!,
                );
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
