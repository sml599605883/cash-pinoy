import 'package:cash_pinoy/model/address_model.dart';
import 'package:cash_pinoy/model/form_fields_model.dart';
import 'package:cash_pinoy/network/api_endpoints.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:cash_pinoy/utils/hud_manager.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:cash_pinoy/utils/report_manager.dart';
import 'package:cash_pinoy/utils/request_error.dart';
import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../widgets/announcer_select_sheet.dart';
import '../../widgets/address_select_sheet.dart';
import '../../widgets/crosshatch_select_sheet.dart';
import 'base_info_page.dart';

class WorkInfoScreen extends BaseInfoPage {
  const WorkInfoScreen({super.key});

  @override
  State<WorkInfoScreen> createState() => _WorkInfoScreenState();
}

class _WorkInfoScreenState extends BaseInfoPageState<WorkInfoScreen>
    with WidgetsBindingObserver {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _focusNodes = {};
  List<FormFieldModel> _fields = [];
  final Map<int, GlobalKey> _fieldKeys = {};
  final ScrollController _scrollController = ScrollController();
  int? _currentFocusId;
  List<AddressModel> _addressOptions = [];
  final Map<int, String> _addressValues = {};

  @override
  void initState() {
    super.initState();
    _fetchWorkInfo();
    _fetchAddressInfo();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  String? get retentionInputType => '3';

  Future<void> _fetchWorkInfo() async {
    final productId = AppInfoManager.productId;
    if (productId.isEmpty) return;
    try {
      HudManager.showLoading();
      final response = await CertifyApi().fetchJobInfo(productId: productId);
      final model = FormFieldsResponseModel.fromJson(response.dysphasias);
      for (final field in model.fields) {
        _controllers[field.uniquely] = TextEditingController(
          text: field.paralyze,
        );
        final node = FocusNode();
        node.addListener(() {
          if (node.hasFocus) {
            _currentFocusId = field.uniquely;
            _ensureVisible(field.uniquely);
          }
        });
        _focusNodes[field.uniquely] = node;
        _fieldKeys[field.uniquely] = GlobalKey();
      }
      HudManager.dismiss();
      if (!mounted) return;
      setState(() => _fields = model.fields);
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  Future<void> _fetchAddressInfo() async {
    try {
      final response = await CertifyApi().fetchCityInit();
      final addressmodel = response.dysphasias['bleaching'].listValue
          .map((e) => AddressModel.fromJson(e))
          .toList();
      if (!mounted) return;
      setState(() => _addressOptions = addressmodel);
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final inset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (!mounted) return;
    if (inset > 0 && _currentFocusId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ensureVisible(_currentFocusId!);
      });
    }
  }

  @override
  String get title => 'Work Information';

  @override
  String get tip => AppInfoManager.productModel?.cogito.job ?? '';

  @override
  String get progressAsset => AppAssets.process2;

  @override
  String get sectionTitle => 'Work Information';

  @override
  ScrollController? get listController => _scrollController;

  @override
  double get extraBottomPadding => MediaQuery.of(context).viewInsets.bottom;

  @override
  List<Widget> buildFields() {
    if (_fields.isEmpty) {
      return [const SizedBox.shrink()];
    }
    return _fields.map((field) {
      final controller = _controllers[field.uniquely];
      final displayValue = field.selectedOption?.unpaid ?? field.paralyze;
      final addressValue = _addressValues[field.uniquely];
      final resolvedValue = addressValue ?? displayValue;
      if (field.isSelect && controller != null) {
        controller.text = resolvedValue;
      }
      return InfoField(
        key: _fieldKeys[field.uniquely],
        label: field.earnings,
        hint: field.saccharide,
        controller: controller,
        focusNode: _focusNodes[field.uniquely],
        isSelect: field.isSelect,
        keyboardType: field.reckoners == 1
            ? TextInputType.number
            : TextInputType.text,
        onTap: field.isSelect
            ? () async {
                if (field.juridic == 'crosshatch') {
                  _clearFocus();
                  final selection =
                      await showModalBottomSheet<CrosshatchSelection>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) =>
                            CrosshatchSelectSheet(options: field.cogito),
                      );
                  _clearFocus();
                  if (selection == null) return;
                  final text =
                      '${selection.level1.unpaid}|${selection.level2.unpaid}';
                  setState(() {
                    _addressValues[field.uniquely] = text;
                    field.selectedOption = selection.level2;
                  });
                  return;
                }
                if (field.isAddress) {
                  _clearFocus();
                  final selection =
                      await showModalBottomSheet<AddressSelection>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) =>
                            AddressSelectSheet(options: _addressOptions),
                      );
                  _clearFocus();
                  if (selection == null) return;
                  final text =
                      '${selection.level1.unpaid}-${selection.level2.unpaid}-${selection.level3.unpaid}';
                  setState(() {
                    _addressValues[field.uniquely] = text;
                  });
                  return;
                }
                _clearFocus();
                final selected = await showModalBottomSheet<FormOptionModel>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => AnnouncerSelectSheet(options: field.cogito),
                );
                _clearFocus();
                if (selected == null) return;
                setState(() => field.selectOption(selected));
              }
            : null,
        onTapField: () => _ensureVisible(field.uniquely),
        onFocus: () => _ensureVisible(field.uniquely),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  void onSubmit() async {
    final form = <String, String>{};
    for (final field in _fields) {
      final key = field.juridic;
      if (key.isEmpty) continue;
      if (field.isAnnouncer) {
        form[key] = field.selectedOption?.dipteral ?? '';
      } else if (field.juridic == 'crosshatch') {
        form[key] = field.selectedOption?.dipteral ?? '';
      } else {
        final addressValue = _addressValues[field.uniquely];
        final controller = _controllers[field.uniquely];
        final value = addressValue ?? controller?.text.trim() ?? '';
        form[key] = value;
      }
    }
    try {
      HudManager.showLoading();
      await CertifyApi().saveJob(
        productId: AppInfoManager.productId,
        form: form,
      );
      ReportManager.reportBuriedPointWithLocation(
        productId: AppInfoManager.productId,
        sceneType: '6',
        orderNo: AppInfoManager.orderNo,
        startTime: startTime,
      );
      NavHelper.fetchProductDetail(productId: AppInfoManager.productId);
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  void _ensureVisible(int id) {
    final key = _fieldKeys[id];
    final context = key?.currentContext;
    if (context == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: 0.3,
      );
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
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
