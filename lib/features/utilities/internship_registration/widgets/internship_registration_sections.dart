import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/models/internship_registration_form_type.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_date_field.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_dropdown_field.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_field_shell.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_picker_field.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_read_only_field.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_section_card.dart';

class InternshipRegistrationInfoBanner extends StatelessWidget {
  const InternshipRegistrationInfoBanner({
    required this.dateRangeText,
    this.message,
    this.isActive = false,
    super.key,
  });

  final String? message;
  final String dateRangeText;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isActive
        ? const Color(0xFFEAF4FF)
        : const Color(0xFFFFF7E8);

    final borderColor = isActive
        ? const Color(0xFF9CC8F5)
        : const Color(0xFFFFD27D);

    final textColor = isActive
        ? const Color(0xFF1D4F80)
        : const Color(0xFF7A4B00);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: isActive
          ? Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        const TextSpan(text: 'Thời gian đăng ký: '),
                        TextSpan(
                          text: dateRangeText,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Thời gian đăng ký: $dateRangeText',
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
    );
  }
}

class InternshipRegistrationAcademicYearSection extends StatelessWidget {
  const InternshipRegistrationAcademicYearSection({
    required this.items,
    required this.selectedValue,
    required this.isBusy,
    required this.onChanged,
    super.key,
  });

  final List<AcademicYearOption> items;
  final String? selectedValue;
  final bool isBusy;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InternshipRegistrationSectionCard(
      title: '',
      child: InternshipRegistrationDropdownField<String>(
        label: 'Năm học đăng ký',
        value: selectedValue,
        hintText: 'Chọn năm học',
        enabled: !isBusy,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(item.name),
              ),
            )
            .toList(growable: false),
        onChanged: onChanged,
      ),
    );
  }
}

class InternshipRegistrationGeneralSection extends StatelessWidget {
  const InternshipRegistrationGeneralSection({
    required this.majorText,
    required this.cpaController,
    required this.canEditForm,
    required this.isFacultyAssign,
    required this.selectedType,
    required this.onTypeChanged,
    this.showCpaField = true,
    super.key,
  });

  final String majorText;
  final TextEditingController cpaController;
  final bool canEditForm;
  final bool isFacultyAssign;
  final bool showCpaField;
  final InternshipRegistrationFormType? selectedType;
  final ValueChanged<InternshipRegistrationFormType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return InternshipRegistrationSectionCard(
      title: '',
      child: Column(
        children: [
          InternshipRegistrationReadOnlyField(label: 'Ngành', value: majorText),
          if (showCpaField) ...[
            const SizedBox(height: 12),
            InternshipRegistrationTextInput(
              label: 'CPA (thang 4)',
              controller: cpaController,
              enabled: canEditForm,
              hintText: 'Nhập CPA tính đến hiện tại',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (isFacultyAssign)
            const InternshipRegistrationReadOnlyField(
              label: 'Hình thức đăng ký',
              value: 'Khoa phân công',
            )
          else
            InternshipRegistrationDropdownField<InternshipRegistrationFormType>(
              label: 'Hình thức đăng ký',
              value: selectedType,
              hintText: 'Chọn doanh nghiệp thực tập',
              enabled: canEditForm,
              items: const [
                DropdownMenuItem(
                  value: InternshipRegistrationFormType.yourself,
                  child: Text('Tự liên hệ'),
                ),
                DropdownMenuItem(
                  value: InternshipRegistrationFormType.wish,
                  child: Text('Chọn doanh nghiệp thực tập'),
                ),
              ],
              onChanged: onTypeChanged,
            ),
        ],
      ),
    );
  }
}

class InternshipRegistrationWishSection extends StatelessWidget {
  const InternshipRegistrationWishSection({
    required this.slotCount,
    required this.canEditForm,
    required this.preferredCompanyIds,
    required this.companyItemsBuilder,
    required this.onChanged,
    super.key,
  });

  final int slotCount;
  final bool canEditForm;
  final List<String?> preferredCompanyIds;
  final List<InternshipRegistrationPickerOption<String>> Function(
    String? currentValue,
  )
  companyItemsBuilder;
  final void Function(int index, String? value) onChanged;

