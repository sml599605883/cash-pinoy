import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../model/form_fields_model.dart';
import '../utils/screen_adapter.dart';

class AnnouncerSelectSheet extends StatefulWidget {
  final List<FormOptionModel> options;

  const AnnouncerSelectSheet({super.key, required this.options});

  @override
  State<AnnouncerSelectSheet> createState() => _AnnouncerSelectSheetState();
}

class _AnnouncerSelectSheetState extends State<AnnouncerSelectSheet> {
  FormOptionModel? _selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(14.w),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 25.h),
                padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 32.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9C9FF),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    SizedBox(
                      height:
                          60.h *
                              (widget.options.length < 5
                                  ? widget.options.length
                                  : 5) +
                          10.h *
                              (widget.options.length < 4
                                  ? widget.options.length
                                  : 4),
                      child: ListView.separated(
                        itemCount: widget.options.length,
                        itemBuilder: (context, index) {
                          final item = widget.options[index];
                          return _SelectItem(
                            label: item.unpaid,
                            selected: _selected == item,
                            onTap: () => setState(() => _selected = item),
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                child: Center(
                  child: Image.asset(AppAssets.idSelect, height: 47.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(_selected),
            child: Container(
              height: 44.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF7B39F5),
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const _SelectItem({
    required this.label,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFC4ABFF),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (selected)
              Image.asset(AppAssets.isSelected, width: 24.w, height: 24.h),
          ],
        ),
      ),
    );
  }
}
