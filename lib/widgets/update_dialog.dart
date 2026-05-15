import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../utils/screen_adapter.dart';

class UpdateDialog extends StatelessWidget {
  final String title;
  final String version;
  final String messages;
  final String buttonText;
  final VoidCallback? onUpdate;

  const UpdateDialog({
    super.key,
    required this.title,
    required this.version,
    required this.messages,
    this.buttonText = 'Update Now',
    this.onUpdate,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String version = '',
    String messages = '',
    String buttonText = 'Update Now',
    VoidCallback? onUpdate,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDialog(
        title: title,
        version: version,
        messages: messages,
        buttonText: buttonText,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final imageHeight = width * 110 / 320;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Image.asset(AppAssets.updateBg, fit: BoxFit.cover),
                ),
                SizedBox(height: 32.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
                if (version.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Text(
                    version,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF7B7B7B),
                    ),
                  ),
                ],
                if (messages.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      messages,
                      textAlign: TextAlign.center,
                      maxLines: 10,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF7B7B7B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 18.h),
                Padding(
                  padding: EdgeInsets.only(bottom: 18.h),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      onUpdate?.call();
                    },
                    child: Container(
                      height: 40.h,
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B39F5),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        buttonText,
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
          );
        },
      ),
    );
  }
}
