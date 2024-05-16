import 'package:flutter/material.dart';
import 'package:frontegg/frontegg_flutter.dart';
import 'package:frontegg_flutter_example/tenants_tab.dart';
import 'package:frontegg_flutter_example/user_tab.dart';

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
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await frontegg.refreshToken();
              },
            )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Tenant",
          ),
        ],
      ),
      body: _currentIndex == 0 ? const UserTab() : const TenantsTab(),
    );
  }
}
