import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

const _routerLog = MethodChannel('scene_lifecycle/router');

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Home'))),
    ),
  ],
  errorBuilder: (context, state) {
    _routerLog.invokeMethod('pageNotFound', state.uri.toString());
    return Scaffold(body: Center(child: Text('Page Not Found\n${state.error}')));
  },
);

void main() => runApp(MaterialApp.router(routerConfig: _router));
