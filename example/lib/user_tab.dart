import 'package:flutter/material.dart';
import 'package:frontegg/frontegg.dart';
import 'package:frontegg/models/frontegg_state.dart';
import 'package:provider/provider.dart';

class UserTab extends StatelessWidget {
  const UserTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final frontegg = context.read<FronteggFlutter>();
    final size = MediaQuery.of(context).size;
    return Center(
      child: StreamBuilder<FronteggState>(
        stream: frontegg.onStateChanged,
        builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
          if (snapshot.hasData && snapshot.data?.user != null) {
            final state = snapshot.data!;
            final user = state.user!;
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
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
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
                  ElevatedButton(
                    child: const Text(
                      "Logout",
                    ),
                    onPressed: () {
                      frontegg.logout();
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
