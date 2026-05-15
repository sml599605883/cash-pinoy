import 'package:flutter/material.dart';

import '../../../constants/app_assets.dart';
import '../../../utils/screen_adapter.dart';

class QuickSteps extends StatelessWidget {
  const QuickSteps({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: Image.asset(
        AppAssets.quickSteps,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
