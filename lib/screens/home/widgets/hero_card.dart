import 'package:cash_pinoy/constants/app_assets.dart';
import 'package:cash_pinoy/model/home_model.dart';
import 'package:cash_pinoy/theme/app_colors.dart';
import 'package:cash_pinoy/utils/screen_adapter.dart';
import 'package:flutter/material.dart';
import 'home_header.dart';

class HeroCard extends StatelessWidget {
  final HomeLargeCardModel? model;
  final VoidCallback? onTap;
  final VoidCallback? onSupportTap;

  const HeroCard({super.key, this.model, this.onTap, this.onSupportTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFE1CBFB), Colors.white],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            HomeHeader(onSupportTap: onSupportTap),
            SizedBox(height: 20.h),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppAssets.heroBg),
                      fit: BoxFit.fill,
                    ),
                  ),
                  height: 278.h,
                  padding: EdgeInsets.fromLTRB(34.w, 20.h, 34.w, 22.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 6.w),
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDAD1E8),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Image.network(
                              model?.caesiums ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox();
                              },
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            model?.preadapt ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      SizedBox(
                        height: 45.h,
                        child: Text(
                          model?.sternite ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        height: 72.h,
                        child: _HeroRateRow(model: model),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        model?.amendable ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                      const Spacer(),
                      _HeroApplyButton(title: model?.pargetting ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroRateRow extends StatelessWidget {
  final HomeLargeCardModel? model;
  const _HeroRateRow({this.model});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0.h,
          left: 0.w,
          child: SizedBox(
            height: 16.h,
            child: Text(
              model?.charpoy ?? '',
              style: TextStyle(color: Color(0xffd9c9ff), fontSize: 14.sp),
            ),
          ),
        ),
        if (model != null &&
            model!.egestions.isEmpty &&
            model!.transcendency.isEmpty)
          Positioned(
            top: 30.h,
            left: 0.w,
            child: Row(
              children: [
                _RateChip(icon: AppAssets.iconTerm, label: model!.wistfulness),
                SizedBox(width: 10.w),
                _RateChip(icon: AppAssets.iconRate, label: model!.taffarel),
              ],
            ),
          ),
        if (model != null && model!.transcendency.isNotEmpty)
          Positioned(
            top: 30.h,
            left: 0.w,
            right: 0.w,
            bottom: 0.w,
            child: Row(
              children: List.generate(model!.transcendency.length * 2 - 1, (
                index,
              ) {
                if (index.isOdd) {
                  return SizedBox(width: 10.w);
                }
                final item = model!.transcendency[index ~/ 2];
                return _PeriodTag(
                  title: '${item.pirates} Period',
                  label: item.taffarel,
                );
              }),
            ),
          ),
        if (model != null && model!.egestions.isNotEmpty)
          Positioned(
            top: 0.h,
            right: 0.w,
            left: 0.w,
            bottom: 0.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAssets.heroProcess),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 30.h,
                    child: Row(
                      children: [
                        Spacer(),
                        Text(
                          'My unlocked limit(₱)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ...model!.egestions.map(
                          (item) => Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                color: item.imides == '1'
                                    ? Color(0x33FFFFFF)
                                    : Color(0xFF3D1C79),
                                border: Border.all(
                                  color: item.imides == '1'
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 1.w,
                                ),
                              ),
                              child: Text(
                                item.choky,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: item.imides == '1'
                                      ? Colors.white
                                      : Color(0xFF8057CC),
                                  fontSize: 14.sp,
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
      ],
    );
  }
}

class _PeriodTag extends StatelessWidget {
  final String title;
  final String label;

  const _PeriodTag({required this.label, required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 30.h,
          margin: EdgeInsets.only(top: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: AppColors.chipDark,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0.h,
          left: 0.w,
          child: Container(
            height: 16.h,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              color: AppColors.chipOrange,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RateChip extends StatelessWidget {
  final String icon;
  final String label;

  const _RateChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 5.w, right: 15.w, top: 5.h, bottom: 5.h),
      decoration: BoxDecoration(
        color: AppColors.chipDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 20.w, height: 20.w),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroApplyButton extends StatelessWidget {
  final String title;
  const _HeroApplyButton({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          AppAssets.iconApply,
          // color: AppColors.purple,
          width: 22.w,
          height: 22.h,
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Image.asset(
          AppAssets.iconArrow,
          // color: AppColors.purple,
          width: 38.w,
          height: 22.h,
        ),
      ],
    );
  }
}
