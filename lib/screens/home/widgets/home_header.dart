import 'package:cash_pinoy/constants/app_assets.dart';
import 'package:cash_pinoy/utils/screen_adapter.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onSupportTap;

  const HomeHeader({super.key, this.onSupportTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 20.w),
        Image.asset(
          AppAssets.regulatorBadge,
          height: 36.h,
          fit: BoxFit.contain,
        ),
        Spacer(),
        InkWell(
          onTap: onSupportTap,
          child: Image.asset(
            AppAssets.iconSupport,
            // color: AppColors.purple,
            width: 36.w,
            height: 36.h,
          ),
        ),
        SizedBox(width: 20.w),
      ],
    );
  }
}
