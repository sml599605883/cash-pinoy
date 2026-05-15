import 'package:cash_pinoy/screens/bind/withdraw_info_screen.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../model/loan_card_model.dart';
import '../../network/api_endpoints.dart';
import '../../utils/hud_manager.dart';
import '../../utils/request_error.dart';
import '../../utils/screen_adapter.dart';

class LoanDetailScreen extends StatefulWidget {
  final String productId;
  final String orderNo;

  const LoanDetailScreen({
    super.key,
    required this.productId,
    required this.orderNo,
  });

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  List<LoanCardSectionModel> _sections = const [];

  @override
  void initState() {
    super.initState();
    _fetchUserCardList();
  }

  Future<void> _fetchUserCardList() async {
    var didShowLoading = false;
    try {
      if (!HudManager.isShowing) {
        HudManager.showLoading();
        didShowLoading = true;
      }
      final response = await CertifyApi().fetchUserCardList(
        productId: widget.productId,
      );
      final model = response.dysphasias['bleaching'].listValue
          .map(LoanCardSectionModel.fromJson)
          .toList();
      if (!mounted) return;
      setState(() => _sections = model);
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    } finally {
      if (didShowLoading) {
        HudManager.dismiss();
      }
    }
  }

  List<Widget> _buildSections() {
    final widgets = <Widget>[];
    for (final section in _sections) {
      final title = section.prosodists;
      final odeons = section.odeons;
      if (title.isNotEmpty) {
        widgets.add(_SectionTitle(title: title));
        widgets.add(SizedBox(height: 8.h));
      }
      for (final odeon in odeons) {
        widgets.add(
          _PaymentCard(
            selected: odeon.isSelected,
            title: odeon.tightwires,
            subtitle: 'Receipt Account',
            value: odeon.exaptive,
            iconUrl: odeon.matchboard,
            hint: odeon.isSafeguard ? odeon.postvagotomy : null,
            onTap: () {
              setState(() {
                for (final section in _sections) {
                  for (final item in section.odeons) {
                    item.setSelected(item == odeon);
                  }
                }
              });
            },
          ),
        );
        widgets.add(SizedBox(height: 12.h));
      }
      if (widgets.isNotEmpty) {
        widgets.add(SizedBox(height: 6.h));
      }
    }
    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }
    return widgets;
  }

  void _onSubmit() async {
    try {
      final selectedList = _sections
          .expand((s) => s.odeons)
          .where((o) => o.isSelected)
          .toList();
      if (selectedList.isEmpty) {
        HudManager.showFailure(message: 'Please choose');
        return;
      }
      final selected = selectedList.first;
      final response = await CertifyApi().changeBankCard(
        bindId: selected.tillers,
        orderNo: widget.orderNo,
      );
      final belletristic = response.dysphasias['belletristic'].stringValue;
      NavHelper.toScheme(belletristic);
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFFA),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              AppAssets.navBg,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        SizedBox(width: 12.w),
                        InkWell(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Image.asset(
                            AppAssets.iconBack,
                            width: 22.w,
                            height: 22.w,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Loan details',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 34.w),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.only(
                          left: 14.w,
                          right: 14.w,
                          bottom: 90.h,
                        ),
                        children: [
                          SizedBox(height: 38.h),
                          _AddPaymentCard(
                            onTap: () {
                              NavHelper.to(
                                WithdrawInfoScreen(
                                  productId: widget.productId,
                                  orderNo: widget.orderNo,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16.h),
                          ..._buildSections(),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 24.w,
                  right: 24.w,
                  bottom: 20.h,
                  child: GestureDetector(
                    onTap: _onSubmit,
                    child: Container(
                      height: 48.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7B39F5), Color(0xFF9E45F7)],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }
}

class _AddPaymentCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddPaymentCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 44.h,
        child: Image.asset(AppAssets.cardAdd, fit: BoxFit.contain),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(AppAssets.heroBadge, width: 18.w, height: 18.w),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final String value;
  final String? hint;
  final String? iconUrl;
  final VoidCallback? onTap;

  const _PaymentCard({
    required this.selected,
    this.title = '',
    this.subtitle = '',
    this.value = '',
    this.hint,
    this.iconUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showTitle = title.isNotEmpty;
    final showSubtitle = subtitle.isNotEmpty;
    final showValue = value.isNotEmpty;
    final showHint = hint != null && hint!.isNotEmpty;
    final showIcon = iconUrl != null && iconUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(20.w),
        child: Stack(
          children: [
            Positioned(
              child: Image.asset(
                AppAssets.cardBg,
                height: 150.h,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              right: 6.w,
              top: 6.h,
              child: Image.asset(
                selected ? AppAssets.cardS : AppAssets.cardN,
                width: 18.w,
                height: 18.w,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 17.h),
                if (showTitle || showIcon)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 17.w),
                      if (showIcon)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: Image.network(
                            iconUrl!,
                            width: 35.w,
                            height: 35.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      if (showIcon) SizedBox(width: 6.w),
                      if (showTitle)
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                    ],
                  ),
                if (showSubtitle) ...[
                  SizedBox(height: 16.h),
                  Container(
                    height: 20.h,
                    padding: EdgeInsets.only(left: 17.w),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF5B5B5B),
                      ),
                    ),
                  ),
                ],
                if (showValue) ...[
                  SizedBox(height: 14.h),
                  Container(
                    height: 28.h,
                    padding: EdgeInsets.only(left: 17.w),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
                if (showHint) ...[
                  SizedBox(height: 30.h),
                  Text(
                    hint ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFFFF6A35),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
