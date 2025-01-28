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
                          key: const ValueKey("LoginButton"),
                          child: const Text("Login"),
                          onPressed: () async {
                            await frontegg.login();
                            debugPrint("Login Finished");
                          },
                        ),
                        ElevatedButton(
                          child: const Text("Login with Google"),
                          onPressed: () {
                            frontegg.directLoginAction("social-login", "google");
                          },
                        ),
                        ElevatedButton(
                          child: const Text("Request Authorized With Tokens"),
                          onPressed: () async {
                            final user = await frontegg.requestAuthorize(
                              refreshToken: "afb750a7-68a1-444b-8c5e-d9276f994fc4",
                              deviceTokenCookie: "34b61432-86bb-4e0f-97c4-f1c31427c385",
                            );
                            debugPrint("Request Authorized With Tokens Finished, Result = $user");
                          },
                        ),
                        ElevatedButton(
                          child: const Text("Login with Passkeys"),
                          onPressed: () async {
                            try {
                              await frontegg.loginWithPasskeys();
                              debugPrint("Login With Passkeys Finished");
                            } on FronteggException catch (e) {
                              debugPrint("Exception: $e");
                            }
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
