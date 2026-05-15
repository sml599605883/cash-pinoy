import 'package:cash_pinoy/model/contact_model.dart';
import 'package:cash_pinoy/model/form_fields_model.dart';
import 'package:cash_pinoy/network/api_endpoints.dart';
import 'package:cash_pinoy/tools/json.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:cash_pinoy/utils/hud_manager.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:cash_pinoy/utils/report_manager.dart';
import 'package:cash_pinoy/utils/request_error.dart';
import 'package:cash_pinoy/widgets/announcer_select_sheet.dart';
import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../utils/screen_adapter.dart';
import '../certify/base_info_page.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

class EmergencyContactsScreen extends BaseInfoPage {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends BaseInfoPageState<EmergencyContactsScreen>
    with WidgetsBindingObserver {
  List<ContactModel> _contactModels = [];
  List<TextEditingController> _nameControllers = [];
  List<TextEditingController> _phoneControllers = [];
  List<TextEditingController> _relationControllers = [];
  bool _pickingContact = false;
  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();

  @override
  void initState() {
    super.initState();
    _fetchContactInfo();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  String? get retentionInputType => '4';

  Future<void> _fetchContactInfo() async {
    final productId = AppInfoManager.productId;
    if (productId.isEmpty) return;
    try {
      HudManager.showLoading();
      final response = await CertifyApi().fetchExtInfo(productId: productId);
      final models = response.dysphasias['starwort']['bleaching'].listValue
          .map((e) => ContactModel.fromJson(e))
          .toList();
      HudManager.dismiss();
      if (!mounted) return;
      _resetControllers(models);
      setState(() {
        _contactModels = models;
      });
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  void _resetControllers(List<ContactModel> models) {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _phoneControllers) {
      c.dispose();
    }
    for (final c in _relationControllers) {
      c.dispose();
    }
    _nameControllers = List.generate(
      models.length,
      (i) => TextEditingController(text: models[i].unpaid),
    );
    _phoneControllers = List.generate(
      models.length,
      (i) => TextEditingController(text: models[i].parashioth),
    );
    _relationControllers = List.generate(
      models.length,
      (i) => TextEditingController(text: _findRelationName(models[i])),
    );
  }

  Future<void> _pickContact(int index) async {
    if (_pickingContact) return;
    _pickingContact = true;
    try {
      FocusScope.of(context).unfocus();
      final contact = await _contactPicker.selectContact();
      if (!mounted || contact == null) return;
      if (index >= _nameControllers.length ||
          index >= _phoneControllers.length) {
        return;
      }

      final name = contact.fullName?.trim() ?? '';
      var phone = '';
      final numbers = contact.phoneNumbers;
      if (numbers != null) {
        for (final raw in numbers) {
          final trimmed = raw.trim();
          if (trimmed.isNotEmpty) {
            phone = trimmed;
            break;
          }
        }
      }

      // Update input controllers directly to avoid rebuilding the whole page.
      _nameControllers[index].text = name;
      _phoneControllers[index].text = phone;
    } finally {
      _pickingContact = false;
    }
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _phoneControllers) {
      c.dispose();
    }
    for (final c in _relationControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  String get title => 'Emergency Contacts';

  @override
  String get tip => AppInfoManager.productModel?.cogito.ext ?? '';

  @override
  String get progressAsset => AppAssets.process3;

  @override
  String get sectionTitle => 'Emergency Contacts';

  @override
  Color get bgColor => Colors.transparent;

  @override
  EdgeInsets get padding => EdgeInsets.zero;

  @override
  List<Widget> buildFields() {
    if (_contactModels.isEmpty) {
      return [const SizedBox.shrink()];
    }
    return List.generate(_contactModels.length, (index) {
      final i = index + 1;
      final model = _contactModels[index];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionChip(title: 'Relationship with Emergency Contacts - $i'),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => _pickContact(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(20.w),
              margin: EdgeInsets.only(bottom: 23.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoField(
                    label: 'Relationship',
                    hint: 'Please enter',
                    controller: _relationControllers[index],
                    isSelect: true,
                    onTap: () async {
                      final selected =
                          await showModalBottomSheet<FormOptionModel>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) =>
                                AnnouncerSelectSheet(options: model.fayed),
                          );
                      if (selected == null) return;
                      setState(() {
                        model.calypsoes = selected.dipteral;
                        _relationControllers[index].text = selected.unpaid;
                      });
                    },
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6A5E7A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _ContactInfoCard(
                    nameController: _nameControllers[index],
                    phoneController: _phoneControllers[index],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  @override
  void onSubmit() async {
    final list = <Map<String, String>>[];
    for (var i = 0; i < _contactModels.length; i++) {
      final model = _contactModels[i];
      list.add({
        'parashioth': _phoneControllers[i].text,
        'unpaid': _nameControllers[i].text,
        'calypsoes': model.calypsoes,
        'furtively': model.furtively,
      });
    }
    final payload = Json(list).rawString();
    try {
      HudManager.showLoading();
      await CertifyApi().saveExtInfo(
        productId: AppInfoManager.productId,
        data: payload,
      );
      ReportManager.reportBuriedPointWithLocation(
        productId: AppInfoManager.productId,
        sceneType: '7',
        orderNo: AppInfoManager.orderNo,
        startTime: startTime,
      );
      NavHelper.fetchProductDetail(productId: AppInfoManager.productId);
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  String _findRelationName(ContactModel model) {
    if (model.calypsoes.isEmpty) return '';
    for (final option in model.fayed) {
      if (option.dipteral == model.calypsoes) {
        return option.unpaid;
      }
    }
    return '';
  }
}

class _SectionChip extends StatelessWidget {
  final String title;

  const _SectionChip({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        gradient: LinearGradient(
          colors: [Color(0xFFE1C7FF), Color(0x00C4A5FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF6A5E7A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const _ContactInfoCard({
    required this.nameController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECFB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      height: 76.h,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InlineField(
                  controller: nameController,
                  hint: 'Name',
                ),
                SizedBox(height: 6.h),
                _InlineField(
                  controller: phoneController,
                  hint: 'Phone Number',
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 28.w,
            height: 28.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F6EA),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Image.asset(
              AppAssets.contactIcon,
              width: 20.w,
              height: 26.h,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _InlineField({
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        final text = value.text.trim();
        final hasValue = text.isNotEmpty;
        return Text(
          hasValue ? value.text : hint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            color: hasValue
                ? const Color(0xFF2F2F2F)
                : const Color(0xFF969696),
            fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      },
    );
  }
}
