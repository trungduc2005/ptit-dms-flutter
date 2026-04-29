import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/eligibility.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_cv_upload_result.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/eligibility_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_cv_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoadingYears = false;
  bool _isLoadingEligibility = false;
  bool _isLoadingTimelines = false;
  bool _isUploadingCv = false;
  String? _error;

  final TextEditingController _cvFilePathController = TextEditingController();

  List<AcademicYearOption> _academicYears = const [];
  String? _selectedAcademicYearId;
  Eligibility? _eligibility;
  List<Timeline> _timelines = const [];
  InternCvUploadResult? _uploadedCv;

  @override
  void dispose() {
    _cvFilePathController.dispose();
    super.dispose();
  }

  void _logout() {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  Future<void> _loadAcademicYears() async {
    setState(() {
      _isLoadingYears = true;
      _error = null;
      _eligibility = null;
      _timelines = const [];
      _academicYears = const [];
      _selectedAcademicYearId = null;
      _uploadedCv = null;
    });

    try {
      final repository = context.read<AcademicYearRepository>();
      final academicYears = await repository.getInternAcademicYears();

      if (!mounted) return;

      setState(() {
        _academicYears = academicYears;
        _selectedAcademicYearId = academicYears.isNotEmpty
            ? academicYears.first.id
            : null;
        _isLoadingYears = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoadingYears = false;
      });
    }
  }

  Future<void> _loadEligibility() async {
    final academicYearId = _selectedAcademicYearId;

    if (academicYearId == null || academicYearId.isEmpty) {
      setState(() {
        _error = 'Hãy gọi API academic years và chọn 1 năm học trước';
      });
      return;
    }

    setState(() {
      _isLoadingEligibility = true;
      _error = null;
      _eligibility = null;
    });

    try {
      final repository = context.read<EligibilityRepository>();
      final eligibility = await repository.getRegistrationEligibility(
        academicYearId: academicYearId,
      );

      if (!mounted) return;

      setState(() {
        _eligibility = eligibility;
        _isLoadingEligibility = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoadingEligibility = false;
      });
    }
  }

  Future<void> _loadTimelines() async {
    final academicYearId = _selectedAcademicYearId;

    if (academicYearId == null || academicYearId.isEmpty) {
      setState(() {
        _error = 'Hãy gọi API academic years và chọn 1 năm học trước';
      });
      return;
    }

    setState(() {
      _isLoadingTimelines = true;
      _error = null;
      _timelines = const [];
    });

    try {
      final repository = context.read<TimelineRepository>();
      final timelines = await repository.getInternTimelines(
        academicYearId: academicYearId,
      );

      if (!mounted) return;

      setState(() {
        _timelines = timelines;
        _isLoadingTimelines = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoadingTimelines = false;
      });
    }
  }

  Future<void> _uploadCv() async {
    final academicYearId = _selectedAcademicYearId;
    final filePath = _cvFilePathController.text.trim();

    if (academicYearId == null || academicYearId.isEmpty) {
      setState(() {
        _error = 'Hãy gọi API academic years và chọn 1 năm học trước';
      });
      return;
    }

    if (filePath.isEmpty) {
      setState(() {
        _error = 'Hãy nhập đường dẫn file CV trước';
      });
      return;
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      setState(() {
        _error = 'Không tìm thấy file: $filePath';
      });
      return;
    }

    setState(() {
      _isUploadingCv = true;
      _error = null;
      _uploadedCv = null;
    });

    try {
      final repository = context.read<InternCvRepository>();
      final uploadedCv = await repository.uploadCv(
        academicYearId: academicYearId,
        filePath: filePath,
      );

      if (!mounted) return;

      setState(() {
        _uploadedCv = uploadedCv;
        _isUploadingCv = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isUploadingCv = false;
      });
    }
  }

  Widget _buildAcademicYearCard(AcademicYearOption item) {
    final isSelected = item.id == _selectedAcademicYearId;

    return Card(
      child: ListTile(
        selected: isSelected,
        title: Text(item.name),
        subtitle: Text('ID: ${item.id}'),
        trailing: isSelected ? const Icon(Icons.check) : null,
        onTap: () {
          setState(() {
            _selectedAcademicYearId = item.id;
            _eligibility = null;
            _timelines = const [];
            _uploadedCv = null;
            _error = null;
          });
        },
      ),
    );
  }

  Widget _buildTimelineCard(Timeline timeline) {
    return Card(
      child: ListTile(
        title: Text(timeline.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID: ${timeline.id}'),
            Text('type: ${timeline.type ?? '-'}'),
            Text('role: ${timeline.role ?? '-'}'),
            Text('academicYear: ${timeline.academicYear ?? '-'}'),
            Text('startTime: ${timeline.startTime?.toIso8601String() ?? '-'}'),
            Text('endTime: ${timeline.endTime?.toIso8601String() ?? '-'}'),
            Text(
              'preferredCompanyCount: '
              '${timeline.preferredCompanyCount?.toString() ?? '-'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số lượng năm học: ${_academicYears.length}'),
            Text('Số lượng timelines: ${_timelines.length}'),
            Text(
              'academicYearId đang chọn: ${_selectedAcademicYearId ?? '(chưa chọn)'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityCard() {
    if (_eligibility == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Chưa gọi eligibility hoặc chưa có dữ liệu'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'canRegisterSpecialization: '
              '${_eligibility!.canRegisterSpecialization}',
            ),
            const SizedBox(height: 8),
            Text(
              'canRegisterInternship: '
              '${_eligibility!.canRegisterInternship}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedCvCard() {
    if (_uploadedCv == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Chưa upload CV'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('cvFileName: ${_uploadedCv!.cvFileName}'),
            const SizedBox(height: 8),
            SelectableText('cvFileKey: ${_uploadedCv!.cvFileKey}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        _isLoadingYears ||
        _isLoadingEligibility ||
        _isLoadingTimelines ||
        _isUploadingCv;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Intern APIs'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: _isLoadingYears ? null : _loadAcademicYears,
                    child: const Text('Gọi API academic years'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoadingEligibility ? null : _loadEligibility,
                    child: const Text('Gọi API eligibility'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoadingTimelines ? null : _loadTimelines,
                    child: const Text('Gọi API timelines'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cvFilePathController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Đường dẫn file CV',
                  hintText: r'C:\Users\Duc\Documents\cv.pdf',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isUploadingCv ? null : _uploadCv,
                child: const Text('Upload CV'),
              ),
              const SizedBox(height: 16),
              if (isLoading) const LinearProgressIndicator(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 12),
              _buildSummaryCard(),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _buildSectionTitle('Academic years'),
                    const SizedBox(height: 8),
                    if (_academicYears.isEmpty)
                      const Text('Chưa có academic years')
                    else
                      ..._academicYears.map(_buildAcademicYearCard),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Eligibility'),
                    const SizedBox(height: 8),
                    _buildEligibilityCard(),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Upload CV'),
                    const SizedBox(height: 8),
                    _buildUploadedCvCard(),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Timelines'),
                    const SizedBox(height: 8),
                    if (_timelines.isEmpty)
                      const Text('Chưa có timelines')
                    else
                      ..._timelines.map(_buildTimelineCard),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
