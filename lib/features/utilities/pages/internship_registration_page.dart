import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/data/models/company_model.dart';
import 'package:ptit_dms_flutter/data/models/current_intern_registration_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_request_model.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/eligibility_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_cv_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_registration_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/bloc/context/internship_registration_context_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/bloc/submit/internship_registration_submit_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/models/internship_registration_form_type.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_sections.dart';
import 'package:ptit_dms_flutter/features/utilities/widgets/utilities_header.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_calendar_dialog.dart';
import 'package:ptit_dms_flutter/core/widgets/app_popup_dialog.dart';

class InternshipRegistrationPage extends StatelessWidget {
  const InternshipRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => InternshipRegistrationContextBloc(
            academicYearRepository: context.read<AcademicYearRepository>(),
            eligibilityRepository: context.read<EligibilityRepository>(),
            timelineRepository: context.read<TimelineRepository>(),
            internRegistrationRepository: context
                .read<InternRegistrationRepository>(),
            companyRepository: context.read<CompanyRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => InternshipRegistrationSubmitBloc(
            internCvRepository: context.read<InternCvRepository>(),
            internRegistrationRepository: context
                .read<InternRegistrationRepository>(),
          ),
        ),
      ],
      child: const _InternshipRegistrationView(),
    );
  }
}

class _InternshipRegistrationView extends StatefulWidget {
  const _InternshipRegistrationView();

  @override
  State<_InternshipRegistrationView> createState() =>
      _InternshipRegistrationViewState();
}