  @override
  Widget build(BuildContext context) {
    if (slotCount <= 0) {
      return const InternshipRegistrationSectionCard(
        title: '',
        child: Text(
          'Chưa có cấu hình số lượng nguyện vọng doanh nghiệp từ hệ thống.',
        ),
      );
    }

    return InternshipRegistrationSectionCard(
      title: '',
      child: Column(
        children: List<Widget>.generate(slotCount, (index) {
          final currentValue = index < preferredCompanyIds.length
              ? preferredCompanyIds[index]
              : null;

          return Padding(
            padding: EdgeInsets.only(bottom: index == slotCount - 1 ? 0 : 12),
            child: InternshipRegistrationPickerField<String>(
              label: 'Nguyện vọng ${index + 1}',
              value: currentValue?.trim().isEmpty ?? true ? null : currentValue,
              hintText: 'Chọn công ty',
              enabled: canEditForm,
              enableLocalSearch: true,
              options: companyItemsBuilder(currentValue),
              onChanged: (value) => onChanged(index, value),
            ),
          );
        }),
      ),
    );
  }
}

class InternshipRegistrationSelfContactSection extends StatelessWidget {
  const InternshipRegistrationSelfContactSection({
    required this.canEditForm,
    required this.companyNameController,
    required this.companyFieldController,
    required this.companyAddressController,
    required this.representativeNameController,
    required this.representativePhoneController,
    required this.representativeJobController,
    required this.expectedStartTime,
    required this.expectedEndTime,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.formatDate,
    super.key,
  });

  final bool canEditForm;
  final TextEditingController companyNameController;
  final TextEditingController companyFieldController;
  final TextEditingController companyAddressController;
  final TextEditingController representativeNameController;
  final TextEditingController representativePhoneController;
  final TextEditingController representativeJobController;
  final DateTime? expectedStartTime;
  final DateTime? expectedEndTime;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final String Function(DateTime value) formatDate;

