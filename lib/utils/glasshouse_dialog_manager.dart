import 'package:cash_pinoy/widgets/glasshouse_image_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../network/api_endpoints.dart';
import '../utils/hud_manager.dart';
import '../utils/request_error.dart';
import '../utils/nav_helper.dart';
import '../widgets/update_dialog.dart';

class GlasshouseDialogManager {
  static bool _loading = false;
  static final Map<int, DateTime> _lastShownAt = {};

  static Future<void> checkAndShow(
    BuildContext context, {
    required int adaptationPage,
  }) async {
    if (_loading) return;
    if (_shouldThrottle(adaptationPage)) return;
    if (HudManager.isShowing) return;
    _loading = true;
    try {
      final response = await AppApi().fetchDialog(
        adaptationPage: '$adaptationPage',
      );
      final dialogJson = response.dysphasias['hamulous'];
      final type = response.dysphasias['dipteral'].intValue;
      final link = dialogJson['dampen'].stringValue;
      _lastShownAt[adaptationPage] = DateTime.now();
      if (!context.mounted) return;
      if (type == 3) {
        final imageUrl = dialogJson['discophiles'].stringValue;
        if (imageUrl.isEmpty) return;
        if (imageUrl.isEmpty) return;
        await GlasshouseImageDialog.show(
          context,
          imageUrl: imageUrl,
          onTap: () {
            NavHelper.toScheme(link);
          },
        );
      } else if (type == 1) {
        final title = 'New version released';
        final version = dialogJson['rippling'].stringValue;
        final messages = dialogJson['semicentennial'].stringValue;
        final buttonText = 'Update Now';
        await UpdateDialog.show(
          context,
          title: title,
          version: version,
          messages: messages,
          buttonText: buttonText,
          onUpdate: () async {
            if (!await launchUrl(
              Uri.parse(link),
              mode: LaunchMode.externalApplication,
            )) {
              throw Exception('Open link Error');
            }
          },
        );
      }
    } catch (e) {
      // ignore dialog errors
      // ignore: avoid_print
      print(RequestError.message(e));
    } finally {
      _loading = false;
    }
  }

  static bool _shouldThrottle(int page) {
    final last = _lastShownAt[page];
    if (last == null) return false;
    return DateTime.now().difference(last).inSeconds < 3;
  }
}
