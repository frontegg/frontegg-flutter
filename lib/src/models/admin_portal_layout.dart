/// How the embedded Admin Portal lays itself out.
enum AdminPortalLayout {
  /// Renders the portal at 1024px and scales it to fit, with the sidebar always visible.
  desktop("desktop"),

  /// Uses the device's real width, so on phones the sidebar collapses into a menu button.
  responsive("responsive");

  /// The value sent to the native SDKs.
  final String value;

  /// Creates an [AdminPortalLayout] with the given [value].
  const AdminPortalLayout(this.value);
}
