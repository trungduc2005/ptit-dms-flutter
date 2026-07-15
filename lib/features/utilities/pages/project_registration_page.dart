import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/core/widgets/app_popup_dialog.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_search_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/bloc/context/project_registration_context_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/bloc/student_search/project_student_search_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/bloc/submit/project_registration_submit_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/widgets/project_registration_sections.dart';

class ProjectRegistrationPage extends StatelessWidget {
  const ProjectRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProjectRegistrationContextBloc(
            academicYearRepository: context.read<AcademicYearRepository>(),
            projectRepository: context.read<ProjectRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => ProjectRegistrationSubmitBloc(
            projectRepository: context.read<ProjectRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => ProjectStudentSearchBloc(
            studentSearchRepository: context.read<StudentSearchRepository>(),
          ),
        ),
      ],
      child: const _ProjectRegistrationView(),
    );
  }
}

class _ProjectRegistrationView extends StatefulWidget {
  const _ProjectRegistrationView();

  @override
  State<_ProjectRegistrationView> createState() =>
      _ProjectRegistrationViewState();
}

class _ProjectRegistrationViewState extends State<_ProjectRegistrationView> {
  // Form controllers
  final TextEditingController _fieldController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _outcomeController = TextEditingController();
  final TextEditingController _guiderNameController = TextEditingController();
  final TextEditingController _memberSearchController = TextEditingController();

  Timer? _memberSearchDebounce;

  // Form state
  String? _selectedPeriod;
  List<ProjectMemberEntry> _members = const [];
  bool _isAddingMember = false;

  // Bootstrap state
  StudentProfile? _profile;
  bool _isBootstrapping = true;
  String? _bootstrapError;

