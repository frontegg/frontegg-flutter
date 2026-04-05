import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Dart mirror of the Swift/Kotlin `LocalMockAuthServer` for embedded E2E.
class LocalMockAuthServer {
  static const int defaultPort = 49384;

  /// Non-localhost hostname used on iOS so the Frontegg SDK's WebView does not
  /// block navigation to it (CustomWebView.swift blocks any URL whose host
  /// contains "localhost" or "127.0.0.1").
  /// CI adds a /etc/hosts entry mapping this to 127.0.0.1.
  /// On Android the SDK does NOT have this block, so we keep 127.0.0.1.
  static const String _iosHostname = 'mock-frontegg.test';

  final String clientId = 'demo-embedded-e2e-client';
  late final HttpServer _server;
  late final String urlRoot;
  final _state = _MockAuthState();
  final _requestLog = <_LoggedRequest>[];

  Future<void> start({int port = defaultPort}) async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    final host = Platform.isIOS ? _iosHostname : '127.0.0.1';
    urlRoot = 'http://$host:${_server.port}';
    _server.listen(_handleRequest);
  }

  Future<void> shutdown() async {
    await _server.close(force: true);
  }

  void reset() {
    _state.reset();
    _requestLog.clear();
  }

  void configureTokenPolicy({
    required String email,
    required int accessTTL,
    required int refreshTTL,
    int startingTokenVersion = 1,
  }) {
    _state.configureTokenPolicy(
      email: email,
      accessTTL: accessTTL,
      refreshTTL: refreshTTL,
      startingTokenVersion: startingTokenVersion,
    );
  }

  void queueProbeFailures(List<int> statusCodes) {
    _state.enqueue(
      method: 'HEAD',
      path: '/test',
      responses: statusCodes.map((s) => {'status': s, 'body': 'offline'}).toList(),
    );
  }

  void queueProbeTimeouts({required int count, int delayMs = 1500}) {
    _state.enqueue(
      method: 'HEAD',
      path: '/test',
      responses: List.generate(count, (_) => {'status': 200, 'body': 'ok', 'delay_ms': delayMs}),
    );
  }

  void queueConnectionDrops({String method = 'POST', required String path, int count = 1}) {
    _state.enqueue(
      method: method,
      path: path,
      responses: List.generate(count, (_) => {'close_connection': true}),
    );
  }

  void queueEmbeddedSocialSuccessOAuthError(String errorCode, String errorDescription) {
    _state.queueEmbeddedSocialSuccessOAuthError(errorCode, errorDescription);
  }

  int requestCount(String? method, String path) {
    return _requestLog.where((r) => r.path == path && (method == null || r.method == method)).length;
  }

  // ---------------------------------------------------------------------------
  // Request handling
  // ---------------------------------------------------------------------------

  Future<void> _handleRequest(HttpRequest request) async {
    final method = request.method.toUpperCase();
    final path = _normalizePath(request.uri.path);
    final query = request.uri.queryParametersAll;
    final headers = <String, String>{};
    request.headers.forEach((name, values) {
      headers[name.toLowerCase()] = values.join(', ');
    });
    final bodyBytes = await request.fold<List<int>>([], (prev, chunk) => prev..addAll(chunk));

    _requestLog.add(_LoggedRequest(method: method, path: path));

    // Debug logging for CI: trace mock-server requests to diagnose login flow failures.
    stderr.writeln('[MockServer] $method $path${request.uri.hasQuery ? '?${request.uri.query}' : ''}');

    final queued = _state.dequeue(method: method, path: path);
    if (queued != null) {
      await _sendQueuedResponse(request.response, queued, method);
      return;
    }

    final key = '$method $path';
    switch (key) {
      case 'HEAD /test':
      case 'GET /test':
        _sendText(request.response, 200, 'ok');
      case 'GET /oauth/authorize':
        _renderAuthorizePage(request.response, query);
      case 'GET /oauth/account/social/success':
        _handleSocialLoginSuccess(request.response, query);
      case 'GET /oauth/prelogin':
        _handleHostedPrelogin(request.response, query);
      case 'POST /oauth/postlogin':
        _handleHostedPostlogin(request.response, bodyBytes);
      case 'GET /oauth/postlogin/redirect':
        _handleHostedPostloginRedirect(request.response, query);
      case 'GET /idp/google/authorize':
        _handleMockGoogleAuthorize(request.response, query);
      case 'GET /embedded/continue':
        _renderEmbeddedContinue(request.response, query);
      case 'POST /embedded/password':
        _completeEmbeddedPassword(request.response, bodyBytes);
      case 'GET /browser/complete':
        _completeBrowserFlow(request.response, query);
      case 'GET /dashboard':
        _sendHtml(request.response, 200, 'Dashboard', '<h1>Dashboard</h1>');
      case 'POST /oauth/token':
        _handleOAuthToken(request.response, bodyBytes);
      case 'POST /frontegg/oauth/authorize/silent':
        _handleSilentAuthorize(request.response, headers);
      case 'GET /flags':
      case 'GET /frontegg/flags':
        _sendJson(request.response, 200, {'mobile-enable-logging': 'off'});
      case 'GET /frontegg/metadata':
        _sendJson(request.response, 200, {'appName': 'demo-embedded-e2e', 'environment': 'local'});
      case 'GET /vendors/public':
      case 'GET /frontegg/vendors/public':
        _sendJson(request.response, 200, {'vendors': []});
      case 'GET /frontegg/identity/resources/sso/v2':
        _handleSocialLoginConfig(request.response);
      case 'GET /frontegg/identity/resources/configurations/v1/public':
        _sendJson(request.response, 200, {'embeddedMode': true, 'loginBoxVisible': true});
      case 'GET /frontegg/identity/resources/configurations/v1/auth/strategies/public':
        _sendJson(request.response, 200, {'password': true, 'socialLogin': true, 'sso': true});
      case 'GET /frontegg/identity/resources/configurations/v1/sign-up/strategies':
        _sendJson(request.response, 200, {'allowSignUp': true});
      case 'GET /frontegg/team/resources/sso/v2/configurations/public':
        _sendJson(request.response, 200, []);
      case 'GET /identity/resources/sso/custom/v1':
      case 'GET /frontegg/identity/resources/sso/custom/v1':
        _sendJson(request.response, 200, {'providers': []});
      case 'GET /identity/resources/configurations/sessions/v1':
        _sendJson(request.response, 200, {'cookieName': 'fe_refresh_demo_embedded_e2e', 'keepSessionAlive': true});
      case 'GET /frontegg/identity/resources/configurations/v1/captcha-policy/public':
        _sendJson(request.response, 200, {'enabled': false});
      case 'POST /frontegg/identity/resources/auth/v1/user/token/refresh':
        _handleHostedRefresh(request.response, headers);
      case 'POST /frontegg/identity/resources/auth/v2/user/sso/prelogin':
        _handleHostedSSOPrelogin(request.response, bodyBytes);
      case 'POST /frontegg/identity/resources/auth/v1/user':
        _handleHostedPasswordLogin(request.response, bodyBytes);
      case 'GET /identity/resources/users/v2/me':
        _handleMe(request.response, headers);
      case 'GET /identity/resources/users/v3/me/tenants':
        _handleTenants(request.response, headers);
      case 'POST /oauth/logout/token':
        _handleLogout(request.response, headers);
      default:
        stderr.writeln('[MockServer] ⚠️ 404 Unhandled: $method $path');
        _sendJson(request.response, 404, {'error': 'Unhandled route $method $path'});
    }
  }

  // ---------------------------------------------------------------------------
  // Route handlers
  // ---------------------------------------------------------------------------

  void _renderAuthorizePage(HttpResponse res, Map<String, List<String>> query) {
    final redirectUri = _fv(query, 'redirect_uri');
    final stateValue = _fv(query, 'state');
    final clientId = _fv(query, 'client_id');
    final loginAction = _fv(query, 'login_direct_action');
    final loginHint = _fv(query, 'login_hint');

    if (loginAction.isNotEmpty) {
      final decoded = _decodeBase64UrlJson(loginAction) ?? {};
      final destination = decoded['data'] as String? ?? '';
      String title, buttonTitle, email;
      if (destination.contains('custom-sso')) {
        title = 'Custom SSO Mock Server';
        buttonTitle = 'Continue to Custom SSO';
        email = 'custom-sso@frontegg.com';
      } else if (destination.contains('mock-social-provider')) {
        title = 'Mock Social Login';
        buttonTitle = 'Continue with Mock Social';
        email = 'social-login@frontegg.com';
      } else {
        title = 'Direct Login Mock Server';
        buttonTitle = 'Continue';
        email = 'direct-login@frontegg.com';
      }
      final body = '''
<h1>${_he(title)}</h1>
<form action="/browser/complete" method="get">
  <input type="hidden" name="email" value="${_he(email)}" />
  <input type="hidden" name="redirect_uri" value="${_he(redirectUri)}" />
  <input type="hidden" name="state" value="${_he(stateValue)}" />
  <button type="submit">${_he(buttonTitle)}</button>
</form>''';
      _sendHtml(res, 200, title, body);
      return;
    }

    final hostedState = _state.issueHostedLoginContext(
      redirectUri: redirectUri,
      originalState: stateValue,
      loginHint: loginHint,
    );

    final preloginUri = Uri.parse('$urlRoot/oauth/prelogin').replace(
      queryParameters: {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'state': hostedState,
        if (loginHint.isNotEmpty) 'login_hint': loginHint,
      },
    );
    _sendRedirect(res, preloginUri.toString());
  }

  void _handleHostedPrelogin(HttpResponse res, Map<String, List<String>> query) {
    final hostedState = _fv(query, 'state');
    final context = _state.hostedLoginContext(hostedState);
    if (context == null) {
      _sendHtml(res, 400, 'Invalid hosted flow', '<h1>Invalid hosted flow</h1>');
      return;
    }

    var email = _fv(query, 'email');
    if (email.isEmpty) email = context.loginHint;

    if (email.isEmpty) {
      _renderHostedEmailStep(res, hostedState);
      return;
    }

    if (email.endsWith('@saml-domain.com')) {
      _renderHostedProviderStep(res, title: 'OKTA SAML Mock Server', buttonTitle: 'Login With Okta', hostedState: hostedState, email: email);
      return;
    }

    if (email.endsWith('@oidc-domain.com')) {
      _renderHostedProviderStep(res, title: 'OKTA OIDC Mock Server', buttonTitle: 'Login With Okta', hostedState: hostedState, email: email);
      return;
    }

    _renderHostedPasswordStep(res, hostedState: hostedState, email: email, prefilledPassword: context.loginHint.isNotEmpty);
  }

  void _renderHostedEmailStep(HttpResponse res, String hostedState) {
    final body = '''
<h1>Mock Embedded Login</h1>
<form action="/oauth/prelogin" method="get">
  <input type="hidden" name="state" value="${_he(hostedState)}" />
  <input type="email" name="email" placeholder="Email is required" />
  <button type="submit">Continue</button>
</form>
<form action="/__frontegg_test/social-login" method="get">
  <input type="hidden" name="provider" value="google" />
  <button type="submit" id="e2e-mock-google">Continue with Mock Google</button>
</form>
${_hostedBootstrapScript(true)}''';
    _sendHtml(res, 200, 'Mock Embedded Login', body);
  }

  void _renderHostedPasswordStep(HttpResponse res, {required String hostedState, required String email, required bool prefilledPassword}) {
    final passwordValue = prefilledPassword ? ' value="Testpassword1!"' : '';
    final hostedStateLit = _jsLiteral(hostedState);
    final emailLit = _jsLiteral(email);
    final autoSubmit = prefilledPassword ? '''
window.addEventListener('load', () => {
  setTimeout(() => { if (passwordField.value) form.requestSubmit(); }, 350);
});''' : '';
    final body = '''
<h1>Password Login</h1>
<form id="password-login-form">
  <input id="hosted-email" type="email" name="email" value="${_he(email)}" />
  <input id="hosted-password" type="password" name="password"$passwordValue />
  <button type="submit">Sign in</button>
  <p id="status-message"></p>
</form>
<script>
${_hostedBootstrapScript(true)}
const hostedState = $hostedStateLit;
const defaultEmail = $emailLit;
const form = document.getElementById('password-login-form');
const emailField = document.getElementById('hosted-email');
const passwordField = document.getElementById('hosted-password');
const statusMessage = document.getElementById('status-message');
form.addEventListener('submit', async (event) => {
  event.preventDefault();
  const email = emailField.value || defaultEmail;
  try {
    await fetch('/frontegg/identity/resources/auth/v2/user/sso/prelogin', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email})}).catch(()=>null);
    const authResponse = await fetch('/frontegg/identity/resources/auth/v1/user', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email,password:passwordField.value,invitationToken:''})});
    if(!authResponse.ok) throw new Error('auth_failed');
    const authData = await authResponse.json();
    await fetch('/identity/resources/configurations/sessions/v1').catch(()=>null);
    const postloginResponse = await fetch('/oauth/postlogin', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({state:hostedState,token:authData.access_token})});
    if(!postloginResponse.ok) throw new Error('postlogin_failed');
    await postloginResponse.json();
    window.location.assign('/oauth/postlogin/redirect?state='+encodeURIComponent(hostedState));
  } catch(error) { statusMessage.textContent = 'Sign in failed'; }
});
$autoSubmit
</script>''';
    _sendHtml(res, 200, 'Password Login', body);
  }

  void _renderHostedProviderStep(HttpResponse res, {required String title, required String buttonTitle, required String hostedState, required String email}) {
    final policy = _state.tokenPolicy(email);
    final accessTok = _accessToken(email: email, tokenVersion: policy.startingTokenVersion, expiresIn: policy.accessTTL);
    final body = '''
<h1>${_he(title)}</h1>
<form id="provider-login-form">
  <button type="submit">${_he(buttonTitle)}</button>
  <p id="provider-status"></p>
</form>
<script>
${_hostedBootstrapScript(true)}
const hostedState = ${_jsLiteral(hostedState)};
const email = ${_jsLiteral(email)};
const accessToken = ${_jsLiteral(accessTok)};
const form = document.getElementById('provider-login-form');
form.addEventListener('submit', async (event) => {
  event.preventDefault();
  try {
    await fetch('/frontegg/identity/resources/auth/v2/user/sso/prelogin', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email})});
    const r = await fetch('/oauth/postlogin', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({state:hostedState,token:accessToken})});
    if(!r.ok) throw new Error('postlogin_failed');
    await r.json();
    window.location.assign('/oauth/postlogin/redirect?state='+encodeURIComponent(hostedState));
  } catch(e) { document.getElementById('provider-status').textContent = 'Login failed'; }
});
</script>''';
    _sendHtml(res, 200, title, body);
  }

  String _hostedBootstrapScript(bool includeRefresh) {
    const urls = [
      '/vendors/public', '/frontegg/metadata', '/flags', '/frontegg/flags',
      '/frontegg/identity/resources/sso/v2', '/frontegg/identity/resources/configurations/v1/public',
      '/frontegg/identity/resources/configurations/v1/auth/strategies/public',
      '/frontegg/identity/resources/configurations/v1/sign-up/strategies',
      '/frontegg/team/resources/sso/v2/configurations/public', '/frontegg/vendors/public',
      '/frontegg/identity/resources/sso/custom/v1',
      '/frontegg/identity/resources/configurations/v1/captcha-policy/public',
    ];
    final fetches = urls.map((u) => "fetch('$u').catch(()=>null)").join(',\n');
    final refresh = includeRefresh
        ? "fetch('/frontegg/identity/resources/auth/v1/user/token/refresh',{method:'POST',headers:{'Content-Type':'application/json'},body:'{}'}).catch(()=>null),"
        : '';
    return "window.addEventListener('load',()=>{Promise.allSettled([$refresh$fetches]);});";
  }

  void _renderEmbeddedContinue(HttpResponse res, Map<String, List<String>> query) {
    final email = _fv(query, 'email', 'test@frontegg.com');
    final redirectUri = _fv(query, 'redirect_uri');
    final stateValue = _fv(query, 'state');

    if (email.endsWith('@saml-domain.com') || email.endsWith('@oidc-domain.com')) {
      final title = email.endsWith('@saml-domain.com') ? 'OKTA SAML Mock Server' : 'OKTA OIDC Mock Server';
      final body = '''
<h1>$title</h1>
<form action="/browser/complete" method="get">
  <input type="hidden" name="email" value="${_he(email)}" />
  <input type="hidden" name="redirect_uri" value="${_he(redirectUri)}" />
  <input type="hidden" name="state" value="${_he(stateValue)}" />
  <button type="submit">Login With Okta</button>
</form>''';
      _sendHtml(res, 200, title, body);
      return;
    }

    final body = '''
<h1>Password Login</h1>
<form action="/embedded/password" method="post">
  <input type="hidden" name="email" value="${_he(email)}" />
  <input type="hidden" name="redirect_uri" value="${_he(redirectUri)}" />
  <input type="hidden" name="state" value="${_he(stateValue)}" />
  <input type="password" name="password" placeholder="Password is required" />
  <button type="submit">Sign in</button>
</form>''';
    _sendHtml(res, 200, 'Password Login', body);
  }

  void _completeEmbeddedPassword(HttpResponse res, List<int> bodyBytes) {
    final form = _parseUrlEncodedForm(bodyBytes);
    final email = form['email'] ?? 'test@frontegg.com';
    final redirectUri = form['redirect_uri'] ?? '';
    final stateValue = form['state'] ?? '';
    final code = _state.issueCode(email: email, redirectUri: redirectUri, state: stateValue);
    _sendRedirect(res, _buildCallbackUrl(redirectUri, code: code, state: stateValue));
  }

  void _completeBrowserFlow(HttpResponse res, Map<String, List<String>> query) {
    final email = _fv(query, 'email', 'browser@frontegg.com');
    final redirectUri = _fv(query, 'redirect_uri');
    final stateValue = _fv(query, 'state');
    final code = _state.issueCode(email: email, redirectUri: redirectUri, state: stateValue);
    _sendRedirect(res, _buildCallbackUrl(redirectUri, code: code, state: stateValue));
  }

  void _handleOAuthToken(HttpResponse res, List<int> bodyBytes) {
    final body = _parseJsonBody(bodyBytes);
    final grantType = body['grant_type'] as String? ?? '';

    switch (grantType) {
      case 'authorization_code':
        final code = body['code'] as String? ?? '';
        if (code.isEmpty) return _sendJson(res, 400, {'error': 'missing_code'});
        final authCode = _state.consumeCode(code);
        if (authCode == null) return _sendJson(res, 400, {'error': 'invalid_code'});
        final issued = _state.issueRefreshToken(authCode.email);
        _sendJson(res, 200, _authResponse(issued.record, issued.token));

      case 'refresh_token':
        final refreshToken = body['refresh_token'] as String? ?? '';
        if (refreshToken.isEmpty) return _sendJson(res, 400, {'error': 'missing_refresh_token'});
        final session = _state.refreshSession(refreshToken);
        if (session == null) return _sendJson(res, 401, {'error': 'invalid_refresh_token'});
        _sendJson(res, 200, _authResponse(session, refreshToken));

      default:
        _sendJson(res, 400, {'error': 'unsupported_grant_type $grantType'});
    }
  }

  void _handleSilentAuthorize(HttpResponse res, Map<String, String> headers) {
    final refreshToken = _refreshTokenFromCookies(headers['cookie']);
    if (refreshToken == null) return _sendJson(res, 401, {'error': 'invalid_refresh_cookie'});
    final session = _state.validRefreshTokenRecord(refreshToken);
    if (session == null) return _sendJson(res, 401, {'error': 'invalid_refresh_cookie'});
    _sendJson(res, 200, _authResponse(session, refreshToken));
  }

  void _handleSocialLoginConfig(HttpResponse res) {
    _sendJson(res, 200, [
      {
        'type': 'google',
        'active': true,
        'customised': false,
        'clientId': 'mock-google-client-id',
        'redirectUrl': '$urlRoot/oauth/account/social/success',
        'redirectUrlPattern': '$urlRoot/oauth/account/social/success',
        'options': {'verifyEmail': false},
        'additionalScopes': [],
      },
    ]);
  }

  void _handleHostedRefresh(HttpResponse res, Map<String, String> headers) {
    final refreshToken = _refreshTokenFromCookies(headers['cookie']);
    if (refreshToken == null) return _sendJson(res, 401, {'errors': ['Session not found']});
    final session = _state.refreshSession(refreshToken);
    if (session == null) return _sendJson(res, 401, {'errors': ['Session not found']});
    _sendJson(res, 200, _authResponse(session, refreshToken));
  }

  void _handleHostedSSOPrelogin(HttpResponse res, List<int> bodyBytes) {
    final body = _parseJsonBody(bodyBytes);
    final email = (body['email'] as String? ?? '').toLowerCase();
    if (email.endsWith('@saml-domain.com')) {
      _sendJson(res, 200, {'type': 'saml', 'tenantId': _tenantId(email)});
    } else if (email.endsWith('@oidc-domain.com')) {
      _sendJson(res, 200, {'type': 'oidc', 'tenantId': _tenantId(email)});
    } else {
      _sendJson(res, 404, {'errors': ['SSO domain was not found']});
    }
  }

  void _handleHostedPasswordLogin(HttpResponse res, List<int> bodyBytes) {
    final body = _parseJsonBody(bodyBytes);
    final email = body['email'] as String? ?? 'test@frontegg.com';
    final issued = _state.issueRefreshToken(email);
    final authData = jsonEncode(_authResponse(issued.record, issued.token));
    res.statusCode = 200;
    res.headers.contentType = ContentType.json;
    res.headers.add('set-cookie', 'fe_refresh_demo_embedded_e2e=${issued.token}; Path=/; HttpOnly; SameSite=Lax');
    res.write(authData);
    res.close();
  }

  void _handleHostedPostlogin(HttpResponse res, List<int> bodyBytes) {
    final body = _parseJsonBody(bodyBytes);
    final hostedState = body['state'] as String? ?? '';
    final context = _state.hostedLoginContext(hostedState);
    if (context == null) return _sendJson(res, 400, {'error': 'invalid_state'});

    String email;
    final token = body['token'] as String?;
    if (token != null) {
      email = _emailFromBearerToken(token) ?? context.loginHint;
    } else {
      email = context.loginHint;
    }
    if (email.isEmpty) return _sendJson(res, 400, {'error': 'missing_token'});

    final code = _state.issueCode(email: email, redirectUri: context.redirectUri, state: context.originalState);
    final redirectUrl = _buildCallbackUrl(context.redirectUri, code: code, state: context.originalState);
    _state.recordHostedPostloginCompletion(hostedState, email);
    _sendJson(res, 200, {'redirectUrl': redirectUrl});
  }

  void _handleHostedPostloginRedirect(HttpResponse res, Map<String, List<String>> query) {
    final hostedState = _fv(query, 'state');
    final context = _state.hostedLoginContext(hostedState);
    final email = _state.completedHostedLoginEmail(hostedState);
    if (context == null || email == null) return _sendJson(res, 400, {'error': 'missing_postlogin_completion'});
    final code = _state.issueCode(email: email, redirectUri: context.redirectUri, state: context.originalState);
    _sendRedirect(res, _buildCallbackUrl(context.redirectUri, code: code, state: context.originalState));
  }

  void _handleMockGoogleAuthorize(HttpResponse res, Map<String, List<String>> query) {
    final redirectUri = _fv(query, 'redirect_uri');
    final stateValue = _fv(query, 'state');
    if (redirectUri.isEmpty || stateValue.isEmpty) {
      _sendHtml(res, 400, 'Invalid mock Google request', '<h1>Invalid mock Google request</h1>');
      return;
    }
    const email = 'google-social@frontegg.com';
    final code = _state.issueCode(email: email, redirectUri: redirectUri, state: stateValue);
    final body = '''
<h1>Mock Google Login</h1>
<p>Fake Google account: $email</p>
<form action="${_he(redirectUri)}" method="get">
  <input type="hidden" name="code" value="${_he(code)}" />
  <input type="hidden" name="state" value="${_he(stateValue)}" />
  <button type="submit">Continue with Mock Google</button>
</form>''';
    _sendHtml(res, 200, 'Mock Google Login', body);
  }

  void _handleSocialLoginSuccess(HttpResponse res, Map<String, List<String>> query) {
    final code = _fv(query, 'code');
    final rawState = _fv(query, 'state');
    if (_state.authCode(code) == null) return _sendJson(res, 400, {'error': 'invalid_social_code'});

    final redirectUri = _fv(query, 'redirectUri');
    if (redirectUri.isEmpty) {
      final socialState = _decodeSocialState(rawState);
      final bundleId = socialState?['bundleId'] as String?;
      if (bundleId == null || bundleId.isEmpty) return _sendJson(res, 400, {'error': 'invalid_social_state'});
      _sendRedirect(res, _buildGeneratedRedirectCodeCallbackUrl(bundleId, rawState, code));
      return;
    }

    final pendingError = _state.consumeEmbeddedSocialSuccessOAuthError();
    if (pendingError != null) {
      final callbackState = _state.latestHostedLoginState ?? rawState;
      final bundleId = _embeddedBundleIdentifier(redirectUri);
      if (bundleId != null) {
        _sendRedirect(res, _buildGeneratedRedirectErrorCallbackUrl(bundleId, callbackState, pendingError.$1, pendingError.$2));
      } else {
        _sendRedirect(res, _buildCallbackUrl(redirectUri, state: callbackState, error: pendingError.$1, errorDescription: pendingError.$2));
      }
      return;
    }

    _sendRedirect(res, _buildCallbackUrl(redirectUri, code: code, state: rawState));
  }

  void _handleMe(HttpResponse res, Map<String, String> headers) {
    final email = _emailFromAuthHeader(headers['authorization']);
    if (email == null) return _sendJson(res, 401, {'error': 'missing_access_token'});
    _sendJson(res, 200, _userResponse(email));
  }

  void _handleTenants(HttpResponse res, Map<String, String> headers) {
    final email = _emailFromAuthHeader(headers['authorization']);
    if (email == null) return _sendJson(res, 401, {'error': 'missing_access_token'});
    final tenant = _tenantResponse(email);
    _sendJson(res, 200, {'tenants': [tenant], 'activeTenant': tenant});
  }

  void _handleLogout(HttpResponse res, Map<String, String> headers) {
    final rt = _refreshTokenFromCookies(headers['cookie']);
    if (rt != null) _state.invalidateRefreshToken(rt);
    _sendJson(res, 200, {'ok': true});
  }

  // ---------------------------------------------------------------------------
  // Response helpers
  // ---------------------------------------------------------------------------

  void _sendJson(HttpResponse res, int status, Object payload) {
    res.statusCode = status;
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(payload));
    res.close();
  }

  void _sendText(HttpResponse res, int status, String body) {
    res.statusCode = status;
    res.headers.contentType = ContentType.text;
    res.write(body);
    res.close();
  }

  void _sendHtml(HttpResponse res, int status, String title, String body) {
    final page = '''<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>${_he(title)}</title>
<style>body{font-family:-apple-system,BlinkMacSystemFont,sans-serif;padding:32px 20px;background:#f7f7f8;color:#111}
h1{font-size:28px;margin:0 0 16px}form{display:flex;flex-direction:column;gap:12px;max-width:360px}
input{font-size:16px;padding:12px;border-radius:10px;border:1px solid #d0d5dd}
button{font-size:16px;padding:14px 18px;border:0;border-radius:12px;background:#0f62fe;color:white}</style>
</head><body>$body</body></html>''';
    res.statusCode = status;
    res.headers.contentType = ContentType.html;
    res.write(page);
    res.close();
  }

  void _sendRedirect(HttpResponse res, String location) {
    stderr.writeln('[MockServer] 302 → $location');
    res.statusCode = 302;
    res.headers.set('location', location);
    res.close();
  }

  Future<void> _sendQueuedResponse(HttpResponse res, Map<String, dynamic> spec, String method) async {
    final delayMs = spec['delay_ms'] as int? ?? 0;
    final closeConnection = spec['close_connection'] as bool? ?? false;

    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }

    if (closeConnection) {
      res.close();
      return;
    }

    var status = spec['status'] as int? ?? 200;
    final redirect = spec['redirect'] as String?;
    if (redirect != null && redirect.isNotEmpty) {
      res.headers.set('location', redirect);
      if (!spec.containsKey('status')) status = 302;
    }

    final json = spec['json'];
    final bodyStr = spec['body'] as String?;
    if (json != null) {
      res.statusCode = status;
      res.headers.contentType = ContentType.json;
      res.write(jsonEncode(json));
    } else if (bodyStr != null) {
      res.statusCode = status;
      res.headers.contentType = ContentType.text;
      res.write(bodyStr);
    } else {
      res.statusCode = status;
    }
    res.close();
  }

  // ---------------------------------------------------------------------------
  // Token / auth helpers
  // ---------------------------------------------------------------------------

  String _accessToken({required String email, required int tokenVersion, required int expiresIn}) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payload = {
      'sub': 'user-${email.split('@').first}',
      'email': email,
      'name': _userName(email),
      'tenantId': _tenantId(email),
      'tenantIds': [_tenantId(email)],
      'profilePictureUrl': 'https://example.com/avatar.png',
      'exp': now + expiresIn,
      'iat': now,
      'token_version': tokenVersion,
    };
    final header = _encodeBase64UrlJson({'alg': 'none', 'typ': 'JWT'});
    final body = _encodeBase64UrlJson(payload);
    return '$header.$body.signature';
  }

  Map<String, dynamic> _authResponse(_RefreshTokenRecord session, String refreshToken) {
    final policy = _state.tokenPolicy(session.email);
    final at = _accessToken(email: session.email, tokenVersion: session.tokenVersion, expiresIn: policy.accessTTL);
    return {
      'token_type': 'Bearer',
      'refresh_token': refreshToken,
      'access_token': at,
      'id_token': at,
      'expires_in': policy.accessTTL,
      'expires': (DateTime.now().millisecondsSinceEpoch ~/ 1000 + policy.accessTTL).toString(),
    };
  }

  Map<String, dynamic> _tenantResponse(String email) {
    final tid = _tenantId(email);
    const now = '2026-03-26T00:00:00.000Z';
    return {
      'id': tid, 'name': '${_userName(email)} Tenant', 'tenantId': tid,
      'createdAt': now, 'updatedAt': now, 'isReseller': false, 'metadata': '{}', 'vendorId': 'vendor-demo',
    };
  }

  Map<String, dynamic> _userResponse(String email) {
    final tenant = _tenantResponse(email);
    return {
      'id': 'user-${email.split('@').first}', 'email': email, 'mfaEnrolled': false,
      'name': _userName(email), 'profilePictureUrl': 'https://example.com/avatar.png',
      'phoneNumber': null, 'profileImage': null, 'roles': [], 'permissions': [],
      'tenantId': tenant['id'], 'tenantIds': [tenant['id']], 'tenants': [tenant],
      'activeTenant': tenant, 'activatedForTenant': true, 'metadata': '{}', 'verified': true, 'superUser': false,
    };
  }

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  String _userName(String email) {
    final local = email.split('@').first;
    return local.replaceAll('-', ' ').replaceAll('.', ' ')
        .split(' ').where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  String _tenantId(String email) {
    final local = email.split('@').first.replaceAll('.', '-').replaceAll('_', '-');
    return 'tenant-$local';
  }

  String _fv(Map<String, List<String>> query, String key, [String defaultValue = '']) =>
      query[key]?.firstOrNull ?? defaultValue;

  String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    return path.startsWith('/') ? path : '/$path';
  }

  String _he(String s) => s
      .replaceAll('&', '&amp;').replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

  String _jsLiteral(String s) {
    final json = jsonEncode([s]);
    return json.substring(1, json.length - 1);
  }

  String _encodeBase64UrlJson(Map<String, dynamic> value) {
    final data = utf8.encode(jsonEncode(value));
    return base64Url.encode(data).replaceAll('=', '');
  }

  Map<String, dynamic>? _decodeBase64UrlJson(String value) {
    if (value.isEmpty) return null;
    try {
      var normalized = value.replaceAll('-', '+').replaceAll('_', '/');
      final remainder = normalized.length % 4;
      if (remainder > 0) normalized += '=' * (4 - remainder);
      final decoded = utf8.decode(base64.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _decodeSocialState(String rawState) {
    try {
      return jsonDecode(rawState) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  String? _emailFromBearerToken(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    final payload = _decodeBase64UrlJson(parts[1]);
    return payload?['email'] as String?;
  }

  String? _emailFromAuthHeader(String? header) {
    if (header == null || !header.startsWith('Bearer ')) return null;
    return _emailFromBearerToken(header.substring(7).trim());
  }

  String? _refreshTokenFromCookies(String? cookieHeader) {
    if (cookieHeader == null) return null;
    for (final segment in cookieHeader.split(';')) {
      final chunk = segment.trim();
      if (chunk.startsWith('fe_refresh_')) {
        final eq = chunk.indexOf('=');
        if (eq > 0) return chunk.substring(eq + 1);
      }
    }
    return null;
  }

  Map<String, String> _parseUrlEncodedForm(List<int> bodyBytes) {
    final bodyStr = utf8.decode(bodyBytes);
    final values = <String, String>{};
    for (final pair in bodyStr.split('&')) {
      if (pair.isEmpty) continue;
      final parts = pair.split('=');
      final name = Uri.decodeComponent(parts[0].replaceAll('+', ' '));
      final value = parts.length > 1 ? Uri.decodeComponent(parts[1].replaceAll('+', ' ')) : '';
      values[name] = value;
    }
    return values;
  }

  Map<String, dynamic> _parseJsonBody(List<int> bodyBytes) {
    if (bodyBytes.isEmpty) return {};
    try {
      return jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  String _buildCallbackUrl(String redirectUri, {String? code, String? state, String? error, String? errorDescription}) {
    final uri = Uri.parse(redirectUri);
    final params = Map<String, String>.from(uri.queryParameters);
    if (code != null) params['code'] = code;
    if (state != null && state.isNotEmpty) params['state'] = state;
    if (error != null) params['error'] = error;
    if (errorDescription != null) params['error_description'] = errorDescription;
    return uri.replace(queryParameters: params).toString();
  }

  String? _embeddedBundleIdentifier(String redirectUri) {
    final uri = Uri.tryParse(redirectUri);
    if (uri == null) return null;
    const prefix = '/oauth/account/redirect/ios/';
    if (!uri.path.startsWith(prefix)) return null;
    final suffix = uri.path.substring(prefix.length);
    final bundleId = suffix.split('/').first;
    return bundleId.isEmpty ? null : bundleId;
  }

  String _buildGeneratedRedirectCodeCallbackUrl(String bundleId, String state, String code) {
    return '${bundleId.toLowerCase()}://127.0.0.1/ios/oauth/callback?state=${Uri.encodeComponent(state)}&code=${Uri.encodeComponent(code)}&social-login-callback=true';
  }

  String _buildGeneratedRedirectErrorCallbackUrl(String bundleId, String state, String error, String errorDescription) {
    return '${bundleId.toLowerCase()}://127.0.0.1/ios/oauth/callback?error=${Uri.encodeComponent(error)}&error_description=${Uri.encodeComponent(errorDescription)}&state=${Uri.encodeComponent(state)}';
  }
}

// ---------------------------------------------------------------------------
// Internal types
// ---------------------------------------------------------------------------

class _LoggedRequest {
  final String method;
  final String path;
  _LoggedRequest({required this.method, required this.path});
}

class _AuthCode {
  final String email;
  final String redirectUri;
  final String state;
  _AuthCode({required this.email, required this.redirectUri, required this.state});
}

class _HostedLoginContext {
  final String redirectUri;
  final String originalState;
  final String loginHint;
  _HostedLoginContext({required this.redirectUri, required this.originalState, required this.loginHint});
}

class _TokenPolicy {
  final int accessTTL;
  final int refreshTTL;
  final int startingTokenVersion;
  _TokenPolicy({this.accessTTL = 3600, this.refreshTTL = 86400, this.startingTokenVersion = 1});
  static final defaultPolicy = _TokenPolicy();
}

class _RefreshTokenRecord {
  final String email;
  final double expiresAt;
  int tokenVersion;
  _RefreshTokenRecord({required this.email, required this.expiresAt, required this.tokenVersion});
}

class _IssuedRefreshToken {
  final String token;
  final _RefreshTokenRecord record;
  _IssuedRefreshToken({required this.token, required this.record});
}

class _MockAuthState {
  final _queuedResponses = <String, List<Map<String, dynamic>>>{};
  final _authCodes = <String, _AuthCode>{};
  final _hostedLoginContexts = <String, _HostedLoginContext>{};
  String? latestHostedLoginState;
  final _completedHostedLogins = <String, String>{};
  final _refreshTokens = <String, _RefreshTokenRecord>{};
  final _tokenPolicies = <String, _TokenPolicy>{};
  (String, String)? _pendingEmbeddedSocialOAuthError;
  int _codeCounter = 0;

  _MockAuthState() { reset(); }

  void reset() {
    _queuedResponses.clear();
    _authCodes.clear();
    _hostedLoginContexts.clear();
    latestHostedLoginState = null;
    _completedHostedLogins.clear();
    _tokenPolicies.clear();
    _pendingEmbeddedSocialOAuthError = null;
    _refreshTokens.clear();
    _refreshTokens['signup-refresh-token'] = _RefreshTokenRecord(
      email: 'signup@frontegg.com',
      expiresAt: DateTime.now().millisecondsSinceEpoch / 1000 + _TokenPolicy.defaultPolicy.refreshTTL,
      tokenVersion: _TokenPolicy.defaultPolicy.startingTokenVersion,
    );
  }

  void enqueue({required String method, required String path, required List<Map<String, dynamic>> responses}) {
    final key = '${method.toUpperCase()} $path';
    _queuedResponses.putIfAbsent(key, () => []).addAll(responses);
  }

  Map<String, dynamic>? dequeue({required String method, required String path}) {
    final key = '${method.toUpperCase()} $path';
    final q = _queuedResponses[key];
    if (q == null || q.isEmpty) return null;
    final r = q.removeAt(0);
    if (q.isEmpty) _queuedResponses.remove(key);
    return r;
  }

  String issueCode({required String email, required String redirectUri, required String state}) {
    _codeCounter++;
    final code = 'code-$_codeCounter-${DateTime.now().millisecondsSinceEpoch}';
    _authCodes[code] = _AuthCode(email: email, redirectUri: redirectUri, state: state);
    return code;
  }

  String issueHostedLoginContext({required String redirectUri, required String originalState, required String loginHint}) {
    final hostedState = 'hosted-${DateTime.now().millisecondsSinceEpoch}-${_codeCounter++}';
    _hostedLoginContexts[hostedState] = _HostedLoginContext(redirectUri: redirectUri, originalState: originalState, loginHint: loginHint);
    latestHostedLoginState = hostedState;
    return hostedState;
  }

  _HostedLoginContext? hostedLoginContext(String hostedState) => _hostedLoginContexts[hostedState];

  void recordHostedPostloginCompletion(String hostedState, String email) {
    _completedHostedLogins[hostedState] = email;
  }

  String? completedHostedLoginEmail(String hostedState) => _completedHostedLogins[hostedState];

  _AuthCode? consumeCode(String code) {
    final ac = _authCodes[code];
    _authCodes.remove(code);
    return ac;
  }

  _AuthCode? authCode(String code) => _authCodes[code];

  void configureTokenPolicy({required String email, required int accessTTL, required int refreshTTL, int startingTokenVersion = 1}) {
    _tokenPolicies[email.toLowerCase()] = _TokenPolicy(accessTTL: accessTTL, refreshTTL: refreshTTL, startingTokenVersion: startingTokenVersion);
  }

  _TokenPolicy tokenPolicy(String email) => _tokenPolicies[email.toLowerCase()] ?? _TokenPolicy.defaultPolicy;

  _IssuedRefreshToken issueRefreshToken(String email) {
    final token = 'refresh-${DateTime.now().millisecondsSinceEpoch}-${_codeCounter++}';
    final policy = tokenPolicy(email);
    final record = _RefreshTokenRecord(
      email: email,
      expiresAt: DateTime.now().millisecondsSinceEpoch / 1000 + policy.refreshTTL,
      tokenVersion: policy.startingTokenVersion,
    );
    _refreshTokens[token] = record;
    return _IssuedRefreshToken(token: token, record: record);
  }

  _RefreshTokenRecord? validRefreshTokenRecord(String refreshToken) {
    final record = _refreshTokens[refreshToken];
    if (record == null) return null;
    if (record.expiresAt <= DateTime.now().millisecondsSinceEpoch / 1000) {
      _refreshTokens.remove(refreshToken);
      return null;
    }
    return record;
  }

  _RefreshTokenRecord? refreshSession(String refreshToken) {
    final record = validRefreshTokenRecord(refreshToken);
    if (record == null) return null;
    record.tokenVersion++;
    return record;
  }

  void invalidateRefreshToken(String refreshToken) {
    _refreshTokens.remove(refreshToken);
  }

  void queueEmbeddedSocialSuccessOAuthError(String errorCode, String errorDescription) {
    _pendingEmbeddedSocialOAuthError = (errorCode, errorDescription);
  }

  (String, String)? consumeEmbeddedSocialSuccessOAuthError() {
    final e = _pendingEmbeddedSocialOAuthError;
    _pendingEmbeddedSocialOAuthError = null;
    return e;
  }
}
