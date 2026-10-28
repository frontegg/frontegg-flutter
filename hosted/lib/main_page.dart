import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import 'login_page.dart';
import 'region_page.dart';
import 'user_page.dart';

/// Main page
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<FronteggConstants>? constantsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    constantsFuture ??= context.frontegg.getConstants();
  }

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return Scaffold(
      body: Center(
        child: FutureBuilder<FronteggConstants>(
          future: constantsFuture,
          builder: (
            BuildContext context,
            AsyncSnapshot<FronteggConstants> constantsSnapshot,
          ) {
            if (!constantsSnapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final constants = constantsSnapshot.data!;

            // StreamBuilder to listen to the state of the authentication
            return StreamBuilder<FronteggState>(
              stream: frontegg.stateChanged,
              builder: (
                BuildContext context,
                AsyncSnapshot<FronteggState> snapshot,
              ) {
                if (snapshot.hasData) {
                  final state = snapshot.data!;
                  if (constants.isRegional && state.selectedRegion == null) {
                    // In multi-region mode, ask for the region before anything else
                    return RegionPage(regions: constants.regions);
                  } else if (state.isAuthenticated && state.user != null) {
                    // If the user is authenticated and the user is not null, show the user page
                    return const UserPage();
                  } else if (state.initializing) {
                    // If the app is initializing, show a loading indicator
                    return const CircularProgressIndicator();
                  } else {
                    // If the user is not authenticated, show the login page
                    return const LoginPage();
                  }
                }

                return const SizedBox();
              },
            );
          },
        ),
      ),
    );
  }
}
