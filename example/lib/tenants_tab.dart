import 'package:flutter/material.dart';
import 'package:frontegg/frontegg_flutter.dart';

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
                  final isActive = user.activeTenant.id == e.id;
                  return ListTile(
                    title: Row(
                      children: [
                        Text(e.name),
                        if (isActive) const SizedBox(width: 10),
                        if (isActive)
                          const Text(
                            "(active)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      frontegg.switchTenant(e.id);
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
