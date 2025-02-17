/// Enum representing supported social authentication providers in Frontegg.
enum FronteggSocialProvider {
  /// Google authentication provider.
  google("google"),

  /// LinkedIn authentication provider.
  linkedin("linkedin"),

  /// Facebook authentication provider.
  facebook("facebook"),

  /// GitHub authentication provider.
  github("github"),

  /// Apple authentication provider.
  apple("apple"),

  /// Microsoft authentication provider.
  microsoft("microsoft"),

  /// Slack authentication provider.
  slack("slack");

  /// The string representation of the provider type.
  final String type;

  /// Creates a [FronteggSocialProvider] with the given [type].
  const FronteggSocialProvider(this.type);
}
