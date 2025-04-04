import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

/// TenantsTab
///
/// This is a stateless widget that builds the tenants tab.
/// It is used to switch between tenants.
///
class TenantsTab extends StatelessWidget {
  const TenantsTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;

    // StreamBuilder to listen to the state of the authentication
    return StreamBuilder<FronteggState>(
      stream: frontegg.stateChanged,
      builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
        if (snapshot.hasData && snapshot.data?.user != null) {
          final state = snapshot.data!;
          final user = state.user!;
          if (state.isLoading) {
            // If the app is loading, show a loading indicator
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // If the user is authenticated and the user is not null, show the tenants tab
          return SingleChildScrollView(
            child: Column(
              children: user.tenants.map(
                (e) {
                  final isActive = user.activeTenant.tenantId == e.tenantId;
                  return ListTile(
                    key: ValueKey(e.tenantId),
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: e.name,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          if (isActive)
                            const TextSpan(
                              text: " (active)",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ),
                    onTap: () {
                      // Switch to the tenant by providing the tenant id
                      frontegg.switchTenant(e.tenantId);
                    },
                  );
                },
              ).toList(),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
