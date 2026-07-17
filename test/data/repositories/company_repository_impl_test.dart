import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/company_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/repositories/company_repository_impl.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';

// CompanyRemoteDataSource is a concrete class – wrap it in a fake Dio to
// avoid platform dependencies, or simply subclass for mocking.
class _FakeCompanyDataSource extends Fake implements CompanyRemoteDataSource {
  _FakeCompanyDataSource(this._impl);
  final _GetCompaniesCallback _impl;

  @override
  Future<List<Company>> getCompanies({
    required String academicYearCode,
    String search = '',
  }) =>
      _impl(academicYearCode: academicYearCode, search: search);
}

typedef _GetCompaniesCallback =
    Future<List<Company>> Function({
      required String academicYearCode,
      String search,
    });

DioException _dioError(DioExceptionType type, {int? statusCode, dynamic data}) {
  final response =
      statusCode != null
          ? Response(
            requestOptions: RequestOptions(),
            statusCode: statusCode,
            data: data,
          )
          : null;
  return DioException(
    requestOptions: RequestOptions(),
    type: type,
    response: response,
  );
}

const _tCompany = Company(
  id: 'abc123',
  companyId: 'C001',
  companyName: 'PTIT Corp',
);

const tCode = '2024-2025';

void main() {
  const mapper = DioExceptionMapper();

  CompanyRepositoryImpl _makeRepo(_GetCompaniesCallback cb) {
    return CompanyRepositoryImpl(_FakeCompanyDataSource(cb), mapper);
  }

  group('CompanyRepositoryImpl.getCompanies –', () {
    test('returns companies on success', () async {
      final repo = _makeRepo(
        ({required academicYearCode, search = ''}) async => [_tCompany],
      );

      final result = await repo.getCompanies(academicYearCode: tCode);

      expect(result, [_tCompany]);
    });

    test('DioException (connectionTimeout) → throws NetworkException', () {
      final repo = _makeRepo(({required academicYearCode, search = ''}) {
        throw _dioError(DioExceptionType.connectionTimeout);
      });

      expect(
        () => repo.getCompanies(academicYearCode: tCode),
        throwsA(isA<NetworkException>()),
      );
    });

    test('DioException (401) → throws UnauthorizedException', () {
      final repo = _makeRepo(({required academicYearCode, search = ''}) {
        throw _dioError(DioExceptionType.badResponse, statusCode: 401);
      });

      expect(
        () => repo.getCompanies(academicYearCode: tCode),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('DioException (500) → throws ServerException with statusCode', () {
      final repo = _makeRepo(({required academicYearCode, search = ''}) {
        throw _dioError(DioExceptionType.badResponse, statusCode: 500);
      });

      expect(
        () => repo.getCompanies(academicYearCode: tCode),
        throwsA(
          isA<ServerException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('FormatException → throws UnexpectedException', () {
      final repo = _makeRepo(({required academicYearCode, search = ''}) {
        throw const FormatException('bad json');
      });

      expect(
        () => repo.getCompanies(academicYearCode: tCode),
        throwsA(isA<UnexpectedException>()),
      );
    });

    test('passes search param to data source', () async {
      String? capturedSearch;
      final repo = _makeRepo(({required academicYearCode, search = ''}) async {
        capturedSearch = search;
        return [];
      });

      await repo.getCompanies(academicYearCode: tCode, search: 'PTIT');

      expect(capturedSearch, 'PTIT');
    });
  });
}