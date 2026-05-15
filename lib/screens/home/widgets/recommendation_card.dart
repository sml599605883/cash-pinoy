import 'package:flutter/material.dart';

import '../../../model/home_model.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/nav_helper.dart';
import '../../../utils/screen_adapter.dart';

class RecommendationCard extends StatelessWidget {
  final HomeProductModel product;

  const RecommendationCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final title = product.preadapt;
    final status = _pickStatus(product);
    final buttonLabel = product.pargetting;
    final amount = product.sternite;
    final rate = product.speakable;
    return GestureDetector(
      onTap: () {
        NavHelper.enterProduct(productId: product.uniquely);
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE1C7FF),
                    Color(0x00C4A5FF),
                    Color(0x00C4A5FF),
                  ],
                  begin: AlignmentGeometry.centerLeft,
                  end: AlignmentGeometry.centerRight,
                ),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Image.network(
                      product.caesiums,
                      errorBuilder: (context, error, stackTrace) => SizedBox(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  Spacer(),
                  Flexible(
                    child: Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(color: AppColors.muted, fontSize: 11.sp),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 55.w),
              child: ElevatedButton(
                onPressed: () {
                  if (product.uniquely.isNotEmpty) {
                    NavHelper.enterProduct(productId: product.uniquely);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: product.oxidising != '0'
                      ? Color(0xFFBEB7C8)
                      : Color(0xFF962EF2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _ValueBlock(value: amount, label: product.charpoy),
                ),
                Expanded(
                  child: _ValueBlock(
                    value: rate,
                    label: product.precipitantness,
                    alignment: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _pickStatus(HomeProductModel model) {
    return '${model.pandowdy}:${model.wistfulness}';
  }
}

class _ValueBlock extends StatelessWidget {
  final String value;
  final String label;
  final CrossAxisAlignment alignment;

  const _ValueBlock({
    required this.value,
    required this.label,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.purple,
          ),
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
