import 'package:cash_pinoy/screens/id_verify/id_type_screen.dart';
import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../utils/screen_adapter.dart';
import '../../widgets/app_tip.dart';
import '../../utils/retention_helper.dart';

abstract class BaseInfoPage extends StatefulWidget {
  const BaseInfoPage({super.key});
}

abstract class BaseInfoPageState<T extends BaseInfoPage> extends State<T> {
  String get title;
  String get tip;
  String get progressAsset;
  String get sectionTitle;
  Color get bgColor => Colors.white;
  EdgeInsets get padding =>
      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h);
  double get extraBottomPadding => 0;
  String? get retentionInputType => null;
  bool get interceptBack => retentionInputType != null;
  String startTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

  List<Widget> buildFields();
  ScrollController? get listController => null;
  void onSubmit();

  Future<void> onInterceptBack() async {
    final type = retentionInputType;
    if (type == null) {
      Navigator.of(context).maybePop();
      return;
    }
    await RetentionHelper.confirmLeave(context, inputType: type);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!interceptBack) return true;
        await onInterceptBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3EFFA),
        resizeToAvoidBottomInset: false,
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
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            SizedBox(width: 12.w),
                            InkWell(
                              onTap: () {
                                if (interceptBack) {
                                  onInterceptBack();
                                } else {
                                  Navigator.of(context).maybePop();
                                }
                              },
                              child: Image.asset(
                                AppAssets.iconBack,
                                width: 22.w,
                                height: 22.w,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                              ),
                            ),
                            Image.asset(progressAsset, height: 20.h),
                            SizedBox(width: 14.w),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, _) {
                              final inset = MediaQuery.of(
                                context,
                              ).viewInsets.bottom;
                              return ListView(
                                controller: listController,
                                padding: EdgeInsets.only(
                                  bottom: 90.h + extraBottomPadding + inset,
                                ),
                                children: [
                                  AppTip(title: tip),
                                  SizedBox(height: 16.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                    ),
                                    child: SectionTitle(title: sectionTitle),
                                  ),
                                  SizedBox(height: 10.h),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                    ),
                                    padding: padding,
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Column(children: buildFields()),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 24.w,
                      right: 24.w,
                      bottom: 20.h,
                      child: GestureDetector(
                        onTap: onSubmit,
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
      ),
    );
  }
}

class InfoField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isSelect;
  final TextInputType keyboardType;
  final Widget? prefix;
  final VoidCallback? onTap;
  final VoidCallback? onTapField;
  final VoidCallback? onFocus;
  final FocusNode? focusNode;

  const InfoField({
    super.key,
    required this.label,
    this.hint = 'Please select',
    this.controller,
    this.isSelect = false,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.onTap,
    this.onTapField,
    this.onFocus,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final mergedListenable = controller == null
        ? null
        : Listenable.merge(
            <Listenable>[
              controller!,
              if (focusNode != null) focusNode!,
            ],
          );

    final field = Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECFB),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          if (prefix != null) ...[prefix!, SizedBox(width: 8.w)],
          Expanded(
            child: mergedListenable == null
                ? IgnorePointer(
                    ignoring: isSelect,
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      readOnly: isSelect,
                      keyboardType: keyboardType,
                      onTap: onFocus,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF969696),
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF969696),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                : ListenableBuilder(
                    listenable: mergedListenable,
                    builder: (_, __) {
                      final hasValue = controller!.text.trim().isNotEmpty;
                      final hasFocus = focusNode?.hasFocus ?? false;
                      final active = hasValue || hasFocus;
                      return IgnorePointer(
                        ignoring: isSelect,
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          readOnly: isSelect,
                          keyboardType: keyboardType,
                          onTap: onFocus,
                          decoration: InputDecoration(
                            hintText: hint,
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF969696),
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: active
                                ? const Color(0xFF2F2F2F)
                                : const Color(0xFF969696),
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (isSelect)
            Icon(
              Icons.chevron_right,
              size: 18.sp,
              color: const Color(0xFFB3A8C8),
            ),
        ],
      ),
    );

    final content = Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF6A5E7A),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          field,
        ],
      ),
    );

    if (isSelect) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTapField,
      child: content,
    );
  }
}
