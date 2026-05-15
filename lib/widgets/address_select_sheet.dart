import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../model/address_model.dart';
import '../utils/screen_adapter.dart';

class AddressSelection {
  final AddressModel level1;
  final AddressModel level2;
  final AddressModel level3;

  const AddressSelection({
    required this.level1,
    required this.level2,
    required this.level3,
  });
}

class AddressSelectSheet extends StatefulWidget {
  final List<AddressModel> options;
  final bool twoLevel;

  const AddressSelectSheet({
    super.key,
    required this.options,
    this.twoLevel = false,
  });

  @override
  State<AddressSelectSheet> createState() => _AddressSelectSheetState();
}

class _AddressSelectSheetState extends State<AddressSelectSheet> {
  late List<AddressModel> _level1;
  late List<AddressModel> _level2;
  late List<AddressModel> _level3;

  int _index1 = 0;
  int _index2 = 0;
  int _index3 = 0;

  late FixedExtentScrollController _c1;
  late FixedExtentScrollController _c2;
  late FixedExtentScrollController _c3;

  @override
  void initState() {
    super.initState();
    _level1 = _safeList(widget.options);
    _level2 = _safeList(_level1[_index1].bleaching);
    _level3 = _safeList(_level2[_index2].bleaching);
    _c1 = FixedExtentScrollController(initialItem: _index1);
    _c2 = FixedExtentScrollController(initialItem: _index2);
    _c3 = FixedExtentScrollController(initialItem: _index3);
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    super.dispose();
  }

  List<AddressModel> _safeList(List<AddressModel> list) {
    if (list.isEmpty) {
      return [AddressModel(uniquely: '', unpaid: '-', bleaching: const [])];
    }
    return list;
  }

  void _updateLevel2() {
    _level2 = _safeList(_level1[_index1].bleaching);
    _index2 = 0;
    _level3 = _safeList(_level2[_index2].bleaching);
    _index3 = 0;
    _c2.jumpToItem(_index2);
    _c3.jumpToItem(_index3);
  }

  void _updateLevel3() {
    _level3 = _safeList(_level2[_index2].bleaching);
    _index3 = 0;
    _c3.jumpToItem(_index3);
  }

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
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      bottom: 0,
                      right: 0,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.w),
                          child: Container(color: Colors.white, height: 36.h),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 150.h,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildPicker(
                              controller: _c1,
                              itemCount: _level1.length,
                              onChanged: (index) {
                                setState(() {
                                  _index1 = index;
                                  _updateLevel2();
                                });
                              },
                              itemBuilder: (index) => Center(
                                child: Text(
                                  _level1[index].unpaid,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF6B5B8D),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildPicker(
                              controller: _c2,
                              itemCount: _level2.length,
                              onChanged: (index) {
                                setState(() {
                                  _index2 = index;
                                  _updateLevel3();
                                });
                              },
                              itemBuilder: (index) => Center(
                                child: Text(
                                  _level2[index].unpaid,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF6B5B8D),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          if (!widget.twoLevel)
                            Expanded(
                              child: _buildPicker(
                                controller: _c3,
                                itemCount: _level3.length,
                                onChanged: (index) {
                                  setState(() => _index3 = index);
                                },
                                itemBuilder: (index) => Center(
                                  child: Text(
                                    _level3[index].unpaid,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF6B5B8D),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
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
              Positioned(
                child: Center(
                  child: Image.asset(AppAssets.idSelect, height: 47.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              final selection = AddressSelection(
                level1: _level1[_index1],
                level2: _level2[_index2],
                level3: widget.twoLevel ? _level2[_index2] : _level3[_index3],
              );
              Navigator.of(context).pop(selection);
            },
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

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required ValueChanged<int> onChanged,
    required Widget Function(int index) itemBuilder,
  }) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: 36.h,
      onSelectedItemChanged: onChanged,
      selectionOverlay: const SizedBox.shrink(),
      children: List.generate(itemCount, itemBuilder),
    );
  }
}
