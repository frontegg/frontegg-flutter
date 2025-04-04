import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

/// UserTab
/// 
/// This is a stateless widget that builds the user tab.
/// It is used to display the user's profile information.
/// 
class UserTab extends StatelessWidget {
  const UserTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    final size = MediaQuery.of(context).size;
    return Center(
      // StreamBuilder to listen to the state of the authentication
      child: StreamBuilder<FronteggState>(
        stream: frontegg.stateChanged,
        builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
          if (snapshot.hasData && snapshot.data?.user != null) {
            final state = snapshot.data!;
            final user = state.user!;
            // If the user is authenticated and the user is not null, show the user tab
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: size.width / 6,
                  backgroundImage: NetworkImage(user.profilePictureUrl),
                ),
                const SizedBox(height: 20),
                Text(
                  user.name,
                  style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  user.activeTenant.name,
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 40),
                if (state.isLoading) const CircularProgressIndicator(),
                if (!state.isLoading)
                  // Register Passkeys Button
                  ElevatedButton(
                    child: const Text("Register Passkeys"),
                    onPressed: () async {
                      try {
                        await frontegg.registerPasskeys();
                        debugPrint("Passkeys registered");
                      } on FronteggException catch (e) {
                        debugPrint("Exception: $e");
                      }
                    },
                  ),
                if (!state.isLoading)
                  // Logout Button
                  ElevatedButton(
                    key: const ValueKey("LogoutButton"),
                    child: const Text("Logout"),
                    onPressed: () async {
                      await frontegg.logout();
                      debugPrint("Logout Finished");
                    },
                  ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
