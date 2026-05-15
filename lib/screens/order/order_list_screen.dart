import 'package:cash_pinoy/model/order_model.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../constants/app_assets.dart';
import '../../network/api_endpoints.dart';
import '../../utils/hud_manager.dart';
import '../../utils/request_error.dart';
import '../../utils/screen_adapter.dart';

class OrderListScreen extends StatefulWidget {
  final String? initialType;

  const OrderListScreen({super.key, this.initialType});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with RouteAware {
  static final int _pageSize = 50;
  final ScrollController _scrollController = ScrollController();
  final List<OrderModel> _items = [];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _noMoreHintShown = false;
  int _pageNum = 1;
  String _currentType = '4';

  @override
  void initState() {
    super.initState();
    _currentType = _resolveInitialType(widget.initialType);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchList(refresh: true);
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
  void didPopNext() {
    _fetchList(refresh: true);
  }

  @override
  void dispose() {
    CashPinoyApp.routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  String _resolveInitialType(String? type) {
    const valid = {'4', '5', '6', '7'};
    if (type != null && valid.contains(type)) return type;
    return '4';
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 120.h) {
      _fetchList();
    }
  }

  Future<void> _fetchList({bool refresh = false}) async {
    if (_loading) return;
    if (refresh) {
      _pageNum = 1;
      _hasMore = true;
      _noMoreHintShown = false;
    }
    if (!_hasMore) return;
    setState(() {
      _loading = refresh;
      _loadingMore = !refresh;
    });
    try {
      if (refresh) HudManager.showLoading();
      final response = await OrderApi().fetchOrderList(
        orderType: _currentType,
        pageNum: _pageNum.toString(),
      );
      final list = response.dysphasias['bleaching'].listValue
          .map((e) => OrderModel.fromJson(e))
          .toList();
      if (refresh) {
        _items.clear();
      }
      _items.addAll(list);
      _pageNum += 1;
      _hasMore = list.length >= _pageSize;
      if (!_hasMore && _items.isNotEmpty && !_noMoreHintShown) {
        _noMoreHintShown = true;
        HudManager.showMessage(message: 'No more data');
      }
      if (refresh) HudManager.dismiss();
      if (mounted) setState(() {});
    } catch (e) {
      if (refresh) {
        HudManager.showFailure(message: RequestError.message(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  String _statusLabel(String type) {
    switch (type) {
      case '7':
        return 'Outstanding';
      case '6':
        return 'Overdue';
      case '5':
        return 'Settled';
      default:
        return 'All';
    }
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
            bottom: false,
            child: Column(
              children: [
                SizedBox(height: 6.h),
                Row(
                  children: [
                    SizedBox(width: 12.w),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
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
                          'Loan List',
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
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: _StatusTabs(
                    current: _currentType,
                    onChanged: (type) {
                      if (type == _currentType) return;
                      setState(() => _currentType = type);
                      _fetchList(refresh: true);
                    },
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _fetchList(refresh: true),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                        ),
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        itemCount: _items.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _items.length) {
                            if (_loadingMore) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            if (_items.isEmpty && !_loading) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.h),
                                child: Text(
                                  'No orders yet',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF9B95A3),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              );
                            }
                            if (!_hasMore && _items.isNotEmpty) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: Text(
                                  'No more data',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF9B95A3),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              );
                            }
                            return SizedBox(height: 20.h);
                          }
                          return _OrderItem(
                            data: _items[index],
                            defaultStatus: _statusLabel(_currentType),
                          );
                        },
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

class _StatusTabs extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _StatusTabs({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      _OrderTab(label: 'All', type: '4'),
      _OrderTab(label: 'Outstanding', type: '7'),
      _OrderTab(label: 'Overdue', type: '6'),
      _OrderTab(label: 'Settled', type: '5'),
    ];
    return Row(
      children: tabs
          .map(
            (tab) => Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(tab.type),
                child: Container(
                  height: 32.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    image: tab.type == current
                        ? const DecorationImage(
                            image: AssetImage(AppAssets.bankTitleBg),
                            fit: BoxFit.contain,
                          )
                        : null,
                    color: tab.type == current ? null : const Color(0xFFE2DEEA),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    tab.label,
                    style: TextStyle(
                      color: tab.type == current
                          ? const Color(0xFF6F2EF6)
                          : const Color(0xFF9B95A3),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final OrderModel data;
  final String defaultStatus;

  const _OrderItem({required this.data, required this.defaultStatus});

  @override
  Widget build(BuildContext context) {
    final showAction = data.outdistances == '180' || data.outdistances == '174';
    final actionColor = data.outdistances == '174'
        ? const Color(0xFF7B39F5)
        : const Color(0xFFFF6A35);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (data.gaslight.isEmpty) {
          NavHelper.enterProduct(productId: data.enfeeblement);
        } else {
          NavHelper.toScheme(data.gaslight);
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Container(
              height: 26.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE1C7FF),
                    const Color(0x00C4A5FF),
                    const Color(0x00C4A5FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                children: [
                  Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Image.network(
                      data.caesiums,
                      errorBuilder: (context, error, stackTrace) => SizedBox(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      data.preadapt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  Spacer(),
                  Flexible(
                    child: Text(
                      data.imitatively,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color:
                            data.outdistances == '180' ||
                                data.outdistances == '174'
                            ? const Color(0xFFFF6A35)
                            : const Color(0xFF9B95A3),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                if (!showAction) SizedBox(width: 30.w),
                Expanded(
                  child: _InfoItem(value: data.goniometry, label: data.sultans),
                ),
                Expanded(
                  child: _InfoItem(
                    value: data.riderships,
                    label: data.affiliated,
                    alignment: CrossAxisAlignment.end,
                  ),
                ),
                if (!showAction) SizedBox(width: 30.w),
                if (showAction)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: actionColor,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      'Repay Now',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20.h),
            Container(color: const Color(0xFFE2DEEA), height: 1.h),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String value;
  final String label;
  final CrossAxisAlignment alignment;

  const _InfoItem({
    required this.value,
    required this.label,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(color: const Color(0xFF9B95A3), fontSize: 11.sp),
        ),
      ],
    );
  }
}

class _OrderTab {
  final String label;
  final String type;

  const _OrderTab({required this.label, required this.type});
}
