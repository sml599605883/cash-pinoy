import 'package:cash_pinoy/network/api_endpoints.dart';
import 'package:cash_pinoy/screens/id_verify/id_type_screen.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:cash_pinoy/utils/hud_manager.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:cash_pinoy/utils/report_manager.dart';
import 'package:cash_pinoy/utils/request_error.dart';
import 'package:cash_pinoy/widgets/app_tip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../utils/screen_adapter.dart';

class IdSuccessScreen extends StatefulWidget {
  final String initialFullName;
  final String initialIdNo;
  final DateTime? initialDob;
  final String initialImageUrl;
  final String idType;
  final String startTime;

  const IdSuccessScreen({
    super.key,
    this.initialFullName = '',
    this.initialIdNo = '',
    this.initialDob,
    this.initialImageUrl = '',
    this.idType = '',
    this.startTime = '',
  });

  @override
  State<IdSuccessScreen> createState() => _IdSuccessScreenState();
}

class _IdSuccessScreenState extends State<IdSuccessScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _idController;
  final FocusNode _blankFocusNode = FocusNode();
  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialFullName);
    _idController = TextEditingController(text: widget.initialIdNo);
    _dob = widget.initialDob;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _blankFocusNode.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day-$month-$year';
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).requestFocus(_blankFocusNode);
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 20, now.month, now.day);
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DateSelectSheet(initial: initial),
    );
    if (picked == null) {
      FocusScope.of(context).requestFocus(_blankFocusNode);
      return;
    }
    setState(() => _dob = picked);
  }

  Future<void> _submitIdInfo({
    required String birthday,
    required String idNumber,
    required String name,
  }) async {
    try {
      HudManager.showLoading();
      await CertifyApi().saveBasicPersonInfo(
        birthday: birthday,
        idNumber: idNumber,
        name: name,
        type: '11',
        cardType: widget.idType,
      );
      ReportManager.reportBuriedPointWithLocation(
        productId: AppInfoManager.productId,
        sceneType: '3',
        orderNo: AppInfoManager.orderNo,
        startTime: widget.startTime,
      );
      NavHelper.fetchProductDetail(productId: AppInfoManager.productId);
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFFA),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned(
              child: Image.asset(
                AppAssets.navHBg,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'Document verification',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(height: 6.h),
                        AppTip(
                          title:
                              AppInfoManager.productModel!.cogito.baseSuccess,
                        ),
                        SizedBox(height: 46.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: SectionTitle(title: 'Successfully'),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          height: 234.h,
                          margin: EdgeInsets.symmetric(horizontal: 14.w),
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Image.network(
                            widget.initialImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox();
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Image.asset(
                            AppAssets.idSuccess,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Container(
                          height: 168.h,
                          margin: EdgeInsets.symmetric(horizontal: 24.w),
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          decoration: BoxDecoration(
                            color: Color(0xFFD9C9FF),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(14.r),
                              bottomRight: Radius.circular(14.r),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _InfoRow(
                                label: 'Full Name',
                                controller: _nameController,
                                readOnly: false,
                              ),
                              SizedBox(height: 10.h),
                              _InfoRow(
                                label: 'ID No.',
                                controller: _idController,
                                readOnly: false,
                              ),
                              SizedBox(height: 10.h),
                              _DateRow(
                                label: 'Date of Birth',
                                value: _formatDate(_dob),
                                onTap: _pickDate,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 20.h,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        final name = _nameController.text.trim();
                        final idNo = _idController.text.trim();
                        final dob = _formatDate(_dob);
                        // ignore: avoid_print
                        _submitIdInfo(
                          birthday: dob,
                          idNumber: idNo,
                          name: name,
                        );
                      },
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
                          'Submit',
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
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;

  const _InfoRow({
    required this.label,
    required this.controller,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelectSheet extends StatefulWidget {
  final DateTime initial;

  const _DateSelectSheet({required this.initial});

  @override
  State<_DateSelectSheet> createState() => _DateSelectSheetState();
}

class _DateSelectSheetState extends State<_DateSelectSheet> {
  late int _day;
  late int _month;
  late int _year;

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  @override
  void initState() {
    super.initState();
    _day = widget.initial.day;
    _month = widget.initial.month;
    _year = widget.initial.year;
    _dayController = FixedExtentScrollController(initialItem: _day - 1);
    _monthController = FixedExtentScrollController(initialItem: _month - 1);
    _yearController = FixedExtentScrollController(
      initialItem: _year - _minYear,
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  static const int _minYear = 1900;
  static int get _maxYear => DateTime.now().year;

  int _maxDayInMonth(int year, int month) {
    final nextMonth = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  void _syncDay() {
    final maxDay = _maxDayInMonth(_year, _month);
    if (_day > maxDay) {
      setState(() => _day = maxDay);
      _dayController.jumpToItem(maxDay - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDay = _maxDayInMonth(_year, _month);
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
                              controller: _dayController,
                              itemCount: maxDay,
                              onChanged: (index) => setState(() {
                                _day = index + 1;
                              }),
                              itemBuilder: (index) => Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF6B5B8D),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildPicker(
                              controller: _monthController,
                              itemCount: 12,
                              onChanged: (index) {
                                setState(() {
                                  _month = index + 1;
                                  _syncDay();
                                });
                              },
                              itemBuilder: (index) => Center(
                                child: Text(
                                  (index + 1).toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF6B5B8D),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildPicker(
                              controller: _yearController,
                              itemCount: _maxYear - _minYear + 1,
                              onChanged: (index) {
                                setState(() {
                                  _year = _minYear + index;
                                  _syncDay();
                                });
                              },
                              itemBuilder: (index) => Center(
                                child: Text(
                                  '${_minYear + index}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF6B5B8D),
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
              Navigator.of(context).pop(DateTime(_year, _month, _day));
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
