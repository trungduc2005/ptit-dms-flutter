import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_accepted_company_proof.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_request.dart';

void main() {
  group('InternRegistrationAcceptedCompanyProof', () {
    test('parses backend proof response and serializes request payload', () {
      final proof = InternRegistrationAcceptedCompanyProof.fromJson({
        'proofType': 'email-confirmation',
        'contactName': 'Nguyen Van A',
        'contactPhone': '0987654321',
        'contactPosition': 'HR Manager',
        'evidenceFile': {
          'fileName': 'evidence.pdf',
          'fileKey': 'internships/2026/B21/evidence/evidence.pdf',
          'fileType': 'pdf',
          'uploadedAt': '2026-05-01T08:00:00.000Z',
        },
      });

      expect(proof.proofType, 'email-confirmation');
      expect(proof.contactName, 'Nguyen Van A');
      expect(proof.contactPhone, '0987654321');
      expect(proof.contactPosition, 'HR Manager');
      expect(proof.evidenceFile.fileName, 'evidence.pdf');
      expect(
        proof.evidenceFile.fileKey,
        'internships/2026/B21/evidence/evidence.pdf',
      );
      expect(proof.evidenceFile.fileType, 'pdf');

      expect(proof.toJson(), {
        'proofType': 'email-confirmation',
        'contactName': 'Nguyen Van A',
        'contactPhone': '0987654321',
        'contactPosition': 'HR Manager',
        'evidenceFile': {
          'fileName': 'evidence.pdf',
          'fileKey': 'internships/2026/B21/evidence/evidence.pdf',
          'fileType': 'pdf',
          'uploadedAt': '2026-05-01T08:00:00.000Z',
        },
      });
    });

    test(
      'upload result converts backend flat fields to evidence file payload',
      () {
        final result = InternRegistrationEvidenceUploadResult.fromJson({
          'evidenceFileName': 'B21DCCN001-Nguyen-Van-A-Evid.pdf',
          'evidenceFileKey': 'internships/2026/B21DCCN001/evidence/file',
          'evidenceFileType': 'pdf',
        });

        expect(result.evidenceFileName, 'B21DCCN001-Nguyen-Van-A-Evid.pdf');
        expect(
          result.evidenceFileKey,
          'internships/2026/B21DCCN001/evidence/file',
        );
        expect(result.evidenceFileType, 'pdf');
        expect(result.evidenceFile.toJson(), {
          'fileName': 'B21DCCN001-Nguyen-Van-A-Evid.pdf',
          'fileKey': 'internships/2026/B21DCCN001/evidence/file',
          'fileType': 'pdf',
          'uploadedAt': null,
        });
      },
    );
  });

  group('intern registration accepted company proof mapping', () {
    test(
      'register wish request includes acceptedCompanyProof when provided',
      () {
        const request = RegisterWishInternRequest(
          academicYearId: 'ay-1',
          cpa: 3.4,
          cvFileKey: 'cv-key',
          cvFileName: 'cv.pdf',
          preferredCompanies: ['DN001', 'DN002'],
          acceptedCompanyProof: InternRegistrationAcceptedCompanyProof(
            proofType: 'email-confirmation',
            contactName: 'Nguyen Van A',
            contactPhone: '0987654321',
            contactPosition: 'HR Manager',
            evidenceFile: InternRegistrationEvidenceFile(
              fileName: 'evidence.pdf',
              fileKey: 'evidence-key',
              fileType: 'pdf',
            ),
          ),
        );

        expect(request.toJson()['acceptedCompanyProof'], {
          'proofType': 'email-confirmation',
          'contactName': 'Nguyen Van A',
          'contactPhone': '0987654321',
          'contactPosition': 'HR Manager',
          'evidenceFile': {
            'fileName': 'evidence.pdf',
            'fileKey': 'evidence-key',
            'fileType': 'pdf',
            'uploadedAt': null,
          },
        });
      },
    );

    test('registration response maps acceptedCompanyProof', () {
      final registration = InternRegistration.fromJson({
        '_id': 'reg-1',
        'internId': 'intern-1',
        'studentId': 'B21DCCN001',
        'type': 'registerWish',
        'preferredCompanies': const [],
        'rejectReasons': const [],
        'acceptedCompanyProof': {
          'proofType': 'email-confirmation',
          'contactName': 'Nguyen Van A',
          'contactPhone': '0987654321',
          'contactPosition': 'HR Manager',
          'evidenceFile': {
            'fileName': 'evidence.pdf',
            'fileKey': 'evidence-key',
            'fileType': 'pdf',
          },
        },
      });

      expect(
        registration.acceptedCompanyProof?.proofType,
        'email-confirmation',
      );
      expect(
        registration.acceptedCompanyProof?.evidenceFile.fileKey,
        'evidence-key',
      );
    });
  });
}
