import 'package:cash_pinoy/network/api_manager.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:cash_pinoy/utils/report_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';

import '../../constants/app_assets.dart';
import '../../network/api_endpoints.dart';
import '../../utils/hud_manager.dart';
import '../../utils/request_error.dart';
import '../../utils/screen_adapter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocus = FocusNode();
  String startTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

  bool _submitting = false;
  bool _agree = true;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _phoneController.text = AppInfoManager.phone;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  bool get _canSubmit => _codeController.text.trim().length == 6 && _agree;

  bool get _canSendCode => _countdown == 0;

  Future<void> _submitLogin() async {
    if (_submitting || !_canSubmit) return;
    setState(() => _submitting = true);
    FocusScope.of(context).unfocus();
    try {
      HudManager.showLoading();
      final phone = _phoneController.text.trim();
      final code = _codeController.text.trim();
      final response = await UserApi().loginBySms(
        username: phone,
        smsCode: code,
      );
      final minesweepers = response.dysphasias['minesweepers'].stringValue;
      AppInfoManager.setToken(minesweepers);
      AppInfoManager.setPhone(phone);
      AppInfoManager.setLoginTime(
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      );
      ReportManager.reportLocationFromNative();
      ReportManager.reportGoogleMarket();
      ReportManager.uploadApplePushToken();
      ReportManager.reportBuriedPointWithLocation(
        productId: '',
        sceneType: '1',
        orderNo: '',
        startTime: startTime,
      );
      await HudManager.showSuccess(
        message: response.amenorrheic,
        onDismiss: () {
          AppInfoManager.notifyLogin();
          if (mounted) NavHelper.backToHome();
        },
      );
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
      _handleLoginFailure();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _handleLoginFailure() {
    _codeController.clear();
    _codeFocus.requestFocus();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    try {
      HudManager.showLoading();
      startTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final response = await UserApi().getSmsCode(phone: phone);
      HudManager.showSuccess(message: response.amenorrheic);
      _startCountdown();
      _codeFocus.requestFocus();
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
        return;
      }
      setState(() => _countdown -= 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        NavHelper.backToHome();
        return false;
      },
      child: Scaffold(
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.loginBg),
              fit: BoxFit.fill,
            ),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      child: InkWell(
                        onTap: NavHelper.backToHome,
                        child: Image.asset(
                          AppAssets.iconBack,
                          width: 24.w,
                          height: 24.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Center(
                      child: Text(
                        'Cash Pinoy',
                        style: TextStyle(
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 18.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              AppAssets.loginTop,
                              height: 82.h,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Please fill in your phone number',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF7B7B7B),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            _buildPhoneField(),
                            SizedBox(height: 24.h),
                            Text(
                              'Send SMS verification code',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF7B7B7B),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            _buildCodeField(),
                            SizedBox(height: 24.h),
                            _buildLoginButton(),
                            SizedBox(height: 14.h),
                            _buildPolicyRow(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECFA),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          Text(
            '+63',
            style: TextStyle(
              color: const Color(0xFF7E3AF2),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Cellphone number',
                  hintStyle: TextStyle(
                    color: const Color(0xFF969696),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  isCollapsed: true,
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF2F2F2F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeField() {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECFA),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: AutofillGroup(
              child: CupertinoTextField(
                controller: _codeController,
                focusNode: _codeFocus,
                keyboardType: TextInputType.number,
                maxLength: 6,
                placeholder: 'Verification Code',
                decoration: BoxDecoration(
                  border: null,
                  color: Colors.transparent,
                ),
                onChanged: (value) {
                  setState(() {});
                  if (value.trim().length == 6 && _agree) {
                    _submitLogin();
                  }
                },
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: _canSendCode ? _sendCode : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _canSendCode
                    ? const Color(0xFFEDE7FF)
                    : const Color(0xFFE0DFE3),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _canSendCode
                      ? const Color(0xFF7E3AF2)
                      : const Color(0xFFBFBAC2),
                ),
              ),
              child: Text(
                _countdown > 0 ? '${_countdown}s' : 'Get Code',
                style: TextStyle(
                  color: _canSendCode
                      ? const Color(0xFF7E3AF2)
                      : const Color(0xFF8B8B8B),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    final enabled = _canSubmit && !_submitting;
    return GestureDetector(
      onTap: enabled ? _submitLogin : null,
      child: Container(
        height: 46.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? null : const Color(0xFFBFBAC2),
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFF7927EB), Color(0xFFA932F7)],
                )
              : null,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Text(
          'Sign up / Sign in',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyRow() {
    return Row(
      children: [
        InkWell(
          onTap: () => setState(() => _agree = !_agree),
          child: Container(
            width: 18.w,
            height: 18.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: const Color(0xFFBFBAC2)),
              color: _agree ? const Color(0xFF7E3AF2) : Colors.transparent,
            ),
            child: Image.asset(
              _agree ? AppAssets.loginSelected : AppAssets.loginNormal,
              width: 16.w,
              height: 16.w,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: const Color(0xFF7B7B7B), fontSize: 14.sp),
              children: [
                const TextSpan(text: 'I have read and agree to the '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(color: Color(0xFF7E3AF2)),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _openPrivacyPolicy,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openPrivacyPolicy() {
    HudManager.showLoading();
    NavHelper.toWeb('${ApiManager.defaultBaseWebUrl}/#/DecurvesSynanon');
  }
}
