import 'dart:async';

import 'package:cash_pinoy/model/home_model.dart';
import 'package:cash_pinoy/network/api_endpoints.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:cash_pinoy/utils/hud_manager.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import 'data/home_repository.dart';
import '../../utils/screen_adapter.dart';
import '../../app.dart';
import '../home_shell.dart';
import '../../utils/request_error.dart';
import '../../utils/glasshouse_dialog_manager.dart';
import 'widgets/hero_card.dart';
import 'widgets/order_status_card.dart';
import 'widgets/promo_banner.dart';
import 'widgets/quick_steps.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with RouteAware, WidgetsBindingObserver {
  bool _loading = false;
  final HomeRepository _repository = HomeRepository();
  HomeModel? _homeData;
  bool _hasRequested = false;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  Future<void> refresh() => _fetchHome(force: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppInfoManager.homeRefreshVersion.addListener(_handleHomeRefresh);
    _initConnectivity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasRequested) {
        _refreshOnAppear();
      }
    });
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
  void dispose() {
    CashPinoyApp.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    AppInfoManager.homeRefreshVersion.removeListener(_handleHomeRefresh);
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  void didPush() {
    _refreshOnAppear();
  }

  @override
  void didPopNext() {
    _refreshOnAppear();
  }

  void _refreshOnAppear() {
    if (HomeShell.tabIndex.value != 0) return;
    if (!_hasRequested) {
      _hasRequested = true;
      _fetchHome();
      return;
    }
    _fetchHome(force: true);
  }

  void _handleHomeRefresh() {
    if (!mounted) return;
    _fetchHome(force: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        mounted &&
        !_loading &&
        _homeData == null) {
      _fetchHome(force: true);
    }
  }

  Future<void> _fetchHome({bool force = false}) async {
    if (_loading && !force) return;
    setState(() => _loading = true);
    try {
      HudManager.showLoading();
      final response = await _repository.fetchHome();
      _homeData = HomeModel.fromJson(response.dysphasias);
      HudManager.dismiss();
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          GlasshouseDialogManager.checkAndShow(context, adaptationPage: 1);
        });
      }
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();
    final initial = await connectivity.checkConnectivity();
    _updateConnectivity(initial);
    _connectivitySub = connectivity.onConnectivityChanged.listen(
      (results) => _updateConnectivity(results),
    );
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    final online = results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
    if (online != _isOnline) {
      setState(() => _isOnline = online);
    }
    if (online && _homeData == null && !_loading) {
      _fetchHome(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final banners = _homeData?.banners ?? <HomeBannerModel>[];
    final processList = _homeData?.processList ?? <HomeProcessModel>[];
    final products = _homeData?.productList ?? <HomeProductModel>[];
    if (!_isOnline) {
      return SafeArea(child: _NoNetworkView(onRetry: _fetchHome));
    }
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchHome,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroCard(
                model: _homeData?.largeCard,
                onTap: () {
                  NavHelper.enterProduct(
                    productId: _homeData!.largeCard!.uniquely,
                  );
                },
                onSupportTap: () {
                  HudManager.showLoading();
                  NavHelper.toScheme(_homeData?.grayout.surliest ?? '');
                },
              ),
              if (_homeData != null)
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (processList.isNotEmpty)
                        OrderStatusCard(processList: processList),
                      if (_homeData!.largeCard!.egestions.isEmpty &&
                          _homeData!.largeCard!.transcendency.isEmpty) ...[
                        SizedBox(height: 16.h),
                        QuickSteps(),
                      ],
                      if (banners.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        PromoBanner(
                          banners: banners,
                          onTap: (banner) {
                            if (banner.linkUrl.isNotEmpty) {
                              try {
                                AppApi().uploadBannerClick(
                                  bannerConfigId: banner.bannerId,
                                );
                              } catch (e) {
                                print(RequestError.message(e));
                              }
                              NavHelper.toScheme(banner.linkUrl);
                            }
                          },
                        ),
                        SizedBox(height: 18.h),
                      ],
                      if (products.isNotEmpty) ...[
                        const SectionTitle(
                          title: 'Recommendation',
                          showIcon: true,
                        ),
                        SizedBox(height: 12.h),
                        ...products.asMap().entries.map((entry) {
                          final item = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: RecommendationCard(product: item),
                          );
                        }),
                      ],
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

class _NoNetworkView extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _NoNetworkView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppAssets.noNetwork, width: 220.w, fit: BoxFit.contain),
          SizedBox(height: 16.h),
          Text(
            'Calculating your credit limit, just 30 seconds\nPlease wait patiently',
            textAlign: TextAlign.center,
            style: TextStyle(color: const Color(0xFF9B95A3), fontSize: 12.sp),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF7B39F5),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Update Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