class _InternshipRegistrationViewState
    extends State<_InternshipRegistrationView> {
  final TextEditingController _cpaController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyFieldController = TextEditingController();
  final TextEditingController _companyAddressController =
      TextEditingController();
  final TextEditingController _representativeNameController =
      TextEditingController();
  final TextEditingController _representativePhoneController =
      TextEditingController();
  final TextEditingController _representativeJobController =
      TextEditingController();

  bool _isPopupOpen = false;

  StudentProfileModel? _profile;
  bool _isBootstrapping = true;
  String? _bootstrapError;
  InternshipRegistrationFormType? _selectedType;
  List<String?> _preferredCompanyIds = const [];
  DateTime? _expectedStartTime;
  DateTime? _expectedEndTime;
  String? _pickedFileName;
  String _lastSyncedKey = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _cpaController.dispose();
    _companyNameController.dispose();
    _companyFieldController.dispose();
    _companyAddressController.dispose();
    _representativeNameController.dispose();
    _representativePhoneController.dispose();
    _representativeJobController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _isBootstrapping = true;
      _bootstrapError = null;
    });

    try {
      final profile = await context
          .read<StudentProfileRepository>()
          .getProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isBootstrapping = false;
      });

      context.read<InternshipRegistrationContextBloc>().add(
        InternshipRegistrationContextStarted(studentId: profile.studentId),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isBootstrapping = false;
        _bootstrapError = 'Không thể tải thông tin sinh viên.';
      });
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (isError) {
      _showErrorDialog(message);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.brandColor),
      );
  }

  Future<T?> _showPopup<T>({
    required Widget Function(BuildContext dialogContext) builder,
  }) async {
    if (!mounted || _isPopupOpen) {
      return null;
    }

    _isPopupOpen = true;

    final result = await showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: builder,
    );

    if (!mounted) {
      return result;
    }

    _isPopupOpen = false;
    return result;
  }

  Future<void> _showErrorDialog(String message) async {
    await _showPopup<void>(
      builder: (dialogContext) {
        return AppPopupDialog(title: 'Thông báo', message: message);
      },
    );
  }

  void _handleContextStateChanged(
    BuildContext context,
    InternshipRegistrationContextState state,
  ) {
    if (state.status == InternshipRegistrationContextStatus.failure &&
        (state.errorMessage?.trim().isNotEmpty ?? false)) {
      _showSnack(state.errorMessage!, isError: true);
    }

    if (state.status == InternshipRegistrationContextStatus.success) {
      _syncFormFromContext(state);
    }
  }

  void _handleSubmitStateChanged(
    BuildContext context,
    InternshipRegistrationSubmitState state,
  ) {
    final message = state.message?.trim();
    if (message != null && message.isNotEmpty) {
      final isError =
          state.uploadStatus == InternshipCvUploadStatus.failure ||
          state.submitStatus == InternshipRegistrationSubmitStatus.failure;
      _showSnack(message, isError: isError);
    }

    if (state.submitStatus == InternshipRegistrationSubmitStatus.success) {
      context.read<InternshipRegistrationContextBloc>().add(
        const InternshipRegistrationContextRefreshed(),
      );
    }
  }

  void _syncFormFromContext(InternshipRegistrationContextState state) {
    final registration = state.currentRegistration;
    final slotCount = _slotCountForState(state);

    final syncKey = [
      state.selectedAcademicYearId ?? '',
      registration?.id ?? '',
      registration?.updatedAt?.toIso8601String() ?? '',
      state.mode.name,
      slotCount.toString(),
    ].join('|');

    if (syncKey == _lastSyncedKey) {
      return;
    }

    final defaultStart = state.expectedInternshipPeriodTimeline?.startTime;
    final defaultEnd = state.expectedInternshipPeriodTimeline?.endTime;

    setState(() {
      _pickedFileName = null;

      if (registration == null) {
        _selectedType ??= InternshipRegistrationFormType.yourself;
        _cpaController.clear();
        _clearSelfContactFields();
        _expectedStartTime = defaultStart;
        _expectedEndTime = defaultEnd;
        _preferredCompanyIds = List<String?>.filled(
          slotCount,
          null,
          growable: false,
        );
      } else if (registration.type == InternRegistrationType.yourself.value) {
        _selectedType = InternshipRegistrationFormType.yourself;
        _cpaController.text = _formatCpa(registration.cpa);
        _companyNameController.text = registration.companyName ?? '';
        _companyFieldController.text = registration.companyField ?? '';
        _companyAddressController.text = registration.companyAddress ?? '';
        _representativeNameController.text =
            registration.representativeName ?? '';
        _representativePhoneController.text =
            registration.representativePhoneNumber ?? '';
        _representativeJobController.text =
            registration.representativeJob ?? '';
        _expectedStartTime = registration.expectedStartTime ?? defaultStart;
        _expectedEndTime = registration.expectedEndTime ?? defaultEnd;
        _preferredCompanyIds = List<String?>.filled(
          slotCount,
          null,
          growable: false,
        );
      } else if (registration.type ==
          InternRegistrationType.registerWish.value) {
        _selectedType = InternshipRegistrationFormType.wish;
        _cpaController.text = _formatCpa(registration.cpa);
        _clearSelfContactFields();
        _expectedStartTime = defaultStart;
        _expectedEndTime = defaultEnd;

        final sortedCompanies = [...registration.preferredCompanies]
          ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

        final values = sortedCompanies
            .map((item) => item.companyId?.trim())
            .whereType<String>()
            .where((item) => item.isNotEmpty)
            .toList(growable: false);

        _preferredCompanyIds = List<String?>.generate(
          slotCount,
          (index) => index < values.length ? values[index] : null,
          growable: false,
        );
      } else {
        _selectedType = null;
        _cpaController.text = _formatCpa(registration.cpa);
        _companyNameController.text = registration.companyName ?? '';
        _companyFieldController.text = registration.companyField ?? '';
        _companyAddressController.text = registration.companyAddress ?? '';
        _representativeNameController.text =
            registration.representativeName ?? '';
        _representativePhoneController.text =
            registration.representativePhoneNumber ?? '';
        _representativeJobController.text =
            registration.representativeJob ?? '';
        _expectedStartTime = registration.expectedStartTime ?? defaultStart;
        _expectedEndTime = registration.expectedEndTime ?? defaultEnd;
        _preferredCompanyIds = List<String?>.filled(
          slotCount,
          null,
          growable: false,
        );
      }

      _lastSyncedKey = syncKey;
    });
  }

  void _clearSelfContactFields() {
    _companyNameController.clear();
    _companyFieldController.clear();
    _companyAddressController.clear();
    _representativeNameController.clear();
    _representativePhoneController.clear();
    _representativeJobController.clear();
  }

  int _slotCountForState(InternshipRegistrationContextState state) {
    final existingCount =
        state.currentRegistration?.preferredCompanies.length ?? 0;
    return math.max(state.preferredCompanySlots, existingCount);
  }

  bool _isFacultyAssign(InternshipRegistrationContextState state) {
    return state.currentRegistration?.type ==
        InternRegistrationType.facultyAssign.value;
  }

  bool _hasExistingCv(InternshipRegistrationContextState state) {
    final registration = state.currentRegistration;
    return (registration?.cvFileKey?.trim().isNotEmpty ?? false) &&
        (registration?.cvFileName?.trim().isNotEmpty ?? false);
  }

  bool _hasEffectiveCv(
    InternshipRegistrationContextState contextState,
    InternshipRegistrationSubmitState submitState,
  ) {
    return submitState.hasUploadedCv || _hasExistingCv(contextState);
  }

  bool _canEditForm(
    InternshipRegistrationContextState contextState,
    InternshipRegistrationSubmitState submitState,
  ) {
    return !contextState.isViewOnly &&
        !submitState.isBusy &&
        (contextState.canCreateRegistration ||
            contextState.canEditRegistration);
  }

  String _effectiveCvName(
    InternshipRegistrationContextState contextState,
    InternshipRegistrationSubmitState submitState,
  ) {
    final uploadedCv = submitState.uploadedCv;
    if ((uploadedCv?.cvFileName.trim().isNotEmpty ?? false)) {
      return uploadedCv!.cvFileName.trim();
    }

    return contextState.currentRegistration?.cvFileName?.trim() ?? '';
  }

  String _formatCpa(double? cpa) {
    if (cpa == null) return '';
    final value = cpa.toStringAsFixed(2);
    return value.endsWith('00')
        ? cpa.toStringAsFixed(0)
        : value.endsWith('0')
        ? cpa.toStringAsFixed(1)
        : value;
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }

  String _formatDateRange(InternshipRegistrationContextState state) {
    final start = state.registrationTimeline?.startTime;
    final end = state.registrationTimeline?.endTime;

    if (start == null || end == null) {
      return 'Chưa có thời gian đăng ký.';
    }

    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _registrationBannerText(InternshipRegistrationContextState state) {
    if (_isFacultyAssign(state)) {
      return 'Hồ sơ này do khoa phân công và đang ở chế độ chỉ xem.';
    }

    if (state.isViewOnly && state.hasCurrentRegistration) {
      return 'Hồ sơ hiện đang bị khóa, bạn chỉ có thể xem lại thông tin đã đăng ký.';
    }

    if (state.canEditRegistration) {
      return 'Bạn có thể cập nhật hồ sơ đã đăng ký. CV cũ sẽ được giữ nếu bạn không upload CV mới.';
    }

    if (state.canCreateRegistration) {
      return 'Điền đầy đủ thông tin, upload CV PDF, rồi gửi đăng ký.';
    }

    if (!state.canRegisterInternship) {
      return 'Bạn chưa đủ điều kiện đăng ký thực tập.';
    }

    if (!state.isInRegistrationWindow) {
      return 'Hiện tại không nằm trong thời gian đăng ký thực tập.';
    }

    return 'Đang tải dữ liệu đăng ký thực tập.';
  }

  bool _useActiveRegistrationBanner(InternshipRegistrationContextState state) {
    return !_isFacultyAssign(state) &&
        !state.isViewOnly &&
        state.isInRegistrationWindow &&
        (state.canCreateRegistration || state.canEditRegistration);
  }

  Future<void> _pickAndUploadCv(
    InternshipRegistrationContextState contextState,
  ) async {
    final academicYearId = contextState.selectedAcademicYearId?.trim() ?? '';
    if (academicYearId.isEmpty) {
      _showSnack('Bạn phải chọn năm học trước khi upload CV.', isError: true);
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final filePath = file.path?.trim() ?? '';

    if (filePath.isEmpty) {
      _showSnack('Không lấy được đường dẫn tệp PDF.', isError: true);
      return;
    }

    setState(() {
      _pickedFileName = file.name;
    });

    context.read<InternshipRegistrationSubmitBloc>().add(
      InternshipCvUploadRequested(
        academicYearId: academicYearId,
        filePath: filePath,
      ),
    );
  }

  Future<void> _pickDate({
    required bool isStartDate,
    required InternshipRegistrationContextState contextState,
  }) async {
    if (_isFacultyAssign(contextState) || contextState.isViewOnly) {
      return;
    }

    final timelineStart =
        contextState.expectedInternshipPeriodTimeline?.startTime;
    final timelineEnd = contextState.expectedInternshipPeriodTimeline?.endTime;
    final now = DateTime.now();

    final selectableFirstDate = timelineStart ?? DateTime(now.year - 1);
    final selectableLastDate = timelineEnd ?? DateTime(now.year + 2);

    var initialDate = isStartDate
        ? (_expectedStartTime ?? selectableFirstDate)
        : (_expectedEndTime ?? _expectedStartTime ?? selectableFirstDate);

    if (initialDate.isBefore(selectableFirstDate)) {
      initialDate = selectableFirstDate;
    }
    if (initialDate.isAfter(selectableLastDate)) {
      initialDate = selectableLastDate;
    }

    final picked = await showInternshipCalendarDialog(
      context: context,
      initialDate: initialDate,
      selectableFirstDate: DateTime(
        now.year - 1,
      ), // cần đổi lại thành selectTable ở bên trên
      selectableLastDate: DateTime(now.year + 2),
      navigationFirstMonth: DateTime(initialDate.year, initialDate.month - 12),
      navigationLastMonth: DateTime(initialDate.year, initialDate.month + 12),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStartDate) {
        _expectedStartTime = picked;
        if (_expectedEndTime != null && _expectedEndTime!.isBefore(picked)) {
          _expectedEndTime = picked;
        }
      } else {
        _expectedEndTime = picked;
      }
    });
  }

  void _submitForm(
    InternshipRegistrationContextState contextState,
    InternshipRegistrationSubmitState submitState,
  ) {
    final academicYearId = contextState.selectedAcademicYearId?.trim() ?? '';
    if (academicYearId.isEmpty) {
      _showSnack('Bạn phải chọn năm học.', isError: true);
      return;
    }

    final cpa =
        double.tryParse(_cpaController.text.trim().replaceAll(',', '.')) ?? -1;

    final uploadedCv = submitState.uploadedCv;
    final existingRegistration = contextState.currentRegistration;

    final cvFileKey = (uploadedCv?.cvFileKey.trim().isNotEmpty ?? false)
        ? uploadedCv!.cvFileKey.trim()
        : existingRegistration?.cvFileKey?.trim() ?? '';

    final cvFileName = (uploadedCv?.cvFileName.trim().isNotEmpty ?? false)
        ? uploadedCv!.cvFileName.trim()
        : existingRegistration?.cvFileName?.trim() ?? '';

    late final InternRegistrationRequestModel request;

    if (_selectedType == InternshipRegistrationFormType.wish) {
      final slotCount = _slotCountForState(contextState);
      final preferredCompanies = List<String>.generate(slotCount, (index) {
        if (index >= _preferredCompanyIds.length) {
          return '';
        }
        return _preferredCompanyIds[index]?.trim() ?? '';
      }, growable: false);

      request = RegisterWishInternRequestModel(
        academicYearId: academicYearId,
        cpa: cpa,
        cvFileKey: cvFileKey,
        cvFileName: cvFileName,
        preferredCompanies: preferredCompanies,
      );
    } else {
      if (_expectedStartTime == null || _expectedEndTime == null) {
        _showSnack('Bạn phải chọn thời gian thực tập dự kiến.', isError: true);
        return;
      }

      request = RegisterYourselfInternRequestModel(
        academicYearId: academicYearId,
        cpa: cpa,
        cvFileKey: cvFileKey,
        cvFileName: cvFileName,
        companyName: _companyNameController.text.trim(),
        companyField: _companyFieldController.text.trim(),
        companyAddress: _companyAddressController.text.trim(),
        representativeName: _representativeNameController.text.trim(),
        representativePhoneNumber: _representativePhoneController.text.trim(),
        representativeJob: _representativeJobController.text.trim(),
        expectedStartTime: _expectedStartTime!,
        expectedEndTime: _expectedEndTime!,
      );
    }

    if (contextState.canEditRegistration) {
      context.read<InternshipRegistrationSubmitBloc>().add(
        InternshipRegistrationUpdated(
          request: request,
          expectedPreferredCompanyCount: contextState.preferredCompanySlots,
          allowMissingCv: true,
        ),
      );
      return;
    }

    context.read<InternshipRegistrationSubmitBloc>().add(
      InternshipRegistrationSubmitted(
        request: request,
        expectedPreferredCompanyCount: contextState.preferredCompanySlots,
      ),
    );
  }

  String _resolveCompanyValue(CompanyModel company) {
    final companyId = company.companyId.trim();
    if (companyId.isNotEmpty) {
      return companyId;
    }

    return company.id.trim();
  }

  String? _resolveCurrentCompanyLabel(
    CurrentInternRegistrationModel? registration,
    String value,
  ) {
    if (registration == null) {
      return null;
    }

    for (final item in registration.preferredCompanies) {
      if ((item.companyId?.trim() ?? '') == value) {
        return item.companyName;
      }
    }

    if ((registration.companyId?.trim() ?? '') == value) {
      return registration.companyName;
    }

    return null;
  }

  List<DropdownMenuItem<String>> _buildCompanyItems(
    InternshipRegistrationContextState state, {
    String? currentValue,
  }) {
    final selectedValue = currentValue?.trim() ?? '';

    final selectedValues = _preferredCompanyIds
        .map((value) => value?.trim() ?? '')
        .where((value) => value.isNotEmpty && value != selectedValue)
        .toSet();

    final options = <String, String>{};

    for (final company in state.companies) {
      final value = _resolveCompanyValue(company);
      if (value.isEmpty) continue;

      if (selectedValues.contains(value)) {
        continue;
      }

      options[value] = company.companyName;
    }

    if (selectedValue.isNotEmpty && !options.containsKey(selectedValue)) {
      options[selectedValue] =
          _resolveCurrentCompanyLabel(
            state.currentRegistration,
            selectedValue,
          ) ??
          selectedValue;
    }

    return options.entries
        .map(
          (entry) => DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          ),
        )
        .toList(growable: false);
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildBootstrapError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _bootstrapError ?? 'Đã xảy ra lỗi.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _bootstrap, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: const UtilitiesHeader(
        title: 'Đăng ký thực tập',
        showBackButton: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<
            InternshipRegistrationContextBloc,
            InternshipRegistrationContextState
          >(listener: _handleContextStateChanged),
          BlocListener<
            InternshipRegistrationSubmitBloc,
            InternshipRegistrationSubmitState
          >(listener: _handleSubmitStateChanged),
        ],
        child:
            BlocBuilder<
              InternshipRegistrationContextBloc,
              InternshipRegistrationContextState
            >(
              builder: (context, contextState) {
                final submitState = context
                    .watch<InternshipRegistrationSubmitBloc>()
                    .state;

                if (_isBootstrapping ||
                    (contextState.status ==
                            InternshipRegistrationContextStatus.initial &&
                        _bootstrapError == null)) {
                  return _buildLoadingState();
                }

                if (_bootstrapError != null &&
                    contextState.status ==
                        InternshipRegistrationContextStatus.initial) {
                  return _buildBootstrapError();
                }

                final canEditForm = _canEditForm(contextState, submitState);
                final hasEffectiveCv = _hasEffectiveCv(
                  contextState,
                  submitState,
                );
                final slotCount = _slotCountForState(contextState);
                final registration = contextState.currentRegistration;
                final useActiveBanner = _useActiveRegistrationBanner(
                  contextState,
                );

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<InternshipRegistrationContextBloc>().add(
                      const InternshipRegistrationContextRefreshed(),
                    );
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      if (contextState.status ==
                              InternshipRegistrationContextStatus.loading ||
                          contextState.isCheckingRegistrationStatus ||
                          submitState.isBusy)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: LinearProgressIndicator(),
                        ),
                      InternshipRegistrationInfoBanner(
                        message: useActiveBanner
                            ? null
                            : _registrationBannerText(contextState),
                        dateRangeText: _formatDateRange(contextState),
                        isActive: useActiveBanner,
                      ),
                      InternshipRegistrationAcademicYearSection(
                        items: contextState.academicYears,
                        selectedValue: contextState.selectedAcademicYearId,
                        isBusy: submitState.isBusy,
                        onChanged: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return;
                          }

                          context.read<InternshipRegistrationSubmitBloc>().add(
                            const InternshipRegistrationSubmitStateCleared(),
                          );

                          setState(() {
                            _lastSyncedKey = '';
                            _pickedFileName = null;
                          });

                          context.read<InternshipRegistrationContextBloc>().add(
                            InternshipRegistrationAcademicYearSelected(value),
                          );
                        },
                      ),
                      InternshipRegistrationGeneralSection(
                        majorText: (_profile?.major ?? const []).join(', '),
                        cpaController: _cpaController,
                        canEditForm: canEditForm,
                        isFacultyAssign: _isFacultyAssign(contextState),
                        selectedType: _selectedType,
                        onTypeChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedType = value;
                          });
                        },
                      ),
                      if (_isFacultyAssign(contextState))
                        InternshipRegistrationAssignedSummarySection(
                          status: registration?.status ?? '',
                          companyName: registration?.companyName ?? '',
                          companyField: registration?.companyField ?? '',
                          companyAddress: registration?.companyAddress ?? '',
                        )
                      else if (_selectedType ==
                          InternshipRegistrationFormType.wish)
                        InternshipRegistrationWishSection(
                          slotCount: slotCount,
                          canEditForm: canEditForm,
                          preferredCompanyIds: _preferredCompanyIds,
                          companyItemsBuilder: (currentValue) {
                            return _buildCompanyItems(
                              contextState,
                              currentValue: currentValue,
                            );
                          },
                          onChanged: (index, value) {
                            setState(() {
                              final values = List<String?>.from(
                                _preferredCompanyIds,
                              );
                              while (values.length < slotCount) {
                                values.add(null);
                              }
                              values[index] = value;
                              _preferredCompanyIds = values;
                            });
                          },
                        )
                      else
                        InternshipRegistrationSelfContactSection(
                          canEditForm: canEditForm,
                          companyNameController: _companyNameController,
                          companyFieldController: _companyFieldController,
                          companyAddressController: _companyAddressController,
                          representativeNameController:
                              _representativeNameController,
                          representativePhoneController:
                              _representativePhoneController,
                          representativeJobController:
                              _representativeJobController,
                          expectedStartTime: _expectedStartTime,
                          expectedEndTime: _expectedEndTime,
                          onStartDateTap: () => _pickDate(
                            isStartDate: true,
                            contextState: contextState,
                          ),
                          onEndDateTap: () => _pickDate(
                            isStartDate: false,
                            contextState: contextState,
                          ),
                          formatDate: _formatDate,
                        ),
                      InternshipRegistrationCvSection(
                        canEditForm: canEditForm,
                        hasEffectiveCv: hasEffectiveCv,
                        hasExistingCv: _hasExistingCv(contextState),
                        hasUploadedCv: submitState.hasUploadedCv,
                        effectiveCvName: _effectiveCvName(
                          contextState,
                          submitState,
                        ),
                        pickedFileName: _pickedFileName,
                        onPickCv: () => _pickAndUploadCv(contextState),
                      ),
                      InternshipRegistrationRejectReasonsSection(
                        reasons: (registration?.rejectReasons ?? const [])
                            .map((item) => item.reason)
                            .toList(growable: false),
                      ),
                      InternshipRegistrationSubmitSection(
                        isViewOnly: contextState.isViewOnly,
                        canSubmit:
                            !submitState.isBusy &&
                            (contextState.canCreateRegistration ||
                                contextState.canEditRegistration) &&
                            hasEffectiveCv &&
                            !(_selectedType ==
                                    InternshipRegistrationFormType.wish &&
                                contextState.preferredCompanySlots <= 0),
                        hasEffectiveCv: hasEffectiveCv,
                        buttonLabel: contextState.canEditRegistration
                            ? 'Cập nhật đăng ký'
                            : 'Gửi đăng ký',
                        onSubmit: () => _submitForm(contextState, submitState),
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}
