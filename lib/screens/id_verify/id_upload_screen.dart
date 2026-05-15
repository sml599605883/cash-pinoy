import 'dart:io';

import 'package:cash_pinoy/tools/json.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'dart:ui' as ui;

import 'package:cash_pinoy/widgets/app_tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../constants/app_assets.dart';
import '../../network/api_endpoints.dart';
import '../../utils/hud_manager.dart';
import '../../utils/permission_helper.dart';
import '../../utils/request_error.dart';
import '../../utils/screen_adapter.dart';
import 'id_success_screen.dart';
import 'widgets/id_select_sheet.dart';

class IdUploadScreen extends StatefulWidget {
  final String idType;

  const IdUploadScreen({super.key, required this.idType});

  @override
  State<IdUploadScreen> createState() => _IdUploadScreenState();
}

class _IdUploadScreenState extends State<IdUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openSelect() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const IdSelectSheet(),
    );
    if (source == null) return;
    if (source == ImageSource.camera) {
      final allowed = await PermissionHelper.ensureCameraPermission(context);
      if (!allowed) return;
    }
    HudManager.showLoading();
    await _pickAndUpload(source);
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final startTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .toString();
      final picked = await _picker.pickImage(source: source, imageQuality: 100);
      if (picked == null) {
        HudManager.dismiss();
        return;
      }
      HudManager.showLoading();
      final compressed = await _compressToLimit(File(picked.path));
      if (compressed == null) {
        HudManager.showFailure(message: 'Image compress failed');
        return;
      }

      HudManager.showLoading();
      final response = await CertifyApi().uploadCertifyImage(
        filePath: compressed.path,
        type: '11',
        imageSource: source == ImageSource.camera ? '2' : '1',
        cardType: widget.idType,
      );
      final data = response.dysphasias;
      if (!response.isSuccess) {
        HudManager.showFailure(message: response.amenorrheic);
        return;
      }
      HudManager.dismiss();
      if (!mounted) return;
      final parsed = _parseSuccessData(data);
      NavHelper.to(
        IdSuccessScreen(
          initialFullName: parsed.fullName,
          initialIdNo: parsed.idNo,
          initialDob: parsed.dob,
          initialImageUrl: parsed.imageUrl,
          idType: widget.idType,
          startTime: startTime,
        ),
        replace: true,
      );
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  _SuccessData _parseSuccessData(Json data) {
    if (data.exists()) {
      final imageUrl = data['dampen'].stringValue;
      final fullName = data['unpaid'].stringValue;
      final idNo = data['plimsols'].stringValue;
      final dobRaw = data['coassisting'].stringValue;
      return _SuccessData(
        imageUrl: imageUrl,
        fullName: fullName,
        idNo: idNo,
        dob: _parseDate(dobRaw),
      );
    }
    return const _SuccessData();
  }

  DateTime? _parseDate(String raw) {
    if (raw.trim().isEmpty) return null;
    final normalized = raw.replaceAll('-', '/');
    final parts = normalized.split('/');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    final parsed = DateTime(year, month, day);
    if (parsed.isAfter(DateTime.now())) return null;
    return parsed;
  }

  Future<File?> _compressToLimit(File file) async {
    final target = 500 * 1024;
    var quality = 90;
    File compressFile = file;
    while (quality >= 10) {
      compressFile = await _compressImageQuality(compressFile, quality);
      final curSize = compressFile.lengthSync();
      if (curSize <= target) {
        return compressFile;
      }
      quality -= 5;
    }

    final bytes = await compressFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final originalImage = await codec.getNextFrame();
    int curWidth = originalImage.image.width;
    int curHeight = originalImage.image.height;

    while (curWidth > 100 && curHeight > 100) {
      curWidth = (curWidth * 0.95).toInt();
      curHeight = (curHeight * 0.95).toInt();
      compressFile = await _compressImageSize(file, curWidth, curHeight);
      final curSize = compressFile.lengthSync();
      if (curSize <= target) {
        return compressFile;
      }
    }
    return compressFile;
  }

  Future<File> _compressImageQuality(File file, int quality) async {
    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      path,
      quality: quality,
      format: CompressFormat.jpeg,
      autoCorrectionAngle: false,
      keepExif: false,
    );
    return File(result!.path);
  }

  Future<File> _compressImageSize(File file, int width, int height) async {
    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      path,
      minWidth: width,
      minHeight: height,
      quality: 95,
      format: CompressFormat.jpeg,
    );
    return File(result!.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          'ID Verification',
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
                SizedBox(height: 6.h),
                AppTip(title: AppInfoManager.productModel!.cogito.base),
                SizedBox(height: 46.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Image.asset(AppAssets.idUpload, fit: BoxFit.contain),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  child: GestureDetector(
                    onTap: _openSelect,
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
    );
  }
}

class _SuccessData {
  final String imageUrl;
  final String fullName;
  final String idNo;
  final DateTime? dob;

  const _SuccessData({
    this.imageUrl = '',
    this.fullName = '',
    this.idNo = '',
    this.dob,
  });
}
