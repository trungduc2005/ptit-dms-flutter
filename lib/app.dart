import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/router/router.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/domain/repositories/auth_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';

class App extends StatelessWidget {
  const App({
    required this.authRepository,
    required this.studentProfileRepository,
    super.key,
  });

  final AuthRepository authRepository;
  final StudentProfileRepository studentProfileRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<StudentProfileRepository>.value(
          value: studentProfileRepository,
        ),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(context.read<AuthRepository>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: '/',
        ),
      ),
    );
  }
}
