import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

/// Login page
///
/// This is a simple login page that allows the user to login with a username and password.
/// It also allows the user to login with a social provider.
/// It also allows the user to login with a passkey.
/// It also allows the user to login with a token.
///
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
            // StreamBuilder to listen to the state of the authentication
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
                        // Login with email and password
                        // loginHint is the email of the user (optional)
                        ElevatedButton(
                          key: const ValueKey("LoginButton"),
                          child: const Text("Login"),
                          onPressed: () async {
                            await frontegg.login();
                            debugPrint("Login Finished");
                          },
                        ),
                      ],
                    );
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
