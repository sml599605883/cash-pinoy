import 'dart:async';

import 'package:cash_pinoy/network/api_endpoints.dart';
import 'package:cash_pinoy/screens/bind/withdraw_info_screen.dart';
import 'package:cash_pinoy/screens/loan/loan_detail_screen.dart';
import 'package:cash_pinoy/utils/hud_manager.dart';
import 'package:cash_pinoy/utils/request_error.dart';
import 'package:flutter/material.dart';

import '../../../model/home_model.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/nav_helper.dart';
import '../../../utils/screen_adapter.dart';

class OrderStatusCard extends StatefulWidget {
  final List<HomeProcessModel> processList;

  const OrderStatusCard({super.key, required this.processList});

  @override
  State<OrderStatusCard> createState() => _OrderStatusCardState();
}

class _OrderStatusCardState extends State<OrderStatusCard> {
  static const int _loopStart = 1000;
  Timer? _timer;
  PageController? _controller;
  int _currentPage = 0;

  bool get _enableLoop => widget.processList.length > 1;

  @override
  void initState() {
    super.initState();
    _setupController();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant OrderStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.processList.length != widget.processList.length) {
      _timer?.cancel();
      _controller?.dispose();
      _setupController();
      _startTimer();
    }
  }

  void _setupController() {
    if (widget.processList.isEmpty) return;
    _currentPage = _enableLoop ? widget.processList.length * _loopStart : 0;
    _controller = PageController(initialPage: _currentPage);
  }

  void _startTimer() {
    if (!_enableLoop) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _controller == null || !_controller!.hasClients) return;
      _currentPage += 1;
      _controller!.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.processList.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () {
        if (widget.processList.isEmpty) return;
        final current =
            widget.processList[_currentPage % widget.processList.length];
        if (current.dampen.isEmpty) {
          NavHelper.enterProduct(productId: current.strikes);
        } else {
          HudManager.showLoading();
          NavHelper.toScheme(current.dampen);
        }
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A118A), Color(0xFFF06BC6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'View My Order Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: Colors.white, size: 20.sp),
              ],
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: SizedBox(
                height: 92.h,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _enableLoop ? null : widget.processList.length,
                  onPageChanged: (index) => _currentPage = index,
                  itemBuilder: (context, index) {
                    final item =
                        widget.processList[index % widget.processList.length];
                    return _ProcessItem(model: item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessItem extends StatelessWidget {
  final HomeProcessModel model;

  const _ProcessItem({required this.model});

  @override
  Widget build(BuildContext context) {
    final amount = model.feminity;
    final date = model.birl;
    final showActions = model.artistic.any((element) => element.babiest);
    final actions = model.artistic.where((element) => element.babiest).toList();
    return Column(
      children: [
        Container(
          height: 26.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            gradient: LinearGradient(
              colors: model.bgColors,
              begin: AlignmentGeometry.centerLeft,
              end: AlignmentGeometry.centerRight,
            ),
          ),
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Image.network(
                  model.enalapril,
                  errorBuilder: (context, error, stackTrace) => SizedBox(),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  model.prostitute,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              Spacer(),
              Expanded(
                child: Text(
                  model.overdried,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: model.statusColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            if (!showActions) SizedBox(width: 30.w),
            Expanded(
              child: _StatusInfo(value: amount, label: model.denies),
            ),
            Expanded(
              child: _StatusInfo(
                value: date,
                label: model.loci,
                cAlignment: CrossAxisAlignment.end,
              ),
            ),
            if (!showActions) SizedBox(width: 30.w),
            if (showActions) ...[
              SizedBox(width: 10.w),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: actions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == actions.length - 1 ? 0 : 6.h,
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        if (item.dipteral == 'retry') {
                          try {
                            HudManager.showLoading();
                            final response = await RetryApi()
                                .retryOrderRequests(model.defilading);
                            final newUrl =
                                response.dysphasias['belletristic'].stringValue;
                            HudManager.dismiss();
                            NavHelper.toScheme(newUrl);
                          } catch (e) {
                            HudManager.showFailure(
                              message: RequestError.message(e),
                            );
                          }
                          return;
                        } else if (item.dipteral == 'change') {
                          final productId = model.strikes;
                          final orderNo = model.defilading;
                          // change account
                          try {
                            HudManager.showLoading();
                            final response = await CertifyApi()
                                .fetchUserCardList(productId: productId);
                            final model =
                                response.dysphasias['bleaching'].listValue;
                            HudManager.dismiss();
                            if (model.isNotEmpty) {
                              NavHelper.to(
                                LoanDetailScreen(
                                  productId: productId,
                                  orderNo: orderNo,
                                ),
                              );
                            } else {
                              NavHelper.to(
                                WithdrawInfoScreen(
                                  productId: productId,
                                  orderNo: orderNo,
                                ),
                              );
                            }
                          } catch (e) {
                            HudManager.showFailure(
                              message: RequestError.message(e),
                            );
                          }
                          return;
                        } else if (item.dipteral == 'repay') {
                          if (model.dampen.isEmpty) {
                            NavHelper.enterProduct(productId: model.strikes);
                          } else {
                            NavHelper.toScheme(model.dampen);
                          }
                          return;
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        width: 80.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _StatusInfo extends StatelessWidget {
  final String value;
  final String label;
  final CrossAxisAlignment cAlignment;

  const _StatusInfo({
    required this.value,
    required this.label,
    this.cAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: cAlignment,
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(color: AppColors.muted, fontSize: 11.sp),
        ),
      ],
    );
  }
}
