import 'package:ptit_dms_flutter/data/datasources/project_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._remoteDataSource);

  final ProjectRemoteDataSource _remoteDataSource;

  @override
  Future<Project?> checkProject({required String academicYearId}) {
    return _remoteDataSource.checkProject(academicYearId: academicYearId);
  }

  @override
  Future<Project> registerProject({
    required ProjectRegistrationRequest request,
  }) {
    return _remoteDataSource.registerProject(request: request);
  }

  @override
  Future<Project> updateProject({
    required ProjectRegistrationRequest request,
  }) {
    return _remoteDataSource.updateProject(request: request);
  }

  @override
  Future<void> approveProjectMembership({
    required String projectId,
    required String studentRef,
  }) {
    return _remoteDataSource.approveProjectMembership(
      projectId: projectId,
      studentRef: studentRef,
    );
  }

  @override
  Future<void> rejectProjectMembership({
    required String projectId,
    required String studentRef,
    String? reason,
  }) {
    return _remoteDataSource.rejectProjectMembership(
      projectId: projectId,
      studentRef: studentRef,
      reason: reason,
    );
  }
}