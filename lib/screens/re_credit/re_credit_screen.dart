import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../utils/nav_helper.dart';
import '../../utils/re_credit_manager.dart';
import '../../utils/screen_adapter.dart';

class ReCreditScreen extends StatefulWidget {
  final String productId;

  const ReCreditScreen({super.key, required this.productId});

  @override
  State<ReCreditScreen> createState() => _ReCreditScreenState();
}

class _ReCreditScreenState extends State<ReCreditScreen> {
  Timer? _progressTimer;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    ReCreditManager.setPageVisible(true);
    ReCreditManager.start(widget.productId);
    _startProgress();
  }

  @override
  void dispose() {
    ReCreditManager.setPageVisible(false);
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    const totalSeconds = 30;
    final step = 100 / totalSeconds;
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_progress >= 100) {
        timer.cancel();
        return;
      }
      setState(() => _progress = min(100, _progress + step));
    });
  }

  @override
  Widget build(BuildContext context) {
    final percent = _progress.round();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  AppAssets.reCreditBg,
                  width: 160.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 18.h),
                _ProgressPill(text: 'Progress $percent%'),
                SizedBox(height: 16.h),
                Text(
                  'Calculating your credit limit, just 30 seconds\nPlease wait patiently',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF9B95A3),
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 20.w, top: 8.h),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: NavHelper.back,
                child: SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: Center(
                    child: Image.asset(
                      AppAssets.iconBack,
                      width: 22.w,
                      height: 22.w,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final String text;

  const _ProgressPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF7B39F5), width: 1.w),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF7B39F5),
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
