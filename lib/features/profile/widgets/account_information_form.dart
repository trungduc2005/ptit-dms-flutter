import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_field_shell.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_read_only_field.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_text_field.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile_update_request.dart';
import 'package:ptit_dms_flutter/features/profile/bloc/profile_submit_bloc.dart';
import 'package:ptit_dms_flutter/features/profile/widgets/account_avatar_section.dart';

class AccountInformationForm extends StatefulWidget {
  const AccountInformationForm({required this.profile, super.key});

  final StudentProfile profile;

  @override
  State<AccountInformationForm> createState() => _AccountInformationFormState();
}

class _AccountInformationFormState extends State<AccountInformationForm> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  String? _gender;
  DateTime? _dateOfBirth;
  String? _selectedAvatarPath;
  String? _validationMessage;
  bool _waitingForAvatarUpload = false;
  bool _submissionRequested = false;
  bool _isEditing = false;

  StudentProfileUser? get _user => widget.profile.user;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: _user?.email ?? '');
    _phoneController = TextEditingController(text: _user?.phone ?? '');
    _addressController = TextEditingController(text: _user?.address ?? '');
    _gender = _normalizeGender(_user?.gender);
    _dateOfBirth = _dateOnly(_user?.dateOfBirth);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _normalizeGender(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == 'male' || normalized == 'female') {
      return normalized;
    }
    return null;
  }

  DateTime? _dateOnly(DateTime? value) {
    if (value == null) return null;
    return DateTime(value.year, value.month, value.day);
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Chọn ngày sinh';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _validationMessage = null;
    });
  }

  void _cancelEditing() {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailController.text = _user?.email ?? '';
      _phoneController.text = _user?.phone ?? '';
      _addressController.text = _user?.address ?? '';
      _gender = _normalizeGender(_user?.gender);
      _dateOfBirth = _dateOnly(_user?.dateOfBirth);
      _selectedAvatarPath = null;
      _validationMessage = null;
      _isEditing = false;
    });
  }

  String _displayValue(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? 'Chưa cập nhật' : trimmed;
  }

  String _displayGender(String? value) {
    if (value == 'male') return 'Nam';
    if (value == 'female') return 'Nữ';
    return 'Chưa cập nhật';
  }

  String? _validate() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isNotEmpty &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Email không hợp lệ.';
    }
    if (phone.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(phone)) {
      return 'Số điện thoại phải gồm đúng 10 chữ số.';
    }
    return null;
  }

  Future<void> _pickDate(bool enabled) async {
    if (!enabled) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Chọn ngày sinh',
    );

    if (!mounted || picked == null) return;
    setState(() => _dateOfBirth = _dateOnly(picked));
  }

  void _submit(bool isBusy) {
    if (!_isEditing || isBusy || _submissionRequested) return;
    FocusScope.of(context).unfocus();

    final validationMessage = _validate();
    setState(() => _validationMessage = validationMessage);
    if (validationMessage != null) return;

    _submissionRequested = true;
    _waitingForAvatarUpload = _selectedAvatarPath != null;
    context.read<ProfileSubmitBloc>().add(
      ProfileUpdateSubmitted(
        request: StudentProfileUpdateRequest(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          gender: _gender,
          dateOfBirth: _dateOfBirth,
          address: _addressController.text.trim(),
        ),
      ),
    );
  }

  void _handleState(BuildContext context, ProfileSubmitState state) {
    if (state.submitStatus == ProfileSubmitStatus.failure) {
      _submissionRequested = false;
      _waitingForAvatarUpload = false;
      _showMessage(state.message ?? 'Cập nhật thông tin thất bại.');
      return;
    }

    if (state.uploadStatus == ProfileAvatarUploadStatus.failure) {
      _submissionRequested = false;
      _showMessage(state.message ?? 'Upload avatar thất bại.');
      return;
    }

    if (state.uploadStatus == ProfileAvatarUploadStatus.success) {
      _finishSuccessfully('Cập nhật thông tin và avatar thành công.');
      return;
    }

    if (state.submitStatus == ProfileSubmitStatus.success &&
        state.uploadStatus == ProfileAvatarUploadStatus.initial) {
      if (_waitingForAvatarUpload && _selectedAvatarPath != null) {
        _waitingForAvatarUpload = false;
        context.read<ProfileSubmitBloc>().add(
          ProfileAvatarUploadRequested(filePath: _selectedAvatarPath!),
        );
        return;
      }
      _finishSuccessfully(state.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _finishSuccessfully(String? message) {
    _showMessage(message ?? 'Cập nhật thông tin thành công.');
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileSubmitBloc, ProfileSubmitState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus ||
          previous.uploadStatus != current.uploadStatus,
      listener: _handleState,
      builder: (context, state) {
        final isBusy = state.isBusy;

        return SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AccountAvatarSection(
                        avatarUrl: _user?.avatarUrl,
                        selectedAvatarPath: _selectedAvatarPath,
                        fullName: _user?.fullName ?? '',
                        studentId: widget.profile.studentId,
                        enabled: _isEditing && !isBusy,
                        onAvatarSelected: (path) {
                          setState(() => _selectedAvatarPath = path);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!_isEditing) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.tonalIcon(
                                  onPressed: _startEditing,
                                  style: FilledButton.styleFrom(
                                    foregroundColor: AppTheme.brandColor,
                                    backgroundColor: const Color(0xFFFCEEEE),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 11,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Chỉnh sửa',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            _ProfileSectionCard(
                              icon: Icons.school_outlined,
                              title: 'Thông tin học tập',
                              subtitle:
                                  'Thông tin được đồng bộ từ hệ thống đào tạo',
                              child: _isEditing
                                  ? Column(
                                      children: [
                                        FormReadOnlyField(
                                          label: 'Họ và tên',
                                          value: _user?.fullName ?? '',
                                        ),
                                        const SizedBox(height: 14),
                                        FormReadOnlyField(
                                          label: 'Mã sinh viên',
                                          value: widget.profile.studentId,
                                        ),
                                        const SizedBox(height: 14),
                                        FormReadOnlyField(
                                          label: 'Lớp',
                                          value:
                                              widget.profile.classInfo?.name ??
                                              '',
                                        ),
                                        const SizedBox(height: 14),
                                        FormReadOnlyField(
                                          label: 'Khóa',
                                          value: widget.profile.cohort,
                                        ),
                                        const SizedBox(height: 14),
                                        FormReadOnlyField(
                                          label: 'Ngành',
                                          value: widget.profile.major.join(
                                            ', ',
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _InformationRow(
                                          label: 'Họ và tên',
                                          value: _displayValue(_user?.fullName),
                                        ),
                                        _InformationRow(
                                          label: 'Mã sinh viên',
                                          value: _displayValue(
                                            widget.profile.studentId,
                                          ),
                                        ),
                                        _InformationRow(
                                          label: 'Lớp',
                                          value: _displayValue(
                                            widget.profile.classInfo?.name,
                                          ),
                                        ),
                                        _InformationRow(
                                          label: 'Khóa',
                                          value: _displayValue(
                                            widget.profile.cohort,
                                          ),
                                        ),
                                        _InformationRow(
                                          label: 'Ngành',
                                          value: _displayValue(
                                            widget.profile.major.join(', '),
                                          ),
                                          showDivider: false,
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 18),
                            _ProfileSectionCard(
                              icon: Icons.person_outline_rounded,
                              title: 'Thông tin cá nhân',
                              subtitle: _isEditing
                                  ? 'Chỉnh sửa thông tin có thể cập nhật'
                                  : 'Thông tin liên hệ của bạn',
                              child: _isEditing
                                  ? Column(
                                      children: [
                                        FormTextField(
                                          label: 'Email',
                                          controller: _emailController,
                                          enabled: !isBusy,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          hintText: 'Nhập email',
                                        ),
                                        const SizedBox(height: 14),
                                        FormTextField(
                                          label: 'Số điện thoại',
                                          controller: _phoneController,
                                          enabled: !isBusy,
                                          keyboardType: TextInputType.phone,
                                          hintText: 'Nhập số điện thoại',
                                        ),
                                        const SizedBox(height: 14),
                                        FormDropdownField<String>(
                                          label: 'Giới tính',
                                          value: _gender,
                                          enabled: !isBusy,
                                          hintText: 'Chọn giới tính',
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'male',
                                              child: Text('Nam'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'female',
                                              child: Text('Nữ'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() => _gender = value);
                                          },
                                        ),
                                        const SizedBox(height: 14),
                                        GestureDetector(
                                          onTap: () => _pickDate(!isBusy),
                                          child: FormFieldShell(
                                            label: 'Ngày sinh',
                                            enabled: !isBusy,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _formatDate(_dateOfBirth),
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.calendar_month_outlined,
                                                  size: 20,
                                                  color: AppTheme.brandColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        FormTextField(
                                          label: 'Địa chỉ',
                                          controller: _addressController,
                                          enabled: !isBusy,
                                          hintText: 'Nhập địa chỉ',
                                          height: 104,
                                          maxLines: null,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _InformationRow(
                                          label: 'Email',
                                          value: _displayValue(_user?.email),
                                        ),
                                        _InformationRow(
                                          label: 'Số điện thoại',
                                          value: _displayValue(_user?.phone),
                                        ),
                                        _InformationRow(
                                          label: 'Giới tính',
                                          value: _displayGender(_gender),
                                        ),
                                        _InformationRow(
                                          label: 'Ngày sinh',
                                          value: _dateOfBirth == null
                                              ? 'Chưa cập nhật'
                                              : _formatDate(_dateOfBirth),
                                        ),
                                        _InformationRow(
                                          label: 'Địa chỉ',
                                          value: _displayValue(_user?.address),
                                          showDivider: false,
                                        ),
                                      ],
                                    ),
                            ),
                            if (_validationMessage != null) ...[
                              const SizedBox(height: 14),
                              _ErrorMessage(message: _validationMessage!),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFEAECF0))),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: isBusy ? null : _cancelEditing,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF475467),
                              side: const BorderSide(color: Color(0xFFD0D5DD)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: isBusy ? null : () => _submit(isBusy),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.brandColor,
                              disabledBackgroundColor: const Color(0xFFD8A5A5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            icon: isBusy
                                ? const SizedBox(
                                    width: 21,
                                    height: 21,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_rounded, size: 21),
                            label: Text(
                              isBusy ? 'Đang lưu...' : 'Lưu thay đổi',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
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
      },
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == 'Chưa cập nhật';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 112,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isEmpty
                        ? const Color(0xFF98A2B3)
                        : const Color(0xFF1D2939),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFF2F4F7)),
      ],
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D101828),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEEEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.brandColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1D2939),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD3D3)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB42318),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
