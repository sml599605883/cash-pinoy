import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../utils/screen_adapter.dart';

enum ActionConfirmType { logout, deleteAccount }

class ActionConfirmDialog extends StatelessWidget {
  final ActionConfirmType type;
  final String title;
  final String message;
  final String leftText;
  final String rightText;
  final VoidCallback? onLeft;

  const ActionConfirmDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.leftText,
    required this.rightText,
    this.onLeft,
  });

  static Future<void> show(
    BuildContext context, {
    required ActionConfirmType type,
    VoidCallback? onLeft,
  }) {
    final config = _resolveConfig(type);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ActionConfirmDialog(
        type: type,
        title: config.title,
        message: config.message,
        leftText: config.leftText,
        rightText: config.rightText,
        onLeft: onLeft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = 320.w;
    final height = width * 336 / 320;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SizedBox(
                height: 110.h,
                width: double.infinity,
                child: Image.asset(AppAssets.logoutBg, fit: BoxFit.cover),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 32.h),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF7B7B7B),
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: _DialogButton(
                              text: leftText,
                              filled: false,
                              onTap: () {
                                Navigator.of(context).pop();
                                onLeft?.call();
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _DialogButton(
                              text: rightText,
                              filled: true,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogConfig {
  final String title;
  final String message;
  final String leftText;
  final String rightText;

  const _DialogConfig({
    required this.title,
    required this.message,
    required this.leftText,
    required this.rightText,
  });
}

_DialogConfig _resolveConfig(ActionConfirmType type) {
  switch (type) {
    case ActionConfirmType.logout:
      return const _DialogConfig(
        title: 'Log out now?',
        message: 'Stay logged in to get updates on your limit and payments.',
        leftText: 'Log Out',
        rightText: 'Stay',
      );
    case ActionConfirmType.deleteAccount:
      return const _DialogConfig(
        title: 'We’ll miss you',
        message:
            'Deleting your account will remove your data and offers. You’ll need to apply again next time.',
        leftText: 'Delete',
        rightText: 'Keep Account',
      );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final bool filled;
  final VoidCallback onTap;

  const _DialogButton({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF7B39F5) : const Color(0xFFD9D6DC),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
