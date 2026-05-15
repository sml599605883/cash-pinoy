import 'dart:convert';
import 'dart:io';
import 'package:cash_pinoy/tools/json.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:cash_pinoy/utils/permission_helper.dart';
import 'package:cash_pinoy/utils/report_manager.dart';
import 'package:flutter/material.dart';
import 'package:trustdevice_pro_plugin/trustdevice_pro_plugin.dart';
import 'package:path_provider/path_provider.dart';

import '../../constants/app_assets.dart';
import '../../model/bind_model.dart';
import '../../network/api_endpoints.dart';
import '../../utils/app_info_manager.dart';
import '../../utils/hud_manager.dart';
import '../../utils/request_error.dart';
import '../../utils/screen_adapter.dart';
import '../../widgets/app_tip.dart';
import '../id_verify/id_type_screen.dart';
import 'widgets/bind_announcer_sheet.dart';

class WithdrawInfoScreen extends StatefulWidget {
  final String? productId;
  final String? orderNo;

  const WithdrawInfoScreen({super.key, this.productId, this.orderNo});

  @override
  State<WithdrawInfoScreen> createState() => _WithdrawInfoScreenState();
}

class _WithdrawInfoScreenState extends State<WithdrawInfoScreen>
    with WidgetsBindingObserver {
  BindInitModel? _model;
  int _tabIndex = 0;
  String _topTipText = '';
  String _bottomTipText = '';
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, BindFieldModel> _fieldByKey = {};
  String? _focusedKey;
  final Map<String, GlobalKey> _inputKeys = {};
  final ScrollController _scrollController = ScrollController();
  String startTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

  bool get _isChangeBind =>
      (widget.productId != null && widget.productId!.isNotEmpty) &&
      (widget.orderNo != null && widget.orderNo!.isNotEmpty);
  final _trustdeviceProPlugin = TrustdeviceProPlugin();

  @override
  void initState() {
    super.initState();
    _fetchBindInit();
    WidgetsBinding.instance.addObserver(this);

    _initWithOptions();
  }

  Future<void> _initWithOptions() async {
    Map<String, dynamic> options = {
      'partner': 'boqin_ph',
      'appKey': '1dc25522f2adc77f5347816c0f7fa31b',
      'appName': 'julyTwo_test',
      'country': 'sg',
      'language': 'en',
    };
    //Anti debugging switch, used during development phase
    options["debug"] = true;
    _trustdeviceProPlugin.initWithOptions(options);
  }

  Future<void> _fetchBindInit() async {
    final productId = _isChangeBind
        ? widget.productId!
        : AppInfoManager.productId;
    if (productId.isEmpty) return;
    try {
      HudManager.showLoading();
      final response = await CertifyApi().fetchBindCardInit(
        productId: productId,
      );
      HudManager.dismiss();
      if (!mounted) return;
      final model = BindInitModel.fromJson(response.dysphasias);
      _initControllers(model);
      setState(() {
        _model = model;
        _topTipText = model.chirked;
        _bottomTipText = model.presentableness;
      });
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  void _initControllers(BindInitModel model) {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _fieldByKey.clear();
    for (final tab in model.tabs) {
      for (final field in tab.fields) {
        _fieldByKey[_fieldKey(tab.dipteral, field.juridic)] = field;
        if (field.isInput) {
          final key = _fieldKey(tab.dipteral, field.juridic);
          final controller = TextEditingController(text: field.paralyze);
          controller.addListener(() {
            field.paralyze = controller.text;
          });
          controller.addListener(() {
            final key = _fieldKey(tab.dipteral, field.juridic);
            if (_focusedKey == key) {
              setState(() {});
            }
          });
          _controllers[key] = controller;
        }
      }
    }
  }

  String _fieldKey(String tabId, String juridic) => '${tabId}_$juridic';

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final inset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (!mounted) return;
    if (inset > 0 && _focusedKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ensureVisible(_focusedKey!);
      });
    }
  }

  void onSubmit() async {
    await _submitBind();
  }

  Future<void> _submitBind({
    String illiterately = '',
    String nazi = '',
    String attach = '',
    String checkmating = '',
    String phonologists = '',
  }) async {
    final tabs = _model?.tabs ?? [];
    if (tabs.isEmpty) return;
    final tab = tabs[_tabIndex];
    final form = <String, dynamic>{
      'harrowers': tab.dipteral,
      'illiterately': illiterately,
      'nazi': nazi,
      'checkmating': checkmating,
      'phonologists': phonologists,
    };
    for (final field in tab.fields) {
      final key = field.juridic;
      if (key.isEmpty) continue;
      if (field.isSelect) {
        form[key] = field.selectedOption?.dipteral ?? '';
      } else {
        form[key] = field.paralyze.trim();
      }
    }
    try {
      HudManager.showLoading();
      final file = await _saveBase64ToFile(attach);
      final response = await CertifyApi().bindCardSubmit(
        productId: widget.productId ?? AppInfoManager.productId,
        form: form,
        filePath: file.path,
      );
      if (response.juridic == 20000) {
        HudManager.dismiss();
        final allowed = await PermissionHelper.ensureCameraPermission(context);
        if (!allowed) return;
        loadFaceToken();
        return;
      } else {
        if (_isChangeBind) {
          await _submitChangeBind(response.dysphasias['tillers'].stringValue);
        } else {
          ReportManager.reportBuriedPointWithLocation(
            productId: widget.productId ?? AppInfoManager.productId,
            sceneType: '8',
            orderNo: widget.orderNo ?? AppInfoManager.orderNo,
            startTime: startTime,
          );
          NavHelper.fetchProductDetail(productId: AppInfoManager.productId);
        }
      }
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  Future<void> _submitChangeBind(String tillers) async {
    try {
      HudManager.showLoading();
      final response = await CertifyApi().changeBankCard(
        bindId: tillers,
        orderNo: widget.orderNo!,
      );
      final belletristic = response.dysphasias['belletristic'].stringValue;
      NavHelper.toScheme(belletristic);
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  Future<File> _saveBase64ToFile(String base64Str) async {
    final cleaned = base64Str.contains(',')
        ? base64Str.split(',').last
        : base64Str;
    final bytes = base64Decode(cleaned);
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/face_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> loadFaceToken() async {
    try {
      HudManager.showLoading();
      final response = await CertifyApi().fetchFaceToken(
        orderNo: widget.orderNo ?? AppInfoManager.orderNo,
        type: '1',
      );
      final regulate = response.dysphasias['regulate'].stringValue;
      if (regulate == '200') {
        final chaquetas = response.dysphasias['chaquetas'].stringValue;
        await _showFace(chaquetas);
      }
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  Future<void> _showFace(String license) async {
    await _trustdeviceProPlugin.showLiveness(
      license,
      TDLivenessCallback(
        onSuccess: (successResultMap) {
          final sequenceId = successResultMap['sequence_id'].toString();
          // final message = successResultMap['message'].toString();
          final code = successResultMap['code'].toString();
          // final function = successResultMap['function'].toString();
          final livenessId = successResultMap['liveness_id'].toString();
          final image = successResultMap['image'].toString();
          _submitBind(
            illiterately: '7',
            nazi: livenessId,
            attach: image,
            phonologists: license,
          );
          ReportManager.reportFaceRecognitionResult(
            livenessId: livenessId,
            requestId: sequenceId,
            resultCode: code,
            result: Json(successResultMap).rawString(),
          );
        },
        onFailed: (failResultMap) {
          final sequenceId = failResultMap['sequence_id'].toString();
          final message = failResultMap['message'].toString();
          final code = failResultMap['code'].toString();
          // final function = failResultMap['function'].toString();
          HudManager.showFailure(message: message);
          final json = Json(failResultMap);
          ReportManager.reportFaceRecognitionResult(
            livenessId: json['liveness_id'].stringOrNull ?? '',
            requestId: sequenceId,
            resultCode: code,
            result: json.rawString(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _model?.tabs ?? [];
    final tab = tabs.isNotEmpty ? tabs[_tabIndex] : null;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
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
                                'Withdrawal Info',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                            ),
                          ),
                          Image.asset(AppAssets.process4, height: 20.h),
                          SizedBox(width: 14.w),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Expanded(
                        child: ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.only(
                            bottom:
                                90.h + MediaQuery.of(context).viewInsets.bottom,
                          ),
                          children: [
                            AppTip(
                              title: _topTipText.isEmpty
                                  ? 'Tell us more about yourself to speed up your approval.'
                                  : _topTipText,
                            ),
                            SizedBox(height: 16.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: SectionTitle(title: 'Withdrawal Info'),
                            ),
                            SizedBox(height: 10.h),
                            if (tabs.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                child: _TabRow(
                                  titles: tabs.map((e) => e.earnings).toList(),
                                  selectedIndex: _tabIndex,
                                  onTap: (index) =>
                                      setState(() => _tabIndex = index),
                                ),
                              ),
                            SizedBox(height: 10.h),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 14.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: tab == null
                                    ? []
                                    : _buildFormFields(tab, keyboardVisible),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 110.h),
                    ],
                  ),
                  Positioned(
                    left: 24.w,
                    right: 24.w,
                    bottom: 76.h,
                    child: Text(
                      _bottomTipText.isNotEmpty
                          ? _bottomTipText
                          : 'Double-check your account details to avoid errors and ensure a smooth transaction.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF7B39F5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24.w,
                    right: 24.w,
                    bottom: 20.h,
                    child: GestureDetector(
                      onTap: () => onSubmit(),
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

  List<Widget> _buildFormFields(BindTabModel tab, bool keyboardVisible) {
    final widgets = <Widget>[];
    var showConfirmTip = tab.earnings == 'E-wallet';
    for (final field in tab.fields) {
      if (field.isSelect) {
        final selectedLabel = field.selectedOption?.unpaid ?? field.paralyze;
        final isPlaceholder = selectedLabel.isEmpty;
        final displayText = isPlaceholder ? field.saccharide : selectedLabel;
        widgets.add(
          _SelectRow(
            title: field.earnings,
            value: displayText,
            isPlaceholder: isPlaceholder,
            onTap: () async {
              _clearFocus();
              final selected = await showModalBottomSheet<BindOptionModel>(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => BindAnnouncerSelectSheet(options: field.cogito),
              );
              _clearFocus();
              if (selected == null) return;
              setState(() => field.selectedOption = selected);
            },
          ),
        );
        if (showConfirmTip) {
          widgets.add(SizedBox(height: 10.h));
          widgets.add(
            Text(
              'Please confirm your payout account details to ensure successful fund disbursement.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.sp, color: const Color(0xFFFF5A5A)),
            ),
          );
          widgets.add(SizedBox(height: 10.h));
          showConfirmTip = false;
        }
      } else {
        final key = _fieldKey(tab.dipteral, field.juridic);
        final controller = _controllers[key]!;
        _inputKeys[key] ??= GlobalKey();
        final showTag =
            keyboardVisible &&
            _focusedKey == key &&
            controller.text.isEmpty &&
            field.ruddy.isNotEmpty;
        widgets.add(
          _InputRow(
            key: _inputKeys[key],
            label: field.earnings,
            hint: field.saccharide,
            controller: controller,
            showTag: showTag,
            tagText: field.ruddy,
            keyboardType: field.reckoners == 1
                ? TextInputType.number
                : TextInputType.text,
            onTagTap: () => _applyRuddy(tab),
            onFocus: () {
              setState(() => _focusedKey = key);
              _ensureVisible(key);
            },
          ),
        );
      }
    }
    return widgets;
  }

  void _applyRuddy(BindTabModel tab) {
    FocusScope.of(context).unfocus();
    for (final field in tab.fields) {
      if (!field.isInput) continue;
      if (field.paralyze.isNotEmpty) continue;
      if (field.ruddy.isEmpty) continue;
      field.paralyze = field.ruddy;
      final key = _fieldKey(tab.dipteral, field.juridic);
      _controllers[key]?.text = field.paralyze;
    }
    setState(() {});
  }

  void _ensureVisible(String key) {
    final ctx = _inputKeys[key]?.currentContext;
    if (ctx == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: 0.3,
      );
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: 0.3,
      );
    });
  }

  void _clearFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
  }
}

class _TabRow extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<String> titles;

  const _TabRow({
    required this.selectedIndex,
    required this.onTap,
    required this.titles,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(titles.length, (index) {
        final selected = index == selectedIndex;
        return Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: InkWell(
            onTap: () => onTap(index),
            child: Container(
              height: 30.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: selected
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppAssets.bankTitleBg),
                        fit: BoxFit.fill,
                      ),
                    )
                  : BoxDecoration(
                      color: const Color(0xFFE6E0F2),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
              child: Text(
                titles[index],
                style: TextStyle(
                  fontSize: 12.sp,
                  color: selected
                      ? const Color(0xFF7B39F5)
                      : const Color(0xFF8A7FA3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SelectRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isPlaceholder;
  final VoidCallback onTap;

  const _SelectRow({
    required this.title,
    required this.value,
    required this.isPlaceholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF6A5E7A),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF2ECFB),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: isPlaceholder
                          ? const Color(0xFF969696)
                          : const Color(0xFF2F2F2F),
                      fontWeight: isPlaceholder
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18.sp,
                  color: const Color(0xFFB3A8C8),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InputRow extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool showTag;
  final String tagText;
  final TextInputType keyboardType;
  final VoidCallback onTagTap;
  final VoidCallback onFocus;

  const _InputRow({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.showTag,
    required this.tagText,
    required this.keyboardType,
    required this.onTagTap,
    required this.onFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF6A5E7A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 6.w),
              const Spacer(),
              if (showTag)
                GestureDetector(
                  onTap: onTagTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3C3C3C),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      tagText,
                      style: TextStyle(fontSize: 10.sp, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            onTap: onFocus,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF969696),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(20.r),
              ),
              filled: true,
              fillColor: const Color(0xFFF2ECFB),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
            ),
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF2F2F2F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
