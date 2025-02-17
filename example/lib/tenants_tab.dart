import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

class TenantsTab extends StatelessWidget {
  const TenantsTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return StreamBuilder<FronteggState>(
      stream: frontegg.stateChanged,
      builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
        if (snapshot.hasData && snapshot.data?.user != null) {
          final state = snapshot.data!;
          final user = state.user!;
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
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
