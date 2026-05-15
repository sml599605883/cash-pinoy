import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:flutter/material.dart';

import '../network/api_endpoints.dart';
import 'app_info_manager.dart';
import 'hud_manager.dart';
import '../widgets/retention_dialog.dart';

class RetentionHelper {
  static Future<void> confirmLeave(
    BuildContext context, {
    required String inputType,
    String? productId,
  }) async {
    if (HudManager.isShowing) return;
    try {
      HudManager.showLoading();
      final response = await CertifyApi().fetchRetainDialog(
        inputType: inputType,
        productId: productId ?? AppInfoManager.productId,
      );
      final dampen = response.dysphasias['hamulous']['dampen'].stringValue;
      HudManager.dismiss();
      if (dampen.isEmpty) {
        NavHelper.back();
        return;
      }
      final shouldPop = await RetentionDialog.confirm(
        context,
        imageUrl: dampen,
      );
      if (shouldPop) {
        NavHelper.back();
      }
    } catch (_) {
      HudManager.dismiss();
      NavHelper.back();
    }
  }
}
