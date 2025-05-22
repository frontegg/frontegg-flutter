import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import 'utils.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final frontegg = context.frontegg;

    return Scaffold(
      appBar: const FronteggAppBar(),
      body: Stack(
        children: [
          StreamBuilder<FronteggState>(
            stream: frontegg.stateChanged,
            builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
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
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F8FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: double.infinity,
                        ),
                        Text(
                          'This sample uses Frontegg\'s default credentials.\nSign up to use your own configurations',
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            launchUrl('https://frontegg-prod.frontegg.com/oauth/account/sign-up');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign-up',
                            style: TextStyle(
                              color: Color(0xFF4461F2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          launchUrl(
                            'https://flutter-guide.frontegg.com/#/',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(64, 32),
                          maximumSize: const Size(120, 32),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.open_in_new,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Visit Docs',
                              style: textTheme.bodySmall?.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            launchUrl(
                              'https://github.com/frontegg/frontegg-flutter',
                            );
                          },
                          icon: Image.asset(
                            'assets/github-icon.png',
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            launchUrl(
                              'https://slack.com/oauth/authorize?client_id=1234567890.1234567890&scope=identity.basic,identity.email,identity.team,identity.avatar',
                            );
                          },
                          icon: Image.asset(
                            'assets/slack-icon.png',
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                    const SizedBox(height: 8),
                    // Login with Google Provider
                    ElevatedButton(
                      child: const Text('Login with Google'),
                      onPressed: () async {
                        await frontegg.socialLogin(provider: FronteggSocialProvider.google);

                        debugPrint('Login via Google Finished');
                      },
                    ),
                    const SizedBox(height: 8),
                    // Direct Apple login by providing the url of the apple login page
                    ElevatedButton(
                      child: const Text('Direct apple login'),
                      onPressed: () async {
                        await frontegg.directLogin(
                          url:
                              'https://appleid.apple.com/auth/authorize?response_type=code&response_mode=form_post&redirect_uri=https%3A%2F%2Fauth.davidantoon.me%2Fidentity%2Fresources%2Fauth%2Fv2%2Fuser%2Fsso%2Fapple%2Fpostlogin&scope=openid+name+email&state=%7B%22oauthState%22%3A%22eyJGUk9OVEVHR19PQVVUSF9SRURJUkVDVF9BRlRFUl9MT0dJTiI6ImNvbS5mcm9udGVnZy5kZW1vOi8vYXV0aC5kYXZpZGFudG9vbi5tZS9pb3Mvb2F1dGgvY2FsbGJhY2siLCJGUk9OVEVHR19PQVVUSF9TVEFURV9BRlRFUl9MT0dJTiI6IjQ1MDVkMzljLTg0ZTctNDhiZi1hMzY3LTVmMjhmMmZlMWU1YiJ9%22%2C%22provider%22%3A%22apple%22%2C%22appId%22%3A%22%22%2C%22action%22%3A%22login%22%7D&client_id=com.frontegg.demo.client',
                        );

                        debugPrint('Direct Login Finished');
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
                          deviceTokenCookie: 'ef5b2160-5b84-4ad9-afc2-e9beafacc778',
                        );

                        debugPrint('Request Authorized With Tokens Finished, Result = $user');
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