  @override
  Widget build(BuildContext context) {
    return InternshipRegistrationSectionCard(
      title: '',
      child: Column(
        children: [
          InternshipRegistrationTextInput(
            label: 'Tên công ty',
            controller: companyNameController,
            enabled: canEditForm,
            hintText: 'Nhập tên công ty',
          ),
          const SizedBox(height: 12),
          InternshipRegistrationTextInput(
            label: 'Lĩnh vực',
            controller: companyFieldController,
            enabled: canEditForm,
            hintText: 'Nhập lĩnh vực công ty',
          ),
          const SizedBox(height: 12),
          InternshipRegistrationTextInput(
            label: 'Địa chỉ công ty',
            controller: companyAddressController,
            enabled: canEditForm,
            hintText: 'Nhập địa chỉ công ty',
          ),
          const SizedBox(height: 12),
          InternshipRegistrationTextInput(
            label: 'Họ tên người hướng dẫn',
            controller: representativeNameController,
            enabled: canEditForm,
            hintText: 'Nhập họ tên người hướng dẫn',
          ),
          const SizedBox(height: 12),
          InternshipRegistrationTextInput(
            label: 'Số điện thoại người hướng dẫn',
            controller: representativePhoneController,
            enabled: canEditForm,
            hintText: 'Nhập số điện thoại',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          InternshipRegistrationTextInput(
            label: 'Chức vụ người hướng dẫn',
            controller: representativeJobController,
            enabled: canEditForm,
            hintText: 'Nhập chức vụ',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InternshipRegistrationDateField(
                  label: 'Ngày bắt đầu',
                  value: expectedStartTime,
                  enabled: canEditForm,
                  onTap: onStartDateTap,
                  formatDate: formatDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InternshipRegistrationDateField(
                  label: 'Ngày kết thúc',
                  value: expectedEndTime,
                  enabled: canEditForm,
                  onTap: onEndDateTap,
                  formatDate: formatDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InternshipRegistrationAssignedSummarySection extends StatelessWidget {
  const InternshipRegistrationAssignedSummarySection({
    required this.status,
    required this.companyName,
    required this.companyField,
    required this.companyAddress,
    super.key,
  });

  final String status;
  final String companyName;
  final String companyField;
  final String companyAddress;

  @override
  Widget build(BuildContext context) {
    return InternshipRegistrationSectionCard(
      title: '',
      child: Column(
        children: [
          InternshipRegistrationReadOnlyField(
            label: 'Trạng thái',
            value: status,
          ),
          const SizedBox(height: 12),
          InternshipRegistrationReadOnlyField(
            label: 'Tên công ty',
            value: companyName,
          ),
          const SizedBox(height: 12),
          InternshipRegistrationReadOnlyField(
            label: 'Lĩnh vực',
            value: companyField,
          ),
          const SizedBox(height: 12),
          InternshipRegistrationReadOnlyField(
            label: 'Địa chỉ công ty',
            value: companyAddress,
          ),
        ],
      ),
    );
  }
}

class InternshipRegistrationCvSection extends StatelessWidget {
  const InternshipRegistrationCvSection({
    required this.canEditForm,
    required this.hasEffectiveCv,
    required this.hasExistingCv,
    required this.hasUploadedCv,
    required this.effectiveCvName,
    required this.pickedFileName,
    required this.onPickCv,
    super.key,
  });

  final bool canEditForm;
  final bool hasEffectiveCv;
  final bool hasExistingCv;
  final bool hasUploadedCv;
  final String effectiveCvName;
  final String? pickedFileName;
  final VoidCallback onPickCv;

  @override
  Widget build(BuildContext context) {
    final helperText = hasUploadedCv
        ? 'CV mới đã upload thành công và sẽ được dùng khi gửi.'
        : hasExistingCv
        ? 'Đang giữ CV cũ. Bạn có thể chọn file khác để thay thế.'
        : 'Bạn phải upload CV PDF trước khi gửi đăng ký.';

    return InternshipRegistrationSectionCard(
      title: '',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: hasEffectiveCv ? const Color(0xFFFFFBF3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasEffectiveCv
                ? AppTheme.brandColor.withValues(alpha: 0.35)
                : const Color(0xFFE7EAF0),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.upload_file_outlined,
              size: 40,
              color: hasEffectiveCv
                  ? AppTheme.brandColor
                  : const Color(0xFF99A1AA),
            ),
            const SizedBox(height: 12),
            Text(
              hasEffectiveCv ? effectiveCvName : 'Chưa có CV',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              helperText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: hasEffectiveCv
                    ? const Color(0xFF7A4B00)
                    : const Color(0xFF7D8794),
              ),
            ),
            if (pickedFileName != null && !hasUploadedCv) ...[
              const SizedBox(height: 8),
              Text(
                'Đã chọn: $pickedFileName',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
            if (canEditForm) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onPickCv,
                icon: const Icon(Icons.attach_file),
                label: Text(hasEffectiveCv ? 'Chọn CV khác' : 'Chọn CV PDF'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class InternshipRegistrationRejectReasonsSection extends StatelessWidget {
  const InternshipRegistrationRejectReasonsSection({
    required this.reasons,
    super.key,
  });

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    if (reasons.isEmpty) {
      return const SizedBox.shrink();
    }

    return InternshipRegistrationSectionCard(
      title: '',
      child: Column(
        children: reasons
            .map(
              (reason) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFC9C9)),
                ),
                child: Text(reason),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class InternshipRegistrationSubmitSection extends StatelessWidget {
  const InternshipRegistrationSubmitSection({
    required this.isViewOnly,
    required this.canSubmit,
    required this.hasEffectiveCv,
    required this.buttonLabel,
    required this.onSubmit,
    super.key,
  });

  final bool isViewOnly;
  final bool canSubmit;
  final bool hasEffectiveCv;
  final String buttonLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    if (isViewOnly) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Hồ sơ đang ở chế độ chỉ xem.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit ? onSubmit : null,
            child: Text(buttonLabel),
          ),
        ),
        // if (!hasEffectiveCv) ...[
        //   const SizedBox(height: 10),
        //   const Text(
        //     'Bạn phải upload CV trước khi gửi đăng ký.',
        //     style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        //   ),
        // ],
      ],
    );
  }
}

class InternshipRegistrationTextInput extends StatelessWidget {
  const InternshipRegistrationTextInput({
    required this.label,
    required this.controller,
    required this.enabled,
    this.hintText,
    this.keyboardType,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String? hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return InternshipRegistrationFieldShell(
      label: label,
      enabled: enabled,
      child: SizedBox.expand(
        child: TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          expands: true,
          minLines: null,
          maxLines: null,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            isCollapsed: true,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            fillColor: Colors.transparent,
            filled: false,
          ),
          style: const TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
