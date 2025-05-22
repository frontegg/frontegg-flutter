import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import 'theme.dart';
import 'widgets/frontegg_app_bar.dart';

/// UserPage
class UserPage extends StatefulWidget {
  const UserPage({
    super.key,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const FronteggAppBar(),
      body: StreamBuilder(
        stream: frontegg.stateChanged,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          final state = snapshot.data!;
          if (state.isAuthenticated && state.user != null) {
            final user = state.user;

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (user != null)
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      "Hello, ${user.name.split(" ")[0]}!",
                                      style: textTheme.headlineSmall?.copyWith(
                                        color: const Color(0xFF202020),
                                      ),
                                    ),
                                  ),
                                if (user != null)
                                  TenantInfo(
                                    activeTenant: user.activeTenant,
                                    tenants: user.tenants,
                                  ),
                                const SizedBox(height: 20),
                                if (user != null) UserInfo(user: user),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16.0,
                                    left: 10.5,
                                    right: 10.5,
                                    bottom: 24,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    child: const Text("Sensitive action"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F8FF),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: double.infinity,
                              ),
                              Text(
                                'This sample uses Frontegg\'s default credentials.\nSign up to use your own configurations',
                                style: textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("User not authenticated"));
          }
        },
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  final FronteggUser user;

  const UserInfo({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.profilePictureUrl),
                    radius: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  user.name,
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(
              thickness: 1,
              height: 1,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Flexible(
                    flex: 3,
                    fit: FlexFit.tight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name:",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Email:",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Roles:",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF7A7C81),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.email,
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF7A7C81),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.roles.isNotEmpty
                              ? user.roles.map((e) => e.name).join(", ")
                              : "No roles assigned",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF7A7C81),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TenantInfo extends StatelessWidget {
  final FronteggTenant activeTenant;
  final List<FronteggTenant> tenants;

  const TenantInfo({
    super.key,
    required this.activeTenant,
    required this.tenants,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final frontegg = context.frontegg;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircleAvatar(
                    backgroundColor: grayColor,
                    radius: 12,
                    child: Text(
                      activeTenant.name[0],
                      style: textTheme.headlineSmall?.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF7A7C81),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  activeTenant.name,
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(
              thickness: 1,
              height: 1,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 3,
                    fit: FlexFit.tight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Text(
                            "ID:",
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Website:",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Creator:",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.38,
                              height: 30,
                              child: Text(
                                activeTenant.id,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF7A7C81),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: IconButton(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: activeTenant.id),
                                  );
                                  Fluttertoast.showToast(
                                    msg: "Tenant ID was copied to clipboard",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: primaryColor,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                },
                                icon: const Icon(
                                  Icons.copy,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          activeTenant.website ?? "No website",
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF7A7C81),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          activeTenant.creatorName ?? "Unknown",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF7A7C81),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
