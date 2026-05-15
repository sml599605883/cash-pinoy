import 'package:cash_pinoy/network/api_manager.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../app.dart';
import '../../utils/nav_helper.dart';
import '../../utils/screen_adapter.dart';
import '../account/account_screen.dart';
import '../home_shell.dart';
import '../order/order_list_screen.dart';
import '../../utils/glasshouse_dialog_manager.dart';

class MineScreen extends StatefulWidget {
  const MineScreen({super.key});

  @override
  State<MineScreen> createState() => _MineScreenState();
}

class _MineScreenState extends State<MineScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    HomeShell.tabIndex.addListener(_handleTabChange);
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
    HomeShell.tabIndex.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (HomeShell.tabIndex.value == 1 && mounted) {
      setState(() {});
      GlasshouseDialogManager.checkAndShow(context, adaptationPage: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topHeight = 280.h;
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFFA),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topHeight,
            child: Image.asset(AppAssets.mineTopBg, fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                children: [
                  SizedBox(height: 6.h),
                  Text(
                    'Mine',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3A3A3A),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: GestureDetector(
                      onTap: () => NavHelper.to(const AccountScreen()),
                      child: _buildAccountCard(),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _buildStatusRow(),
                  SizedBox(height: 18.h),
                  _buildServiceTitle(),
                  SizedBox(height: 12.h),
                  _buildServiceCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      height: 117.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          image: AssetImage(AppAssets.mineCardBg),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 30.h,
            child: Text(
              AppInfoManager.phone.isNotEmpty
                  ? '${AppInfoManager.phone.substring(0, 3)}***${AppInfoManager.phone.substring(AppInfoManager.phone.length - 4)}'
                  : '',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'User ID :',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B6B6B)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 36.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatusItem(
            icon: AppAssets.mineIconAll,
            label: 'All',
            onTap: () => NavHelper.to(const OrderListScreen(initialType: '4')),
          ),
          _StatusItem(
            icon: AppAssets.mineIconOutstanding,
            label: 'Outstanding',
            onTap: () => NavHelper.to(const OrderListScreen(initialType: '7')),
          ),
          _StatusItem(
            icon: AppAssets.mineIconSettled,
            label: 'Settled',
            onTap: () => NavHelper.to(const OrderListScreen(initialType: '5')),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Image.asset(AppAssets.heroBadge, width: 18.w, height: 18.w),
          SizedBox(width: 8.w),
          Text(
            'Our service',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 192.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
        child: Column(
          children: [
            _ServiceItem(
              icon: AppAssets.mineIconService,
              label: 'Customer service',
              onTap: () {
                NavHelper.toWeb('${ApiManager.defaultBaseWebUrl}/#/Outer');
              },
            ),
            const _ServiceDivider(),
            _ServiceItem(
              icon: AppAssets.mineIconPrivacy,
              label: 'Privacy',
              onTap: () {
                NavHelper.toWeb(
                  '${ApiManager.defaultBaseWebUrl}/#/DecurvesSynanon',
                );
              },
            ),
            const _ServiceDivider(),
            _ServiceItem(
              icon: AppAssets.mineIconSetting,
              label: 'Account',
              onTap: () {
                NavHelper.to(const AccountScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const _StatusItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62.w,
            height: 62.w,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Image.asset(icon),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF444444)),
          ),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const _ServiceItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52.h,
        child: Row(
          children: [
            Image.asset(icon, width: 32.w, height: 32.w),
            SizedBox(width: 14.w),
            Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF333333)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceDivider extends StatelessWidget {
  const _ServiceDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 8.h, thickness: 1, color: const Color(0xFFE7E2F2));
  }
}
