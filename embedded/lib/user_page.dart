import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import 'theme.dart';
import 'utils.dart';
import 'widgets/footer.dart';
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
  Timer? _hideMessageTimer;

  Widget? _messageWidget;

  @override
  void dispose() {
    super.dispose();
    _hideMessageTimer?.cancel();
  }

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

          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state.isAuthenticated && state.user != null) {
            final user = state.user;

            return Stack(
              children: [
                SizedBox.expand(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        if (_messageWidget != null) _messageWidget!,
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Card(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 13.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (user != null)
                                    Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        "Hello, ${user.name.split(" ")[0]}!",
                                        style:
                                            textTheme.headlineSmall?.copyWith(
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
                                      bottom: 8,
                                    ),
                                    // Receive access token button
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final accessToken = state.accessToken;
                                        if (accessToken != null && accessToken.isNotEmpty) {
                                          await Clipboard.setData(
                                            ClipboardData(text: accessToken),
                                          );
                                          Fluttertoast.showToast(
                                            msg: "Access token was copied to clipboard",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: primaryColor,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        } else {
                                          _showFailureMessage(
                                            "Access token is not available",
                                          );
                                        }
                                      },
                                      child: const Text("Receive access token"),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      left: 10.5,
                                      right: 10.5,
                                      bottom: 24,
                                    ),
                                    // Sensitive action button
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        const maxAge = Duration(minutes: 1);
                                        final isSteppedUp =
                                            await frontegg.isSteppedUp(
                                          maxAge: maxAge,
                                        );
                                        if (isSteppedUp) {
                                          _showSuccessMessage(
                                            "You are already stepped up",
                                          );
                                        } else {
                                          try {
                                            await frontegg.stepUp();
                                            _showSuccessMessage(
                                              "Action completed successfully",
                                            );
                                          } catch (e) {
                                            _showFailureMessage(
                                              "Failed to step up: $e",
                                            );
                                          }
                                        }
                                      },
                                      child: const Text("Sensitive action"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 220),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FutureBuilder<bool>(
                    future: context.isDefaultCredentials,
                    builder: (context, asyncSnapshot) {
                      if (!asyncSnapshot.hasData) {
                        return const SizedBox();
                      }

                      final isDefaultCredentials = asyncSnapshot.data!;

                      return Footer(
                        showSignUpBanner: isDefaultCredentials,
                      );
                    },
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

  void _showSuccessMessage(String msg) {
    final size = MediaQuery.sizeOf(context);
    setState(() {
      _messageWidget = Container(
        width: size.width - 48,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8FEE0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4DA82D),
              size: 16,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: size.width - 48 - 16 - 16 - 8 - 16,
              child: Text(
                msg,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF4DA82D),
                      fontSize: 14,
                    ),
              ),
            ),
          ],
        ),
      );
    });
    _hideMessage();
  }

  void _showFailureMessage(String msg) {
    final size = MediaQuery.sizeOf(context);
    setState(() {
      _messageWidget = Container(
        width: size.width - 48,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error,
              color: Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: size.width - 48 - 16 - 16 - 8 - 16,
              child: Text(
                msg,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.red,
                      fontSize: 14,
                    ),
              ),
            ),
          ],
        ),
      );
    });
    _hideMessage();
  }

  void _hideMessage() {
    _hideMessageTimer?.cancel();
    _hideMessageTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        _messageWidget = null;
      });
    });
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
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 12.0,
                    top: 4.0,
                    bottom: 4.0,
                  ),
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
                          "Name",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Email",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Roles",
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
            DropdownMenu<FronteggTenant>(
              initialSelection: activeTenant,
              expandedInsets: EdgeInsets.zero,
              inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none,
              ),
              trailingIcon: Image.asset(
                "assets/menu-icon.png",
                width: 16,
                height: 24,
              ),
              selectedTrailingIcon: Image.asset(
                "assets/menu-icon.png",
                width: 16,
                height: 24,
              ),
              leadingIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
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
              ),
              menuStyle: const MenuStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
                minimumSize:
                    WidgetStatePropertyAll(Size.fromWidth(double.infinity)),
                maximumSize:
                    WidgetStatePropertyAll(Size.fromWidth(double.infinity)),
              ),
              dropdownMenuEntries: tenants
                  .map(
                    (tenant) => DropdownMenuEntry<FronteggTenant>(
                      value: tenant,
                      labelWidget: Text(
                        tenant.name,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              tenant == activeTenant ? FontWeight.w600 : null,
                          color: tenant == activeTenant ? primaryColor : null,
                        ),
                      ),
                      leadingIcon: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircleAvatar(
                          backgroundColor: grayColor,
                          child: Text(
                            activeTenant.name[0],
                            style: textTheme.headlineSmall?.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF7A7C81),
                            ),
                          ),
                        ),
                      ),
                      trailingIcon: tenant == activeTenant
                          ? const Icon(
                              Icons.check,
                              color: primaryColor,
                              size: 20,
                            )
                          : null,
                      label: tenant.name,
                    ),
                  )
                  .toList(),
              onSelected: (tenant) async {
                if (tenant == null) return;
                await frontegg.switchTenant(tenant.tenantId);
              },
            ),
            const SizedBox(height: 4),
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
                            "ID",
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Website",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Creator",
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
                              width: MediaQuery.sizeOf(context).width * 0.35,
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
