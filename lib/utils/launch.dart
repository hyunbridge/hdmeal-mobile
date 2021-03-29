// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

void launch(BuildContext context, String _url) {
  try {
    if (kIsWeb) {
      throw UnimplementedError();
    }
    FlutterWebBrowser.openWebPage(
      url: _url,
      customTabsOptions: CustomTabsOptions(
        toolbarColor: Theme.of(context).primaryColor,
        navigationBarColor: Theme.of(context).primaryColor,
      ),
    );
  } catch (_) {
    urlLauncher.launch(_url);
  }
}
