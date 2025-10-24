import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import 'widgets/footer.dart';
import 'widgets/frontegg_app_bar.dart';

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
      appBar: const FronteggAppBar(),
      body: Stack(
        children: [
          StreamBuilder<FronteggState>(
            stream: frontegg.stateChanged,
            builder:
                (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.expand(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final state = snapshot.data!;
              if (state.isLoading) {
                return const SizedBox.expand(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (!state.initializing && !state.isAuthenticated) {
                return const Body();
              }
              return const SizedBox();
            },
          ),
          const Align(
            alignment: Alignment.bottomRight,
            child: Footer(),
          ),
        ],
      ),
    );
  }
}

/// Body of the login page
class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final frontegg = context.frontegg;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🤗',
                      style: TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 16),
                    Text('Welcome!', style: textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'This is Frontegg\'s sample app that will let you experiment with our authentication flows.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    // Login with email and password
                    // loginHint is the email of the user (optional)
                    ElevatedButton(
                      key: const ValueKey('LoginButton'),
                      child: const Text('Sign in'),
                      onPressed: () async {
                        try {
                          await frontegg.login();
                          debugPrint("Login Finished");
                        } catch (e) {
                          debugPrint("Login failed $e");
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    // Login with Google Provider
                    ElevatedButton(
                      child: const Text('Login with Google'),
                      onPressed: () async {
                        await frontegg.socialLogin(
                          provider: FronteggSocialProvider.google,
                        );

                        debugPrint('Login via Google Finished');
                      },
                    ),
                    const SizedBox(height: 8),
                    // Login with Apple Provider
                    ElevatedButton(
                      child: const Text('Login with Apple'),
                      onPressed: () async {
                        await frontegg.socialLogin(
                          provider: FronteggSocialProvider.apple,
                        );

                        debugPrint('Login via Apple Finished');
                      },
                    ),
                    const SizedBox(height: 8),
                    // Custom social login by providing the id
                    ElevatedButton(
                      child: const Text('Custom social login'),
                      onPressed: () async {
                        await frontegg.customSocialLogin(
                          id: '6fbe9b2d-bfce-4804-aa4b-a1503db588ae',
                        );

                        debugPrint('Custom Social Login Finished');
                      },
                    ),
                    const SizedBox(height: 8),
                    // Request Authorized With Tokens
                    ElevatedButton(
                      child: const Text('Request Authorized With Tokens'),
                      onPressed: () async {
                        final user = await frontegg.requestAuthorize(
                          refreshToken: 'd6da8424-3205-4dec-9ba9-eb1299dda314',
                          deviceTokenCookie:
                              'ef5b2160-5b84-4ad9-afc2-e9beafacc778',
                        );

                        debugPrint(
                          'Request Authorized With Tokens Finished, Result = $user',
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Login with Passkeys
                    ElevatedButton(
                      child: const Text('Login with Passkeys'),
                      onPressed: () async {
                        try {
                          await frontegg.loginWithPasskeys();
                          debugPrint('Login With Passkeys Finished');
                        } on FronteggException catch (e) {
                          debugPrint('Exception: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 220),
          ],
        ),
      ),
    );
  }
}
