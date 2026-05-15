import 'package:cash_pinoy/network/api_endpoints.dart';
import 'package:cash_pinoy/network/api_manager.dart';
import 'package:cash_pinoy/screens/bind/withdraw_info_screen.dart';
import 'package:cash_pinoy/tools/json.dart';
import 'package:cash_pinoy/utils/hud_manager.dart';
import 'package:cash_pinoy/utils/native_bridge.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:cash_pinoy/utils/report_manager.dart';
import 'package:cash_pinoy/utils/request_error.dart';
import 'package:cash_pinoy/utils/retention_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cash_pinoy/screens/loan/loan_detail_screen.dart';

import '../../app.dart';
import '../../constants/app_assets.dart';
import '../../utils/screen_adapter.dart';

class WebviewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const WebviewScreen({super.key, required this.url, this.title});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen>
    with RouteAware, WidgetsBindingObserver {
  static const String _bridgeHandlerName = 'ph_cash_pinoy_ios';
  InAppWebViewController? _controller;
  late String _title;
  bool _loading = true;
  bool _routeActive = true;
  bool _appForeground = true;
  bool _bridgeEnabled = false;

  @override
  void initState() {
    super.initState();
    _title = widget.title ?? 'Loading...';
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      CashPinoyApp.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPush() {
    _routeActive = true;
    _syncJsBridgeState();
  }

  @override
  void didPopNext() {
    _routeActive = true;
    _syncJsBridgeState();
  }

  @override
  void didPushNext() {
    _routeActive = false;
    _syncJsBridgeState();
  }

  @override
  void didPop() {
    _routeActive = false;
    _syncJsBridgeState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appForeground = state == AppLifecycleState.resumed;
    _syncJsBridgeState();
  }

  @override
  void dispose() {
    _routeActive = false;
    _appForeground = false;
    _syncJsBridgeState();
    CashPinoyApp.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> didClickBackButton() async {
    try {
      final url = (await _controller?.getUrl() ?? '').toString();
      if (url.contains('Solecisms')) {
        String productId = '';
        try {
          final uri = Uri.parse(url);
          productId = uri.queryParameters['enfeeblement'] ?? '';
          if (productId.isEmpty) {
            final fragment = uri.fragment;
            final idx = fragment.indexOf('?');
            if (idx != -1 && idx + 1 < fragment.length) {
              final fragQuery = fragment.substring(idx + 1);
              productId = Uri.splitQueryString(fragQuery)['enfeeblement'] ?? '';
            }
          }
        } catch (_) {}
        await RetentionHelper.confirmLeave(
          context,
          inputType: '5',
          productId: productId,
        );
        return;
      }
      final canBack = await _controller?.canGoBack() ?? false;
      if (canBack) {
        _controller?.goBack();
      } else {
        NavHelper.back();
      }
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  void _syncJsBridgeState() {
    final controller = _controller;
    if (controller == null) return;
    final shouldEnable = _routeActive && _appForeground;
    if (shouldEnable == _bridgeEnabled) return;
    if (shouldEnable) {
      controller.addJavaScriptHandler(
        handlerName: _bridgeHandlerName,
        callback: _handleJsBridgeCall,
      );
      _bridgeEnabled = true;
    } else {
      controller.removeJavaScriptHandler(handlerName: _bridgeHandlerName);
      _bridgeEnabled = false;
    }
  }

  Future<dynamic> _handleJsBridgeCall(List<dynamic> arguments) async {
    if (!_routeActive || !_appForeground || !mounted) {
      return {'ignored': true};
    }
    final raw = arguments.isNotEmpty ? arguments.first : null;
    final json = raw is String ? Json.parse(raw) : Json(raw);
    final action = json['action'].stringValue;
    final callbackId = json['callbackId'].stringValue;
    final data = json['data'];
    if (action == 'cash_pinoy_xiCKXBomQ2fNpAq') {
      // risk point
      final productId = data['enfeeblement'].stringValue;
      final orderNo = data['sirens'].stringValue;
      ReportManager.reportBuriedPointWithLocation(
        productId: productId,
        sceneType: '10',
        orderNo: orderNo,
        startTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      );
    } else if (action == 'cash_pinoy_SUM3gX4ldFByQYQ') {
      // open safari
      final uri = Uri.parse(data.stringValue);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Open link Error');
      }
    } else if (action == 'cash_pinoy_NDlNGLLeflS5fvF') {
      // open url
      final url = data.stringValue;
      if (url.isNotEmpty) {
        NavHelper.toScheme(url);
      }
    } else if (action == 'cash_pinoy_3jBYZbHLzajPcxX') {
      // close web
      NavHelper.back();
    } else if (action == 'cash_pinoy_GSgLS4BIxfSGq8M') {
      // to home
      NavHelper.backToHome();
    } else if (action == 'cash_pinoy_hxCJwC841asuaL6') {
      // review app
      await NativeBridge.requestAppReview();
    } else if (action == 'cash_pinoy_dzzUjhHtGw6VmA1') {
      // try again
      try {
        final orderNo = data['sirens'].stringValue;
        HudManager.showLoading();
        final response = await RetryApi().retryOrderRequests(orderNo);
        final newUrl = response.dysphasias['belletristic'].stringValue;
        HudManager.dismiss();
        NavHelper.toScheme(newUrl);
      } catch (e) {
        HudManager.showFailure(message: RequestError.message(e));
      }
    } else if (action == 'cash_pinoy_4dio8vc7hGlUjFF') {
      // change account
      try {
        HudManager.showLoading();
        final productId = data['enfeeblement'].stringValue;
        final orderNo = data['sirens'].stringValue;
        final response = await CertifyApi().fetchUserCardList(
          productId: productId,
        );
        final model = response.dysphasias['bleaching'].listValue;
        HudManager.dismiss();
        if (model.isNotEmpty) {
          NavHelper.to(LoanDetailScreen(productId: productId, orderNo: orderNo));
        } else {
          NavHelper.to(
            WithdrawInfoScreen(productId: productId, orderNo: orderNo),
          );
        }
      } catch (e) {
        HudManager.showFailure(message: RequestError.message(e));
      }
    } else if (action == 'cash_pinoy_TzvTGfY4ZGIIPwR') {
      // load parame
      try {
        final path = data.stringValue;
        final publicParam = await ApiManager.buildCommonParamsAsync(path: path);
        final jsonStr = Json({
          'callbackId': callbackId,
          'data': publicParam,
        }).rawString();
        await _controller?.evaluateJavascript(
          source: 'window.ph_cash_pinoy_ios.handleMessage($jsonStr);',
        );
      } catch (e) {
        HudManager.showFailure(message: RequestError.message(e));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await didClickBackButton();
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
              bottom: false,
              child: Column(
                children: [
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      SizedBox(width: 12.w),
                      InkWell(
                        onTap: () async {
                          await didClickBackButton();
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
                            _title,
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
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri.uri(Uri.parse(widget.url)),
                      ),
                      onReceivedServerTrustAuthRequest:
                          (controller, challenge) async {
                            return ServerTrustAuthResponse(
                              action: ServerTrustAuthResponseAction.PROCEED,
                            );
                          },
                      onPermissionRequest:
                          (controller, permissionRequest) async {
                            return PermissionResponse(
                              resources: permissionRequest.resources,
                              action: PermissionResponseAction.GRANT,
                            );
                          },
                      initialSettings: InAppWebViewSettings(
                        allowsInlineMediaPlayback: true,
                        useHybridComposition: true,
                        javaScriptEnabled: true,
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false,
                        mixedContentMode:
                            MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                        isInspectable: true,
                      ),
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                            var uri = navigationAction.request.url!;
                            List<String> list = [
                              'http',
                              'https',
                              'file',
                              'chrome',
                              'data',
                              'javascript',
                              'about',
                            ];
                            if (!list.contains(uri.scheme)) {
                              await launchUrl(uri);
                              return NavigationActionPolicy.CANCEL;
                            }
                            return NavigationActionPolicy.ALLOW;
                          },
                      onTitleChanged: (controller, title) {
                        setState(() {
                          HudManager.dismiss();
                          _title = title ?? '';
                        });
                      },
                      onLoadStart: (controller, url) {
                        if (mounted) setState(() => _loading = true);
                      },
                      onLoadStop: (controller, url) {
                        if (mounted) {
                          setState(() {
                            HudManager.dismiss();
                            _loading = false;
                          });
                        }
                      },
                      onWebViewCreated: (controller) async {
                        _controller = controller;
                        _syncJsBridgeState();
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: SizedBox(
                      width: 28.w,
                      height: 28.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF7B39F5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
