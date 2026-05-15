import 'dart:async';

import 'package:flutter/material.dart';

import '../../../model/home_model.dart';
import '../../../utils/screen_adapter.dart';

class PromoBanner extends StatefulWidget {
  final List<HomeBannerModel> banners;
  final ValueChanged<HomeBannerModel>? onTap;
  final Duration interval;

  const PromoBanner({
    super.key,
    required this.banners,
    this.onTap,
    this.interval = const Duration(seconds: 3),
  });

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  static const int _loopStart = 1000;
  Timer? _timer;
  late PageController _controller;
  int _currentPage = 0;

  bool get _enableLoop => widget.banners.length > 1;

  @override
  void initState() {
    super.initState();
    _currentPage = _enableLoop ? widget.banners.length * _loopStart : 0;
    _controller = PageController(initialPage: _currentPage);
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant PromoBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _timer?.cancel();
      _controller.dispose();
      _currentPage = _enableLoop ? widget.banners.length * _loopStart : 0;
      _controller = PageController(initialPage: _currentPage);
      _startTimer();
    }
  }

  void _startTimer() {
    if (!_enableLoop) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!_controller.hasClients) return;
      _currentPage += 1;
      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22.r),
      child: SizedBox(
        height: 120.h,
        width: double.infinity,
        child: PageView.builder(
          controller: _controller,
          itemCount: _enableLoop ? null : widget.banners.length,
          onPageChanged: (index) => _currentPage = index,
          itemBuilder: (context, index) {
            final banner = widget.banners[index % widget.banners.length];
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap == null ? null : () => widget.onTap!(banner),
              child: Image.network(
                banner.bannerUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE6DAFF),
                    alignment: Alignment.center,
                    child: Text(
                      'Image unavailable',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 12.sp,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
