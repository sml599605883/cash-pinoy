import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import '../utils/screen_adapter.dart';

class AppTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppTabBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _TabItem(
                label: 'Home',
                asset: currentIndex == 0
                    ? AppAssets.tabHomeS
                    : AppAssets.tabHomeN,
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _TabItem(
                label: 'Mine',
                asset: currentIndex == 1
                    ? AppAssets.tabMineS
                    : AppAssets.tabMineN,
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        // decoration: BoxDecoration(
        //   color: selected ? const Color(0xFFF1ECFF) : Colors.white,
        //   borderRadius: BorderRadius.circular(16),
        //   border: Border.all(color: AppColors.cardBorder),
        // ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: selected ? 1 : 0.45,
              child: Image.asset(asset, width: 22.w, height: 22.w),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.purple : AppColors.mutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
