import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../utils/screen_adapter.dart';

class RetentionDialog extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onGoBack;
  final String leftText;
  final String rightText;

  const RetentionDialog({
    super.key,
    required this.imageUrl,
    this.onGoBack,
    this.leftText = 'Go Back',
    this.rightText = 'Get Funds',
  });

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    VoidCallback? onGoBack,
    String leftText = 'Go Back',
    String rightText = 'Get Funds',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RetentionDialog(
        imageUrl: imageUrl,
        onGoBack: onGoBack,
        leftText: leftText,
        rightText: rightText,
      ),
    );
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String imageUrl,
    VoidCallback? onGoBack,
    String leftText = 'Go Back',
    String rightText = 'Get Funds',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RetentionDialog(
        imageUrl: imageUrl,
        onGoBack: onGoBack,
        leftText: leftText,
        rightText: rightText,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
      child: SizedBox(
        width: 316.w,
        child: AspectRatio(
          aspectRatio: 316 / 365,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF1E9FF),
                        alignment: Alignment.center,
                        child: Text(
                          'Image unavailable',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.4),
                            fontSize: 12.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                left: 24.w,
                right: 24.w,
                bottom: 24.h,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).maybePop(true);
                          onGoBack?.call();
                        },
                        child: Container(
                          height: 46.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8D5DD),
                            borderRadius: BorderRadius.circular(23.r),
                          ),
                          child: Text(
                            leftText,
                            style: TextStyle(
                              color: const Color(0xFF9B95A3),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(false),
                        child: Container(
                          height: 46.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage(AppAssets.dialogBtnBg),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(23.r),
                          ),
                          child: Text(
                            rightText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
