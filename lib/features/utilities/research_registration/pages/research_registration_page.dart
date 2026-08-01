import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/core/widgets/app_popup_dialog.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_read_only_field.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_section_card.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_text_field.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_time_range_caption.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/research_member_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research_registration_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/research_registration/bloc/research_registration_bloc.dart';

class ResearchRegistrationPage extends StatelessWidget {
  const ResearchRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResearchRegistrationBloc(
        repository: context.read<ResearchRepository>(),
        timelineRepository: context.read<TimelineRepository>(),
      ),
      child: const _ResearchRegistrationView(),
    );
  }
}

class _ResearchRegistrationView extends StatefulWidget {
  const _ResearchRegistrationView();

  @override
  State<_ResearchRegistrationView> createState() =>
      _ResearchRegistrationViewState();
}

class _ResearchRegistrationViewState extends State<_ResearchRegistrationView> {
  static const _researchType = 'student';

  final _topicController = TextEditingController();
  final _keywordController = TextEditingController();
  final _outcomeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _necessityController = TextEditingController();
  final _nationalOverviewController = TextEditingController();
  final _internationalOverviewController = TextEditingController();

  List<AcademicYearOption> _academicYears = const [];
  String? _selectedYearId;
  ResearchMemberOption? _selectedLecturer;
  List<ResearchMemberOption> _selectedMembers = const [];
  String _leaderName = 'Bạn';
  bool _isLoadingYears = true;
  String? _yearError;
  bool _isPopupOpen = false;
  bool _isAddingMember = false;

  @override
  void initState() {
    super.initState();
    _loadAcademicYears();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _keywordController.dispose();
    _outcomeController.dispose();
    _descriptionController.dispose();
    _necessityController.dispose();
    _nationalOverviewController.dispose();
    _internationalOverviewController.dispose();
    super.dispose();
  }

