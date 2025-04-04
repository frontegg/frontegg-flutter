import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';
import 'package:frontegg_flutter_application_id_example/tenants_tab.dart';
import 'package:frontegg_flutter_application_id_example/user_tab.dart';

/// UserPage
class UserPage extends StatefulWidget {
  const UserPage({
    super.key,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? "User" : "Tenants"),
        centerTitle: true,
        actions: [
          if (_currentIndex == 0)
            // Refresh token button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                // Refresh token
                await frontegg.refreshToken();
              },
            )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // If the index is different from the current index, update the current index
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          // Profile tab
          BottomNavigationBarItem(
            key: ValueKey("ProfileTab"),
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          // Tenants tab
          BottomNavigationBarItem(
            key: ValueKey("TenantTab"),
            icon: Icon(Icons.notifications),
            label: "Tenant",
          ),
        ],
      ),
      body: _currentIndex == 0 ? const UserTab() : const TenantsTab(),
    );
  }
}
