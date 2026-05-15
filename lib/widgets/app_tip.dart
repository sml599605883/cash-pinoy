import 'package:cash_pinoy/constants/app_assets.dart';
import 'package:cash_pinoy/utils/screen_adapter.dart';
import 'package:flutter/material.dart';

class AppTip extends StatelessWidget {
  final String title;

  const AppTip({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 10.w, right: 20.w),
      child: Stack(
        children: [
          Positioned(
            top: 16.h,
            left: 17.h,
            right: 0.h,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19.w),
                color: Color(0x4D000000),
              ),
              padding: EdgeInsets.only(
                top: 8.h,
                left: 52.w,
                bottom: 8.h,
                right: 14.w,
              ),
              // height: 44.h,
              alignment: Alignment.center,
              child: Text(
                title,
                maxLines: 2,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  height: 1.1,
                ),
              ),
            ),
          ),
          Image.asset(AppAssets.tipImg, width: 64.w, height: 64.h),
        ],
      ),
    );
  }
}