  Future<void> _loadAcademicYears() async {
    setState(() {
      _isLoadingYears = true;
      _yearError = null;
    });

    try {
      final years = await context
          .read<AcademicYearRepository>()
          .getAcademicYears();
      if (!mounted) return;

      final validYears = years
          .where((year) => year.id.trim().isNotEmpty)
          .toList(growable: false);

      setState(() {
        _academicYears = validYears;
        _selectedYearId = validYears.isEmpty ? null : validYears.first.id;
        _isLoadingYears = false;
      });

      await _loadLeaderProfile();
      if (_selectedYearId != null) {
        _loadResearches();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingYears = false;
        _yearError = 'Không thể tải danh sách năm học.';
      });
    }
  }

  Future<void> _loadLeaderProfile() async {
    try {
      final profile = await context
          .read<StudentProfileRepository>()
          .getProfile();
      if (!mounted) return;
      final fullName = profile.user?.fullName.trim() ?? '';
      final studentId = profile.studentId.trim();
      setState(() {
        _leaderName = [
          if (fullName.isNotEmpty) fullName,
          if (studentId.isNotEmpty) studentId,
        ].join(' - ');
        if (_leaderName.isEmpty) _leaderName = 'Bạn';
      });
    } catch (_) {
      // Giữ nhãn mặc định nếu hồ sơ cá nhân tạm thời không tải được.
    }
  }

  void _loadResearches() {
    final yearId = _selectedYearId?.trim() ?? '';
    if (yearId.isEmpty) return;

    context.read<ResearchRegistrationBloc>().add(
      ResearchRegistrationStarted(yearId: yearId, type: _researchType),
    );
  }

  void _clearForm() {
    setState(() {
      _selectedLecturer = null;
      _selectedMembers = const [];
      _isAddingMember = false;
      _topicController.clear();
      _keywordController.clear();
      _outcomeController.clear();
      _descriptionController.clear();
      _necessityController.clear();
      _nationalOverviewController.clear();
      _internationalOverviewController.clear();
    });
  }

  void _submit(ResearchRegistrationState state) {
    if (state.isSubmitting) return;

    final yearId = _selectedYearId?.trim() ?? '';
    if (yearId.isEmpty) {
      _showMessage('Bạn phải chọn năm học.');
      return;
    }

    final fields = <TextEditingController, String>{
      _topicController: 'Bạn phải nhập tên chủ đề.',
      _keywordController: 'Bạn phải nhập từ khóa.',
      _outcomeController: 'Bạn phải nhập mục tiêu.',
      _descriptionController: 'Bạn phải nhập nội dung.',
      _nationalOverviewController:
          'Bạn phải nhập tình hình nghiên cứu trong nước.',
      _internationalOverviewController:
          'Bạn phải nhập tình hình nghiên cứu quốc tế.',
      _necessityController: 'Bạn phải nhập tính cấp thiết của đề tài.',
    };

    for (final entry in fields.entries) {
      if (entry.key.text.trim().isEmpty) {
        _showMessage(entry.value);
        return;
      }
    }

    if (_selectedLecturer == null) {
      _showMessage('Bạn phải chọn giảng viên hướng dẫn.');
      return;
    }

    final request = ResearchRegistrationRequest(
      yearId: yearId,
      type: _researchType,
      researchTopic: _topicController.text.trim(),
      keyword: _keywordController.text.trim(),
      outcome: _outcomeController.text.trim(),
      description: _descriptionController.text.trim(),
      researchNecessity: _necessityController.text.trim(),
      nationalOverview: _nationalOverviewController.text.trim(),
      internationalOverview: _internationalOverviewController.text.trim(),
      guiderId: _selectedLecturer!.id,
      members: _selectedMembers
          .map(
            (member) => ResearchRegistrationMemberRequest(memberId: member.id),
          )
          .toList(growable: false),
    );

    context.read<ResearchRegistrationBloc>().add(
      ResearchRegistrationCreated(request: request),
    );
  }

  Future<void> _showMessage(String message) async {
    if (_isPopupOpen || !mounted) return;
    _isPopupOpen = true;
    await showDialog<void>(
      context: context,
      builder: (_) => AppPopupDialog(title: 'Thông báo', message: message),
    );
    if (mounted) _isPopupOpen = false;
  }

  void _handleState(BuildContext context, ResearchRegistrationState state) {
    if (state.actionStatus == ResearchRegistrationActionStatus.initial) return;

    final message = state.actionMessage?.trim();
    if (message != null && message.isNotEmpty) {
      if (state.actionStatus == ResearchRegistrationActionStatus.success) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppTheme.brandColor,
            ),
          );
        _clearForm();
      } else if (state.actionStatus ==
          ResearchRegistrationActionStatus.failure) {
        _showMessage(message);
      }
    }

    if (state.actionStatus != ResearchRegistrationActionStatus.loading) {
      context.read<ResearchRegistrationBloc>().add(
        const ResearchRegistrationActionStateCleared(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const AppHeader(
        title: 'Đăng ký nghiên cứu khoa học',
        showBackButton: true,
      ),
      body: BlocListener<ResearchRegistrationBloc, ResearchRegistrationState>(
        listener: _handleState,
        child: BlocBuilder<ResearchRegistrationBloc, ResearchRegistrationState>(
          builder: (context, state) {
            if (_isLoadingYears) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_yearError != null) {
              return _ErrorView(
                message: _yearError!,
                onRetry: _loadAcademicYears,
              );
            }

            if (_academicYears.isEmpty) {
              return const _EmptyView(
                message: 'Chưa có năm học để đăng ký nghiên cứu khoa học.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ResearchRegistrationBloc>().add(
                  const ResearchRegistrationRefreshed(),
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  if (state.isLoading || state.isSubmitting)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(),
                    ),
                  _buildAcademicYearSection(state),
                  const SizedBox(height: 16),
                  if (state.loadStatus ==
                          ResearchRegistrationLoadStatus.failure &&
                      state.researches.isEmpty)
                    _InlineError(
                      message:
                          state.loadErrorMessage ??
                          'Không thể tải danh sách nghiên cứu khoa học.',
                      onRetry: _loadResearches,
                    )
                  else if (state.researches.isNotEmpty)
                    _buildRegisteredResearches(state.researches)
                  else
                    _buildForm(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAcademicYearSection(ResearchRegistrationState state) {
    final timeline = state.registrationTimeline;

    return _Card(
      child: Column(
        children: [
          FormDropdownField<String>(
            label: 'Năm học',
            value: _selectedYearId,
            hintText: 'Chọn năm học',
            enabled: !state.isSubmitting,
            items: _academicYears
                .map(
                  (year) => DropdownMenuItem(
                    value: year.id,
                    child: Text(
                      year.name.trim().isEmpty ? year.code : year.name,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null || value == _selectedYearId) return;
              setState(() {
                _selectedYearId = value;
              });
              _clearForm();
              _loadResearches();
            },
          ),
          if (timeline?.startTime != null || timeline?.endTime != null) ...[
            const SizedBox(height: 8),
            FormTimeRangeCaption(
              startTime: timeline?.startTime,
              endTime: timeline?.endTime,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegisteredResearches(List<Research> researches) {
    return Column(
      children: [
        for (var index = 0; index < researches.length; index++) ...[
          _Card(
            child: FormSectionCard(
              title: researches.length == 1
                  ? 'Đề tài đã đăng ký'
                  : 'Đề tài đã đăng ký ${index + 1}',
              bottomPadding: 0,
              child: _RegisteredResearchDetails(research: researches[index]),
            ),
          ),
          if (index < researches.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildForm(ResearchRegistrationState state) {
    final enabled = !state.isSubmitting;

    return _Card(
      child: FormSectionCard(
        title: 'Thông tin đăng ký',
        bottomPadding: 0,
        child: Column(
          children: [
            FormTextField(
              label: 'Tên chủ đề *',
              controller: _topicController,
              enabled: enabled,
              hintText: 'Nhập tên chủ đề',
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 14),
            FormTextField(
              label: 'Từ khóa *',
              controller: _keywordController,
              enabled: enabled,
              hintText: 'Nhập từ khóa',
            ),
            const SizedBox(height: 14),
            _multilineField(
              label: 'Mục tiêu *',
              hintText: 'Nhập mục tiêu',
              controller: _outcomeController,
              enabled: enabled,
            ),
            const SizedBox(height: 14),
            _multilineField(
              label: 'Nội dung *',
              hintText: 'Nhập nội dung',
              controller: _descriptionController,
              enabled: enabled,
            ),
            const SizedBox(height: 14),
            _multilineField(
              label: 'Tình hình nghiên cứu trong nước *',
              hintText: 'Nhập tình hình nghiên cứu trong nước',
              controller: _nationalOverviewController,
              enabled: enabled,
            ),
            const SizedBox(height: 14),
            _multilineField(
              label: 'Tình hình nghiên cứu quốc tế *',
              hintText: 'Nhập tình hình nghiên cứu quốc tế',
              controller: _internationalOverviewController,
              enabled: enabled,
            ),
            const SizedBox(height: 14),
            _multilineField(
              label: 'Tính cấp thiết của đề tài *',
              hintText: 'Mô tả về tính cấp thiết của đề tài',
              controller: _necessityController,
              enabled: enabled,
            ),
            const SizedBox(height: 14),
            _ResearchLecturerSearchField(
              key: const ValueKey('research-lecturer-dropdown'),
              label: 'Giảng viên hướng dẫn *',
              enabled: enabled,
              selected: _selectedLecturer,
              repository: context.read<ResearchRepository>(),
              onSelected: (lecturer) {
                setState(() => _selectedLecturer = lecturer);
              },
            ),
            const SizedBox(height: 14),
            FormReadOnlyField(
              label: 'Thành viên trong nhóm (tối đa 5 thành viên)',
              value: _leaderName,
            ),
            const SizedBox(height: 12),
            if (_selectedMembers.isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._selectedMembers.map(
                (member) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SelectedPersonTile(
                    person: member,
                    onDeleted: enabled
                        ? () {
                            setState(() {
                              _selectedMembers = _selectedMembers
                                  .where((item) => item.id != member.id)
                                  .toList(growable: false);
                            });
                          }
                        : null,
                  ),
                ),
              ),
            ],
            if (_selectedMembers.length < 4) ...[
              if (!_isAddingMember)
                OutlinedButton.icon(
                  onPressed: enabled
                      ? () => setState(() => _isAddingMember = true)
                      : null,
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: const Text('Thêm thành viên'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                )
              else
                _ResearchMemberSearchField(
                  key: ValueKey(
                    'student-${_selectedYearId ?? ''}-${_selectedMembers.map((e) => e.id).join(',')}',
                  ),
                  hintText: 'Nhập mã hoặc tên sinh viên...',
                  enabled: enabled,
                  repository: context.read<ResearchRepository>(),
                  academicYearId: _selectedYearId!,
                  excludedIds: _selectedMembers.map((e) => e.id).toSet(),
                  onCancel: () {
                    setState(() => _isAddingMember = false);
                  },
                  onSelected: (member) {
                    setState(() {
                      _selectedMembers = [..._selectedMembers, member];
                      _isAddingMember = false;
                    });
                  },
                ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: enabled ? () => _submit(state) : null,
                    icon: state.isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: const Text('Gửi đăng ký'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _multilineField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    String? hintText,
  }) {
    return FormTextField(
      label: label,
      controller: controller,
      hintText: hintText,
      enabled: enabled,
      height: 120,
      minLines: null,
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

class _ResearchLecturerSearchField extends StatefulWidget {
  const _ResearchLecturerSearchField({
    required this.label,
    required this.enabled,
    required this.selected,
    required this.repository,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool enabled;
  final ResearchMemberOption? selected;
  final ResearchRepository repository;
  final ValueChanged<ResearchMemberOption> onSelected;

  @override
  State<_ResearchLecturerSearchField> createState() =>
      _ResearchLecturerSearchFieldState();
}

class _ResearchLecturerSearchFieldState
    extends State<_ResearchLecturerSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<ResearchMemberOption> _options = const [];
  bool _isLoading = false;
  bool _showOptions = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.selected?.label ?? '';
  }

  @override
  void didUpdateWidget(covariant _ResearchLecturerSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected?.id != widget.selected?.id) {
      _controller.text = widget.selected?.label ?? '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();

    setState(() {
      _showOptions = true;
      _options = const [];
      _error = null;
      _isLoading = false;
    });

    if (query.length < 3) return;

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _showOptions = true;
    });

    try {
      final results = await widget.repository.searchLecturers(query: query);
      if (!mounted || _controller.text.trim() != query) return;

      setState(() {
        _options = results
            .where((option) => option.id.trim().isNotEmpty)
            .toList(growable: false);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || _controller.text.trim() != query) return;

      setState(() {
        _options = const [];
        _isLoading = false;
        _error = 'Không thể tìm giảng viên.';
      });
    }
  }

  void _select(ResearchMemberOption option) {
    _controller.text = option.label;
    _focusNode.unfocus();
    setState(() {
      _options = const [];
      _showOptions = false;
    });
    widget.onSelected(option);
  }

  @override
  Widget build(BuildContext context) {
    final queryLength = _controller.text.trim().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFADACB2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: Color(0xFF757575)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const ValueKey('research-lecturer-search-input'),
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  onTap: () => setState(() => _showOptions = true),
                  onChanged: _onQueryChanged,
                  decoration: const InputDecoration(
                    hintText: 'Tìm giảng viên theo mã hoặc tên',
                    hintStyle: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 16,
                  ),
                ),
              ),
              if (_isLoading)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          )
        else if (_showOptions && !_isLoading && _options.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _options.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final option = _options[index];
                  return ListTile(
                    dense: true,
                    title: Text(option.label),
                    onTap: () => _select(option),
                  );
                },
              ),
            ),
          )
        else if (_showOptions && !_isLoading && queryLength > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              queryLength < 3
                  ? 'Nhập tối thiểu 3 ký tự'
                  : 'Không tìm thấy giảng viên',
              style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
            ),
          ),
      ],
    );
  }
}

class _ResearchMemberSearchField extends StatefulWidget {
  const _ResearchMemberSearchField({
    super.key,
    required this.hintText,
    required this.enabled,
    required this.repository,
    required this.academicYearId,
    required this.onSelected,
    required this.onCancel,
    this.excludedIds = const {},
  });

  final String hintText;
  final bool enabled;
  final ResearchRepository repository;
  final String academicYearId;
  final ValueChanged<ResearchMemberOption> onSelected;
  final VoidCallback onCancel;
  final Set<String> excludedIds;

  @override
  State<_ResearchMemberSearchField> createState() =>
      _ResearchMemberSearchFieldState();
}

class _ResearchMemberSearchFieldState
    extends State<_ResearchMemberSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<ResearchMemberOption> _options = const [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      setState(() {
        _options = const [];
        _error = null;
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await widget.repository.searchStudents(
        query: query,
        academicYearId: widget.academicYearId,
      );
      if (!mounted || _controller.text.trim() != query) return;
      setState(() {
        _options = results
            .where(
              (option) =>
                  option.id.trim().isNotEmpty &&
                  !widget.excludedIds.contains(option.id),
            )
            .toList(growable: false);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || _controller.text.trim() != query) return;
      setState(() {
        _options = const [];
        _isLoading = false;
        _error = 'Không thể tìm sinh viên.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFADACB2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 18,
                      color: Color(0xFF757575),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        enabled: widget.enabled,
                        onChanged: _onQueryChanged,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: const TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: widget.onCancel, child: const Text('Hủy')),
          ],
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        if (_options.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 210),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _options.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final option = _options[index];
                return ListTile(
                  dense: true,
                  title: Text(option.label),
                  onTap: () {
                    widget.onSelected(option);
                    _controller.clear();
                    setState(() => _options = const []);
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _RegisteredResearchDetails extends StatelessWidget {
  const _RegisteredResearchDetails({required this.research});

  final Research research;

  @override
  Widget build(BuildContext context) {
    final guiderName = research.guider?.lecturerName?.trim() ?? '';
    final members = research.members;
    final status = _statusLabel(research.approvalStatus);

    return Column(
      children: [
        FormReadOnlyField(
          label: 'Tên chủ đề',
          value: _displayValue(research.researchTopic),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Loại hình',
          value: research.type == 'student'
              ? 'Sinh viên'
              : _displayValue(research.type),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Từ khóa',
          value: _displayValue(research.keyword),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Mục tiêu',
          value: _displayValue(research.outcome),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Nội dung',
          value: _displayValue(research.description),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Tình hình nghiên cứu trong nước',
          value: _displayValue(research.nationalOverview),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Tình hình nghiên cứu quốc tế',
          value: _displayValue(research.internationalOverview),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Tính cấp thiết của đề tài',
          value: _displayValue(research.researchNecessity),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Giảng viên hướng dẫn',
          value: guiderName.isEmpty ? 'Chưa có thông tin' : guiderName,
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(label: 'Trạng thái', value: status),
        if (members.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var index = 0; index < members.length; index++) ...[
            FormReadOnlyField(
              label: members[index].isLeader
                  ? 'Chủ nhiệm đề tài'
                  : 'Thành viên ${index + 1}',
              value: _memberLabel(members[index]),
            ),
            if (index < members.length - 1) const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  String _displayValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Chưa có thông tin' : trimmed;
  }

  String _memberLabel(ResearchMember member) {
    final name = member.memberName.trim();
    final id = member.memberId.trim();
    if (name.isNotEmpty && id.isNotEmpty) return '$name - $id';
    if (name.isNotEmpty) return name;
    return id.isNotEmpty ? id : 'Chưa có thông tin';
  }

  String _statusLabel(String status) {
    switch (status.trim().toLowerCase()) {
      case 'approved':
        return 'Đã phê duyệt';
      case 'rejected':
        return 'Đã từ chối';
      case 'hasissue':
      case 'needs_revision':
        return 'Cần chỉnh sửa';
      case 'pending':
      default:
        return 'Đang chờ duyệt';
    }
  }
}

class _SelectedPersonTile extends StatelessWidget {
  const _SelectedPersonTile({required this.person, this.onDeleted});

  final ResearchMemberOption person;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return _PersonTile(
      icon: Icons.person_outline,
      label: person.label,
      onDeleted: onDeleted,
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.icon, required this.label, this.onDeleted});

  final IconData icon;
  final String label;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5D5F5F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1F1F1F),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDeleted != null)
            IconButton(
              key: ValueKey('remove-person-$label'),
              onPressed: onDeleted,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              tooltip: 'Xóa',
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF5D5F5F)),
            ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF616161)),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _InlineError(message: message, onRetry: onRetry),
      ),
    );
  }
}
