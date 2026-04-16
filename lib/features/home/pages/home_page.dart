import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ptit_dms_flutter/core/network/dio_client.dart';
import 'package:ptit_dms_flutter/data/datasources/academic_year_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/datasources/eligibility_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/datasources/intern_cv_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/datasources/timeline_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/models/academic_year_option_model.dart';
import 'package:ptit_dms_flutter/data/models/eligibility_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_cv_upload_result_model.dart';
import 'package:ptit_dms_flutter/data/models/timeline_model.dart';
import 'package:ptit_dms_flutter/data/repositories/academic_year_repository_impl.dart';
import 'package:ptit_dms_flutter/data/repositories/eligibility_repository_impl.dart';
import 'package:ptit_dms_flutter/data/repositories/intern_cv_repository_impl.dart';
import 'package:ptit_dms_flutter/data/repositories/timeline_repository_impl.dart';
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

  List<AcademicYearOptionModel> _academicYears = const [];
  String? _selectedAcademicYearId;
  EligibilityModel? _eligibility;
  List<TimelineModel> _timelines = const [];
  InternCvUploadResultModel? _uploadedCv;

  late final Future<_HomeDependencies> _dependenciesFuture =
      _createDependencies();

  Future<_HomeDependencies> _createDependencies() async {
    final directory = await getApplicationDocumentsDirectory();

    final cookieJar = PersistCookieJar(
      ignoreExpires: false,
      storage: FileStorage('${directory.path}/.cookies/'),
    );

    final dio = createDioClient(cookieJar);

    final academicYearRepository = AcademicYearRepositoryImpl(
      AcademicYearRemoteDataSource(dio),
    );

    final eligibilityRepository = EligibilityRepositoryImpl(
      EligibilityRemoteDataSource(dio),
    );

    final timelineRepository = TimelineRepositoryImpl(
      TimelineRemoteDataSource(dio),
    );

    final internCvRepository = InternCvRepositoryImpl(
      InternCvRemoteDataSource(dio),
    );

    return _HomeDependencies(
      academicYearRepository: academicYearRepository,
      eligibilityRepository: eligibilityRepository,
      timelineRepository: timelineRepository,
      internCvRepository: internCvRepository,
    );
  }

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
      final dependencies = await _dependenciesFuture;
      final academicYears =
          await dependencies.academicYearRepository.getInternAcademicYears();

      if (!mounted) return;

      setState(() {
        _academicYears = academicYears;
        _selectedAcademicYearId =
            academicYears.isNotEmpty ? academicYears.first.id : null;
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
        _error = 'Hay goi API academic years va chon 1 nam hoc truoc';
      });
      return;
    }

    setState(() {
      _isLoadingEligibility = true;
      _error = null;
      _eligibility = null;
    });

    try {
      final dependencies = await _dependenciesFuture;
      final eligibility = await dependencies.eligibilityRepository
          .getRegistrationEligibility(
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
        _error = 'Hay goi API academic years va chon 1 nam hoc truoc';
      });
      return;
    }

    setState(() {
      _isLoadingTimelines = true;
      _error = null;
      _timelines = const [];
    });

    try {
      final dependencies = await _dependenciesFuture;
      final timelines = await dependencies.timelineRepository.getInternTimelines(
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
        _error = 'Hay goi API academic years va chon 1 nam hoc truoc';
      });
      return;
    }

    if (filePath.isEmpty) {
      setState(() {
        _error = 'Hay nhap duong dan file CV truoc';
      });
      return;
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      setState(() {
        _error = 'Khong tim thay file: $filePath';
      });
      return;
    }

    setState(() {
      _isUploadingCv = true;
      _error = null;
      _uploadedCv = null;
    });

    try {
      final dependencies = await _dependenciesFuture;
      final uploadedCv = await dependencies.internCvRepository.uploadCv(
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

  Widget _buildAcademicYearCard(AcademicYearOptionModel item) {
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

  Widget _buildTimelineCard(TimelineModel timeline) {
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
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('So luong nam hoc: ${_academicYears.length}'),
            Text('So luong timelines: ${_timelines.length}'),
            Text(
              'academicYearId dang chon: ${_selectedAcademicYearId ?? '(chua chon)'}',
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
          child: Text('Chua goi eligibility hoac chua co du lieu'),
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
          child: Text('Chua upload CV'),
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
    final isLoading = _isLoadingYears ||
        _isLoadingEligibility ||
        _isLoadingTimelines ||
        _isUploadingCv;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Intern APIs'),
        actions: [
          IconButton(
            tooltip: 'Dang xuat',
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
                    child: const Text('Goi API academic years'),
                  ),
                  ElevatedButton(
                    onPressed:
                        _isLoadingEligibility ? null : _loadEligibility,
                    child: const Text('Goi API eligibility'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoadingTimelines ? null : _loadTimelines,
                    child: const Text('Goi API timelines'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cvFilePathController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Duong dan file CV',
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
                Text(
                  'Loi: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
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
                      const Text('Chua co academic years')
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
                      const Text('Chua co timelines')
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

class _HomeDependencies {
  const _HomeDependencies({
    required this.academicYearRepository,
    required this.eligibilityRepository,
    required this.timelineRepository,
    required this.internCvRepository,
  });

  final AcademicYearRepository academicYearRepository;
  final EligibilityRepository eligibilityRepository;
  final TimelineRepository timelineRepository;
  final InternCvRepository internCvRepository;
}
