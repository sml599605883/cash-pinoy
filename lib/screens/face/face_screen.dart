import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:cash_pinoy/network/api_endpoints.dart';
import 'package:cash_pinoy/tools/json.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:cash_pinoy/utils/hud_manager.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:cash_pinoy/utils/permission_helper.dart';
import 'package:cash_pinoy/utils/report_manager.dart';
import 'package:cash_pinoy/utils/request_error.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trustdevice_pro_plugin/trustdevice_pro_plugin.dart';

import '../../constants/app_assets.dart';
import '../../utils/retention_helper.dart';
import '../../utils/screen_adapter.dart';
import '../../widgets/app_tip.dart';

class FaceScreen extends StatefulWidget {
  const FaceScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FaceScreenState();
}

class _FaceScreenState extends State<FaceScreen> with WidgetsBindingObserver {
  final _trustdeviceProPlugin = TrustdeviceProPlugin();
  late final String startTime;
  Completer<void>? _resumeCompleter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    _initWithOptions();
  }

  @override
  void dispose() {
    _resumeCompleter?.complete();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  Future<void> _didClickNextButton() async {
    final allowed = await PermissionHelper.ensureCameraPermission(context);
    if (!allowed) return;
    await _waitForUiReadyAfterPermission();
    if (!mounted) return;
    try {
      HudManager.showLoading();
      final response = await CertifyApi().fetchFaceToken(
        orderNo: AppInfoManager.orderNo,
        type: '0',
      );
      final regulate = response.dysphasias['regulate'].stringValue;
      if (regulate == '200') {
        final chaquetas = response.dysphasias['chaquetas'].stringValue;
        await _waitForUiReadyAfterPermission();
        if (!mounted) return;
        await _showFace(chaquetas);
      }
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  Future<void> _waitForUiReadyAfterPermission() async {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != AppLifecycleState.resumed) {
      _resumeCompleter ??= Completer<void>();
      await _resumeCompleter!.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
      _resumeCompleter = null;
    }
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }

  void _onResume() {
    if (_resumeCompleter != null && !_resumeCompleter!.isCompleted) {
      _resumeCompleter!.complete();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onResume();
    }
  }

  Future<void> _uploadFaceInfo(
    String image,
    String livenessId,
    String license,
  ) async {
    try {
      HudManager.showLoading();
      final file = await _saveBase64ToFile(image);
      final response = await CertifyApi().uploadCertifyImage(
        filePath: file.path,
        type: '10',
        imageSource: '1',
        cardType: '',
        faceType: '7',
        license: license,
        livenessId: livenessId,
      );
      if (!response.isSuccess) {
        HudManager.showFailure(message: response.amenorrheic);
        return;
      }
      ReportManager.reportBuriedPointWithLocation(
        productId: AppInfoManager.productId,
        sceneType: '4',
        orderNo: AppInfoManager.orderNo,
        startTime: startTime,
      );
      NavHelper.fetchProductDetail(productId: AppInfoManager.productId);
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
          _uploadFaceInfo(image, livenessId, license);
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

  Future<void> _confirmLeave() async {
    await RetentionHelper.confirmLeave(context, inputType: '1');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _confirmLeave();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3EFFA),
        body: Stack(
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
                      SizedBox(width: 12.w),
                      InkWell(
                        onTap: _confirmLeave,
                        child: Image.asset(
                          AppAssets.iconBack,
                          width: 22.w,
                          height: 22.w,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Face recognition',
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
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(height: 6.h),
                        AppTip(
                          title: AppInfoManager.productModel!.cogito.livness,
                        ),
                        SizedBox(height: 46.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: Image.asset(
                            AppAssets.faceBg,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 24.h),
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
                        _didClickNextButton();
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
                          'Next',
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
