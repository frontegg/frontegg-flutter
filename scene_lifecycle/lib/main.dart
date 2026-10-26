import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

const _routerLog = MethodChannel('scene_lifecycle/router');

final _router = GoRouter(
  redirect: (context, state) {
    debugPrint('DIAG route ${state.uri}');
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Home'))),
    ),
  ],
  errorBuilder: (context, state) {
    debugPrint('DIAG errorBuilder ${state.uri}');
    _routerLog.invokeMethod('pageNotFound', state.uri.toString());
    return Scaffold(body: Center(child: Text('Page Not Found\n${state.error}')));
  },
);

class _LinkDiagnostics with WidgetsBindingObserver {
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    debugPrint(
      'DIAG pushRouteInformation ${routeInformation.uri} '
      'lifecycle=${WidgetsBinding.instance.lifecycleState} '
      'framesEnabled=${SchedulerBinding.instance.framesEnabled}',
    );
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('DIAG lifecycle $state');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(_LinkDiagnostics());
  runApp(MaterialApp.router(routerConfig: _router));
}
