enum FronteggSocialProvider {
  google("google"),
  linkedin("linkedin"),
  facebook("facebook"),
  github("github"),
  apple("apple"),
  microsoft("microsoft"),
  slack("slack");

  final String type;

  const FronteggSocialProvider(this.type);
}
