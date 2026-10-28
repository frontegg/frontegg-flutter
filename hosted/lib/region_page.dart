import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import 'widgets/frontegg_app_bar.dart';

/// Region page
///
/// Shown in multi-region mode until the user selects the region to sign in to.
class RegionPage extends StatelessWidget {
  final List<FronteggRegionConfig> regions;

  const RegionPage({
    super.key,
    required this.regions,
  });

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;

    return Scaffold(
      appBar: const FronteggAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            'Select your region',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          for (final region in regions)
            Card(
              child: ListTile(
                key: ValueKey('Region-${region.key}'),
                title: Text(region.key.toUpperCase()),
                subtitle: Text(region.baseUrl),
                onTap: () => _selectRegion(
                  frontegg,
                  ScaffoldMessenger.of(context),
                  region.key,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectRegion(
    FronteggFlutter frontegg,
    ScaffoldMessengerState messenger,
    String regionKey,
  ) async {
    try {
      await frontegg.initWithRegion(regionKey);
    } on FronteggException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select region: ${e.message ?? e.failureReason}',
          ),
        ),
      );
    }
  }
}
