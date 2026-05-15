import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../network/api_endpoints.dart';
import '../../utils/app_info_manager.dart';
import '../../utils/hud_manager.dart';
import '../../utils/nav_helper.dart';
import '../../utils/report_manager.dart';
import '../../utils/request_error.dart';
import '../../utils/screen_adapter.dart';
import '../../utils/retention_helper.dart';
import 'id_upload_screen.dart';

class IdTypeScreen extends StatefulWidget {
  const IdTypeScreen({super.key});

  @override
  State<IdTypeScreen> createState() => _IdTypeScreenState();
}

class _IdTypeScreenState extends State<IdTypeScreen> {
  List<String> _recommended = [];
  List<String> _others = [];
  bool _loading = false;
  String startTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadTypes();
    });
  }

  Future<void> _loadTypes() async {
    if (_loading) return;
    final productId = AppInfoManager.productModel?.uniquely ?? '';
    if (productId.isEmpty) return;
    setState(() => _loading = true);
    try {
      HudManager.showLoading();
      final response = await CertifyApi().fetchBasicPersonInfo(
        productId: productId,
      );
      final floweret = response.dysphasias['floweret'].listValue;
      if (floweret.isNotEmpty) {
        _recommended = floweret.first.listValue
            .map((e) => e.stringValue)
            .toList();
        final other = <String>[];
        for (var i = 1; i < floweret.length; i++) {
          other.addAll(floweret[i].listValue.map((e) => e.stringValue));
        }
        _others = other;
      }
      HudManager.dismiss();
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmLeave() async {
    await RetentionHelper.confirmLeave(context, inputType: '0');
  }

  void _reportEnterUpload() {
    ReportManager.reportBuriedPointWithLocation(
      productId: AppInfoManager.productId,
      sceneType: '2',
      orderNo: AppInfoManager.orderNo,
      startTime: startTime,
    );
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
                AppAssets.navBg,
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
                  SizedBox(height: 10.h),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      children: [
                        SizedBox(height: 46.h),
                        if (_recommended.isNotEmpty) ...[
                          SectionTitle(title: 'Recommended ID Type'),
                          SizedBox(height: 10.h),
                          _buildGrid(_recommended),
                          SizedBox(height: 20.h),
                        ],
                        if (_others.isNotEmpty) ...[
                          SectionTitle(title: 'Other Options'),
                          SizedBox(height: 12.h),
                          _buildGrid(_others),
                        ],
                      ],
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

  Widget _buildGrid(List<String> items) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final gap = 12.w;
          final halfWidth = (totalWidth - gap) / 2;
          final normalHeight = halfWidth * 102 / 147;
          final fullHeight = totalWidth * 102 / 307;

          final rows = <Widget>[];
          for (var i = 0; i < items.length; i += 2) {
            final leftType = items[i];
            final leftOrder = (i + 1).toString().padLeft(2, '0');
            final hasRight = i + 1 < items.length;
            rows.add(
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: hasRight
                    ? Row(
                        children: [
                          SizedBox(
                            width: halfWidth,
                            height: normalHeight,
                            child: InkWell(
                              onTap: () {
                                _reportEnterUpload();
                                NavHelper.to(IdUploadScreen(idType: leftType));
                              },
                              child: _IdTypeCard(
                                order: leftOrder,
                                title: leftType,
                                useWide: false,
                              ),
                            ),
                          ),
                          SizedBox(width: gap),
                          SizedBox(
                            width: halfWidth,
                            height: normalHeight,
                            child: InkWell(
                              onTap: () {
                                _reportEnterUpload();
                                NavHelper.to(
                                  IdUploadScreen(idType: items[i + 1]),
                                );
                              },
                              child: _IdTypeCard(
                                order: (i + 2).toString().padLeft(2, '0'),
                                title: items[i + 1],
                                useWide: false,
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: totalWidth,
                        height: fullHeight,
                        child: InkWell(
                          onTap: () {
                            _reportEnterUpload();
                            NavHelper.to(IdUploadScreen(idType: leftType));
                          },
                          child: _IdTypeCard(
                            order: leftOrder,
                            title: leftType,
                            useWide: true,
                          ),
                        ),
                      ),
              ),
            );
          }
          return Column(children: rows);
        },
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(AppAssets.heroBadge, width: 16.w, height: 16.w),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

class _IdTypeCard extends StatelessWidget {
  final String order;
  final String title;
  final bool useWide;

  const _IdTypeCard({
    required this.order,
    required this.title,
    required this.useWide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(
          image: AssetImage(useWide ? AppAssets.idWType : AppAssets.idType),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6.h,
            left: 6.w,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(255, 255, 255, 1),
                    Color.fromRGBO(255, 255, 255, 0),
                  ],
                ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                );
              },
              child: Text(
                order,
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 30.sp,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 14.w,
            right: 14.w,
            bottom: 20.h,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6A42E8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
