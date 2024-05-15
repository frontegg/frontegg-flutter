import 'package:flutter/material.dart';
import 'package:frontegg/frontegg.dart';
import 'package:frontegg/models/frontegg_state.dart';
import 'package:provider/provider.dart';

class TenantsTab extends StatelessWidget {
  const TenantsTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final frontegg = context.read<FronteggFlutter>();
    return SingleChildScrollView(
      child: StreamBuilder<FronteggState>(
        stream: frontegg.onStateChanged,
        builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
          if (snapshot.hasData && snapshot.data?.user != null) {
            final user = snapshot.data!.user!;
            return Column(
              children: user.tenants.map(
                (e) {
                  final isActive = user.activeTenant.id == e.id;
                  return ListTile(
                    title: isActive
                        ? Row(
                            children: [
                              Text(e.name),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                "(active)",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          )
                        : Text(e.name),
                    onTap: () {
                      if (!isActive) {
                        frontegg.switchTenant(e.id);
                      }
                    },
                  );
                },
              ).toList(),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
