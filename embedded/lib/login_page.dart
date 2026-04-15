import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import 'e2e_test_mode.dart';
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
                    ElevatedButton(
                      key: const ValueKey('LoginButton'),
                      child: const Text('Sign in'),
                      onPressed: () async {
                        try {
                          await frontegg.directLogin(
                            url: 'https://autheu.davidantoon.me',
                            ephemeralSession: false,
                          );
                          debugPrint("Login Finished");
                        } catch (e) {
                          debugPrint("Login failed $e");
                        }
                      },
                    ),
                    const SizedBox(height: 8),
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
                    if (E2ETestMode.isEnabled) ..._buildE2EButtons(frontegg),
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

  List<Widget> _buildE2EButtons(FronteggFlutter frontegg) {
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 8),
      const Text(
        'E2E Test Controls',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      const SizedBox(height: 8),
      Semantics(
        label: 'E2EEmbeddedPasswordButton',
        child: ElevatedButton(
          onPressed: () async {
            try {
              await frontegg.login(loginHint: 'test@frontegg.com');
            } catch (e) {
              debugPrint('E2E password login failed: $e');
            }
          },
          child: const Text('E2E Password Login'),
        ),
      ),
      const SizedBox(height: 8),
      Semantics(
        label: 'E2EEmbeddedSAMLButton',
        child: ElevatedButton(
          onPressed: () async {
            try {
              await frontegg.login(loginHint: 'test@saml-domain.com');
            } catch (e) {
              debugPrint('E2E SAML login failed: $e');
            }
          },
          child: const Text('E2E SAML Login'),
        ),
      ),
      const SizedBox(height: 8),
      Semantics(
        label: 'E2EEmbeddedOIDCButton',
        child: ElevatedButton(
          onPressed: () async {
            try {
              await frontegg.login(loginHint: 'test@oidc-domain.com');
            } catch (e) {
              debugPrint('E2E OIDC login failed: $e');
            }
          },
          child: const Text('E2E OIDC Login'),
        ),
      ),
      const SizedBox(height: 8),
      Semantics(
        label: 'E2ESeedRequestAuthorizeTokenButton',
        child: ElevatedButton(
          key: const ValueKey('E2ESeedRequestAuthorizeTokenButtonKey'),
          onPressed: () async {
            debugPrint('E2E: seeded request-authorize refresh token');
          },
          child: const Text('E2E Seed Request Authorize'),
        ),
      ),
      const SizedBox(height: 8),
      Semantics(
        label: 'RequestAuthorizeButton',
        child: ElevatedButton(
          key: const ValueKey('RequestAuthorizeButtonKey'),
          onPressed: () async {
            try {
              await frontegg.requestAuthorize(
                refreshToken: 'signup-refresh-token',
              );
            } catch (e) {
              debugPrint('E2E request authorize failed: $e');
            }
          },
          child: const Text('E2E Request Authorize'),
        ),
      ),
      const SizedBox(height: 8),
      Semantics(
        label: 'E2ECustomSSOButton',
        child: ElevatedButton(
          onPressed: () async {
            try {
              await frontegg.customSocialLogin(id: 'e2e-custom-sso');
            } catch (e) {
              debugPrint('E2E custom SSO failed: $e');
            }
          },
          child: const Text('E2E Custom SSO'),
        ),
      ),
      const SizedBox(height: 8),
      Semantics(
        label: 'E2EDirectSocialLoginButton',
        child: ElevatedButton(
          onPressed: () async {
            try {
              await frontegg.directLogin(
                url: 'mock-social-provider',
                ephemeralSession: false,
              );
            } catch (e) {
              debugPrint('E2E direct social failed: $e');
            }
          },
          child: const Text('E2E Direct Social Login'),
        ),
      ),
      const SizedBox(height: 8),
      Semantics(
        label: 'E2EEmbeddedGoogleSocialButton',
        child: ElevatedButton(
          onPressed: () async {
            try {
              await frontegg.socialLogin(
                provider: FronteggSocialProvider.google,
                ephemeralSession: false,
              );
            } catch (e) {
              debugPrint('E2E Google social failed: $e');
            }
          },
          child: const Text('E2E Google Social Login'),
        ),
      ),
    ];
  }
}
