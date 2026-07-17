import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/core/widgets/app_popup_dialog.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';
import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_search_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/bloc/context/project_registration_context_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/bloc/membership_response/project_membership_response_bloc.dart';
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
            studentProfileRepository: context.read<StudentProfileRepository>(),
            academicYearRepository: context.read<AcademicYearRepository>(),
            projectRepository: context.read<ProjectRepository>(),
            timelineRepository: context.read<TimelineRepository>(),
          )..add(const ProjectRegistrationContextStarted()),
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
        BlocProvider(
          create: (context) => ProjectMembershipResponseBloc(
            projectRepository: context.read<ProjectRepository>(),
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
  final TextEditingController _memberSearchController = TextEditingController();

  Timer? _memberSearchDebounce;

  // Form state
  String? _selectedPeriod;
  String? _selectedGuiderId;
  List<ProjectMemberEntry> _members = const [];
  bool _isAddingMember = false;

  bool _isPopupOpen = false;
  bool _isEditingExistingRegistration = false;
  String _lastSyncedKey = '';
  ProjectRegistrationTab _selectedTab = ProjectRegistrationTab.information;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fieldController.dispose();
    _projectNameController.dispose();
    _keywordController.dispose();
    _descriptionController.dispose();
    _outcomeController.dispose();
    _memberSearchController.dispose();
    _memberSearchDebounce?.cancel();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _getStudentId(ProjectRegistrationContextState state) =>
      state.profile?.studentId.trim() ?? '';

  String _getFullName(ProjectRegistrationContextState state) =>
      state.profile?.user?.fullName.trim() ?? '';

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
      final academicYearId = contextState.selectedAcademicYearId?.trim() ?? '';
      context.read<ProjectStudentSearchBloc>().add(
        ProjectStudentSearchQueryChanged(
          query: trimmed,
          academicYearId: academicYearId,
        ),
      );
    });
  }

  void _addMember(
    ProjectRegistrationContextState contextState,
    StudentSearchResult student,
  ) {
    final studentId = student.studentId.trim();
    if (studentId.isEmpty) return;

    final maxMember = contextState.maxMember;
    final totalMembers = _members.length + 1;

    if (totalMembers >= maxMember) {
      _showError('Một nhóm đồ án chỉ được có tối đa $maxMember thành viên.');
      return;
    }

    // Check if already leader
    final currentStudentId = _getStudentId(contextState);
    if (studentId == currentStudentId) {
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
        _fieldController.text =
            state.profile?.major
                .map((item) => item.trim())
                .where((item) => item.isNotEmpty)
                .join(', ') ??
            '';
        _projectNameController.clear();
        _keywordController.clear();
        _descriptionController.clear();
        _outcomeController.clear();
        _selectedPeriod = null;
        _selectedGuiderId = null;
        _members = const [];
      } else {
        _fieldController.text = registration.field;
        _projectNameController.text = registration.projectName;
        _keywordController.text = registration.keyword;
        _descriptionController.text = registration.description;
        _outcomeController.text = registration.outcome;
        _selectedPeriod = registration.period;
        final existingGuider = registration.guider;
        final guiderCandidates = [
          existingGuider?.lecturerRef?.trim(),
          existingGuider?.lecturerId?.trim(),
        ];
        _selectedGuiderId = guiderCandidates
            .whereType<String>()
            .where((id) => id.isNotEmpty)
            .firstWhere(
              (id) => state.guiders.any((item) => item.lecturerId == id),
              orElse: () => '',
            );
        if (_selectedGuiderId!.isEmpty) _selectedGuiderId = null;

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

      _isEditingExistingRegistration = false;
      _isAddingMember = false;
      _memberSearchController.clear();
      _lastSyncedKey = syncKey;
    });

    context.read<ProjectStudentSearchBloc>().add(
      const ProjectStudentSearchCleared(),
    );
  }

  // ─── Submit ────────────────────────────────────────────────────────────────

  void _submitForm(
    ProjectRegistrationContextState contextState,
    ProjectRegistrationSubmitState submitState,
  ) {
    if (submitState.isBusy) return;

    final academicYearId = contextState.selectedAcademicYearId?.trim() ?? '';

    if (academicYearId.isEmpty) {
      _showError('Bạn phải chọn năm học.');
      return;
    }

    if (_selectedPeriod == null) {
      _showError('Bạn phải chọn đợt đăng ký.');
      return;
    }

    if (_fieldController.text.trim().isEmpty) {
      _showError('Bạn phải nhập lĩnh vực đề tài.');
      return;
    }

    if (_projectNameController.text.trim().isEmpty) {
      _showError('Bạn phải nhập tên đề tài.');
      return;
    }

    if (_keywordController.text.trim().isEmpty) {
      _showError('Bạn phải nhập từ khóa.');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError('Bạn phải nhập mô tả đề tài.');
      return;
    }

    if (_outcomeController.text.trim().isEmpty) {
      _showError('Bạn phải nhập kết quả dự kiến.');
      return;
    }

    final totalMembers = _members.length + 1;
    if (totalMembers < contextState.minMember ||
        totalMembers > contextState.maxMember) {
      final minMember = contextState.minMember;
      final maxMember = contextState.maxMember;
      final message = minMember == maxMember
          ? 'Nhóm đồ án phải có $maxMember thành viên.'
          : 'Nhóm đồ án phải có từ $minMember đến $maxMember thành viên.';
      _showError(message);
      return;
    }

    final selectedGuider = _selectedGuiderId == null
        ? null
        : contextState.guiders
              .where((item) => item.lecturerId == _selectedGuiderId)
              .firstOrNull;

    final request = ProjectRegistrationRequest(
      academicYearId: academicYearId,
      field: _fieldController.text.trim(),
      period: _selectedPeriod!,
      projectName: _projectNameController.text.trim(),
      keyword: _keywordController.text.trim(),
      description: _descriptionController.text.trim(),
      outcome: _outcomeController.text.trim(),
      guiderId: selectedGuider?.lecturerId,
      guiderName: selectedGuider?.fullName,
      members: _members
          .map((member) => {'studentId': member.studentId})
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

  Future<void> _approveMembership(ProjectMember member) async {
    if (_isPopupOpen || !mounted) return;

    final projectId = context
        .read<ProjectRegistrationContextBloc>()
        .state
        .currentRegistration
        ?.projectId
        .trim();
    final studentRef = member.studentRef.trim();
    if (projectId == null || projectId.isEmpty || studentRef.isEmpty) {
      await _showError('Không tìm thấy thông tin lời mời tham gia nhóm.');
      return;
    }

    _isPopupOpen = true;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AppPopupDialog(
        title: 'Xác nhận tham gia',
        message: 'Bạn có chắc chắn muốn tham gia nhóm đồ án này không?',
        secondaryLabel: 'Hủy',
        primaryLabel: 'Đồng ý',
        onSecondaryPressed: () {
          Navigator.of(dialogContext).pop(false);
        },
        onPrimaryPressed: () {
          Navigator.of(dialogContext).pop(true);
        },
      ),
    );
    if (mounted) _isPopupOpen = false;

    if (confirmed != true || !mounted) return;
    context.read<ProjectMembershipResponseBloc>().add(
      ProjectMembershipApproved(projectId: projectId, studentRef: studentRef),
    );
  }

  Future<void> _rejectMembership(ProjectMember member) async {
    if (_isPopupOpen || !mounted) return;

    final projectId = context
        .read<ProjectRegistrationContextBloc>()
        .state
        .currentRegistration
        ?.projectId
        .trim();
    final studentRef = member.studentRef.trim();
    if (projectId == null || projectId.isEmpty || studentRef.isEmpty) {
      await _showError('Không tìm thấy thông tin lời mời tham gia nhóm.');
      return;
    }

    _isPopupOpen = true;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AppPopupDialog(
        title: 'Từ chối tham gia',
        message: 'Bạn có chắc chắn muốn từ chối tham gia nhóm đồ án này không?',
        secondaryLabel: 'Hủy',
        primaryLabel: 'Từ chối',
        onSecondaryPressed: () {
          Navigator.of(dialogContext).pop(false);
        },
        onPrimaryPressed: () {
          Navigator.of(dialogContext).pop(true);
        },
      ),
    );
    if (mounted) _isPopupOpen = false;

    if (confirmed != true || !mounted) return;
    context.read<ProjectMembershipResponseBloc>().add(
      ProjectMembershipRejected(projectId: projectId, studentRef: studentRef),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (isError) {
      _showError(message);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.brandColor),
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
      setState(() {
        _isEditingExistingRegistration = false;
        _isAddingMember = false;
      });
      context.read<ProjectRegistrationContextBloc>().add(
        const ProjectRegistrationContextRefreshed(),
      );
    }
  }

  void _handleMembershipResponseStateChanged(
    BuildContext context,
    ProjectMembershipResponseState state,
  ) {
    if (state.status != ProjectMembershipResponseStatus.success &&
        state.status != ProjectMembershipResponseStatus.failure) {
      return;
    }

    final message = state.message?.trim();
    if (message != null && message.isNotEmpty) {
      _showSnack(
        message,
        isError: state.status == ProjectMembershipResponseStatus.failure,
      );
    }

    if (state.status == ProjectMembershipResponseStatus.success) {
      _lastSyncedKey = '';
      context.read<ProjectRegistrationContextBloc>().add(
        const ProjectRegistrationContextRefreshed(),
      );
    }
  }

  // ─── UI builders ───────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ProjectRegistrationContextBloc>().add(
                  const ProjectRegistrationContextStarted(),
                );
              },
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
      appBar: const AppHeader(title: 'Đăng ký đồ án', showBackButton: true),
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
          BlocListener<
            ProjectMembershipResponseBloc,
            ProjectMembershipResponseState
          >(listener: _handleMembershipResponseStateChanged),
        ],
        child:
            BlocBuilder<
              ProjectRegistrationContextBloc,
              ProjectRegistrationContextState
            >(
              builder: (context, contextState) {
                final submitState = context
                    .watch<ProjectRegistrationSubmitBloc>()
                    .state;
                final searchState = context
                    .watch<ProjectStudentSearchBloc>()
                    .state;
                final membershipResponseState = context
                    .watch<ProjectMembershipResponseBloc>()
                    .state;

                // Show loading during initial load
                if (contextState.status ==
                        ProjectRegistrationContextStatus.initial ||
                    (contextState.status ==
                            ProjectRegistrationContextStatus.loading &&
                        contextState.profile == null)) {
                  return _buildLoadingState();
                }

                // Show error if bootstrap failed
                if (contextState.status ==
                        ProjectRegistrationContextStatus.failure &&
                    contextState.profile == null) {
                  return _buildError(
                    contextState.errorMessage ??
                        'Không thể tải thông tin sinh viên.',
                  );
                }

                final hasExistingRegistration = contextState.hasExistingProject;
                final isViewingExisting =
                    hasExistingRegistration && !_isEditingExistingRegistration;
                final canEdit =
                    !submitState.isBusy &&
                    (contextState.canCreateRegistration ||
                        (contextState.canEditRegistration &&
                            _isEditingExistingRegistration));

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

                      ProjectRegistrationTabSwitcher(
                        selectedTab: _selectedTab,
                        onChanged: (tab) {
                          if (tab == _selectedTab) return;
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _selectedTab = tab;
                            if (tab == ProjectRegistrationTab.status) {
                              _isAddingMember = false;
                            }
                          });
                          if (tab == ProjectRegistrationTab.status) {
                            _memberSearchDebounce?.cancel();
                            _memberSearchController.clear();
                            context.read<ProjectStudentSearchBloc>().add(
                              const ProjectStudentSearchCleared(),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      ProjectMembershipInvitationCard(
                        project: contextState.currentRegistration,
                        currentStudentId: _getStudentId(contextState),
                        isResponding: membershipResponseState.isSubmitting,
                        onApprove: _approveMembership,
                        onReject: _rejectMembership,
                      ),
                      if (contextState.currentRegistration?.members.any(
                            (member) =>
                                member.studentId.trim() ==
                                    _getStudentId(contextState) &&
                                !member.isLeader &&
                                member.isPending &&
                                member.studentRef.trim().isNotEmpty,
                          ) ??
                          false)
                        const SizedBox(height: 16),

                      if (_selectedTab ==
                          ProjectRegistrationTab.information) ...[
                        // Section 1: Năm học + Học kỳ + Lĩnh vực
                        ProjectRegistrationInfoSection(
                          academicYears: contextState.academicYears,
                          selectedAcademicYearId:
                              contextState.selectedAcademicYearId,
                          periods: contextState.periods,
                          selectedPeriod: _selectedPeriod,
                          fieldController: _fieldController,
                          isBusy: submitState.isBusy,
                          canEdit: canEdit,
                          displayOnly: isViewingExisting,
                          onAcademicYearChanged: (value) {
                            if (value == null || value.trim().isEmpty) return;

                            setState(() {
                              _lastSyncedKey = '';
                              _selectedGuiderId = null;
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
                        const SizedBox(height: 16),

                        // Section 2: Thông tin đề tài
                        ProjectRegistrationProjectSection(
                          projectNameController: _projectNameController,
                          keywordController: _keywordController,
                          descriptionController: _descriptionController,
                          outcomeController: _outcomeController,
                          canEdit: canEdit,
                          displayOnly: isViewingExisting,
                        ),
                        const SizedBox(height: 16),

                        // Section 3: Giảng viên hướng dẫn
                        ProjectRegistrationGuiderSection(
                          guiders: contextState.guiders,
                          selectedGuiderId: _selectedGuiderId,
                          canEdit: canEdit,
                          displayOnly: isViewingExisting,
                          existingGuiderName: contextState
                              .currentRegistration
                              ?.guider
                              ?.lecturerName,
                          onChanged: (value) {
                            setState(() {
                              _selectedGuiderId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Section 4: Thành viên nhóm
                        ProjectRegistrationMembersSection(
                          leaderStudentId: _getStudentId(contextState),
                          leaderFullName: _getFullName(contextState),
                          members: _members,
                          minMember: contextState.minMember,
                          maxMember: contextState.maxMember,
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
                          onAdd: (student) => _addMember(contextState, student),
                          onRemove: _removeMember,
                        ),
                        const SizedBox(height: 16),

                        // Submit button
                        ProjectRegistrationSubmitButton(
                          label: isViewingExisting
                              ? 'Sửa thông tin'
                              : contextState.canEditRegistration
                              ? 'Gửi lại thông tin'
                              : 'Gửi đăng ký',
                          canSubmit: isViewingExisting
                              ? contextState.canEditRegistration &&
                                    !submitState.isBusy
                              : canEdit &&
                                    contextState.selectedAcademicYearId != null,
                          isViewOnly:
                              contextState.isViewOnly && isViewingExisting,
                          leadingIcon: isViewingExisting
                              ? Icons.edit_outlined
                              : Icons.send_outlined,
                          onSubmit: isViewingExisting
                              ? () {
                                  setState(() {
                                    _isEditingExistingRegistration = true;
                                  });
                                }
                              : () => _submitForm(contextState, submitState),
                        ),
                      ] else ...[
                        ProjectRegistrationStatusSection(
                          project: contextState.currentRegistration,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}
