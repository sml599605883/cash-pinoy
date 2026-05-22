import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constants/app_assets.dart';
import '../../network/api_endpoints.dart';
import '../../utils/app_info_manager.dart';
import '../../utils/hud_manager.dart';
import '../../utils/nav_helper.dart';
import '../../utils/screen_adapter.dart';
import '../../widgets/action_confirm_dialog.dart';
import '../../utils/request_error.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = packageInfo.version);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFFA),
      body: SafeArea(
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
                      'Account',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 34.w),
              ],
            ),
            SizedBox(height: 18.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 40.w),
                      width: 88.w,
                      height: 88.w,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFF7927EB),
                          width: 1.w,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Image.asset(
                          AppAssets.iconLogo,
                          width: 88.w,
                          height: 88.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Tala',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _version.isEmpty ? '' : 'V$_version',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFFB0B0B0),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Website',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF9B9B9B),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      height: 44.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2ECFA),
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      child: Text(
                        'https://www.babamunshi.com',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => ActionConfirmDialog.show(
                      context,
                      type: ActionConfirmType.logout,
                      onLeft: () => _handleLogout(context),
                    ),
                    child: Container(
                      height: 46.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7B39F5), Color(0xFF9E45F7)],
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onTap: () => ActionConfirmDialog.show(
                      context,
                      type: ActionConfirmType.deleteAccount,
                      onLeft: () => _handleDelete(context),
                    ),
                    child: Container(
                      height: 46.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFBAC2),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      HudManager.showLoading();
      final response = await UserApi().logoutUser();
      if (response.isSuccess) {
        await AppInfoManager.clearAuth();
        HudManager.dismiss();
        NavHelper.backToHome();
        return;
      }
      HudManager.showFailure(message: 'Logout failed');
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    try {
      HudManager.showLoading();
      final response = await UserApi().deleteUser();
      if (response.isSuccess) {
        await AppInfoManager.clearAuth();
        HudManager.dismiss();
        NavHelper.backToHome();
        return;
      }
      HudManager.showFailure(message: 'Delete failed');
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }
}
