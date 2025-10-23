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
              } else if (state.isAuthenticated && state.user != null) {
                // If user is authenticated, show a message and let MainPage handle the redirect
                debugPrint('LoginPage: User is authenticated, showing redirect message');
                return const SizedBox.expand(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('User authenticated, redirecting...'),
                      ],
                    ),
                  ),
                );
              } else if (state.isLoading && state.isAuthenticated) {
                // Special case: user is authenticated but still loading (hosted mode issue)
                debugPrint('LoginPage: Special case - user authenticated but still loading, forcing state update');
                // Try to force state update
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  frontegg.forceStateUpdate();
                });
                return const SizedBox.expand(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Updating state...'),
                      ],
                    ),
                  ),
                );
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
                        await frontegg.login(loginHint: 'some@mail.com');

                        debugPrint('Login Finished');
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
