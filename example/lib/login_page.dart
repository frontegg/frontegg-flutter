import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Frontegg Example App"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'Not Authenticated',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: StreamBuilder<FronteggState>(
              stream: frontegg.stateChanged,
              builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
                if (snapshot.hasData) {
                  final state = snapshot.data!;
                  if (state.isLoading) {
                    return const CircularProgressIndicator();
                  } else if (!state.initializing && !state.isAuthenticated) {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              child: const Text("Login"),
                              onPressed: () async {
                                await frontegg.login();
                                print("Login Finished");
                              }),
                          ElevatedButton(
                            child: const Text("Login with Google"),
                            onPressed: () {
                              frontegg.directLoginAction("social-login", "google");
                            },
                          )
                        ]);
                  }
                }
                return const SizedBox();
              },
            ),
          )
        ],
      ),
    );
  }
}
