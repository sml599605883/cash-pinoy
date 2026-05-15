import 'package:flutter/material.dart';

import '../../../constants/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_adapter.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final bool showIcon;

  const SectionTitle({super.key, required this.title, this.showIcon = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showIcon) ...[
          Image.asset(AppAssets.heroBadge, width: 16.w, height: 16.w),
          SizedBox(width: 8.w),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }
}