  bool _isPopupOpen = false;
  String _lastSyncedKey = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _fieldController.dispose();
    _projectNameController.dispose();
    _keywordController.dispose();
    _descriptionController.dispose();
    _outcomeController.dispose();
    _guiderNameController.dispose();
    _memberSearchController.dispose();
    _memberSearchDebounce?.cancel();
    super.dispose();
  }

  // ─── Bootstrap ─────────────────────────────────────────────────────────────

  Future<void> _bootstrap() async {
    setState(() {
      _isBootstrapping = true;
      _bootstrapError = null;
    });

    try {
      final profile =
          await context.read<StudentProfileRepository>().getProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isBootstrapping = false;
      });

      context.read<ProjectRegistrationContextBloc>().add(
        ProjectRegistrationContextStarted(studentId: profile.studentId),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isBootstrapping = false;
        _bootstrapError = 'Không thể tải thông tin sinh viên.';
      });
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String get _studentId => _profile?.studentId.trim() ?? '';
  String get _fullName => _profile?.user?.fullName.trim() ?? '';
  String get _className => (_profile?.classInfo?.name ?? '').trim();

  String _memberLabel(StudentSearchResult student) {
    final label = student.label.trim();
    if (label.isNotEmpty) return label;

    final name = student.studentName.trim();
    final id = student.studentId.trim();

    if (name.isNotEmpty && id.isNotEmpty) return '$name ($id)';
    return name.isNotEmpty ? name : id;
  }

  // ─── Member search ─────────────────────────────────────────────────────────

  void _startAddingMember() {
    _memberSearchDebounce?.cancel();
    setState(() {
      _isAddingMember = true;
      _memberSearchController.clear();
    });
    context.read<ProjectStudentSearchBloc>().add(
      const ProjectStudentSearchCleared(),
    );
  }

  void _cancelAddingMember() {
    _memberSearchDebounce?.cancel();
    setState(() {
      _isAddingMember = false;
      _memberSearchController.clear();
    });
    context.read<ProjectStudentSearchBloc>().add(
      const ProjectStudentSearchCleared(),
    );
  }

  void _onSearchChanged(
    ProjectRegistrationContextState contextState,
    String query,
  ) {
    _memberSearchDebounce?.cancel();

    final trimmed = query.trim();

    if (trimmed.length < 3) {
      context.read<ProjectStudentSearchBloc>().add(
        const ProjectStudentSearchCleared(),
      );
      return;
    }

    _memberSearchDebounce = Timer(const Duration(milliseconds: 350), () {
      final academicYearId =
          contextState.selectedAcademicYearId?.trim() ?? '';
      context.read<ProjectStudentSearchBloc>().add(
        ProjectStudentSearchQueryChanged(
          query: trimmed,
          academicYearId: academicYearId,
        ),
      );
    });
  }

  void _addMember(StudentSearchResult student) {
    final studentId = student.studentId.trim();
    if (studentId.isEmpty) return;

    // Check if already leader
    if (studentId == _studentId) {
      _showError('Bạn không thể thêm chính mình vào nhóm.');
      return;
    }

    // Check duplicate
    if (_members.any((m) => m.studentId == studentId)) {
      _showError('Sinh viên này đã có trong nhóm.');
      return;
    }

    setState(() {
      _members = [
        ..._members,
        ProjectMemberEntry(
          studentId: studentId,
          label: _memberLabel(student),
          studentName: student.studentName.trim(),
        ),
      ];
      _isAddingMember = false;
      _memberSearchController.clear();
    });

    context.read<ProjectStudentSearchBloc>().add(
      const ProjectStudentSearchCleared(),
    );
  }

  void _removeMember(ProjectMemberEntry member) {
    setState(() {
      _members = _members
          .where((m) => m.studentId != member.studentId)
          .toList(growable: false);
    });
  }

  // ─── Sync form from existing registration ─────────────────────────────────

  void _syncFormFromContext(ProjectRegistrationContextState state) {
    final registration = state.currentRegistration;

    final syncKey = [
      state.selectedAcademicYearId ?? '',
      registration?.id ?? '',
      state.status.name,
    ].join('|');

    if (syncKey == _lastSyncedKey) return;

    setState(() {
      if (registration == null) {
        _fieldController.clear();
        _projectNameController.clear();
        _keywordController.clear();
        _descriptionController.clear();
        _outcomeController.clear();
        _guiderNameController.clear();
        _selectedPeriod = null;
        _members = const [];
      } else {
        _fieldController.text = registration.field;
        _projectNameController.text = registration.projectName;
        _keywordController.text = registration.keyword;
        _descriptionController.text = registration.description;
        _outcomeController.text = registration.outcome;
        _guiderNameController.text = registration.guider?.lecturerName ?? '';
        _selectedPeriod = registration.period;

        // Rebuild members list from existing registration
        _members = registration.members
            .where((m) => m.role != 'Leader')
            .map(
              (m) => ProjectMemberEntry(
                studentId: m.studentId,
                label: m.studentName.isNotEmpty
                    ? '${m.studentName} (${m.studentId})'
                    : m.studentId,
                studentName: m.studentName,
              ),
            )
            .toList(growable: false);
      }

      _lastSyncedKey = syncKey;
    });
  }

  // ─── Submit ────────────────────────────────────────────────────────────────

  void _submitForm(
    ProjectRegistrationContextState contextState,
    ProjectRegistrationSubmitState submitState,
  ) {
    final academicYearId =
        contextState.selectedAcademicYearId?.trim() ?? '';

    if (academicYearId.isEmpty) {
      _showError('Bạn phải chọn năm học.');
      return;
    }

    if (_selectedPeriod == null) {
      _showError('Bạn phải chọn học kỳ.');
      return;
    }

    if (_projectNameController.text.trim().isEmpty) {
      _showError('Bạn phải nhập tên đề tài.');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError('Bạn phải nhập mô tả đề tài.');
      return;
    }

    final request = ProjectRegistrationRequest(
      academicYearId: academicYearId,
      field: _fieldController.text.trim(),
      period: _selectedPeriod!,
      projectName: _projectNameController.text.trim(),
      keyword: _keywordController.text.trim(),
      description: _descriptionController.text.trim(),
      outcome: _outcomeController.text.trim(),
      guiderName: _guiderNameController.text.trim().isEmpty
          ? null
          : _guiderNameController.text.trim(),
      members: _members
          .map((m) => {'studentId': m.studentId})
          .toList(growable: false),
    );

    if (contextState.canEditRegistration) {
      context.read<ProjectRegistrationSubmitBloc>().add(
        ProjectRegistrationUpdated(request: request),
      );
    } else {
      context.read<ProjectRegistrationSubmitBloc>().add(
        ProjectRegistrationSubmitted(request: request),
      );
    }
  }

  // ─── Dialogs ───────────────────────────────────────────────────────────────

  Future<void> _showError(String message) async {
    if (_isPopupOpen || !mounted) return;

    _isPopupOpen = true;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AppPopupDialog(title: 'Thông báo', message: message),
    );

    if (mounted) {
      _isPopupOpen = false;
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (isError) {
      _showError(message);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.brandColor,
        ),
      );
  }

  // ─── BLoC handlers ─────────────────────────────────────────────────────────

  void _handleContextStateChanged(
    BuildContext context,
    ProjectRegistrationContextState state,
  ) {
    if (state.status == ProjectRegistrationContextStatus.failure &&
        (state.errorMessage?.trim().isNotEmpty ?? false)) {
      _showSnack(state.errorMessage!, isError: true);
    }

    if (state.status == ProjectRegistrationContextStatus.success) {
      _syncFormFromContext(state);
    }
  }

  void _handleSubmitStateChanged(
    BuildContext context,
    ProjectRegistrationSubmitState state,
  ) {
    final message = state.message?.trim();
    if (message != null && message.isNotEmpty) {
      final isError = state.status == ProjectRegistrationSubmitStatus.failure;
      _showSnack(message, isError: isError);
    }

    if (state.status == ProjectRegistrationSubmitStatus.success) {
      context.read<ProjectRegistrationContextBloc>().add(
        const ProjectRegistrationContextRefreshed(),
      );
    }
  }

  // ─── UI builders ───────────────────────────────────────────────────────────

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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _bootstrap,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const AppHeader(
        title: 'Đăng ký đồ án',
        showBackButton: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<
            ProjectRegistrationContextBloc,
            ProjectRegistrationContextState
          >(listener: _handleContextStateChanged),
          BlocListener<
            ProjectRegistrationSubmitBloc,
            ProjectRegistrationSubmitState
          >(listener: _handleSubmitStateChanged),
        ],
        child: BlocBuilder<
          ProjectRegistrationContextBloc,
          ProjectRegistrationContextState
        >(
          builder: (context, contextState) {
            final submitState =
                context.watch<ProjectRegistrationSubmitBloc>().state;
            final searchState =
                context.watch<ProjectStudentSearchBloc>().state;

            if (_isBootstrapping ||
                (contextState.status ==
                        ProjectRegistrationContextStatus.initial &&
                    _bootstrapError == null)) {
              return _buildLoadingState();
            }

            if (_bootstrapError != null &&
                contextState.status ==
                    ProjectRegistrationContextStatus.initial) {
              return _buildBootstrapError();
            }

            final canEdit = !contextState.isViewOnly &&
                !submitState.isBusy &&
                (contextState.canCreateRegistration ||
                    contextState.canEditRegistration);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProjectRegistrationContextBloc>().add(
                  const ProjectRegistrationContextRefreshed(),
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  // Loading indicator
                  if (contextState.status ==
                          ProjectRegistrationContextStatus.loading ||
                      submitState.isBusy)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(),
                    ),

                  // Section 1: Năm học + Học kỳ + Lĩnh vực
                  ProjectRegistrationInfoSection(
                    academicYears: contextState.academicYears,
                    selectedAcademicYearId: contextState.selectedAcademicYearId,
                    selectedPeriod: _selectedPeriod,
                    fieldController: _fieldController,
                    isBusy: submitState.isBusy,
                    canEdit: canEdit,
                    onAcademicYearChanged: (value) {
                      if (value == null || value.trim().isEmpty) return;

                      setState(() {
                        _lastSyncedKey = '';
                      });

                      context.read<ProjectRegistrationContextBloc>().add(
                        ProjectRegistrationAcademicYearSelected(value),
                      );
                    },
                    onPeriodChanged: (value) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                    },
                  ),

                  // Section 2: Thông tin sinh viên
                  ProjectRegistrationStudentSection(
                    studentId: _studentId,
                    fullName: _fullName,
                    className: _className,
                  ),

                  // Section 3: Thông tin đề tài
                  ProjectRegistrationProjectSection(
                    projectNameController: _projectNameController,
                    keywordController: _keywordController,
                    descriptionController: _descriptionController,
                    outcomeController: _outcomeController,
                    canEdit: canEdit,
                  ),

                  // Section 4: Giảng viên hướng dẫn
                  ProjectRegistrationGuiderSection(
                    guiderNameController: _guiderNameController,
                    canEdit: canEdit,
                  ),

                  // Section 5: Thành viên nhóm
                  ProjectRegistrationMembersSection(
                    members: _members,
                    searchController: _memberSearchController,
                    searchResults: searchState.results,
                    isSearching: searchState.isLoading,
                    searchError: searchState.error,
                    isAddingMember: _isAddingMember,
                    canEdit: canEdit,
                    onStartAdd: _startAddingMember,
                    onCancelAdd: _cancelAddingMember,
                    onSearchChanged: (query) =>
                        _onSearchChanged(contextState, query),
                    onAdd: _addMember,
                    onRemove: _removeMember,
                  ),

                  const SizedBox(height: 8),

                  // Submit button
                  ProjectRegistrationSubmitButton(
                    label: contextState.canEditRegistration
                        ? 'Cập nhật đăng ký'
                        : 'Gửi đăng ký',
                    canSubmit: canEdit &&
                        contextState.selectedAcademicYearId != null,
                    isViewOnly: contextState.isViewOnly,
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