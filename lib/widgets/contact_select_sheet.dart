import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../utils/screen_adapter.dart';

class ContactCandidate {
  final String name;
  final String phone;

  const ContactCandidate({required this.name, required this.phone});
}

class ContactSelectSheet extends StatefulWidget {
  final List<ContactCandidate> options;

  const ContactSelectSheet({super.key, required this.options});

  @override
  State<ContactSelectSheet> createState() => _ContactSelectSheetState();
}

class _ContactSelectSheetState extends State<ContactSelectSheet> {
  ContactCandidate? _selected;

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
                    ...widget.options.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _SelectItem(
                          name: item.name,
                          phone: item.phone,
                          selected: _selected == item,
                          onTap: () => setState(() => _selected = item),
                        ),
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
  final String name;
  final String phone;
  final VoidCallback onTap;
  final bool selected;

  const _SelectItem({
    required this.name,
    required this.phone,
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF333333),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6A5E7A),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Image.asset(AppAssets.isSelected, width: 24.w, height: 24.h),
          ],
        ),
      ),
    );
  }
}
