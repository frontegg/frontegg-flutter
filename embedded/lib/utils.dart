import 'package:flutter/cupertino.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';
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

extension BuildContextEx on BuildContext {
  Future<bool> get isDefaultCredentials async {
    final constants = await frontegg.getConstants();
    return constants.baseUrl == "https://autheu.davidantoon.me";
  }
}
