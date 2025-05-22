import 'package:url_launcher/url_launcher.dart' as url_launcher;

Future<bool> launchUrl(
  String strUrl,
) async {
  try {
    final url = Uri.parse(strUrl);
    final canLaunchUrl = await url_launcher.canLaunchUrl(url);
    if (canLaunchUrl) {
      await url_launcher.launchUrl(
        url,
        mode: url_launcher.LaunchMode.externalApplication,
      );
      return true;
    } else {
      return false;
    }
  } on FormatException catch (_) {
    return false;
  }
}
