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
              builder: (BuildContext context,
                  AsyncSnapshot<FronteggState> snapshot) {
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
                            await frontegg.login(loginHint: "some@mail.com");
                            debugPrint("Login Finished");
                          },
                        ),
                        ElevatedButton(
                          child: const Text("Login with Google"),
                          onPressed: () {
                            frontegg.socialLogin(
                                provider: FronteggSocialProvider.google);
                          },
                        ),
                        ElevatedButton(
                          child: const Text("Direct apple login"),
                          onPressed: () {
                            frontegg.directLogin(
                              url:
                                  "https://appleid.apple.com/auth/authorize?response_type=code&response_mode=form_post&redirect_uri=https%3A%2F%2Fauth.davidantoon.me%2Fidentity%2Fresources%2Fauth%2Fv2%2Fuser%2Fsso%2Fapple%2Fpostlogin&scope=openid+name+email&state=%7B%22oauthState%22%3A%22eyJGUk9OVEVHR19PQVVUSF9SRURJUkVDVF9BRlRFUl9MT0dJTiI6ImNvbS5mcm9udGVnZy5kZW1vOi8vYXV0aC5kYXZpZGFudG9vbi5tZS9pb3Mvb2F1dGgvY2FsbGJhY2siLCJGUk9OVEVHR19PQVVUSF9TVEFURV9BRlRFUl9MT0dJTiI6IjQ1MDVkMzljLTg0ZTctNDhiZi1hMzY3LTVmMjhmMmZlMWU1YiJ9%22%2C%22provider%22%3A%22apple%22%2C%22appId%22%3A%22%22%2C%22action%22%3A%22login%22%7D&client_id=com.frontegg.demo.client",
                              ephemeralSession: true,
                            );
                          },
                        ),
                        ElevatedButton(
                          child: const Text("Custom social login"),
                          onPressed: () {
                            frontegg.customSocialLogin(
                              id: "6fbe9b2d-bfce-4804-aa4b-a1503db588ae",
                            );
                          },
                        ),
                        ElevatedButton(
                          child: const Text("Request Authorized With Tokens"),
                          onPressed: () async {
                            final user = await frontegg.requestAuthorize(
                              refreshToken:
                                  "d6da8424-3205-4dec-9ba9-eb1299dda314",
                              deviceTokenCookie:
                                  "ef5b2160-5b84-4ad9-afc2-e9beafacc778",
                            );
                            debugPrint(
                                "Request Authorized With Tokens Finished, Result = $user");
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
