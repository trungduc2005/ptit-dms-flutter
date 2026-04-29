import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = await AppDependencies.create();

  runApp(
    App(
      authRepository: dependencies.authRepository,
      studentProfileRepository: dependencies.studentProfileRepository,
      academicYearRepository: dependencies.academicYearRepository,
      eligibilityRepository: dependencies.eligibilityRepository,
      timelineRepository: dependencies.timelineRepository,
      companyRepository: dependencies.companyRepository,
      internCvRepository: dependencies.internCvRepository,
      internRegistrationRepository: dependencies.internRegistrationRepository,
      studentSearchRepository: dependencies.studentSearchRepository,
    ),
  );
}
